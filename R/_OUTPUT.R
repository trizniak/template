
# ==== OUTPUT for UNIDEMO Quality Report ====
# #### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ####

# * DataInfo ####
load("./data/DataInfo.RData")
# ... recreate DataInfo TOC.txt from saved R object ####
# otherwise, at every run of W.DOC.R without _DATA.R same entries are multiplied (_DATA.R initializes DataInfo TOC.txt)
cat(file.TOC,
    file=.file.TOC,
    sep="")

# * FUNS ####
source("./R/F.VIZ.R")


# [ Sections to run ] ####
viz.CountryCounts=TRUE
viz.DeliveryCalendar=FALSE
doc.Tables=FALSE


# ~~~ VIZ : Country counts ~~~ ####
# * output ----
# ... delete old output ####
file.remove(Sys.glob("./output/viz/*Country Counts*.png"))
# ... output ####
if (viz.CountryCounts) {
  pmap(expand.grid(.table_group=seq(length(unique(UNIDEMO.tables$Table.group))),
                   detailed.country=FALSE,
                   save=TRUE),
       F.viz.CountryCounts)
  F.viz.CountryCounts(save=TRUE)
}


# ~~~ VIZ : Delivery Calendar ~~~ ####
# * output ----
# ... delete old output ####
file.remove(Sys.glob("./output/viz/*Delivery Calendar*.png"))
# ... output ####
if (viz.DeliveryCalendar) {
  map(1:3,
      F.viz.DeliveryCalendar,
      .datafile=data.UNIDEMO.delivery,
      save=TRUE)
}


# ~~~ DOC : Tables ~~~ ####
# ... delete old output ####
file.remove("./output/doc/UNIDEMO QR [TAB].docx")
# ... output ####
if (doc.Tables) {
  source("./R/W.DOC.R")
}


# ~~~ COLLECT ~~~ ####

# DataInfo ####
# ... add TOC ####
DataInfo %>%
  openxlsx::writeData(sheet="CONTENTS",
                      x=readLines(.file.TOC))
# ... save to excel ####
openxlsx::saveWorkbook(DataInfo,
                       "./data/UNIDEMO QR - Data Info.xlsx",
                       overwrite=TRUE)

# * Collect output & data info ####
.archive.output="./output/UNIDEMO QR.zip"
#file.remove(.archive.output)
zip::zip(.archive.output,
    files=c(Sys.glob("./data/*UNIDEMO QR*.*"),
            Sys.glob("./output/viz/*UNIDEMO QR*.*g"),
            Sys.glob("./output/doc/*UNIDEMO QR*.doc*")),
    include_directories=FALSE,
    mode="cherry-pick")
# ... message ####
message(gsub("/","\\",
             paste0(getwd(),
                    gsub("./","/",
                         .archive.output,
                         fixed=TRUE)),
             fixed=TRUE))
