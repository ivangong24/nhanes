/*STEP 2:MERGING*/

/*1)Demographic*/

Libname demo "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\Demographic Data";

Libname demo2 "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\Demographic Data\DemographicData";

Data demo2.demographics;
retain seqn year;
	set demo.demo; year=2000; output;
	set demo.demo_b; year=2002;	output;
	set demo.demo_c; year=2004;	output;
	set demo.demo_d; year=2006;	output;
	set demo.demo_e; year=2008;	output;
	set demo.demo_f; year=2010;	output;
	set demo.demo_g; year=2012;	output;
	set demo.demo_h; year=2014;	output;
proc sort data=demo2.demographics; by seqn year;
run;


/*2)Dietary data*/

Libname diet "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\Dietary Data";

Libname diet2 "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\Dietary Data\DietaryData";

Data diet2.dietIntIndFood;
retain seqn year;
	set diet.DRXIFF; year=2000;	output;
	set diet.DRXIFF_b; year=2002;	output; RUN;
proc sort data=diet2.dietIntIndFood; by seqn year;
run;

Data diet2.dietIntIndFood1;
retain seqn year;
	set diet.DR1IFF_c; year=2004;	output;
	set diet.DR1IFF_d; year=2006;	output;
	set diet.DR1IFF_e; year=2008;	output;
	set diet.DR1IFF_f; year=2010;	output;
	set diet.DR1IFF_g; year=2012;	output;
proc sort data=diet2.dietIntIndFood1; by seqn year;
run;

Data diet2.dietIntIndFood2;
retain seqn year;
	set diet.DR2IFF_c; year=2004;	output;
	set diet.DR2IFF_d; year=2006;	output;
	set diet.DR2IFF_e; year=2008;	output;
	set diet.DR2IFF_f; year=2010;	output;
	set diet.DR2IFF_g; year=2012;	output;
proc sort data=diet2.dietIntIndFood2; by seqn year;
run;


****;
Data diet2.dietTotNutIntake;
retain seqn year;
	set diet.DRXTOT; year=2000;	output;
	set diet.DRXTOT_B; year=2002;	output;
proc sort data=diet2.dietTotNutIntake; by seqn year;
run;

Data diet2.dietTotNutIntake1;
retain seqn year;
	set diet.DR1TOT_c; year=2004;	output;
	set diet.DR1TOT_d; year=2006;	output;
	set diet.DR1TOT_e; year=2008;	output;
	set diet.DR1TOT_f; year=2010;	output;
	set diet.DR1TOT_g; year=2012;	output;
proc sort data=diet2.dietTotNutIntake1; by seqn year;
run;

Data diet2.dietTotNutIntake2;
retain seqn year;
	set diet.DR2TOT_c; year=2004;	output;
	set diet.DR2TOT_d; year=2006;	output;
	set diet.DR2TOT_e; year=2008;	output;
	set diet.DR2TOT_f; year=2010;	output;
	set diet.DR2TOT_g; year=2012;	output;
proc sort data=diet2.dietTotNutIntake2; by seqn year;
run;

***;
Data diet2.FFQ_Software;
retain seqn year;
	set diet.FFQDC_c; year=2004;	output;
	set diet.FFQDC_d; year=2006;	output;
proc sort data=diet2.FFQ_Software; by seqn year;
run;

Data diet2.FFQ_Raw;
retain seqn year;
	set diet.FFQRAW_c; year=2004;	output;
	set diet.FFQRAW_d; year=2006;	output;
proc sort data=diet2.FFQ_Raw; by seqn year;
run;

Data diet2.ffq_final;
	merge diet2.FFQ_Software 
	diet2.FFQ_Raw;
	by seqn year;
run;

Data diet2.dieatary;
	merge diet2.dietTotNutIntake
	diet2.FFQ;
	by seqn year;
run;


%macro array(list);
	%let i=1;
	%let v = %scan(&list, &i);

	%do %while("&v" ne "");
		ods html file="D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\Dietary Data\DietaryData\&v..xls";
Proc print data=diet.&v;
run;

ods html close;
ods html;

		%let i = %eval(&i + 1);
		%let v = %scan(&list, &i);
	%end;
%mend array;

%array(DRXFMT DRXFMT_B DRXFCD_D DRXFCD_E DRXFCD_F DRXFCD_G DRXMCD_C DRXMCD_D DRXMCD_E DRXMCD_F DRXMCD_G);






