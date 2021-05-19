********************************************************
Filename NHANES_070416_last.sas
Created by Roch Nianogo
Date 04/07/2016
Purpuse: To clean the NHANES database Contiunous 1999-2014
*********************************************************;

OPTIONS formdlim='-';  
OPTIONS pageno =1; 
Options fmtsearch=(First);
options mprint mlogic;
options threads=yes;
options cpucount=6;
options BUFNO=250;
options bufsize=64k;



Libname First "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\19992000";


Proc format library=First;  

value	SDDSRVYR	1	=	'A-NHANES 1999-2000 Public Release'
				 	2 	= 	'B-NHANES 2001–2002 Public Release' 
					3 	= 	'C-NHANES 2003–2004 Public Release' 
					4 	= 	'D-NHANES 2005–2006 Public Release' 
					5 	= 	'E-NHANES 2007–2008 Public Release'
					6 	= 	'F-NHANES 2009–2010 Public Release'
					7 	= 	'G-NHANES 2011–2012 Public Release'
					8	= 	'H-NHANES 2013–2014 Public Release';

value	IntervExam 	1	=	'Both Interviewed and MEC examined'
					0	=	'Interviewed Only';

value	PREG		1	=	'Definitely Yes'
					0	=	'No/Dont know/Perhaps/NA';

value 	AGEGROUP	1	=	'0 to 5'
					2	=	'6 to 11'
					3	=	'12 to 19'
					4	=	'20 to 39'
					5	=	'40 to 59'
					6	=	'60 +';

Value analytic		1	=	'Early Childhood: 02-05 years'
					2	=	'Childthood: 06-11 years'
					3	=	'Adolescence: 12-19 years'
					4	=	'Young Adulthood: 20-39 years'
					5	=	'Adulthood: 40-65 years';
                                                   
VALUE 	MALE	   	1 	= 	'Male'                          
              		0 	= 	'Female';

VALUE 	RACE	  	1 	= 	'NH-White'
               		2 	= 	'NH-Black'
			   		3 	= 	'Mex-Am'
			   		4 	= 	'Other'; 

Value	YESNO	 	1 	= 	'Yes'
					0	=	'No';

Value	MARRIED		1	=	'Married' 
					0	=	'Single: Widowed/divorce/never married/Living with partner';

VALUE 	EDUC		1	=	'Less than High School'
					2	=	'High school Grad/Some college/AA degree'
					3	=	'College graduate or Above';

value ADHERENCEF	1 	= 	"Below"
        			2 	= 	"Meets"
       				3 	= 	"Exceeds";

value gender 		1	=	'male'
               		2	=	'female';

value agecut 		1	=	'2-17'
               		2	=	'>= 18'
	       			3	=	'2-11'
	       			4	=	'12-17';

VALUE	LOWINC		1	=	'Below or At Poverty Level ≤ 1'
					0	=	'Above Poverty Level >1';

VALUE 	HighSch		1	=	'Less than High School'
					0	=	'High school Grad and above';

VALUE SMK			1	=	'Current Smoker'
					0	=	'Never/Former Smoker';

VALUE Smoker		1	=	'Never Smoker'
					2	=	'Former Smoker'
					3	=	'Current Smoker';

VALUE ALC			1	=	'>= 4(female) or 5 (male) drinks/day past 12mos'
					0	=	'Less than 4(female) or 5 (male) drinks/day past 12mos';

VALUE Ffd			1	=	'>= 1 times Fastfood/week'
					0	=	'0 times Fastfood/week';

VALUE ebf			1	=	'Fully/Exclusive breastfeeding >= 6 mos'
					0	=	'Not fully breastfed';

VALUE BMIcat		1	=	'Underweight <18.5'
					2	=	'Normal Weight 18.5-25'
					3	=	'Overweight 25-30'
					4	=	'Obesity >=30';
RUN;


/*1)Demographics*/

Libname demo "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\Demographic Data";

Data demographics;
retain seqn  sddsrvyr ridstatr;
	 set demo.demo
	 demo.demo_b
	 demo.demo_c
	 demo.demo_d
	 demo.demo_e
	 demo.demo_f
	 demo.demo_g
	demo.demo_h; 
proc sort data=demographics; by seqn; 
run;

/*2)Examination data*/

Libname exam "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\Examination Data";

Data Examination;
	set exam.BMX 
	 exam.BMX_b
	 exam.BMX_c
	 exam.BMX_d
	 exam.BMX_e
	 exam.BMX_f
	 exam.BMX_g	
	 exam.BMX_h; 
proc sort data=Examination;by seqn;
run;


/*4)Questionnaire data*/

Libname quest "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\Questionnaire Data";

