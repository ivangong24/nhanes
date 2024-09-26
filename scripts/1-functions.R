## ---------------------------
##
## Script name: 1-functions.R
##
## Purpose of script: This script contains all the functions that will be used in the project.
##
## Author: Yufan Gong
##
## Date Created: 2021-03-24
##
## Date Modified: 2024-09-25
##
## Copyright (c) Yufan Gong, 2024
## Email: ivangong@ucla.edu
##
## ---------------------------
##
## Notes:
##   
##
## ---------------------------

#------------------------------Check the directory------------------------------
getwd()

#------------------------------Loading packages---------------------------------
if (!require("pacman", quietly = TRUE))
  install.packages("pacman")

pacman::p_load(
  #For creating tables
  "kableExtra", # create amazing tables: kbl()
  "skimr",      # summary statistics:
  "arsenal",    # create tables: tableby()
  "expss",      # create contingency tables: calc_cro_cpct()  
  "gtsummary",  # create amazing tables: tbl_summary()

  #For loading data
  "readr",      # read in csv data: read_csv()
  "haven",      # read in sas data: read_sas()
  "here",       # setting the directory in the project: here()

  #For manipulating data
  "rlang",      # for Non-standard evaluation: eval(), expr(), ensym(), caller_env(), exec(), !!
  "magrittr",   # for the pipe operator: %>% and %<>%
  "broom",      # for tidying up the results of a regression: tidy()
  "lubridate",  # for manipulating dates: intervals(), durations()
  "labelled",   # labelleling the data: set_variable_labels(), set_value_labels()

  # Enhancing plots
  "scales",      #makes easy to format percent, dollars, comas: percent()
  "ggalt",       #makes easy splines: geom_xsplines()
  "ggeasy",      #applies labels among other things: easy_labs()
  "gridExtra",   #combining plots and tables on plots: grid.arrange(), tableGrob()
  "ggpubr",      #combines plots: ggarrange()
  "Amelia",      #check missing pattern: missmap()

  # Other great packages
  "glue",        # replaces paste: glue()
  "Hmisc",       # explore the data: describe()
  "mice",        # impute missing data: mice()
  "gmodels",     # create contigency table: CrossTable()
  "RNHANES",     # download NHANES data: nhanes_load_data()
  "srvyr",       # deal with survey data: as_survey_design(), survey_mean()
  "survey",      # work with survey data: svydesign(), svycoxph()
  "survival",    # used for survival analysis
  "codebook",    # set variable labels with codebook: dict_to_list()
  "nhanesA",     # get information of NHANES: nhanesTables(), nhanesTableVars()
  "rvest",       # scrape data from the web: read_html(), html_nodes(), html_attr()
  "furrr",       # parallel processing: future_map(), plan()

  #For data manipulation
  "tidyverse"   # data manipulation and visualization:select(), mutate()
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
  paste(purrr::map(args, as_string),sep = "")
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

get_nhanes_links <- function() {
  # Read the web page HTML content
  webpage <- read_html("https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx")
  
  # Use rvest to extract all hyperlinks (anchor tags with href attributes)
  links <- webpage %>%
    html_nodes("a") %>%
    html_attr("href")
  
  # Filter only links that end with .XPT (NHANES data files)
  xpt_links <- links[grepl("\\.XPT$", links, ignore.case = TRUE)]
  
  # Convert relative URLs to absolute URLs if necessary
  xpt_links <- ifelse(grepl("^https", xpt_links), xpt_links, 
                      paste0("https://wwwn.cdc.gov", xpt_links)) %>% 
    str_replace(., "xpt", "XPT")
  
  # extract cycle years from the links
  cycle_years <- gsub(".*/(\\d{4}-\\d{4}).*", "\\1", xpt_links)
  
  # extract filenames from the links
  file_names <- gsub(".*\\/([^\\/]+\\.XPT)$", "\\1", xpt_links)
  
  file_name_noxpt <- str_remove(file_names, ".XPT")
  
  doc_links <- links[grepl("\\.htm$", links, ignore.case = TRUE)] %>%
    keep(~str_detect(., paste(file_name_noxpt, collapse = "|")))

  doc_links <- ifelse(grepl("^https", doc_links), doc_links,
                      paste0("https://wwwn.cdc.gov", doc_links))
  
  # Set up parallel processing with furrr
  plan(multisession)  # Use multiple cores (for Windows). Use `multicore` for Unix systems.
  
  # Function to extract the h3 text from a single link
  get_h3_text <- function(link) {
    tryCatch({
      text <- link %>%
        read_html() %>%
        html_nodes("h3") %>%
        html_text(trim = TRUE)
      
      text[2]  # Return the second h3 text
    }, error = function(e) {
      return(NA)  # Handle errors by returning NA
    })
  }
  
  # Parallelize the extraction across all doc_links
  system.time({
    dataname <- future_map(doc_links, get_h3_text)
  })
  

  data <- data.frame(
    url = unique(xpt_links),
    doc_url = unique(doc_links),
    year = cycle_years,
    data_name = unlist(dataname),
    file_name = file_names
  )
  


  
  # Extract component descriptions by scraping the text from the <a> tags near the DOC links
  # component_descriptions <- doc_links %>%
  #   map(function(link){
  #     link %>% 
  #       read_html() %>% 
  #       html_nodes(xpath = '//*[contains(text(), "Component Description")]/following-sibling::p[1]') %>%
  #       html_text(trim = TRUE)
  #   })
  
  return(data)  # Return unique links
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