/*3)Examination data*/

Libname exam "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\Examination Data";

Libname exam2 "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\Examination Data\ExaminationData";

Data exam2.BloodPressure;
retain seqn year;
	set exam.BPX; year=2000; output;
	set exam.BPX_b; year=2002;	output;
	set exam.BPX_c; year=2004;	output;
	set exam.BPX_d; year=2006;	output;
	set exam.BPX_e; year=2008;	output;
	set exam.BPX_f; year=2010;	output;
	set exam.BPX_g; year=2012;	output;
	set exam.BPX_h; year=2014;	output;
proc sort data=exam2.BloodPressure; by seqn year;
run;

Data exam2.BodyMeasures;
retain seqn year;
	set exam.BMX; year=2000; output;
	set exam.BMX_b; year=2002;	output;
	set exam.BMX_c; year=2004;	output;
	set exam.BMX_d; year=2006;	output;
	set exam.BMX_e; year=2008;	output;
	set exam.BMX_f; year=2010;	output;
	set exam.BMX_g; year=2012;	output;
	set exam.BMX_h; year=2014;	output;
proc sort data=exam2.BodyMeasures; by seqn year;
run;

Data exam2.CardioFitness;
retain seqn year;
	set exam.CVX; year=2000; output;
	set exam.CVX_b; year=2002;	output;
	set exam.CVX_c; year=2004;	output;
proc sort data=exam2.CardioFitness; by seqn year;
run;

Data exam2.Examination;
	merge exam2.BloodPressure 
	exam2.BodyMeasures  
	exam2.CardioFitness;
	by seqn year;
run;



/*4)Laboratory data*/

Libname lab "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\Laboratory Data";

Libname lab2 "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\Laboratory Data\LabData";

Data lab2.HDL;
retain seqn year;
	set lab.HDL_d; year=2006;	output;
	set lab.HDL_e; year=2008;	output;
	set lab.HDL_f; year=2010;	output;
	set lab.HDL_g; year=2012;	output;
	set lab.HDL_h; year=2014;	output;
proc sort data=lab2.HDL; by seqn year;
run;

Data lab2.LDL_TRIG;
retain seqn year;
	set lab.LAB13AM; year=2000;	output;
	set lab.L13AM_b; year=2002;	output;
	set lab.L13AM_c; year=2004;	output;
	set lab.TRIGLY_d; year=2006;	output;
	set lab.TRIGLY_e; year=2008;	output;
	set lab.TRIGLY_f; year=2010;	output;
	set lab.TRIGLY_g; year=2012;	output;
	set lab.TRIGLY_h; year=2014;	output;
proc sort data=lab2.LDL_TRIG; by seqn year;
run;

Data lab2.TOTCHOL;
retain seqn year;
	set lab.TCHOL_d; year=2006;	output;
	set lab.TCHOL_e; year=2008;	output;
	set lab.TCHOL_f; year=2010;	output;
	set lab.TCHOL_g; year=2012;	output;
	set lab.TCHOL_h; year=2014;	output;
proc sort data=lab2.TOTCHOL; by seqn year;
run;

Data lab2.TOTCHOL_HDL;
retain seqn year;
	set lab.LAB13; year=2000;	output;
	set lab.L13_b; year=2002;	output;
	set lab.L13_c; year=2004;	output;
proc sort data=lab2.TOTCHOL_HDL; by seqn year;
run;

Data lab2.CHOL_ALL;
retain seqn year;
	set lab.L13_2_b; year=2002;	output;
proc sort data=lab2.CHOL_ALL; by seqn year;
run;

Data lab2.laboratory;
	merge lab2.HDL 
	lab2.LDL_TRIG 
	lab2.TOTCHOL 
	lab2.TOTCHOL_HDL 
	lab2.CHOL_ALL;
	by seqn year;
run;


/*5)Questionnaire data*/

Libname quest "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\Questionnaire Data";

Libname quest2 "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\Questionnaire Data\QuestionnaireData";

Data quest2.ALCOHOL;
retain seqn year;
	set quest.ALQ; year=2000; output;
	set quest.ALQ_b; year=2002;	output;
	set quest.ALQ_c; year=2004;	output;
	set quest.ALQ_d; year=2006;	output;
	set quest.ALQ_e; year=2008;	output;
	set quest.ALQ_f; year=2010;	output;
	set quest.ALQ_g; year=2012;	output;
	set quest.ALQ_h; year=2014;	output;