Data Alcohol; 
	 set quest.ALQ
	 quest.ALQ_b
	 quest.ALQ_c
	 quest.ALQ_d 
	 quest.ALQ_e 
	 quest.ALQ_f 
	 quest.ALQ_g 
	 quest.ALQ_h; 
proc sort data=Alcohol; by seqn;
run;

Data Diabetes;
	set quest.DIQ
	 quest.DIQ_b
	 quest.DIQ_c 
	 quest.DIQ_d 
	 quest.DIQ_e 
	 quest.DIQ_f 
	 quest.DIQ_g 
	 quest.DIQ_h;
proc sort data=Diabetes; by seqn;
run;

Data DietNutrition;
	set quest.DBQ
	 quest.DBQ_b
	 quest.DBQ_c 
	 quest.DBQ_d 
	 quest.DBQ_e 
	 quest.DBQ_f 
	 quest.DBQ_g 
	 quest.DBQ_h;
proc sort data=DietNutrition; by seqn;
run;

Data EarlyChildhood;
	set quest.ECQ 
	 quest.ECQ_b
	 quest.ECQ_c 
	 quest.ECQ_d 
	 quest.ECQ_e 
	 quest.ECQ_f 
	 quest.ECQ_g 
	 quest.ECQ_h;
proc sort data=EarlyChildhood; by seqn;
run;

Data MedicalConditions;
	set quest.MCQ
	 quest.MCQ_b
	 quest.MCQ_c 
	 quest.MCQ_d 
	 quest.MCQ_e 
	 quest.MCQ_f 
	 quest.MCQ_g 
	 quest.MCQ_h;
proc sort data=MedicalConditions; by seqn;
run;

Data PhysicalActivity;
	 set quest.PAQ
	 quest.PAQ_b 
	 quest.PAQ_c 
	 quest.PAQ_d;
proc sort data=PhysicalActivity; by seqn;
run;

Data PhysicalActivityInd;
	 set quest.PAQIAF
	 quest.PAQIAF_b 
	 quest.PAQIAF_c
	 quest.PAQIAF_d;
proc sort data=PhysicalActivityInd; by seqn;
run;

Data SmokingCigarette;
	set quest.SMQ
	 quest.SMQ_b
	 quest.SMQ_c 
	 quest.SMQ_d 
	 quest.SMQ_e 
	 quest.SMQ_f 
	 quest.SMQ_g 
	 quest.SMQ_h;
run;
proc sort data=SmokingCigarette; by seqn;
run;


Data WeightHistory;
set quest.WHQ
	 quest.WHQ_b 
	 quest.WHQ_c
	 quest.WHQ_d 
	 quest.WHQ_e 
	 quest.WHQ_f 
	 quest.WHQ_g 
	 quest.WHQ_h;
proc sort data=WeightHistory; by seqn;
run;

filename pa 'D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\19992000\PhysicalActivityCodes070116.sas';

%include pa;;/*always include two comas*/


Data Questionnaire;
	merge Alcohol 
	Diabetes 
	DietNutrition 
	EarlyChildhood
	MedicalConditions 
	PAWeek
	SmokingCigarette 
	WeightHistory;
	by seqn;
run;


/**5)Dietary Data***/
Libname diet 'D:\Roch\Dropbox (G-Analytics)\G Folder
\1-DATA\ABM Datasets\National Health and Nutrition Examination Survey (NHANES)\Dietary Data';

Data FFQraw;
	set diet.FFQRAW_C
		diet.FFQRAW_D;
proc sort data=FFQraw; by seqn;
run;

Data DTQ_F;
	set diet.DTQ_F;
proc sort data=DTQ_F; by seqn;
run;

Data Dietary;
	merge FFQraw DTQ_F;
	by seqn;
run;
Proc sort data=Dietary; by seqn; run;

filename diet 'D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\19992000\DietaryCodes07012016.sas';

%include diet;; /*Always use two semi-colon*/

/*Merging all the datasets*/

Libname First "D:\Roch\Dropbox (G-Analytics)\G Folder\1-DATA\ABM Datasets
\National Health and Nutrition Examination Survey (NHANES)\19992000";


Data nhanes;
	merge
	demographics
	examination
	questionnaire
	DietarySSBFV;
	by seqn;
run;


/*ANALYSES: 6/28/2016*/

Options fmtsearch=(First);

Data Nhanes1 (compress=yes compress=binary pointobs=no);
retain seqn  sddsrvyr ridstatr;
	set NHANES;

*********************************
****ADMINISTRATIVE VARIABLES*****
********************************;

/*Data Release Number*/
Label 		sddsrvyr		=	'Data Release Number.1999-2014 Cyle. 0-150 years.DEMO DATA';
Format		SDDSRVYR	SDDSRVYR.;

