
# ==== DATA UNIDEMO Quality Report ====
# #### ~~~~~~~~~~~~~~~~~~~~~~~~~~~ ####


# ~~~ DataInfo ~~~ ####
DataInfo = openxlsx::createWorkbook()
# ... add TOC sheet ####
.name="CONTENTS"
DataInfo %T>%
  openxlsx::addWorksheet(.name) %>%
  openxlsx::writeData(.name,
                      x="")
# ... TOC.txt ####
.file.TOC="./T E M P/DataInfo TOC.txt"
cat("             File contents             ",
    "---------------------------------------\n",
    sep="\n",
    file=.file.TOC)
# ... Add DataInfo (details & clarifications) to DataInfo & Contents ####
.name="DataInfo"
DataInfo %T>%
  openxlsx::addWorksheet(.name) %>%
  openxlsx::writeData(.name,
                      x=readLines("./outils/UNIDEMO DataInfo.txt"))
cat(append=TRUE,
    paste0(.name," : ",
           "Data Info & Clarifications"),
    sep="\n",
    file=.file.TOC)


# ~~~ DATA ~~~ ####

# ... sources ####
# Copy Windows path to use in R : (1) copy path (2) run readClipboard() (3) paste
source.folder.2018="\\\\net1.cec.eu.int\\ESTAT\\F\\2\\6 Demo_Census\\Demography\\11_UNIfied DEMOgraphic data collection\\Ref year 2018\\03 Processing data"
source.folder.2019="\\\\net1.cec.eu.int\\ESTAT\\F\\2\\6 Demo_Census\\Demography\\11_UNIfied DEMOgraphic data collection\\Ref year 2019\\09 WGPS_10_2021_QR"
# ! ONLY ONE source folder per Reference Year !

# ... folder to copy input datafiles ####
work.folder="./data/TEMP"
# fs::dir_create(work.folder)

# ... aux fun ####
f.files.UNIDEMO.QR = function (.source.folder) {
  
  # Reference Year ####
  # https://stackoverflow.com/questions/48601627/extract-portion-of-string-startswith-4-digit-number-and-ends-with-period
  Ref.Y = stringr::str_extract(.source.folder,
                               "Ref year 20\\d{2}") %>%
    stringr::str_remove("Ref year ") %>%
    as.numeric()
  
  # get list of files in .source.folder (most recent by country, year, questionnaire) ####
  .file.list_ = list.files(.source.folder,
                           recursive=TRUE,
                           include.dirs=TRUE,
                           full.names=TRUE) %>%
    .[stringr::str_which(.,"[~$]",
                         negate=TRUE)] %>%
    .[stringr::str_which(tolower(.),"[.]xls")] %>%
    .[which(stringr::str_detect(.,"UNIDEMO|DEMOMIGR"))] %>%
    tibble::as.tibble() %>%
    rename(path=1) %>%
    mutate(filename=gsub("^.*/","",path),
           # https://stackoverflow.com/questions/42943533/r-get-last-element-from-str-split
           date.modified=file.mtime(path),
           YEAR=Ref.Y,
           Questionnaire=as.numeric(stringr::str_extract(filename,
                                                         "862|1260")),
           COUNTRY=stringr::str_remove_all(filename,
                                           "_DEMOMIGR|_ESTAT") %>%
             stringr::str_extract(paste(paste("_",
                                              COUNTRY.LIST$COUNTRY,
                                              #"_",
                                              sep=""),
                                        collapse="|")) %>%
             stringr::str_remove_all("_")) %>%
    dplyr::filter(!is.na(Questionnaire),
                  !is.na(COUNTRY)) %>%
    dplyr::group_by(COUNTRY,
                    Questionnaire) %>%
    dplyr::slice(which.max(date.modified))
  
  
  # * Add folders and files to DataInfo & Contents ####
  .name=paste0("Source datafiles - ",
               Ref.Y)
  # ... folders to DataInfo ####
  DataInfo %T>%
    openxlsx::addWorksheet(.name) %>%
    openxlsx::writeData(sheet=.name,
                        x=gsub("/","\\",
                               c("SOURCE folder :\n",
                                 .source.folder),
                               fixed=TRUE))
  # ... files to DataInfo ####
  DataInfo %>%
    openxlsx::writeDataTable(sheet=.name,
                             x=.file.list_,
                             tableName=gsub(" ",".",
                                            gsub(" - ",".",.name)),
                             startRow=4)
  # ... Contents ####
  cat(append=TRUE,
      paste0(.name," : ",
             "Original input datafiles, with source folders (reference year ",
             Ref.Y,")"),
      sep="\n",
      file=.file.TOC)
  
  # output ####
  return(.file.list_)
}
# ... file list ####
files.UNIDEMO.QR = dplyr::bind_rows(
  purrr::map(lapply(ls(pattern="source.folder.20"),
                    get) %>%
               unlist(),
             f.files.UNIDEMO.QR)) %>%
  dplyr::mutate(.copy=nchar(path)<260)



