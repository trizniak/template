
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


# [ SAVE Ref ] ####

save("EU.MS",
     "EFTA.MS",
     "EU.Candidates",
     "COUNTRY.LIST",
     file="./outils/countries.RData")
