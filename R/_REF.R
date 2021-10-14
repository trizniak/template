
# ==== Reference Info ====
# #### ~~~~~~~~~~~~~~ ####


# ~~~ Country lists (Protocol Order) ~~~ ####
# * EU ####
EU.MS = eurostat::eu_countries %>%
  dplyr::filter(code !="UK") %>%
  dplyr::select(-label) %>%
  tibble::deframe()

# * EFTA ####
EFTA.MS = eurostat::efta_countries %>%
  dplyr::select(-label) %>%
  tibble::deframe()

# * EU Candidates ####
EU.Candidates = eurostat::eu_candidate_countries %>%
  dplyr::mutate(code=ifelse(stringr::str_detect(name,"Macedonia"),
                            "MK",
                            code),
                name=ifelse(stringr::str_detect(name,"Macedonia"),
                            "North Macedonia",
                            name),
                label=ifelse(stringr::str_detect(name,"Macedonia"),
                             "North Macedonia",
                             label)) %>%
  dplyr::select(-label) %>%
  tibble::deframe()

# * ENP (European Neighbourhood Policy) ----
# https://ec.europa.eu/eurostat/web/products-eurostat-news/-/wdn-20210504-1
# ENP-East : Armenia, Azerbaijan, Belarus, Georgia, Moldova, Ukraine
# ENP-South : Algeria, Egypt, Israel, Jordan, Lebanon, Libya, Morocco, Palestine, Syria, Tunisia

# * Expanded country list (includes EFTA, candidates, ENP, other) ----

COUNTRY.LIST = jsonlite::fromJSON(url("http://ec.europa.eu/eurostat/wdds/rest/data/v2.1/json/en/demo_gind",
                                      "rb"))$dimension$geo$category$label %>%
  unlist() %>%
  tibble::enframe() %>%
  dplyr::rename(COUNTRY=1,
                `Country Name`=2) %>%
  dplyr::filter(!stringr::str_detect(COUNTRY,"DE_TOT|FX")) %>%
  dplyr::mutate(EU=as.integer(COUNTRY %in% names(EU.MS)),
                EFTA=as.integer(`Country Name` %in% EFTA.MS),
                candidate=as.integer(COUNTRY %in% names(EU.Candidates)),
                `Country Name`=dplyr::case_when(COUNTRY=="DE" ~ EU.MS["DE"],
                                                COUNTRY=="XK" ~ "Kosovo",
                                                TRUE ~ `Country Name`),
                # Protocol order : https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Glossary:Country_codes
                PO=pmatch(COUNTRY,
                          names(c(EU.MS,EFTA.MS,EU.Candidates))),
                country.group=factor(
                  dplyr::case_when(EU==1 ~ "EU27",
                                   EFTA==1 ~ "EFTA",
                                   candidate==1 ~ "EU Candidates",
                                   TRUE ~ "Other countries"),
                  levels=c("EU27",
                           "EFTA",
                           "EU Candidates",
                           "Other countries"))) %>%
  dplyr::filter(!stringr::str_detect(`Country Name`,
                                     "Euro")) %>%
  dplyr::arrange(PO,COUNTRY) %>%
  dplyr::mutate(PO=as.numeric(tidyr::replace_na(rownames(.))))

save("EU.MS",
     "EFTA.MS",
     "EU.Candidates",
     "COUNTRY.LIST",
     file="./outils/countries.RData")


# ~~~ UNIDEMO Tables ~~~ ####
# ... tables ####
UNIDEMO.tables = readr::read_delim("./outils/UNIDEMO_tables.txt") %>%
  dplyr::mutate(Table.family=stringr::str_remove_all(Table,
                                                     "[[:digit:]]"),
                Table.family=dplyr::recode(Table.family,
                                           `E/E`="E",
                                           `I/I`="I",
                                           `A/A`="A"),
                Table.group=factor(
                  dplyr::case_when(Table.family=="P" ~
                                     "Population",
                                   Table.family %in% c("B","L") ~
                                     "Births",
                                   Table.family %in% c("D","X") ~
                                     "Deaths",
                                   Table.family %in% c("M","S") ~
                                     "Marriages &\nDivorces",
                                   Table.family %in% c("E","I","A","LC") ~
                                     "Migration &\nCitizenship"),
                  levels=c("Population",
                           "Births",
                           "Deaths",
                           "Marriages &\nDivorces",
                           "Migration &\nCitizenship")),
                MANDATORY=as.numeric(stringr::str_detect(tolower(Regulations),
                                                         "mandatory")))
UNIDEMO.Q.tables = UNIDEMO.tables %>%
  dplyr::group_by(Questionnaire,
                  Table.family) %>%
  dplyr::summarize() %>%
  dplyr::relocate(Table.family) %>%
  tibble::deframe()

# * Composite tables ####
UNIDEMO.composite.tables = utils::read.table(header=FALSE,
                                             sep=";",
                                             col.names=c("order",
                                                         "tab.1",
                                                         "tab.2"),
                                             text=
"1;I01;I06
2;I02;I07
3;I03;I08
4;I04;I09
5;I05;I10
6;E01;E05
7;E02;E06
8;E03;E07
9;E04;E08
10;A00;A01")

# [ SAVE Ref ] ####

save("UNIDEMO.tables",
     "UNIDEMO.Q.tables",
     "UNIDEMO.composite.tables",
     file="./outils/tables.RData")