# * Copy files in work folder ####
if (copy.datafiles) {
  # ... delete old files ####
  file.remove(Sys.glob(paste0(work.folder,"/*.*")))
  # ... copy ####
  file.copy(subset(files.UNIDEMO.QR,
                   .copy,
                   select=path) %>%
              tibble::deframe(),
            to=work.folder,
            overwrite=TRUE,
            recursive=TRUE)
}


# DATA : MAIN ~~~ ####

# * AUX FUN ####

f.data.UNIDEMO.QR = function (.filename) {
  
  # aux fun ####
  f.data.composite_tables = function (.datafile) {
    
    f.tab.composite = function (..datafile=.datafile,
                                .n) {
      # composite tables ####
      .composite.tables = UNIDEMO.composite.tables %>%
        dplyr::mutate(xxx=purrr::map2(tab.1,tab.2,c)) %>%
        pull()
      # vars to combine ####
      .var1=.composite.tables[[.n]][1]
      .var2=.composite.tables[[.n]][2]
      # data ####
      {if (.var1 %in% names(..datafile) &
           .var2 %in% names(..datafile))
        ..datafile %>%
          dplyr::mutate(!!paste0(.var1,"/",.var2) :=
                          as.numeric(.data[[.var1]]+
                                       .data[[.var2]]>0))
        else ..datafile
      }
    }
    
    purrr::map(c(2,3),
               function(.info) {
                 .datafile %>%
                   dplyr::select(c(1,.info)) %>%
                   tidyr::pivot_wider(names_from=1,
                                      values_from=2) %>%
                   purrr::reduce(seq(nrow(UNIDEMO.composite.tables)),
                                 ~ .x %>%
                                   f.tab.composite(.y),
                                 .init=.) %>%
                   tidyr::pivot_longer(cols=dplyr::everything(),
                                       names_to="Table",
                                       values_to=names(.datafile)[.info])
               }) %>%
      purrr::reduce(dplyr::left_join,
                    by="Table")
  }
  
  # progress info ####
  
  .path = paste0(work.folder,"/",.filename)

  .country = stringr::str_remove_all(.filename,
                                     "_DEMOMIGR|_ESTAT") %>%
    stringr::str_extract(paste(paste("_",
                                     COUNTRY.LIST$COUNTRY,
                                     sep=""),
                               collapse="|")) %>%
    stringr::str_remove_all("_")
  
  .questionnaire = stringr::str_extract(.filename,
                                        "862|1260")
  
  .year = readxl::read_excel(.path,
                             range=dplyr::case_when(
                               .questionnaire=="1260" ~ "Summary!B15",
                               .questionnaire=="862" ~ "codes_menu!F1"),
                             col_names=FALSE) %>%
    dplyr::pull()
  
  # ... message ####
  cat(paste0("data.UNIDEMO.QR ",
             .year,".",
             .questionnaire," : ",
             "#",stringr::str_which(list.files(work.folder),
                                    .filename),
             " ",
             .country,
             " [",length(list.files(work.folder)),"] ",
             format(Sys.time(), "%H:%M:%S")),
      sep="\n")
  
  # read data in range
  .data = readxl::read_excel(
    .path,
    sheet="Summary",
    range=dplyr::case_when(.questionnaire=="1260" ~
                             "A110:C152",
                           .questionnaire=="862" ~
                             "A66:C88"))
  if(nrow(.data)>0) {
    .data %>%
      dplyr::mutate(dplyr::across(
        .cols=2:3,
        .fns=~dplyr::recode(.x,
                            Yes=1,
                            No=0,
                            `-`=0))) %>%
      {if (.questionnaire=="862")
        f.data.composite_tables(.)
        else .} %>%
      dplyr::mutate(COUNTRY=
                      readxl::read_excel(
                        .path,
                        range=dplyr::case_when(
                          .questionnaire=="1260" ~ "Summary!B17:B17",
                          .questionnaire=="862" ~ "codes_menu!B1"),
                        col_names=FALSE) %>%
                      dplyr::pull() %>%
                      as.character(),
                    COUNTRY=ifelse(nchar(COUNTRY)<2,
                                   .country,
                                   COUNTRY),
                    country_=.country,
                    YEAR=.year,
                    questionnaire_=.questionnaire) %>%
      dplyr::left_join(UNIDEMO.tables %>%
                         select(Table,
                                Questionnaire)) %>%
      dplyr::select(Questionnaire,
                    COUNTRY,
                    YEAR,
                    Table,
                    `Data present`,
                    `Individual country data`,
                    questionnaire_,
                    country_)
  }
}

