
# ==== OUTPUT for XXXXXXX ====
# #### ~~~~~~~~~~~~~~~~~~ ####

# ~~~ RUN : START ~~~ ####
run.start=Sys.time()

# ~~~ INIT ~~~ ####

# * DATA ####
# load("./data/data.XXXXXXX.RData")

# * FUNS ####
# source("./R/F.VIZ.R")

# * Sections to run ####
# Check OUTPUT.[ Sections to run ]
viz.XXXXXXX=FALSE
tab.XXXXXXX=FALSE
doc.XXXXXXX=FALSE
report.XXXXXXX=FALSE


# ~~~ OUTPUT SECTIONS ~~~ ####

# ::: XXXXXXX ::: ####
# XXXXXXX ####
# * XXXXXXX ####
# ... XXXXXXX ####


# ~~~ COLLECT ~~~ ####

# ... zip ####
.archive.output="./output/XXXXXXX.zip"
zip::zip(.archive.output,
    files=c(Sys.glob("./data/*XXXXXXX*.*"),
            Sys.glob("./output/*XXXXXXX*.htm*"),
            Sys.glob("./output/viz/*XXXXXXX*.*g"),
            Sys.glob("./output/doc/*XXXXXXX*.doc*")),
    include_directories=FALSE,
    mode="cherry-pick")

# ... message ####
message(gsub("/","\\",
             paste0(getwd(),
                    gsub("./","/",
                         .archive.output,
                         fixed=TRUE)),
             fixed=TRUE))

# ~~~ RUN : END ~~~ ####
cat(paste0("RUNTIME : ",
           lubridate::int_diff(c(run.start,
                                 Sys.time())) %>%
             lubridate::int_length() %>%
             round() %>%
             lubridate::seconds_to_period()))
