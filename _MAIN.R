# ---- [ x x x ] ----

update=FALSE # update main data files (data.breaks, DATAFILE, data)? TRUE/FALSE
report=TRUE # generate output? TRUE/FALSE

# ---- START ----
source("./OUTILS/CONFIG/SETUP.R")
if (update) source("./OUTILS/CONFIG/UPDATES.R")

# ---- PARAMETERS ----
# param.list=list([ x x x ])
# saveRDS(param.list,file=here("OUTILS","CONFIG","param.rds"))

# ---- data.x ----
source(here("OUTILS","FUNS","DATA_X.R"))

# ---- Titles, subtitles, captions, variable names ----
source(here("OUTILS","FUNS","Fdx_TLK.R"))

# ---- data.viz ----
source(here("OUTILS","FUNS","DATA_VIZ.R"))

# ---- OUTPUT ----
if(report) rmarkdown::render(here("OUTILS","BLOX","REPORT.Rmd"),
                             output_file=paste0("COVID.html"),
                             output_dir=here("OUTPUT"),
                             intermediates_dir=here("T E M P"),
                             quiet=TRUE,
                             clean=TRUE)