# ... data ####
data.UNIDEMO.QR = dplyr::bind_rows(
  purrr::map(.x=list.files(work.folder),
               .f=f.data.UNIDEMO.QR)) %>%
  dplyr::right_join(tidyr::expand_grid(COUNTRY=COUNTRY.LIST$COUNTRY,
                                       YEAR=unique(files.UNIDEMO.QR$YEAR),
                                       Table=UNIDEMO.tables$Table)) %>%
  dplyr::mutate(dplyr::across(.cols=c(`Data present`,
                                      `Individual country data`),
                              .fns=~tidyr::replace_na(.x,0))) %>%
  dplyr::left_join(UNIDEMO.tables %>%
                     dplyr::select(Table,
                                   Table.group,
                                   MANDATORY)) %>%
  dplyr::left_join(COUNTRY.LIST) %>%
  # correct info on regional data (see ./outils/UNIDEMO DataInfo.txt)
  dplyr::mutate(`Data present`=ifelse(EU+EFTA+candidate==0 &
                                        Table %in%
                                        with(UNIDEMO.tables,
                                             Table[which(
                                               stringr::str_detect(
                                                 Description,"NUTS"))]),
                                      0,
                                      `Data present`))

# * Add datafile to DataInfo & Contents ####
.name="DATA"
DataInfo %T>%
  openxlsx::addWorksheet(.name) %>%
  openxlsx::writeDataTable(sheet=.name,
                           x=data.UNIDEMO.QR %>%
                             dplyr::select(-c(tidyselect::starts_with("Table."),
                                              tidyselect::ends_with("_"),
                                              names(COUNTRY.LIST)[-c(1,7)])) %>%
                             dplyr::left_join(UNIDEMO.tables %>%
                                                dplyr::select(Table,
                                                              Description)),
                           tableName=gsub(" ",".",.name))
cat(append=TRUE,
    paste0(.name," : ",
           "Main data (info delivered), collected from all input datafiles"),
    sep="\n",
    file=.file.TOC)


# DATA : Delivery date / Punctuality ~~~ ####
# SOURCE :
# "\\\\net1.cec.eu.int\\ESTAT\\F\\2\\6 Demo_Census\\Demography\\11_UNIfied DEMOgraphic data collection\\Ref year 2018\\09 Working Group PS Oct 2020- Quality report\\UNIDEMO RY 2018 - Quality report/01 Unidemo Punctuality 2018 RY.xls"
# EDAMIS : https://webgate.ec.europa.eu/edamis4/reports/delivery-report
# Datasets : (search) DEMOMIGR_UNI
# From : [Ref.Y]-01-01

# ... source ####
delivery.report = Sys.glob("./data/delivery_report_*.csv") %>%
  enframe(NULL,"filename") %>%
  dplyr::mutate(extraction.date=file.mtime(filename)) %>%
  dplyr::filter(extraction.date==max(extraction.date))
source.delivery = delivery.report$filename[1]
delivery.report.extraction =
  strftime(delivery.report$extraction.date[1],
           "%e %b %Y at %H:%m")
source.punctuality="\\\\net1.cec.eu.int\\ESTAT\\F\\2\\6 Demo_Census\\Demography\\11_UNIfied DEMOgraphic data collection\\Ref year 2019\\09 WGPS_10_2021_QR\\UNIDEMO RY 2019 - Quality report\\01 Unidemo Punctuality 2019 RY.xls"

