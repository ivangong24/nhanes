#------------------------------------------------------------------------------#
#---------------------------Created by Yufan Gong------------------------------#
#------------------------------Date:04/15/2021---------------------------------#
#--------------------------------To clean data---------------------------------#
#------------------------------------------------------------------------------#

#---------------------------------1. Clean data---------------------------------

#merge datasets


#-------------------------------Merge NHANES-----------------------------------

list(nhaneslist, nhanes99to14_list, pa_ind_list) %>%
  map(bind_rows) %>%
  set_names(c("nhanes_99to14_mort","nhanes_99to14","paqiaf_99to06")) %>%
  list2env(.,envir = .GlobalEnv)

nhanes_master <- nhanes_99to14 %>% 
  rename_all(str_to_lower) %>% 
  full_join(nhanes_99to14_mort, by = "seqn")

# for (i in length(nhanes99to14_list)) {
#   nhanes_master <- sjlabelled::copy_labels(nhanes_master, nhanes99to14_list[[i]])
# }

nhanes_codebook <- nhanes99to14_list %>% 
  map(look_for) %>% 
  bind_rows() %>% 
  select(variable,label) %>% 
  distinct()

#set variable labels
var_label(nhanes_master) <- nhanes_codebook %>%
  dict_to_list()


nhanes_master %<>% 
  rename(wtsaf2yr = wtsaf2yr.x,
         wtsaf4yr = wtsaf4yr.x,
         lb2day   = lb2day.x,
         wtdr2d   = wtdr2d.x,
         drabf    = drabf.x,
         drdint   = drdint.x,
         phafsthr = phafsthr.x,
         phafstmn = phafstmn.x,
         ) %>% 
  mutate(wtdrd1   = wtdrd1.x,
         smaquex  = smaquex.x,
         smq077   = smq077.x) %>% 
  select(-c(lb2day.x.x,wtdrd1.x,smaquex.x,smq077.x, wtsaf2yr.y, wtsaf4yr.y,
            lb2day.y, lb2day.y.y,smq077.y, wtdrd1.y,wtdr2d.y, drabf.y, 
            drdint.y, phafsthr.y,phafstmn.y,smaquex.y))

nhanes_codebook_final <- nhanes_codebook %>% 
  mutate_all(~replace(.,which(. %in% list("wtsaf2yr.x","wtsaf4yr.x","lb2day.x",
                                          "wtdr2d.x", "drabf.x", "drdint.x", "phafsthr.x",
                                          "phafstmn.x","lb2day.x.x","wtdrd1.x","smaquex.x","smq077.x", "wtsaf2yr.y", "wtsaf4yr.y",
                                          "lb2day.y", "lb2day.y.y","smq077.y", "wtdrd1.y","wtdr2d.y", "drabf.y", 
                                          "drdint.y", "phafsthr.y","phafstmn.y","smaquex.y")), NA)) %>% 
  na.omit()
#write_csv(nhanes_codebook, here("data","processed","nhanes_codebook_final.csv"))
#-----------------------------Create codebook for NHANES------------------------

#https://cran.r-project.org/web/packages/nhanesA/vignettes/Introducing_nhanesA.html

#-----------------nhanesA demo
# nhanesTables("LAB", 2001)
# nhanesTableVars("LAB", "l13_b")
# nhanesTranslate("L34_B","LBXBV")

#------------------------------

