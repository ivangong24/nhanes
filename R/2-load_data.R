#------------------------------------------------------------------------------#
#---------------------------Created by Yufan Gong------------------------------#
#------------------------------Date:03/24/2021---------------------------------#
#-------------------------------To load datasets-------------------------------#
#------------------------------------------------------------------------------#


#-------------------------------1. Loading data---------------------------------

{
  nhanes_year1<-as.character(seq(1999,2013, by=2))
  nhanes_year2<-as.character(seq(2000,2014, by=2))
  nhanes_directory <- here("data", "raw", glue("NHANES_{nhanes_year1}_{nhanes_year2}_MORT_2015_PUBLIC.dat"))
  nhanes_filenames <- glue("nhanes_{nhanes_year1}to{nhanes_year2}_mort")
  
  nhaneslist<-nhanes_directory %>%
    set_names(nhanes_filenames) %>%
    map(read_nhanes) %>%
    map(clean_nhanes)
  list2env(nhaneslist, envir = .GlobalEnv)
} #read in 1999-2014 NHANES mortality data

nhanes_iii_mort <- read_nhanes(here("data","raw","NHANES_III_MORT_2015_PUBLIC.dat")) %>%
  clean_nhanes() #read in NHANES III data


#--------------------------------NHANES with lodown-----------------------------
{
  nhanes_cat <- get_catalog( "nhanes", output_dir = here( "data", "raw" , "NHANES" ))

  var_data_name <- quote_all(`(?i)demo`,chol,thyroid,`blood count`,Immunization,
                            pressure,CRP,hemoglobin,Biochemistry,glucose)

  var_file_name <- quote_all(`(?i)paq`,bmx,alq,diq,mcq,dbq,ecq,smq,whq,DRXTOT,DRXIFF,DR1,DR2)

  nhanes99to14 <- nhanes_cat %>%
    filter(years %in% glue("{nhanes_year1}-{nhanes_year2}") &
             (
               str_detect(data_name, paste(var_data_name, collapse = "|(?i)")) |
                 str_detect(file_name, paste(var_file_name, collapse = "|(?i)"))
             )
           )
  
  nhanes_link <- nhanes99to14 %>% 
    select(full_url,output_filename) %>% 
    mutate_all(~str_replace(.x,"rds","XPT"))
  
  # Map(function(u, d) download.file(u, d, mode="wb"), nhanes_link$full_url, nhanes_link$output_filename)
  # nhanes99to14 <- lodown( "nhanes" , nhanes99to14) ##this line doesn't work...

  } # download the data to your local computer


{

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
  nhanes99to14_list <- list.dirs(here("data","raw", "NHANES"), recursive = FALSE) %>% ## get all subdirs 
    map(sdir_merge)
  
  nhanes99to14_list %>%
    set_names(nhanes_datanames) %>%
    list2env(.,envir = .GlobalEnv)

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
  
  pa_ind_list<-pa_ind %>%
    set_names(pa_names) %>%
    map(read_xpt) %>%
    map(clean_paqinf)
  list2env(pa_ind_list, envir = .GlobalEnv)

} # read in Physical activity--Individual data