/*Interview/Examination Status*/
if RIDSTATR ^=. then IntervExam = (RIDSTATR=2);
Label IntervExam		=	'Interview/Examination Status.1999-2014 Cyle. 0-150 years.DEMO DATA';
Format	IntervExam	IntervExam.;

/*Weights*/
If sddsrvyr in (1,2) 		then MEC12YR = 1/3 * WTMEC4YR; /* for 1999–2002 */ 
If sddsrvyr in (3,4,5,6) 	then MEC12YR = 1/6 * WTMEC2YR; /* for 2003–2010 */

If sddsrvyr in (1,2) 		then MEC14YR = 2/7 * WTMEC4YR; /*for 1999-2002*/ 
If sddsrvyr in (3,4,5,6,7) 	then MEC14YR = 1/7 * WTMEC2YR; /*for 2003-2012*/

If sddsrvyr in (1,2) 		then MEC16YR = 2/8 * WTMEC4YR; /*for 1999-2002*/
If sddsrvyr in (3,4,5,6,7,8) then MEC16YR = 1/8 * WTMEC2YR; /*for 2003-2014*/

Label MEC12YR		=	'12  MEC Sample Weight 1999-2010. 0-150 years.DEMO DATA';
Label MEC14YR		=	'14  MEC Sample Weight 1999-2012. 0-150 years.DEMO DATA';
Label MEC16YR		=	'16  MEC Sample Weight 1999-2014. 0-150 years.DEMO DATA';

/*Behaviors/Intervention Weights MEC Examination*/
If sddsrvyr in (1,2) 	then BF_MEC10YR = 2/5 * WTMEC4YR; /* for 1999–2002 */ 
If sddsrvyr in (3,4,5) 	then BF_MEC10YR = 1/5 * WTMEC2YR; /* for 2003–2008 */

If sddsrvyr in (1,2) 	then PA_MEC08YR = 1/2 * WTMEC4YR; /* for 1999–2002 */ 
If sddsrvyr in (3,4) 	then PA_MEC08YR = 1/4 * WTMEC2YR; /* for 2003–2006 */

If sddsrvyr in (6) 	then SSB_MEC02YR = WTMEC2YR; /* for 2009–2010 */
If sddsrvyr in (6) 	then FV_MEC02YR = WTMEC2YR; /* for 2009–2010 */

If sddsrvyr in (5,6,7,8) 	then FF_MEC08YR = 1/4 * WTMEC2YR; /* for 2007–2014 */
Label BF_MEC10YR	=	'[Breastfeeding Weight MEC] 10  Year Sample Weight 1999-2008. 2-6 years.DEMO DATA';
Label PA_MEC08YR	=	'[Physical Activity Weight MEC] 08  Year Sample Weight 1999-2008. 12+ years.DEMO DATA';
Label SSB_MEC02YR	=	'[SSB Weight MEC] 02  Year Sample Weight 1999-2008. 2-65 years.DEMO DATA';
Label FV_MEC02YR	=	'[Fruit and Veggies Weight MEC] 02  Year Sample Weight 1999-2008. 2-65 years.DEMO DATA';
Label FF_MEC08YR	=	'[Fast food Weight MEC] 08  Year Sample Weight 1999-2008. 2-65 years.DEMO DATA';

/*Behaviors/Intervention Weights Interview*/
If sddsrvyr in (1,2) 	then BF_INT10YR = 2/5 * WTINT4YR; /* for 1999–2002 */ 
If sddsrvyr in (3,4,5) 	then BF_INT10YR = 1/5 * WTINT2YR; /* for 2003–2008 */

If sddsrvyr in (1,2) 	then PA_INT08YR = 1/2 * WTINT4YR; /* for 1999–2002 */ 
If sddsrvyr in (3,4) 	then PA_INT08YR = 1/4 * WTINT2YR; /* for 2003–2006 */

If sddsrvyr in (6) 	then SSB_INT02YR = WTINT2YR; /* for 2009–2010 */
If sddsrvyr in (6) 	then FV_INT02YR = WTINT2YR; /* for 2009–2010 */

If sddsrvyr in (5,6,7,8) 	then FF_INT08YR = 1/4 * WTINT2YR; /* for 2007–2014 */
Label BF_INT10YR	=	'[Breastfeeding Weight INT] 10  Year Sample Weight 1999-2008. 2-6 years.DEMO DATA';
Label PA_INT08YR	=	'[Physical Activity Weight INT] 08  Year Sample Weight 1999-2008. 12+ years.DEMO DATA';
Label SSB_INT02YR	=	'[SSB Weight INT] 02  Year Sample Weight 1999-2008. 2-65 years.DEMO DATA';
Label FV_INT02YR	=	'[Fruit and Veggies Weight INT] 02  Year Sample Weight 1999-2008. 2-65 years.DEMO DATA';
Label FF_INT08YR	=	'[Fast food Weight INT] 08  Year Sample Weight 1999-2008. 2-65 years.DEMO DATA';

