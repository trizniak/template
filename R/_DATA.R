
# ==== DATA XXXXXXX ====
# #### ~~~~~~~~~~~~ ####

# ~~~ RUN : START ~~~ ####
run.start=Sys.time()

# ~~~ XXXXXXX ~~~ ####
# ::: XXXXXXX ::: ####
# XXXXXXX ####
# * XXXXXXX ####
# ... XXXXXXX ####

# [ SAVE datafiles ] #### 
save(xxxxxxx,
     xxxxxxx,
     file="./data/data.XXXXXXX.RData")

# ~~~ RUN : END ~~~ ####
cat(paste0("RUNTIME : ",
           lubridate::int_diff(c(run.start,
                                 Sys.time())) %>%
             lubridate::int_length() %>%
             round() %>%
             lubridate::seconds_to_period()))
