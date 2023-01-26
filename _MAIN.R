
# ==== [PROJECT NAME] XXXXXXXXXXXXXXXXXXXXXX ====
# #### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ####

# ~~~ PARAMS ~~~ ####

# ::: Sections to run ::: ####
run.output=FALSE # check below OUTPUT.[ Sections to run ] - included as parameters in ./R/_OUTPUT.R
  # OUTPUT.xxx=FALSE

# ::: FOLDERS & FILENAMES ::: ####

# ::: UPDATES ::: ####
update.reference.info=FALSE
update.data=FALSE
  copy.datafiles=FALSE # copy input datafiles to work folder ; relevant only if update.data=TRUE


# -------------------------------------------------------------------------------
# |                        DO NOT edit beyond this point                        |
# -------------------------------------------------------------------------------

# ~~~ RUN : START ~~~ ####
run.start=Sys.time()

# ~~~ INIT ~~~ ####
.connect2internet("OrizaT");.connect2internet("OrizaT") # ¯\_(ツ)_/¯

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

# [ SECTION START ] ####
section.start=Sys.time()

if (run.output) {
  source("./R/_OUTPUT.R")  # check above OUTPUT.[ Sections to run ]
}

# [ SECTION END ] ####
f.timing(.message="XXXXXX")

# ~~~ RUN : END ~~~ ####
f.timing(.start=run.start,
         .message="RUNTIME : ",
         .sep.rows=2)