/*Pregnancy Status at Exam */
Preg=.;
if RIDEXPRG=1 				then Preg=1; else Preg=0;
Label Preg	=	'Pregnancy Status at Exam (positive lab test/self-reported).1999-2014. 8-59 years.DEMO DATA';
Format Preg preg.;

*********************************
**SOCIO-DEMOGRAPHICS VARIABLES***
********************************;

/*Age*/

Age = ridageyr;
label Age	= 	'Age in years.1999-2014 cycle. 0-150 years.DEMO DATA';

Age20plus=.;
if ridageyr >= 20 	then age20plus=1; 
else if ridageyr ^=. then age20plus=0; 
format age20plus yesno.;
label Age20plus = 'Age 20 and older. 1999-2014 cycle. 0-150 years.DEMO DATA';

agegroup=.;
if ridageyr 		LE 5  	then agegroup=1;
if 06 LE ridageyr 	LE 11 	then agegroup=2;
if 12 LE ridageyr 	LE 19 	then agegroup=3;
if 20 LE ridageyr 	LE 39 	then agegroup=4;
if 40 LE ridageyr 	LE 59 	then agegroup=5;   
if ridageyr 		GE 60 	then agegroup=6; 
LABEL	Agegroup	= 	'AGE GROUP. 1999-2014 cycle. 0-150 years.DEMO DATA';
Format Agegroup	Agegroup.;

analytic=.;
if 02 <= age <=05 then analytic =1;
if 06 <= age <=11 then analytic =2;
if 12 <= age <=19 then analytic =3;
if 20 <= age <=39 then analytic =4;
if 40 <= age <=65 then analytic =5;

Label analytic = 'Analytic sample 2-65 years.DEMO DATA';
format analytic analytic.;

/*Gender*/
Male=.;
if RIAGENDR=1 	then Male=1; 
if RIAGENDR=2 	then Male=0;
Label Male		= 	'Gender (Male=1).1999-2014 cycle. 0-150 years.DEMO DATA';  
Format 	Male	Male.;

/*Race/Ethnicity*/
Race=.;
if ridreth1=3 				then race=1;
if ridreth1=4 				then race=2; 
if ridreth1=1 				then race=3;
if ridreth1 in (2 5) 		then race=4;
Label 	Race 		= 	'Race/Ethnicity.1999-2014 cycle. 0-150 years.DEMO DATA';
Format Race Race.;

if race ^=. then White = (Race=1);
if race ^=. then Black = (Race=2);
if race ^=. then Hispa = (Race=3);
if race ^=. then OtherRace = (Race=4);
if race ^=. then Minority =(Race>1);
Format White Black Hispa OtherRace yesno.;
Label White = 'White. 1999-2014 cycle. 0-150 years.DEMO DATA';
Label Black = 'Black. 1999-2014 cycle. 0-150 years.DEMO DATA';
Label Hispa = 'Hispa. 1999-2014 cycle. 0-150 years.DEMO DATA';
Label OtherRace = 'Other. 1999-2014 cycle. 0-150 years.DEMO DATA';
Label Minority = 'Minority. 1999-2014 cycle. 0-150 years.DEMO DATA';

Label 	Race 		= 	'Race/Ethnicity. 1999-2014 cycle. 0-150 years.DEMO DATA';
Format race race.;

/*Income*/
LowInc=.;
if  	0 <=INDFMPIR <= 	1	then LowInc=1; /*family income-to-poverty ratio (FIPR)*/
if  	INDFMPIR 	>1 			then LowInc=0;
Label Lowinc = 'Family income-to-poverty ratio (FIPR). 1999-2014 cylce.0 to 150 years. DEMO DATA';
Format Lowinc Lowinc.;

/*Education*/
HighSch=.;
if	DMDEDUC2 in (1 2)		then HighSch=0;
if	DMDEDUC2 in (3 4 5)		then HighSch=1;
Label HighSch	='Education.1999-2014 cylce.20 to 150 years. DEMO DATA';
Format HighSch HighSch.;

/*Marital Status*/
Married=.;
if 	dmdmartl=1 		then Married=1;
if 	dmdmartl in (2 3 4 5 6) 	then Married=0;
Label Married =	'Marital Status. 1999-2014 cylce.14 to 150 years. DEMO DATA';
Format Married Married.;


