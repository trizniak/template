
# ==== XXXXXXXXXXXXXXXXXXXXXX ====
# #### ~~~~~~~~~~~~~~~~~~~~~~ ####

# ~~~ PARAMS ~~~ ####
# Ref.Year=2019 # reference year (year the report refers to)
update.reference.info=FALSE
update.data=FALSE
  copy.datafiles=FALSE # copy input datafiles to work folder ; relevant only if update.data=TRUE

# Sections to run ~~~ ####
run.output=FALSE # check _OUTPUT.R/[ Sections to run ]

# ~~~ SETUP ~~~ ####
source("./R/_SETUP.R")
source("./R/_AUX-FUN.R")

# ~~~ Reference Info ~~~ ####
# load("./outils/countries.RData")
# load("./outils/tables.RData")

# ~~~ UPDATES ~~~ ####
if (update.reference.info) source("./R/_REF.R")
if (update.data) {
  source("./R/_DATA.R")
}

# ~~~ DATA ~~~ ####
# load("./data/XXXXXXXX.RData")

# ~~~ OUTPUT ~~~ ####
if (run.output) {
  source("./R/_OUTPUT.R")  # check _OUTPUT.R/[ Sections to run ]
}