# ... data : EDAMIS ####
data.UNIDEMO.delivery = read.csv(source.delivery) %>%
  dplyr::rename(COUNTRY=2,
                YEAR=Year,
                info=Dataset,
                delivery=Delivery.date,
                delivery.deadline=Indic..deadline) %>%
  dplyr::select(COUNTRY,
                YEAR,
                info,
                Version,
                delivery,
                delivery.deadline) %>%
  dplyr::filter(YEAR==Ref.Year) %>%
  dplyr::mutate(info=sapply(stringr::str_split(info,"_"),
                            function(x) x[2]))

# correction deadline ####
correction.deadline = c(UNIESMS="2020-12-31") %>%
  tibble::enframe(name="info",
                  value="correction")

# deadline (EDAMIS : included in delivery report; different for metadata) ####
EDAMIS.deadline = data.UNIDEMO.delivery %>%
  dplyr::group_by(info,
                  delivery.deadline) %>%
  dplyr::summarize() %>%
  # ... apply correction ####
{if (adjust.deadline)
  dplyr::bind_rows(dplyr::inner_join(.,
                                     correction.deadline,
                                     by="info") %>%
                     dplyr::mutate(delivery.deadline=
                                     correction) %>%
                     dplyr::select(-correction),
                   dplyr::anti_join(.,
                                    correction.deadline,
                                    by="info"))
  else .
}

# ... data : EDAMIS ####
data.UNIDEMO.delivery = data.UNIDEMO.delivery %>%
  select(-delivery.deadline) %>%
  dplyr::bind_rows(dplyr::anti_join(tidyr::expand_grid(COUNTRY=COUNTRY.LIST$COUNTRY,
                                                       info=EDAMIS.deadline$info),
                                    .,
                                    by=c("COUNTRY",
                                         "info"))) %>%
  dplyr::left_join(COUNTRY.LIST) %>%
  dplyr::left_join(EDAMIS.deadline) %>%
  dplyr::mutate(delivery=as.Date(delivery),
                delivery.deadline=as.Date(delivery.deadline))

# ... data : punctuality ####
data.UNIDEMO.punctuality = readxl::read_xls(source.punctuality,
                                            sheet="Date",
                                            range="A1:H50") %>%
  dplyr::select(1,
                UNIDEMO1260,
                UNIDEMO862,
                Metadata) %>%
  dplyr::rename(COUNTRY=1,
                UNIESMS=4) %>%
  tidyr::pivot_longer(cols=!COUNTRY,
                      names_to="info",
                      values_to="punctuality") %>%
  dplyr::mutate(punctuality=as.Date(punctuality),
                info=stringr::str_remove(info,
                                         "DEMO"))

# * Add datafile to DataInfo & Contents ####
.name="Delivery Calendar"
DataInfo %T>%
  openxlsx::addWorksheet(.name) %>%
  openxlsx::writeData(sheet=.name,
                      x=paste0("SOURCE : EDAMIS",
                               " (Report generated on ",
                               delivery.report.extraction,")"))
DataInfo %>%
  openxlsx::writeData(sheet=.name,
                      x=paste0("Alternative source (Punctuality.xls) : ",
                               gsub("\\","/",
                                    source.punctuality,
                                    fixed=TRUE)),
                      startRow=2)
DataInfo %>%
  openxlsx::writeDataTable(sheet=.name,
                           x=EDAMIS.deadline %>%
                             dplyr::mutate(delivery.deadline=
                                             strftime(delivery.deadline,
                                                      "%e %b %Y")) %>%
                             dplyr::rename("Dataset"=info,
                                           "Deadline"=delivery.deadline),
                           tableName="Deadlines",
                           startRow=4)
DataInfo %>%
  openxlsx::writeData(sheet=.name,
                      x="EDAMIS",
                      startRow=9)
DataInfo %>%
  openxlsx::writeDataTable(sheet=.name,
                           x=data.UNIDEMO.delivery %>%
                             dplyr::mutate(missing=ifelse(is.na(delivery),
                                                          "missing","")) %>%
                             dplyr::select(c(country.group,
                                             COUNTRY,
                                             info,
                                             Version,
                                             delivery,
                                             missing)) %>%
                             dplyr::rename("Dataset"=info,
                                           "Delivery date"=delivery),
                           tableName=gsub(" ",".",.name),
                           startRow=11)