/*Family history of Diabetes*/
FamDM=.;
if MCQ250A=1 then FamDM =1; /*1999-2004 cycle*/
if MCQ250A=2 then FamDM =0; /*1999-2004 cycle*/
if MCQ300C=1 then FamDM =1; /*2005-2014 cycle*/
if MCQ300C=2 then FamDM =0; /*2005-2014 cycle*/
Label FamDM = 'Family history of diabetes.1999-2014 cycle.20-150 years. DATA QUEST';
format FamDM yesno.;

*********************************
******OUTCOMES VARIABLES*********
********************************;


/*BODY MASS INDEX*/
if 0 le bmxbmi lt 18.5 then bmicat=1; 
else if 18.5 le bmxbmi lt 25 then bmicat=2; 
else if 25 le bmxbmi lt 30 then bmicat=3; 
else if bmxbmi ge 30 then bmicat=4; 
bmi = bmxbmi;
Label bmi	=	'BMI continuous.1999-2014. 2-150 years.EXAM DATA';
Label BMIcat	=	'BMI categories.1999-2014. 2-150 years.EXAM DATA';
Format bmicat bmicat.;

/*DIABETES*/
if DIQ010 in (1 2) then Diab=DIQ010; if DIQ010 = 2 then Diab = 0;
if DIQ050 in (1 2) then Insulin=DIQ050; if DIQ050 = 2 then Insulin = 0;
if DIQ070 in (1 2) then Diabpills=DIQ070; if DIQ070 = 2 then Diabpills =0;

/*Delete inconsistencies: reported DM and also taking insulin or pills*/
If Diab=0 and Insulin=1 then Diab=.;
If Diab=0 and Diabpills=1 then Diab=.;
If Diab=1 and (Insulin=1 and Diabpills=.) then Diab=.;

If Diab=1 and Insulin=1 and Diabpills=0 then T1DM=1; else if Diab ^=. then T1DM=0;
/*Defined as Demmer, AJE 2013:T1DM if diabetic and taking insulin but no pills*/
If Diab=1 and T1DM ^=1 then T2DM=1; else if Diab ^=. then T2DM=0;
/*Defined as Demmer, AJE 2013: T2DM if no medication or pills (regardeless of Insulin status)*/
/*if Diab=0 and LBXGLU >= 126 then do;*/
/*	Diab=1;*/
/*	T2DM=1;/*undiagnosed diabetes*/ /*I will not use this criteria since some 
people reported no diabetes but were not part of the subsample*/
/*end;*/

Label Diab = 'Diabetes Mellitus.1999-2014 cycles.1-150 years.QUEST DATA';
Label T2DM = 'Type 2 Diabetes Mellitus.1999-2014 cycles.1-150 years.QUEST DATA';
Label T1DM = 'Type 1 Diabetes Mellitus.1999-2014 cycles.1-150 years.QUEST DATA';
Format Diab T1DM T2DM yesno.;


****************************************
**INTERVENTIONS/EXPOSURES VARIABLES*****
***************************************;

/*Breastfeeding*/
bfdays=DBD020; /*has to be explored prior to 2009-2010 since the question was changed to DBD055 to include formula*/
if bfdays=999999 then bfdays=.;
bfmos = bfdays/30.4; /*conversion factor in months given on NHANES website*/
if DBQ010 not in (7, 9) then  everbf=DBQ010;
if DBQ010=2 then everbf=0;
if everbf=0 then bfmos=0; /*never breastfed is equivalent to 0 mos duration*/
bfmosround = round(bfmos);

if sddsrvyr in (1 2 3 4 5) and 0 <= ridageyr <=6 and bfmos ^=. then ebf=(bfmosround>=6);
/*The breastfeeding question pertaining to fully breastfeeding
was (breast milk + water) only asked before the 2009-2010 survey cycle
It was also asked for individuals 0-6 years*/

Label ebf 		= 'Fully/Exclusive breastfeeding w/ water.1999-2008 cylces.0 to 6 years.QUEST DATA.Proxy Inter';
Label bfdays	= 'Breastfeeding duration (in days) rounded.1999-2008 cylces.0 to 6 years.QUEST DATA.Proxy Interv';
Label bfmos		= 'Breastfeeding duration (in months) rounded.1999-2008 cylces.0 to 6 years.QUEST DATA.Proxy Interv';
format ebf ebf.;


/*Physical Activity*/
label ADHERENCE = "Level of adherence to 2008 PA Guidelines. 1999-2006 Cycle.1999-2006 Cycle. 12 and older.QUEST DATA.INT all.MEC 12-15 y only";
label PAmeet = 'Adherence of 2008 PA guidelines 150 for Adults and 60 Adolescents.1999-2006 Cycle. 12 and older.QUEST DATA.INT all.MEC 12-15 y only';
label MVPA	= 'Moderate to High physical activity MET/min/Week >=600.1999-2006 Cycle. 12 and older.QUEST DATA.MEC 12-15 y only';
format ADHERENCE ADHERENCEF.;
format MVPA PAmeet yesno.;