{
  nhanes_data <- nhanes99to14 %>%
    select(doc_name) %>%
    as_vector() %>%
    str_sub(end=-5)

  nhanes_category <- c("DEMO", "DIET", "EXAM", "LAB", "Q")
  nh_cat <- c("demo","diet","exam","lab","quest")
  datalist <- list()
  catlist <- list()

  for(a in 1:5) {
    for (i in 1:8) {
      df <- nhanesTables(nhanes_category[a], nhanes_year1[i])
      catlist[[i]] <- df
    }
    datalist[[a]] <- catlist
  }

  datalist %>%
    set_names(nh_cat) %>%
    map(clean_list) %>%
    list2env(.,envir = .GlobalEnv)

  nh_cat2 <- list(demo,diet,exam,lab,quest)
  varlist <- list()

  for(c in 1:5) {
    df <- nh_cat2[[c]] %>%
      map(~nhanesTableVars(nhanes_category[c],.x))
    varlist[[c]] <- df
  }
  # 
  # nhanes_codebook <- varlist %>%
  #   set_names(nh_cat) %>%
  #   map(bind_rows)
  # 
  # nhanes_codebook_final <- nhanes_codebook %>%
  #   bind_rows() %>%
  #   rename(
  #     var_name = Variable.Name,
  #     var_label = Variable.Description
  #   ) %>%
  #   distinct %>%
  #   modify_at(vars(var_name),tolower) %>%
  #   add_row(
  #     var_name = quote_all(ssatg,sst3f,sst4f,sstgn,sstpo,sstsh1,sstt3,sstt4,
  #                          eligstat,mortstat,ucod_leading,diabetes,hyperten,permth_int,permth_exm),
  #     var_label = quote_all(`Thyroglobulin antibody`,`Free T3`,`Free T4`,Thyroglobulin,
  #                           `Thyroperoxidase antibody`,`Thyroid stimulating hormone`,
  #                           `Total T3`,`Total T4`,
  #                           `Eligibility Status for Mortality Follow-up`,
  #                           `Final Mortality Status`,
  #                           `Underlying Cause of Death`,
  #                           `Diabetes Flag from Multiple Cause of Death`,
  #                           `Hypertension Flag from Multiple Cause of Death`,
  #                           `Number of Person Months of Follow-up from NHANES interview date`,
  #                           `Number of Person Months of Follow-up from NHANES Mobile Examination Center (MEC) date`)
  #   )

  #write_csv(nhanes_codebook_final, here("data","processed","nhanes_codebook.csv"))
} # create codebook

{
# nhanes_codebook_final <- read_csv(here("data","processed","nhanes_codebook.csv"))
# var_miss1 <- setdiff(names(nhanes_master),nhanes_codebook_final$var_name)
# 
# nhanes_master %<>%
#   rename(wtsaf2yr = wtsaf2yr.x,
#          wtsaf4yr = wtsaf4yr.x,
#          lb2day   = lb2day.x,
#          smq077   = smq077.x,
#          phafsthr = phafsthr.x,
#          phafstmn = phafstmn.x,
#          smaquex  = smaquex.x) %>%
#   select(-all_of(var_miss1))
# 
# var_miss2 <- setdiff(nhanes_codebook_final$var_name,names(nhanes_master))
# 
# nhanes_codebook_final %<>%
#   filter(var_name %notin% var_miss2)
} #check and match the variables from the dataset and codebook

#--------------------------------set value labels-------------------------------
nhanes_master %<>%
  rename_all(toupper) %>%
  clean

valuelist <- list(demo, diet, exam, quest)
value_cat <- c("DEMO","DIET", "EXAM", "Q")

for (a in 1:3) {
  vars <- valuelist[[a]] %>%
    map(~nhanesTableVars(value_cat[a], .x, namesonly=TRUE))
  for (i in 1:length(valuelist[[a]])) {
    nhanes_master <- suppressWarnings(nhanesTranslate(valuelist[[a]][i], vars[[i]], data=nhanes_master))
  }
}


#------------------------------set variable names-------------------------------
nhanes_master %<>% 
  rename_all(tolower)

# var_label(nhanes_master) <- nhanes_codebook_final %>%
#   dict_to_list()