cat(append=TRUE,
    paste0(.name," : ",
           "Date of transmission of data (UNIDEMO1260 & UNIDEMO 862) and metadata (UNIESMS)"),
    sep="\n",
    file=.file.TOC)

# ... first delivery ####
data.UNIDEMO.delivery = dplyr::bind_rows(
  data.UNIDEMO.delivery %>%
    dplyr::filter(is.na(delivery)),
  data.UNIDEMO.delivery %>%
    dplyr::group_by(COUNTRY,
                    YEAR,
                    info) %>%
    dplyr::slice(which.min(delivery)))

# ... difference EDAMIS-Punctuality.xls ####
diff.EDAMIS.punctuality = data.UNIDEMO.delivery %>%
  dplyr::select(COUNTRY,
                info,
                delivery) %>%
  dplyr::left_join(data.UNIDEMO.punctuality) %>%
  dplyr::mutate(dplyr::across(.cols=c(delivery,
                                      punctuality),
                              .fns=~tidyr::replace_na(.x,
                                                      "01-01-01"))) %>%
  filter(delivery != punctuality) %>%
  dplyr::mutate(dplyr::across(.cols=c(delivery,
                                      punctuality),
                              .fns=~as.Date(ifelse(.x==as.Date("0001-01-01"),
                                           NA,.x),
                                           origin="1970-01-01")))
  
# * Add difference EDAMIS-Punctuality.xls to DataInfo ####
DataInfo %>%
  openxlsx::writeData(sheet=.name,
                      x="difference EDAMIS-Punctuality.xls",
                      startRow=9,
                      startCol=9)
DataInfo %>%
  openxlsx::writeDataTable(sheet=.name,
                           x=diff.EDAMIS.punctuality %>%
                             dplyr::mutate(diff.days=ifelse(is.na(delivery) |
                                                              is.na(punctuality),NA,
                                                            punctuality-delivery),
                                           dplyr::across(.cols=c(delivery,
                                                                 punctuality),
                                                         .fns=~ifelse(is.na(.x),
                                                                      "---",
                                                                      as.character(.x)))) %>%
                             dplyr::arrange(diff.days) %>%
                             dplyr::mutate(diff.days=ifelse(is.na(diff.days),
                                                            "---",
                                                            as.character(diff.days))) %>%
                             dplyr::rename(Dataset=info,
                                           `EDAMIS (first delivery)`=delivery,
                                           Punctuality.xls=punctuality),
                           tableName="EDAMIS-vs-Punctuality.xls",
                           startRow=11,
                           startCol=9)

# ... correction to EDAMIS data ####
correction.delivery = diff.EDAMIS.punctuality %>%
  dplyr::select(-delivery) %>%
  dplyr::rename(correction=punctuality)
  

data.UNIDEMO.delivery = data.UNIDEMO.delivery %>%
  # ... apply correction ####
  {if (adjust.delivery)
    dplyr::bind_rows(dplyr::inner_join(.,
                                       correction.delivery,
                                       by=c("COUNTRY",
                                            "info")) %>%
                       dplyr::mutate(delivery=
                                       as.Date(correction)) %>%
                       dplyr::select(-correction),
                     dplyr::anti_join(.,
                                      correction.delivery,
                                      by=c("COUNTRY",
                                           "info")))
    else .} %>%
  dplyr::mutate(delivery.timing=factor(
                  dplyr::case_when(is.na(delivery) ~
                                     "missing",
                                   !is.na(delivery) &
                                     delivery<=delivery.deadline ~
                                     "on time",
                                   !is.na(delivery) &
                                     delivery>delivery.deadline &
                                     delivery<=(delivery.deadline+
                                                  lubridate::weeks(2)) ~
                                     "within 2 weeks of the deadline",
                                   !is.na(delivery) &
                                     delivery>(delivery.deadline+
                                                 lubridate::weeks(2)) ~
                                     "at least 2 weeks after the deadline"),
                  levels=c("on time",
                           "within 2 weeks of the deadline",
                           "at least 2 weeks after the deadline",
                           "missing")),
                delivery.r=as.Date(pmin(delivery,
                                        delivery.deadline+
                                          lubridate::weeks(2))))


# ~~~ DATA ISSUES ~~~ ####
# ... file ####
.file.DataIssues="./data/UNIDEMO QR - Data Issues.txt"
if (file.exists(.file.DataIssues)) file.remove(.file.DataIssues)