/*Sugar Sweeneted Beverages*/
ssbgram = predssb*4.2; /*4.2g per teaspoon of added sugar*/
label ssbgram = 'daily intake of added sugar (gram) from SSB.2009-2010 cycle. 2 -69 years.DIET DATA.MEC 12-69yr';

ssbkcal = ssbgram*4; /*1g  of added sugar => 4 kcal of energy*/
label ssbkcal = 'daily intake of added sugar (kcal) from SSB.2009-2010 cycle. 2 -69 years.DIET DATA.MEC 12-69yr';

ssb12oz = predssb/8.76; /*1 12-oz of regular soda contains 8 tsp of sugar*/
label ssb12oz = 'daily intake of added sugar (# of 12-oz sodas from SSB) raw.2009-2010 cycle. 2 -69 years.DIET DATA.MEC 12-69yr';
/*https://ndb.nal.usda.gov/ndb/foods/show/4228?fgcd=&manu=&lfacet=&format=&count=&max=35&offset=&sort=&qlookup=cola*/
/*1 Beverages, carbonated, cola, regular contains 36.78 g of total sugars which is equivalent to 8.76 tsp of added sugar =36.78/4.2g*/

ssb12ozround = round(ssb12oz);
label ssb = 'daily intake of added sugar (# of 12-oz sodas from SSB) rounded.2009-2010 cycle. 2 -69 years.DIET DATA.MEC 12-69yr';

if ssb12ozround = 0 then ssb =0;
if ssb12ozround > 0 then ssb =1;
label ssb = 'Drink 1 or more 12-oz regular cola daily.2009-2010 cycle. 2 -69 years.DIET DATA';
Format ssb yesno.;

if gender = 2 then ssbpct=100*ssbkcal/1800;
if gender = 1 then ssbpct=100*ssbkcal/2200;
label ssbpct = 'daily intake of added sugar (% of total energy) from SSB.2009-2010 cycle. 2 -69 years.DIET DATA';

if (predssb ^=. and gender=1 and predssb>=9) then ssbfail=1;
if (predssb ^=. and gender=1 and predssb<9) then ssbfail=0;
if (predssb ^=. and gender=2 and predssb>=6) then ssbfail=1;
if (predssb ^=. and gender=2 and predssb<6) then ssbfail=0;
label ssbfail = 'Above the AHA dietary limit for daily added sugar 6 woman, 9 men.2009-2010 cycle. 2 -69 years.DIET DATA';
Format ssbfail yesno.;

/*Fruits and Vegetables*/
if predfvl ^=. then fv5=(predfvl>=4.5);
if predfvlnf ^=. then fvl5=(predfvlnf>=4.5); /*2015-2020 dietary recommendation: 2 fruits and 2.5 vegetables*/
label fv5 = 'daily fruit/veg intake (cup) >=4.5. 2009-2010 cycle. 2 -69 years.DIET DATA';
label fvl5 = 'daily fruit/veg/legume intake (cup) >=4.5. 2009-2010 cycle. 2 -69 years.DIET DATA';
format fv5 fvl5 yesno.;

/*Fast-Food*/
if sddsrvyr in (5 6 7 8) then
	do;
if DBD900 not in (5555 9999) then Fastfoodnum = DBD900;
if Fastfoodnum = 0 then Ffd=0;
if Fastfoodnum >=1 then Ffd=1;
	end;
Label Fastfoodnum = 'Consumption of Fastfood (#) per week.2007-2014 cycles.1 to 150 years.QUEST DATA';
Label Ffd = 'Consumption of Fastfood (dichotomized >=1) per week.2007-2014 cycles.1 to 150 years.QUEST DATA. MEC 12-15y only';
Format Ffd ffd.;


****************************************
********OTHER BEHAVIORS VARIABLES*******
***************************************;

/*SMOKING*/
if smq020 eq 2 then smoker=1; /*Never smoker  were defined as individuals who smoked a 100 cigarettes in their lifetime*/
else if smq020 eq 1 and smq040 eq 3 then smoker=2;    /*former smoker*/
else if smq020 eq 1 and smq040 in(1,2) then smoker=3; /*current smoker*/
Label smoker = 'Smoking status (current/former/never).1999-2014 cycle.18-150 years.QUEST DATA';
Format Smoker Smoker.;
SMK =.;
if smoker ^=. then SMK = (smoker=3);
Label SMK ='Current Smoker.1999-2014 cycle.18-150 years.QUEST DATA';
Format SMK SMK.;