proc sort data=quest2.ALCOHOL; by seqn year;
run;

Data quest2.ALCOHOL_YOUTH;
retain seqn year;
	set quest.ALQY_f; year=2010;	output;
proc sort data=quest2.ALCOHOL_YOUTH; by seqn year;
run;

Data quest2.BP_CHOL;
retain seqn year;
	set quest.BPQ; year=2000; output;
	set quest.BPQ_b; year=2002;	output;
	set quest.BPQ_c; year=2004;	output;
	set quest.BPQ_d; year=2006;	output;
	set quest.BPQ_e; year=2008;	output;
	set quest.BPQ_f; year=2010;	output;
	set quest.BPQ_g; year=2012;	output;
	set quest.BPQ_h; year=2014;	output;
proc sort data=quest2.BP_CHOL; by seqn year;
run;


Data quest2.CardioHealth;
retain seqn year;
	set quest.CDQ; year=2000; output;
	set quest.CDQ_b; year=2002;	output;
	set quest.CDQ_c; year=2004;	output;
	set quest.CDQ_d; year=2006;	output;
	set quest.CDQ_e; year=2008;	output;
	set quest.CDQ_f; year=2010;	output;
	set quest.CDQ_g; year=2012;	output;
	set quest.CDQ_h; year=2014;	output;
proc sort data=quest2.CardioHealth; by seqn year;
run;

Data quest2.HealthStatus;
retain seqn year;
	set quest.HSQ; year=2000; output;
	set quest.HSQ_b; year=2002;	output;
	set quest.HSQ_c; year=2004;	output;
	set quest.HSQ_d; year=2006;	output;
	set quest.HSQ_e; year=2008;	output;
	set quest.HSQ_f; year=2010;	output;
	set quest.HSQ_g; year=2012;	output;
proc sort data=quest2.HealthStatus; by seqn year;
run;


Data quest2.Diabetes;
retain seqn year;
	set quest.DIQ; year=2000; output;
	set quest.DIQ_b; year=2002;	output;
	set quest.DIQ_c; year=2004;	output;
	set quest.DIQ_d; year=2006;	output;
	set quest.DIQ_e; year=2008;	output;
	set quest.DIQ_f; year=2010;	output;
	set quest.DIQ_g; year=2012;	output;
	set quest.DIQ_h; year=2014;	output;
proc sort data=quest2.Diabetes; by seqn year;
run;


Data quest2.DietNutrition;
retain seqn year;
	set quest.DBQ; year=2000; output;
	set quest.DBQ_b; year=2002;	output;
	set quest.DBQ_c; year=2004;	output;
	set quest.DBQ_d; year=2006;	output;
	set quest.DBQ_e; year=2008;	output;
	set quest.DBQ_f; year=2010;	output;
	set quest.DBQ_g; year=2012;	output;
	set quest.DBQ_h; year=2014;	output;
proc sort data=quest2.DietNutrition; by seqn year;
run;

Data quest2.EarlyChildhood;
retain seqn year;
	set quest.ECQ; year=2000; output;
	set quest.ECQ_b; year=2002;	output;
	set quest.ECQ_c; year=2004;	output;
	set quest.ECQ_d; year=2006;	output;
	set quest.ECQ_e; year=2008;	output;
	set quest.ECQ_f; year=2010;	output;
	set quest.ECQ_g; year=2012;	output;
	set quest.ECQ_h; year=2014;	output;
proc sort data=quest2.EarlyChildhood; by seqn year;
run;

Data quest2.FoodSecurity;
retain seqn year;
	set quest.FSQ; year=2000; output;
	set quest.FSQ_b; year=2002;	output;
	set quest.FSQ_c; year=2004;	output;
	set quest.FSQ_d; year=2006;	output;
	set quest.FSQ_e; year=2008;	output;
	set quest.FSQ_f; year=2010;	output;
	set quest.FSQ_g; year=2012;	output;
proc sort data=quest2.FoodSecurity; by seqn year;
run;