# * Issues ####
# ... identify issues ####
files.UNIDEMO.QR = files.UNIDEMO.QR %>%
  dplyr::right_join(tidyr::expand_grid(COUNTRY=COUNTRY.LIST$COUNTRY,
                                       files.UNIDEMO.QR %>%
                                         dplyr::group_by(Questionnaire,
                                                         YEAR) %>%
                                         dplyr::summarize())) %>%
  dplyr::left_join(data.UNIDEMO.QR %>%
                     dplyr::group_by(COUNTRY,
                                     YEAR,
                                     Questionnaire) %>%
                     dplyr::summarize(no.data=
                                        sum(`Data present`)==0)) %>%
  dplyr::mutate(no.file=is.na(filename),
                leftover=(!is.na(filename) &
                            !filename %in%
                            list.files(work.folder)),
                no.data=dplyr::coalesce(no.data,!no.file),
                data.issue=(no.file |
                              leftover |
                              no.data))

# ... add issues to to DataInfo & Contents ####

if(sum(files.UNIDEMO.QR$data.issue)>0) {
  # Write file title
  cat("             DATA ISSUES             ",
      "-------------------------------------\n",
      sep="\n",
      file=.file.DataIssues)
  
  # Append leftovers
  if (sum(files.UNIDEMO.QR$leftover)>0) {
    cat(append=TRUE,
        " * Files not processed (path too long)",
        subset(files.UNIDEMO.QR,leftover,select=path) %>% unlist(),
        "\n",
        sep="\n",
        file=.file.DataIssues)
  }
  
  # Append duplicates - NO longer : only most recent file is selected
  
  # Append missing
  if (sum(files.UNIDEMO.QR$no.file)>0) {
    cat(append=TRUE,
        " * Missing (countries with no datafile) : ",
        files.UNIDEMO.QR %>%
          dplyr::filter(no.file) %>%
          dplyr::group_by(YEAR,
                          Questionnaire) %>%
          dplyr::summarize(xxx=glue::glue_collapse(COUNTRY,
                                                   sep=", ")) %>%
          dplyr::mutate(cell=paste(YEAR,
                                   Questionnaire,
                                   xxx,
                                   sep=" : ")) %>%
          pull(),
        "\n",
        sep="\n",
        file=.file.DataIssues)
  }
  
  # Append nodata
  if (sum(files.UNIDEMO.QR$no.data)>0) {
    cat(append=TRUE,
        " * No data (countries with datafile but no data) : ",
        files.UNIDEMO.QR %>%
          dplyr::filter(no.data) %>%
          dplyr::arrange(YEAR,
                         Questionnaire,
                         COUNTRY) %>%
          dplyr::mutate(cell=paste(YEAR,
                                   Questionnaire,
                                   COUNTRY,
                                   path,
                                   sep=" : ")) %>%
          pull(),
        "\n",
        sep="\n",
        file=.file.DataIssues)
  }
  
  # Show list of errors
  cat(readLines(.file.DataIssues),
      sep="\n")
  
  message(gsub("/","\\",
               paste0(getwd(),
                      gsub("./","/",
                           .file.DataIssues,
                           fixed=TRUE)),
               fixed=TRUE))
}

# * Add DataIssues to DataInfo & Contents ####
if (file.exists(.file.DataIssues)) {
  .name="Data issues"
  DataInfo %T>%
    openxlsx::addWorksheet(.name) %>%
    openxlsx::writeData(.name,
                        x=readLines(.file.DataIssues))
  cat(append=TRUE,
      paste0(.name," : ",
             "Files not processed (path too long)"," ; ",
             #"Duplicates (countries with multiple datafiles)"," ; ",
             "Missing (countries with no datafile)"," ; ",
             "No data (countries with datafile but no data)"),
      sep="\n",
      file=.file.TOC)
}


# [ SAVE datafiles ] #### 
save(files.UNIDEMO.QR,
     data.UNIDEMO.QR,
     data.UNIDEMO.delivery,
     delivery.report.extraction,
     EDAMIS.deadline,
     file="./data/data.UNIDEMO.QR.RData")

# [ SAVE DataInfo ] ####
file.TOC=read_file(.file.TOC) # turn into R object in order to save
save(DataInfo,
     file.TOC,
     .file.TOC,
     file="./data/DataInfo.RData")