/*Alcohol Drinking*/
ALC=.;
if ALQ130 not in (. 77 99) and male=1 then ALC =( ALQ130 >=5);
if ALQ130 not in (. 77 99) and male=0 then ALC =( ALQ130 >=4);
Label ALC =	'Drinks more than 4(female) or 5 (male)/day past 12mos.1999-2014 cycle.20-150 years.QUEST.Data';
Format ALC ALC.;


*********************************************
***********WEIGHT HISTORY*********************
**********************************************;
	
array miss whd010 whd020 whd050 whd110 whd120 whd130;
do over miss;
	if miss >=7777 then miss=.; 
end;

self_height0m	=  whd010*0.0254;
self_weight0kg 	= whd020*0.453592;
bmicurrent = self_height0m/(self_weight0kg*self_weight0kg);
Label bmicurrent ='Self Reported Current BMI.1999-2014 cycle. 16 and older.QUEST DATA';

self_weight1kg 	= whd050*0.453592;
bmi1yrago = self_weight1kg/(self_height0m*self_height0m);
Label bmi1yrago ='Self Reported BMI 1 year ago.1999-2014 cycle. 16 and older.QUEST DATA';

intWeightChange =.;
if WHD060=1 then intWeightChange=1; 
if WHD060=2 then intWeightChange=0;
Label intWeightChange = 'Intentional Weight Change. 1999-2014 cylce. 16 and older.QUEST DATA';

tryLoseWeight =.;
if WHD060=1 then tryLoseWeight=1; 
if WHD060=2 then tryLoseWeight=0;
Label tryLoseWeight = 'Tried to lose weight in past year. 1999-2014 cylce. 16 and older.QUEST DATA';
format intWeightChange tryloseWeight yesno.;

/*A "yes" response to the question, "Was the change between {your/SP’s} 
current weight and {your/his/her} weight a year ago intentional?" (WHQ.060) 
incorrectly skipped the interviewer to WHQ.090. 
A "Yes" response to WHQ.060 should have taken the interviewer to WHQ.080.*/

self_weight10kg = whd110*0.453592;
bmi10yrago = self_weight10kg/(self_height0m*self_height0m);/*Used Current Weight since no 10 year ago height*/
Label bmi10yrago ='Self Reported BMI 10 years ago.1999-2014 cycle. 36 and older.QUEST DATA';

self_weight25kg = whd120*0.453592;
self_height25m	= whd130*0.0254;
bmi25 = self_weight25kg/(self_height25m*self_height25m);
Label bmi25 ='Self Reported BMI at Age 25.1999-2014 cycle. 27 and older.QUEST DATA';



