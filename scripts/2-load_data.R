## ---------------------------
##
## Script name: 2-load_data.R
## Purpose of script: This script is used to load data from NHANES database
##
## Author: Yufan Gong
##
## Date Created: 2021-03-24
##
## Date Created: 2024-09-26
##
## Copyright (c) Yufan Gong, 2024
## Email: ivangong@ucla.edu
##
## ---------------------------
##
## Notes: The following code is assuming that you are using Windows OS. 
##        Make sure you have read this post before you run the code:
##        https://rpubs.com/vermanica/SQL_finalProject_MicrosoftAccess
##        If you are using Mac OS, please check this link for accdb connection:
##        https://github.com/ethoinformatics/r-database-connections/blob/master/
##        And please make sure .accbd doesn't has a password if you are using
##        Mac OS.
##        For other database types, please refer this blog:
##        https://ryanpeek.org/2019-09-17-reading-databases-in-r/


#-------------------------------1. Loading data---------------------------------

# let's say you are interested in mortality data from 1999 to 2014
{
  nhanes_year1<-as.character(seq(1999,2013, by=2))
  nhanes_year2<-as.character(seq(2000,2014, by=2))
  nhanes_directory <- here("data", "raw", 
                           glue("NHANES_{nhanes_year1}_{nhanes_year2}_MORT_2015_PUBLIC.dat"))
  nhanes_filenames <- glue("nhanes_{nhanes_year1}to{nhanes_year2}_mort")
  
  nhaneslist<-nhanes_directory %>%
    set_names(nhanes_filenames) %>%
    map(read_nhanes) %>%
    map(clean_nhanes)
  list2env(nhaneslist, envir = .GlobalEnv)
} #read in 1999-2014 NHANES mortality data

nhanes_iii_mort <- read_nhanes(here("data","raw","NHANES_III_MORT_2015_PUBLIC.dat")) %>%
  clean_nhanes() #read in NHANES III data



# Grab data of interest and download --------------------------------------

{
  system.time({
    nhanes_files <- get_nhanes_links()
    })

  var_data_name <- quote_all(`(?i)demo`,chol,thyroid,`blood count`,Immunization,
                            pressure,CRP,hemoglobin,Biochemistry,glucose)

  var_file_name <- quote_all(`(?i)paq`,bmx,alq,diq,mcq,dbq,ecq,
                             smq,whq,DRXTOT,DRXIFF,DR1,DR2)

  nhanes99to14 <- nhanes_files %>%
    filter(year %in% glue("{nhanes_year1}-{nhanes_year2}") &
             (
               str_detect(data_name, paste(var_data_name, collapse = "|(?i)")) |
                 str_detect(file_name, paste(var_file_name, collapse = "|(?i)"))
             )
           ) %>% 
    mutate(output_filename = str_c(here("data", "raw", "NHANES"), 
                                   "/", year, "/", file_name))
  
  nhanes_link <- nhanes99to14 %>% 
    select(url, output_filename)
  
  # create download directory (must run this section first)
  
  # dir.create(here("data", "raw", "NHANES"))
  # 
  # 
  # glue("{nhanes_year1}-{nhanes_year2}") %>% 
  #   map(function(x){
  #     dir.create(here("data", "raw", "NHANES", x), showWarnings = FALSE)
  #   })
  
  
  # download the data to your local computer
  purrr::map2(nhanes_link$url, 
              nhanes_link$output_filename, 
              download.file, mode="wb")
  

  } # download the data to your local computer


{
  # Merge datasets with each subdir (cycle year): it could be slow and consume a great amount of memory
  
  #For example, 1999-2000
 { 
  # nhanes_names <- dir(here("data","raw", "NHANES","1999-2000"))
  # nhanes_directory2 <- here("data","raw", "NHANES", "1999-2000", nhanes_names)
  # 
  # nhanes_1999to2000<-nhanes_directory2 %>%
  #   set_names(nhanes_names) %>%
  #   map(read_rds) %>%
  #   reduce(full_join, by = "seqn")
 }
  
  #Method 1: Purrr like syntax for the whole dataset (More efficient)
  nhanes_datanames <- glue("nhanes_{nhanes_year1}to{nhanes_year2}")
  
  plan(multisession)
  
  system.time({
    list.dirs(
      here("data", "raw", "NHANES"), recursive = FALSE
    ) %>% ## get all subdirs 
      future_map(sdir_merge) %>%
      set_names(nhanes_datanames) %>%
      list2env(.,envir = .GlobalEnv)
  })



  #Method 2: Using for loop for the whole dataset
  # dflist <- list()
  # nhanes_datanames <- glue("nhanes_{nhanes_year1}to{nhanes_year2}")
  # year <- glue("{nhanes_year1}-{nhanes_year2}") %>% as.vector()
  # 
  # for (i in 1:8) {
  #   nhanes_names <- dir(here("data","raw", "NHANES",year[i]))
  #   nhanes_directory2 <- here("data","raw", "NHANES", year[i], nhanes_names)
  # 
  #   df <- nhanes_directory2 %>%
  #     set_names(nhanes_names) %>%
  #     map(read_rds) %>%
  #     reduce(full_join, by = "seqn")
  # 
  #   dflist[[i]] <- df
  # }
  # 
  # dflist %>%
  #   set_names(nhanes_datanames) %>%
  #   list2env(.,envir = .GlobalEnv)

} # read in NHANES data except Physical activity--Individual


{
  num <- c("a","b","c","d")
  pa_ind <- here("data", "raw", "pa_ind", glue("paqiaf_{num}.XPT"))
  pa_names <- glue("paqiaf_{num}")
  
  pa_ind_list <- pa_ind %>%
    set_names(pa_names) %>%
    map(read_xpt) %>%
    map(clean_paqinf)
  list2env(pa_ind_list, envir = .GlobalEnv)

} # read in Physical activity--Individual data