Data quest2.HealthInsurance;
retain seqn year;
	set quest.HIQ; year=2000; output;
	set quest.HIQ_b; year=2002;	output;
	set quest.HIQ_c; year=2004;	output;
	set quest.HIQ_d; year=2006;	output;
	set quest.HIQ_e; year=2008;	output;
	set quest.HIQ_f; year=2010;	output;
	set quest.HIQ_g; year=2012;	output;
	set quest.HIQ_h; year=2014;	output;
proc sort data=quest2.HealthInsurance; by seqn year;
run;


Data quest2.Housing;
retain seqn year;
	set quest.HOQ; year=2000; output;
	set quest.HOQ_b; year=2002;	output;
	set quest.HOQ_c; year=2004;	output;
	set quest.HOQ_d; year=2006;	output;
	set quest.HOQ_e; year=2008;	output;
	set quest.HOQ_f; year=2010;	output;
	set quest.HOQ_g; year=2012;	output;
	set quest.HOQ_h; year=2014;	output;
proc sort data=quest2.Housing; by seqn year;
run;

Data quest2.Income;
retain seqn year;
	set quest.INQ_e; year=2008;	output;
	set quest.INQ_f; year=2010;	output;
	set quest.INQ_g; year=2012;	output;
	set quest.INQ_h; year=2014;	output;
proc sort data=quest2.Income; by seqn year;
run;

Data quest2.Occupation;
retain seqn year;
	set quest.OCQ; year=2000; output;
	set quest.OCQ_b; year=2002;	output;
	set quest.OCQ_c; year=2004;	output;
	set quest.OCQ_d; year=2006;	output;
	set quest.OCQ_e; year=2008;	output;
	set quest.OCQ_f; year=2010;	output;
	set quest.OCQ_g; year=2012;	output;
proc sort data=quest2.Occupation; by seqn year;
run;

Data quest2.MedicalConditions;
retain seqn year;
	set quest.MCQ; year=2000; output;
	set quest.MCQ_b; year=2002;	output;
	set quest.MCQ_c; year=2004;	output;
	set quest.MCQ_d; year=2006;	output;
	set quest.MCQ_e; year=2008;	output;
	set quest.MCQ_f; year=2010;	output;
	set quest.MCQ_g; year=2012;	output;
	set quest.MCQ_h; year=2014;	output;
proc sort data=quest2.MedicalConditions; by seqn year;
run;


Data quest2.PhysicalActivity;
retain seqn year;
	set quest.PAQ; year=2000; output;
	set quest.PAQ_b; year=2002;	output;
	set quest.PAQ_c; year=2004;	output;
	set quest.PAQ_d; year=2006;	output;
	set quest.PAQ_e; year=2008;	output;
	set quest.PAQ_f; year=2010;	output;
	set quest.PAQ_g; year=2012;	output;
	set quest.PAQ_h; year=2014;	output;
proc sort data=quest2.PhysicalActivity; by seqn year;
run;

Data quest2.PhysicalActivityInd;
retain seqn year;
	set quest.PAQIAF; year=2000; output;
	set quest.PAQIAF_b; year=2002;	output;
	set quest.PAQIAF_c; year=2004;	output;
	set quest.PAQIAF_d; year=2006;	output;
proc sort data=quest2.PhysicalActivityInd; by seqn year;
run;

Data quest2.Sleep;
retain seqn year;
	set quest.SLQ_d; year=2006;	output;
	set quest.SLQ_e; year=2008;	output;
	set quest.SLQ_f; year=2010;	output;
	set quest.SLQ_g; year=2012;	output;
proc sort data=quest2.Sleep; by seqn year;
run;

Data quest2.SmokingCigarette;
retain seqn year;
	set quest.SMQ; year=2000; output;
	set quest.SMQ_b; year=2002;	output;
	set quest.SMQ_c; year=2004;	output;
	set quest.SMQ_d; year=2006;	output;
	set quest.SMQ_e; year=2008;	output;
	set quest.SMQ_f; year=2010;	output;
	set quest.SMQ_g; year=2012;	output;
	set quest.SMQ_h; year=2014;	output; 
proc sort data=quest2.SmokingCigarette; by seqn year;
run;

Data quest2.SmokingCigaretteYouth;
retain seqn year;
	set quest.SMQMEC; year=2000; output;
	set quest.SMQMEC_b; year=2002;	output;
	set quest.SMQMEC_c; year=2004;	output;
proc sort data=quest2.SmokingCigaretteYouth; by seqn year;
run;