keep 

		/*Administrative variables*/
		seqn 		/*Respondent sequence number*/
		sddsrvyr  	/*Data Release Number*/
		IntervExam 	/*Interview/Examination Status*/
		RIDEXPRG preg	/*Pregnancy Status - Recode (old version)*/
		sdmvpsu 	/*Masked Variance Pseudo-PSU*/
		sdmvstra 	/*Masked Variance Pseudo-Stratum*/
		wtmec2yr 	/*Full Sample 2  MEC Exam Weight*/
		wtmec4yr 	/*Full Sample 4  MEC Exam Weight*/
		WTINT2YR 	/*Full Sample 2  Interview Weight*/
		WTINT4YR 	/*Full Sample 4  Interview Weight*/
		MEC12YR		/*12  MEC Sample Weight 1999-2010*/
		MEC14YR		/*14  MEC Sample Weight 1999-2012*/
		MEC16YR		/*16  MEC Sample Weight 1999-2014*/	
		analytic 	/*Analytic Sample 2-69 years*/

		BF_MEC10YR	/*[Breastfeeding Weight MEC] 10  Year Sample Weight 1999-2008. 2-6 years.DEMO DATA*/
		PA_MEC08YR	/*[Physical Activity Weight MEC] 08  Year Sample Weight 1999-2008. 12+ years.DEMO DATA*/
		SSB_MEC02YR	/*[SSB Weight MEC] 02  Year Sample Weight 1999-2008. 2-65 years.DEMO DATA*/
		FV_MEC02YR	/*[Fruit and Veggies Weight MEC] 02  Year Sample Weight 1999-2008. 2-65 years.DEMO DATA*/
		FF_MEC08YR /*[Fast food Weight MEC] 08  Year Sample Weight 1999-2008. 2-65 years.DEMO DATA*/
		
		BF_INT10YR	/*[Breastfeeding Weight INT] 10  Year Sample Weight 1999-2008. 2-6 years.DEMO DATA*/
		PA_INT08YR	/*[Physical Activity Weight INT] 08  Year Sample Weight 1999-2008. 12+ years.DEMO DATA*/
		SSB_INT02YR	/*[SSB Weight INT] 02  Year Sample Weight 1999-2008. 2-65 years.DEMO DATA*/
		FV_INT02YR	/*[Fruit and Veggies Weight INT] 02  Year Sample Weight 1999-2008. 2-65 years.DEMO DATA*/
		FF_INT08YR /*[Fast food Weight INT] 08  Year Sample Weight 1999-2008. 2-65 years.DEMO DATA*/
	/*Demographics*/
		Age ridageyr Agegroup age20plus /*Age*/
		riagendr Male	/*Gender (Male=1)*/
	   	ridreth1 Race  Minority white Black Hispa OtherRace	/*Race*/
	    INDFMPIR  LowInc	/*Family Poverty Income ratio (Low income <=1)*/
		HighSch	/*Education level (for 20+)*/
		dmdmartl Married	/*Marital Status(for 20+)*/

	/*Family history*/
		FamDM 	/*Family history of Diabetes*/
		ECD070A /*Weight at birth, pounds*/
		ECD070B /*Weight at birth, ounces*/
	
	/*Outcomes*/
		bmi bmicat 	/*Body Mass Index (kg/m2) 2-150 s*/
		bmxwt 			/*Weight in Kg (0-150 s)*/
		bmxht			/*Height in cm*/
		BMXRECUM  		/*Recumbent Length (cm) 0-47 mos*/
		bmxwaist		/*Wais Circumference*/

		Diab /*Diabetes*/
		T1DM /*Type 1 diabetes*/
		T2DM /*Type 2 diabetes*/

	/*Interventions-Exposures*/

		ssbgram  /*daily intake of added sugar (gram) from SSB */
		ssbkcal /*daily intake of added sugar (kcal) from SSB */
		ssbpct /*daily intake of added sugar (% of total energy) from SSB*/
		ssbfail /*Above the AHA dietary limit for daily added sugar 6 woman, 9 men */
		ssb12ozround /*daily intake of added sugar (contained in a 12-oz soda round) from SSB */
		ssb12oz /*daily intake of added sugar (contained in a 12-oz soda) from SSB */
		ssb /*Drink 1 or more 12-oz regular cola dialy */

		fv5 /*daily fruit/veg intake (cup) >=4.5 */
		fvl5 /*daily fruit/veg/legume intake (cup) >=4.5*/
	 	
		bfdays	/*breastfeeding in days*/
		bfmos	/*breastfeeding in months*/
		ebf		/*Exclusive (fully) breastfeeding (0-6)*/


		ADHERENCE /*Level of adherence to 2008 Physical Activity Guidelines for Americans*/
		PAmeet /*Adherence of 2008 PA guidelines 150 for Adults and 60 for children and Adolescents*/
		MVPA	/*Moderate to High physical activity MET/min/Week >=600*/
		TOTMMPW  /*Total MVPA MET min/wk*/
		mvpakids

		Ffd /*>=1 times eat Fastfood/week*/
		Fastfoodnum /*Fast-food consumption*/

		/*Other Behaviors*/

		SMK smoker /*smoking*/
		ALQ150 /*Ever have 5 or more drinks every day?*/
		ALQ130 /*Avg # alcoholic drinks/day -past 12 mos*/
		ALC /*Binge drinking define as having more than 5 drinks/day*/ /*both questions could be used ever and
		the last 12 months*/

		bmicurrent /*Self Reported Current BMI.1999-2014 cycle. 16 and older.QUEST DATA*/
		bmi1yrago/*Self Reported BMI 1 year ago.1999-2014 cycle. 16 and older.QUEST DATA*/
		intWeightChange /*Intentional Weight Change. 1999-2014 cylce. 16 and older.QUEST DATA*/
		tryLoseWeight /*Tried to lose weight in past year. 1999-2014 cylce. 16 and older.QUEST DATA*/
		bmi10yrago /*Self Reported BMI 10 years ago.1999-2014 cycle. 36 and older.QUEST DATA*/
		bmi25 /*Self Reported BMI at Age 25.1999-2014 cycle. 27 and older.QUEST DATA*/;

run;

/*Proc means data=nhanes1 n nmiss mean;*/
/*var preg Lowinc analytic male race sddsrvyr IntervExam;*/
/*run;*/


Data Nhanes2;
	set nhanes1;
		if preg =0; /*not pregnant*/
		if IntervExam=1;/*Participated in MEC exam (only for BMI)*/
		array miss analytic age male race Lowinc sddsrvyr IntervExam;
		do over miss;
			if miss=. then delete;
		end;
		/*Analytic Sample excluded about 16677 who are <2 or >65, income about 6913 and pregnant about 230 and 2013 for interview */
run;



Data First.Nhanes2;
	set nhanes2;
run;


proc datasets library=work kill; run; quit; 

dm 'output;clear;log;clear;'; 