nhanes_final <- full_join(nhanes_master,paqiaf_99to06, by = "seqn") %>%
  mutate_all(~replace(., which(. %in% list("Refused", "Don't know")), NA)) %>%
  set_variable_labels(
    modmin = "Moderate Leisure-Time min/wk",
    vigmin = "Vigorous Leisure-Time min/wk",
    modmet = "Moderate Leisure-Time MET min/wk",
    vigmet = "Vigorous Leisure-Time MET min/wk",
    minwk  = "Sum of MVPA Leisure-Time min/wk",
    metwk  = "Sum of MVPA Leisure-Time MET min/wk"
  ) %>% 
  set_value_labels(
    eligstat = c("Eligible"=1, "Under age 18, not available for public release"=2,"Ineligible"=3),
    mortstat = c("Assumed alive"=0,"Assumed deceased"=1),
    ucod_leading = c("Diseases of heart"=1,
                     "Malignant neoplasms"=2,
                     "Chronic lower respiratory diseases"=3,
                     "Accidents (unintentional injuries)"=4,
                     "Cerebrovascular diseases"=5,
                     "Alzheimer's disease"=6,
                     "Diabetes mellitus"=7,
                     "Influenza and pneumonia"=8,
                     "Nephritis, nephrotic syndrome and nephrosis"=9,
                     "All other causes (residual)"=10),
    diabetes = c("No"=0,"Yes"=1),
    hyperten = c("No"=0,"Yes"=1)
  ) %>%
  modify_at(vars(mcq240b,mcq240d,mcq240h,mcq240k,mcq240l,mcq240t,mcq240v,mcq240y,
                 mcq240aa,mcq240dk), as.numeric) %>%
  modify_if(is.labelled, to_factor) %>%
  modify_if(is.factor, fct_drop)

#write_rds(nhanes_final,here("data","processed","nhanes_final.rds"))
#nhanes_final <- read_rds(here("data","processed","nhanes_final.rds"))

#-----------------------------Create dataset for analysis-----------------------
look_for(nhanes_final, "age")


# var_label(nhanes_master) <- nhanes_codebook %>%
#   dict_to_list()