Data quest2.SmokingHousehold;
retain seqn year;
	set quest.SMQFAM; year=2000; output;
	set quest.SMQFAM_b; year=2002;	output;
	set quest.SMQFAM_c; year=2004;	output;
	set quest.SMQFAM_d; year=2006;	output;
	set quest.SMQFAM_e; year=2008;	output;
	set quest.SMQFAM_f; year=2010;	output;
	set quest.SMQFAM_g; year=2012;	output;
	set quest.SMQFAM_h; year=2014;	output;
proc sort data=quest2.SmokingHousehold; by seqn year;
run;

Data quest2.SmokingRecentUse;
retain seqn year;
	set quest.SMQRTU_d; year=2006;	output;
	set quest.SMQRTU_e; year=2008;	output;
	set quest.SMQRTU_f; year=2010;	output;
	set quest.SMQRTU_g; year=2012;	output;
	set quest.SMQRTU_h; year=2014;	output;
proc sort data=quest2.SmokingRecentUse; by seqn year;
run;

Data quest2.SecondHandSmoke;
retain seqn year;
	set quest.SMQSHS_h; year=2014;	output;
proc sort data=quest2.SecondHandSmoke; by seqn year;
run;

Data quest2.WeightHistory;
retain seqn year;
	set quest.WHQ; year=2000;	output;
	set quest.WHQ_B; year=2002;	output;
	set quest.WHQ_C; year=2004;	output;
	set quest.WHQ_d; year=2006;	output;
	set quest.WHQ_e; year=2008;	output;
	set quest.WHQ_f; year=2010;	output;
	set quest.WHQ_g; year=2012;	output;
	set quest.WHQ_h; year=2014;	output;
proc sort data=quest2.WeightHistory; by seqn year;
run;

Data quest2.WeightHistoryYouth;
retain seqn year;
	set quest.WHQMEC_d; year=2006;	output;
	set quest.WHQMEC_e; year=2008;	output;
	set quest.WHQMEC_f; year=2010;	output;
	set quest.WHQMEC_g; year=2012;	output;
	set quest.WHQMEC_h; year=2014;	output;
proc sort data=quest2.WeightHistoryYouth; by seqn year;
run;


Data quest2.SocialSupport;
retain seqn year;
	set quest.SSQ; year=2000;	output;
	set quest.SSQ_B; year=2002;	output;
	set quest.SSQ_C; year=2004;	output;
	set quest.SSQ_D; year=2006;	output;
	set quest.SSQ_E; year=2008;	output;
proc sort data=quest2.SocialSupport; by seqn year;
run;

Data quest2.Questionnaire;
	merge quest2.Alcohol (keep=seqn year ALQ100) 
	quest2.Alcohol_Youth (keep=seqn year )
	quest2.BP_CHOL (keep=seqn year )
	quest2.CardioHealth (keep=seqn year )
	quest2.HealthStatus (keep=seqn year )
	quest2.Diabetes (keep=seqn year )
	quest2.DietNutrition (keep=seqn year )
	quest2.EarlyChildhood (keep=seqn year )
	quest2.FoodSecurity (keep=seqn year )
	quest2.HealthInsurance (keep=seqn year )
	quest2.Housing (keep=seqn year )
	quest2.Income (keep=seqn year )
	quest2.Occupation (keep=seqn year )
	quest2.MedicalConditions (keep=seqn year )
	quest2.PhysicalActivity (keep=seqn year )
	quest2.PhysicalActivityInd (keep=seqn year )
	quest2.Sleep (keep=seqn year )
	quest2.SmokingCigarette (keep=seqn year )
	quest2.SmokingCigaretteYouth (keep=seqn year )
	quest2.SmokingHousehold (keep=seqn year )
	quest2.SmokingRecentUse (keep=seqn year )
	quest2.SecondHandSmoke (keep=seqn year )
	quest2.WeightHistory	(keep=seqn year )
	quest2.WeightHistoryYouth (keep=seqn year )
	quest2.SocialSupport (keep=seqn year );
	by seqn year;
run;


Libname comb "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\Combined";

/*Merging all the datasets*/

Data comb.NHANES;
	merge 
	demo2.demographic
	diet2.dietary
	exam2.examination
	lab2.laboratory
	quest2.questionnaire
	by seqn year;
run;
