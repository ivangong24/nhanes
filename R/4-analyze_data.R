#------------------------------------------------------------------------------#
#---------------------------Created by Yufan Gong------------------------------#
#------------------------------Date:05/01/2021---------------------------------#
#--------------------------------To analyze data-------------------------------#
#------------------------------------------------------------------------------#

#------------------------------1. Explore the data------------------------------
# nutrients <- test %>% 
#   select(seqn, ridageyr, dr16yr, sdmvpsu, sdmvstra, 
#          dii) %>% 
#   filter(!is.na(dr16yr)) %>% 
#   as_survey_design(ids = sdmvpsu, strata = sdmvstra, weights = dr16yr, nest=TRUE) %>% 
#   summarize(dii = survey_mean(dii, vartype = "ci", na.rm = T))

skim(test)

demo <- test %>% 
  filter(!is.na(dr16yr) & !is.na(met_cat))

#quantile(demo$methrwk, c(0:3/3), na.rm=T)

demo <- survey::svydesign(ids = ~sdmvpsu, strata = ~sdmvstra, 
                          weights = ~dr16yr, nest=TRUE, data=demo) 

#--------------------------------Create Table 1---------------------------------

demo %>% 
  tbl_svysummary(by = met_cat, 
                 missing = "no",
                 statistic = all_continuous() ~ "{mean} ({sd})",
                 digits = list(all_categorical() ~ c(0, 1),
                               all_continuous() ~ c(1, 1)),
                 include = c(met_cat,ridageyr,riagendr, ridreth1, dmdeduc, dmdmartl,
                             bmi_cat, smoke, alcohol,htn, diabetes, lbxglu, lbxhgb, dii)
                 ) %>% 
  add_p() %>%
  add_overall() %>%
  modify_caption("Table1. Demographic Characteristics by Physical activity level (N = {N})", ) %>% 
  modify_spanning_header(starts_with("stat_") ~ "**Physical Activity**") %>%
  bold_labels() %>%
  table1()



#------------------------------2. Analyze the data------------------------------

library(survival)
model1 <- survey::svycoxph(Surv(py_int,cvd_death)~met_cat+dii,design=demo)
summary(model1)
  
model2 <- survey::svycoxph(Surv(py_int,cvd_death)~met_cat+dii+ridageyr+riagendr+
                             relevel(ridreth1,ref = "Non-Hispanic White"),design=demo)
summary(model2)

model3 <- survey::svycoxph(Surv(py_int,cvd_death)~met_cat+dii+ridageyr+riagendr+
                             relevel(ridreth1,ref = "Non-Hispanic White")+
                             relevel(bmi_cat, ref = "Normal Weight (18.5<=BMI<25)")+
                             htn+diab,design=demo)
summary(model3)

km<-survey::svykm(Surv(py_int,cvd_death>0)~met_cat, design=demo,se=TRUE)
jskm::svyjskm(km, table = T)

