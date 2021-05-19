#------------------------------------------------------------------------------#
#---------------------------Created by Yufan Gong------------------------------#
#------------------------------Date:03/24/2021---------------------------------#
#------------------------------To create functions-----------------------------#
#------------------------------------------------------------------------------#

#------------------------------Check the directory------------------------------
getwd()

#------------------------------Loading packages---------------------------------
pacman::p_load(
  #For creating tables
  "kableExtra", #create amazing tables: kbl()
  "skimr",      #summary statistics:
  "arsenal",    #create tables: tableby()
  "expss",      #create contingency tables: calc_cro_cpct()  
  "gtsummary",  #create amazing tables: tbl_summary()
  
  #For loading data
  "readr",      #read in csv data: read_csv()
  "haven",      #read in sas data: read_sas()
  "here",       #setting the directory in the project: here()
  
  #For manipulating data
  "rlang",      #for Non-standard evaluation: eval(), expr(), ensym(), caller_env(), exec(), !!
  "magrittr",   #for the pipe operator: %>% and %<>%
  "broom",      #for tidying up the results of a regression: tidy()
  "lubridate",  #for manipulating dates: intervals(), durations()
  "labelled",   #labelleling the data: set_variable_labels(), set_value_labels()
  
  # Enhancing plots
  "scales",      #makes easy to format percent, dollars, comas: percent()
  "ggalt",       #makes easy splines: geom_xsplines()
  "ggeasy",      #applies labels among other things: easy_labs()
  "gridExtra",   #combining plots and tables on plots: grid.arrange(), tableGrob()
  "ggpubr",      #combines plots: ggarrange()
  "Amelia",      #check missing pattern: missmap()
  
  # Other great packages
  "glue",        #replaces paste: glue()
  "Hmisc",       #explore the data: describe()
  "mise",        #clear environment space: mise()
  "gmodels",     #create contigency table: CrossTable()
  "lodown",      #downloads and imports all available survey data lodown()
  "srvyr",       #deal with survey data: as_survey_design(), survey_mean()
  "survey",      #work with survey data: svydesign(), svycoxph()
  "survival",    #used for survival analysis
  "codebook",    #set variable labels with codebook: dict_to_list()
  "nhanesA",     #get information of NHANES: nhanesTables(), nhanesTableVars()
  
  #For data manipulation
  "tidyverse"   #data manipulation and visualization:select(), mutate()
)

#---------------------------------Create functions------------------------------

read_nhanes <- function(data){
  data <- 
    read_fwf(data,
             col_types = "ciiiiiiiddii",
             fwf_cols(publicid = c(1,14),
                      eligstat = c(15,15),
                      mortstat = c(16,16),
                      ucod_leading = c(17,19),
                      diabetes = c(20,20),
                      hyperten = c(21,21),
                      dodqtr = c(22,22),
                      dodyear = c(23,26),
                      wgt_new = c(27,34),
                      sa_wgt_new = c(35,42),
                      permth_int = c(43,45),
                      permth_exm = c(46,48)
             ),
             na = "."
    )
}

clean_nhanes <- function(data){
  data %>% 
    mutate(seqn=as.numeric(substr(publicid,1,5))) %>%
    select(-c(publicid,dodqtr,dodyear,
              wgt_new,sa_wgt_new))
}


quote_all <- function(...){
  args<-rlang::ensyms(...)
  paste(purrr::map(args,as_string),sep = "")
}

clean_list <- function(data) {
  data %>%
    bind_rows() %>%
    rename(
      file_name = Data.File.Name,
      file_desc = Data.File.Description
    ) %>%
    filter(str_detect(file_name, paste(nhanes_data, collapse = "|(?i)"))) %>% 
    select(file_name) %>% 
    as_vector
}

clean_paqinf <- function(data) {
  data %>%
    rename_all(str_to_lower) %>% 
    mutate(minmon=padtimes*paddurat,
           metmon=padmets*minmon) %>%
    pivot_wider(
      id_cols = seqn,
      names_from = padlevel,
      values_from = c(minmon:metmon),
      values_fn = sum
    ) %>% 
    transmute(seqn = seqn,
              modmin = minmon_1/4.33,
              vigmin = minmon_2/4.33,
              modmet = metmon_1/4.33,
              vigmet = metmon_2/4.33) %>% 
    mutate(minwk = rowSums(cbind(modmin,vigmin),na.rm = T),
           metwk = rowSums(cbind(modmet,vigmet),na.rm = T))
}

#create a new function %notin%
`%notin%` <- Negate(`%in%`)


# Merge datasets in each directory


str_low <- function(data){
  data %>%
    rename_all(str_to_lower)
}

sdir_merge <- function(sdir) {                              ## map over all subdirs
  list.files(sdir, "\\.XPT$", full.names = TRUE) %>%        ## get all files in sdir
    map(read_xpt) %>%                                       ## read each
    map(str_low) %>% 
    reduce(full_join, by = "seqn")                          ## and merge them
}



is_max <- function(vars, value) {
  max(vars, na.rm=T) == value
}

clean <- function(data) {
  data %>%
    mutate_if(~ any(is_max(.x, value=9)), ~replace(., which(. %in% list(7,9)), NA)) %>%
    mutate_if(~ any(is_max(.x, value=99)), ~replace(., which(. %in% list(77,99)), NA)) %>%
    mutate_if(~ any(is_max(.x, value=999)), ~replace(., which(. %in% list(777,999)), NA)) %>%
    mutate_if(~ any(is_max(.x, value=9999)), ~replace(., which(. %in% list(7777,9999)), NA)) %>%
    mutate_if(~ any(is_max(.x, value=99999)), ~replace(., which(. %in% list(77777,99999)), NA)) %>% 
    mutate_if(~ any(is_max(.x, value=999999)), ~replace(., which(. %in% list(777777,999999)), NA))
}

table1 <- function(table) {
  
  table %>% 
    as_hux_table() -> hux
  
  table %>% 
    as_flex_table() -> flex
  
  return(list(hux=hux, flex=flex))
  
}

# creat codebook
# my_viewer <- function(tab){
#   # generate a temporary html file and display it
#   dir <- tempfile()
#   dir.create(dir)
#   htmlFile <- file.path(dir, "index.html")
#   
#   options(kableExtra.auto_format = FALSE)
#   library(knitr)
#   library(kableExtra)
#   
#   tab %>% 
#     kable(caption = "Codebook") %>% 
#     kable_styling(bootstrap_options = c("striped", "bordered"), 
#                   full_width = F) %>% 
#     save_kable(file = htmlFile, self_contained = T)  
#   
#   rstudioapi::viewer(htmlFile)
#   
# }