test <- nhanes_final %>% 
  mutate(mec16yr = case_when(sddsrvyr %in% c("NHANES 1999-2000 Public Release","NHANES 2001-2002 Public Release") ~ 2/8*wtmec4yr,
                             sddsrvyr %notin% c("NHANES 1999-2000 Public Release","NHANES 2001-2002 Public Release") ~ 1/8*wtmec2yr),
         int16yr = case_when(sddsrvyr %in% c("NHANES 1999-2000 Public Release","NHANES 2001-2002 Public Release") ~ 2/8*wtint4yr,
                             sddsrvyr %notin% c("NHANES 1999-2000 Public Release","NHANES 2001-2002 Public Release") ~ 1/8*wtint2yr),
         saf16yr = case_when(sddsrvyr %in% c("NHANES 1999-2000 Public Release","NHANES 2001-2002 Public Release") ~ 2/8*wtsaf4yr,
                             sddsrvyr %notin% c("NHANES 1999-2000 Public Release","NHANES 2001-2002 Public Release") ~ 1/8*wtsaf2yr),
         dr16yr  = case_when(sddsrvyr %in% c("NHANES 1999-2000 Public Release","NHANES 2001-2002 Public Release") ~ 2/8*wtdr4yr,
                             sddsrvyr %notin% c("NHANES 1999-2000 Public Release","NHANES 2001-2002 Public Release") ~ 1/8*wtdrd1),
         hhmetwk = 4.5*pad120*pad160/(4.33*60),
         trmetwk = case_when(paq050u == 1 ~ 4*pad080*paq050q*7/60,
                             paq050u == 2 ~ 4*pad080*paq050q/60,
                             paq050u == 3 ~ 4*pad080*paq050q/(4.33*60)),
         ltmethrwk = metwk/60,
         methrwk = rowSums(cbind(ltmethrwk,trmetwk,hhmetwk),na.rm = T),
         met_cat = cut(methrwk, breaks=c(0,32,Inf), 
                       labels=c("Low (<32 MET-Hours/Week)", "High (>=32 MET-Hours/Week)")),
         bmi_cat = cut(bmxbmi, breaks = c(0, 18.5, 25, 30, Inf), 
                       labels=c("Underweight (BMI<18.5)","Normal Weight (18.5<=BMI<25)",
                                "Overweight (25<=BMI<30)", "Obesity (BMI>=30)")),
         smoke   = case_when(smq020 == 2 ~ "Never smoker",
                             smq020 == 1 & smq040 == 3 ~ "Former smoker",
                             smq020 == 1 & smq040 %in% c(1,2) ~ "Current smoker"),
         alcohol = case_when(alq100 == 1 ~ "Drink alcohol",
                             alq100 == 2 ~ "Don't drink alcohol"),
         htn     = case_when(bpxsar>=130 | bpxdar>=80 ~ "With Hypertension",
                             bpxsar<130 & bpxdar<80 ~ "Without hypertension"),
         diab    = case_when((lbxglu>=126 & phafsthr>=12) |(lbxglu>=200 & phafsthr<12) |
                                (diq070==1 | diq050==1) | diq010 == 1 | lbxgh>=6.5 ~ "With diabetes",
                              TRUE ~ "Without diabetes"),
         py_int  = permth_int/12,
         py_exm  = permth_exm/12,
         cvd_death = ifelse(ucod_leading %in% c("Diseases of heart","Cerebrovascular diseases"),1,0),
         dii_drxttfat = (2*pnorm((drxttfat-71.4)/19.4)-1)*(0.298),
         dii_drxtsfat = (2*pnorm((drxtsfat-28.6)/8.0)-1)*(0.373),
         dii_drxtmfat = (2*pnorm((drxtmfat-27.0)/6.1)-1)*(-0.009),
         dii_drxtpfat = (2*pnorm((drxtpfat-13.88)/3.76)-1)*(-0.337),
         dii_dr1ttfat = (2*pnorm((dr1ttfat-71.4)/19.4)-1)*(0.298),
         dii_dr1tsfat = (2*pnorm((dr1tsfat-28.6)/8.0)-1)*(0.373),
         dii_dr1tmfat = (2*pnorm((dr1tmfat-27.0)/6.1)-1)*(-0.009),
         dii_dr1tpfat = (2*pnorm((dr1tpfat-13.88)/3.76)-1)*(-0.337),
         dii_drxtvare = (2*pnorm((drxtvare-983.9)/518.6)-1)*(-0.401),
         dii_drxtvb1  = (2*pnorm((drxtvb1-1.70)/0.66)-1)*(-0.098),
         dii_drxtvb2  = (2*pnorm((drxtvb2-1.70)/0.79)-1)*(-0.068),
         dii_drxtvb6  = (2*pnorm((drxtvb6-1.47)/0.74)-1)*(-0.365),
         dii_drxtvb12 = (2*pnorm((drxtvb12-5.15)/2.70)-1)*(0.106),
         dii_drxtvc   = (2*pnorm((drxtvc-118.2)/43.46)-1)*(-0.424),
         dii_drxtve   = (2*pnorm((drxtve-8.73)/1.49)-1)*(-0.419),
         dii_dr1tvb1  = (2*pnorm((dr1tvb1-1.70)/0.66)-1)*(-0.098),
         dii_dr1tvb2  = (2*pnorm((dr1tvb2-1.70)/0.79)-1)*(-0.068),
         dii_dr1tvb6  = (2*pnorm((dr1tvb6-1.47)/0.74)-1)*(-0.365),
         dii_dr1tvb12 = (2*pnorm((dr1tvb12-5.15)/2.70)-1)*(0.106),
         dii_dr1tvc   = (2*pnorm((dr1tvc-118.2)/43.46)-1)*(-0.424),
         dii_dr1tvd   = (2*pnorm((dr1tvd-6.26)/2.21)-1)*(-0.446),
         dii_drxtprot = (2*pnorm((drxtprot-79.4)/13.9)-1)*(0.021),
         dii_dr1tprot = (2*pnorm((dr1tprot-79.4)/13.9)-1)*(0.021),
         dii_drxtcarb = (2*pnorm((drxtcarb-272.2)/40.0)-1)*(0.097),
         dii_dr1tcarb = (2*pnorm((dr1tcarb-272.2)/40.0)-1)*(0.097),
         dii_drxtniac = (2*pnorm((drxtniac-25.90)/11.77)-1)*(-0.246),
         dii_dr1tniac = (2*pnorm((dr1tniac-25.90)/11.77)-1)*(-0.246),
         dii_drxtalco = (2*pnorm((drxtalco-13.98)/3.72)-1)*(-0.278),
         dii_dr1talco = (2*pnorm((dr1talco-13.98)/3.72)-1)*(-0.278),
         dii_drxtfibe = (2*pnorm((drxtfibe-18.8)/4.9)-1)*(-0.663),
         dii_dr1tfibe = (2*pnorm((dr1tfibe-18.8)/4.9)-1)*(-0.663),
         dii_drxtchol = (2*pnorm((drxtchol-279.4)/51.2)-1)*(0.110),
         dii_dr1tchol = (2*pnorm((dr1tchol-279.4)/51.2)-1)*(0.110),
         dii_drxtfa   = (2*pnorm((drxtfa-273.0)/70.7)-1)*(-0.190),
         dii_dr1tfa   = (2*pnorm((dr1tfa-273.0)/70.7)-1)*(-0.190),
         dii_drxtcaff = (2*pnorm((drxtcaff-8.05)/6.67)-1)*(-0.110),
         dii_dr1tcaff = (2*pnorm((dr1tcaff-8.05)/6.67)-1)*(-0.110),
         dii_drxtbcar = (2*pnorm((drxtbcar-3718)/1720)-1)*(-0.584),
         dii_dr1tbcar = (2*pnorm((dr1tbcar-3718)/1720)-1)*(-0.584),
         dii_drxtiron = (2*pnorm((drxtiron-13.35)/3.71)-1)*(0.032),
         dii_dr1tiron = (2*pnorm((dr1tiron-13.35)/3.71)-1)*(0.032),
         dii_drxtzinc = (2*pnorm((drxtzinc-9.84)/2.19)-1)*(-0.313),
         dii_dr1tzinc = (2*pnorm((dr1tzinc-9.84)/2.19)-1)*(-0.313),
         dii_drxtmagn = (2*pnorm((drxtmagn-310.1)/139.4)-1)*(-0.484),
         dii_dr1tmagn = (2*pnorm((dr1tmagn-310.1)/139.4)-1)*(-0.484),
         dii_drxtkcal = (2*pnorm((drxtkcal-2056)/338)-1)*(0.180),
         dii_dr1tkcal = (2*pnorm((dr1tkcal-2056)/338)-1)*(0.180),
         dii = rowSums(across(dii_drxttfat:dii_dr1tkcal), na.rm = T)
         ) %>% 
  mutate_at(vars(methrwk), ~replace(., which(. %in% list(0)), NA)) %>%
  mutate_at(vars(indfmin2), ~replace(., which(. %in% list("$     0 to $ 4,999", "$ 5,000 to $ 9,999", 
                                                          "$10,000 to $14,999", "$15,000 to $19,999",
                                                          "Under $20,000", "$20,000 to $24,999")), "Under $25,000")) %>% 
  set_variable_labels(ltmethrwk = "Leisure time MET Hrs/week",
                      trmetwk   = "Transportation MET Hrs/week",
                      hhmetwk   = "Household MET Hrs/week",
                      methrwk   = "Total MET Hrs/week",
                      met_cat   = "MET category",
                      bmi_cat   = "BMI category",
                      smoke     = "Smoking status",
                      alcohol   = "Alcohol drinking",
                      htn       = "Hypertension status",
                      diab      = "Diabetes status",
                      cvd_death = "CVD Death",
                      py_int    = "Person year (after interview)",
                      py_exm    = "Person year (after MEC)",
                      dii       = "Dietary Inflammatory Index") %>%
  set_value_labels(cvd_death = c("CVD death"=1, "Not CVD death"=0)) %>% 
  select(seqn,                                                       # id variable
         
         ridageyr, riagendr, ridreth1, dmdeduc, dmdmartl,            # demographics
         bmi_cat, smoke, alcohol, indfmin2,
         
         htn, lbxglu, lbxhgb, diab,                                  # lab measurements
         
         methrwk, met_cat,                                           # physical activity
         
         dii,                                                        # dietary inflammatory index
         
         eligstat, mortstat, ucod_leading,                           # outcome variables
         diabetes, hyperten, cvd_death,      
         
         permth_int, permth_exm, py_int, py_exm,                     # time vaiables
         
         mec16yr, int16yr, saf16yr, dr16yr, sdmvpsu, sdmvstra,       # weighting variables
  ) %>% 
  modify_at(vars(htn,diab), fct_rev) %>% 
  filter(ridageyr >=20) 
