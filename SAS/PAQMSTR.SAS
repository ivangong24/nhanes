**************************************************************************;
**************************************************************************;
* This program was created to calculate min/wk and MET min/wk for         ;
* household/yard, transportation, and leisure-time physical activities for;
* all respondents to the PAQ in the 2003-2004 and 2005-2006 NHANES cycles.;
**************************************************************************;
**************************************************************************;

*-------------------------------------------------------------------------;
*LOCATE FILES AND VARIABLES                                               ;
*-------------------------------------------------------------------------;

*On the NHANES website, locate the demographic and physical activity files 
 needed to build the PAQMSTR dataset.;

*-------------------------------------------------------------------------;
*DOWNLOAD DATA                                                            ;
*-------------------------------------------------------------------------;

*To build the "PAQMSTR" dataset, you will need to download the DEMO,     
 PAQ, and PAQIAF files from the 2003-2004 and 2005-2006 cycles.           
 Use the XPORT engine to convert the .xpt files from the SAS transport   
 format to the standard SAS dataset format so that the data are useable  
 for analysis.  Run a proc contents statement in SAS to check that your  
 dataset contains the correct number of observations and variables       
 based on information provided in the documentation.;         		     


libname demo_c xport 'c:\nhanes\download\demo_c.xpt';
libname paq_c xport 'c:\nhanes\download\paq_c.xpt';
libname paqiaf_c xport 'c:\nhanes\download\paqiaf_c.xpt';

libname demo_d xport 'c:\nhanes\download\demo_d.xpt';
libname paq_d xport 'c:\nhanes\download\paq_d.xpt';
libname paqiaf_d xport 'c:\nhanes\download\paqiaf_d.xpt';

*Your final permanent dataset will be stored in this directory;

libname nhanes 'c:\nhanes\data';


*Run proc contents to confirm that your dataset contains the correct number 
 of observations/variables as shown in the data documentation;

proc contents data = demo_c.demo_c;
run;
proc contents data = paq_c.paq_c;
run;
proc contents data = paqiaf_c.paqiaf_c;
run;
proc contents data = demo_d.demo_d;
run;
proc contents data = paq_d.paq_d;
run;
proc contents data = paqiaf_d.paqiaf_d;
run;

*-------------------------------------------------------------------------;
*MERGE AND APPEND DATASETS;
*-------------------------------------------------------------------------;

*Begin by sorting the DEMO and PAQ datasets.  Next, merge the DEMO and
 PAQ data from the 2003-2004 and 2005-2006 cycles.  Following the merge
 process you will append the data from the 2 NHANES cycles.;

proc sort data = demo_c.demo_c out = demo_c;
 by seqn;
run; 
proc sort data = paq_c.paq_c out = paq_c;
 by seqn;
run;
proc sort data = demo_d.demo_d out = demo_d;
 by seqn;
run;  
proc sort data = paq_d.paq_d out = paq_d;
 by seqn;
run; 

*Merge;

data paq3;
 merge demo_c paq_c;
 by seqn;
run;

data paq5;
 merge demo_d paq_d;
 by seqn;
run;

proc contents data = paq3;
run;
proc contents data = paq5;
run;

*Append;

data paq;
 set paq3 paq5;
run;
*-------------------------------------------------------------------------;
*REVIEW DATA AND CREATE NEW VARIABLES                                     ;
*-------------------------------------------------------------------------;

*create a new sample weight variable that is appropriate to use with the;
*appended data that encompasses four years;

data paq (DROP=WTINT2YR);
 set paq;
 WTINT4CD = WTINT2YR/2;
run;

data paq;
set paq;
*-------------------------------------------------------------------------;
* RECODE DATA                                                             ;
*                                                                         ;
* PAQ100: Tasks around home/yard past 30 days (1 = Yes, 2 = No)           ;
* PAD020: Walked or bicycled over past 30 days (1 = Yes, 2 = No)          ; 
* PAD320: Moderate activity over past 30 days (1 = Yes, 2 = No)           ;             
* PAD200: Vigorous activity over past 30 days (1 = Yes, 2 = No)           ;
*                                                                         ;
* Calculate min/week and MET min/week for the three physical activity     ;     
* domains: household/yard, transportation, and leisure.  Begin by recoding;     
* the physical activity data values as follows:                           ;
*  value=3 (Unable to do activity) change to 2 (no)                       ;
*  value=7 (Refused) change to . (missing)                                ; 
*  value=9 (Don't know) change to . (missing)                             ;	                               
*-------------------------------------------------------------------------;

   if PAD020 = 3 then RPAD020 = 2;
     else if PAD020 = 7 then RPAD020 = .;
     else if PAD020 = 9 then RPAD020 = .;
     else RPAD020=PAD020;

   if PAQ100 = 3 then RPAQ100 = 2;
     else if PAQ100 = 7 then RPAQ100 = .;
     else if PAQ100 = 9 then RPAQ100 = .;
     else RPAQ100=PAQ100;

   if PAD200 = 3 then RPAD200 = 2;
     else if PAD200 = 7 then RPAD200 = .;
     else if PAD200 = 9 then RPAD200 = .;
     else RPAD200=PAD200;

   if PAD320 = 3 then RPAD320 = 2;
     else if PAD320 = 7 then RPAD320 = .;
     else if PAD320 = 9 then RPAD320 = .;
     else RPAD320=PAD320;

*-------------------------------------------------------------------------;
*CREATE NEW VARIABLES                                                     ;
*-------------------------------------------------------------------------;

*-------------------------------------------------------------------------;
* Create Household/Yard MET minutes per week (HHMMPW) - use MET score 4.5 ;
* Also create Household/Yard min/wk (HHMINW)                              ;
*  RPAQ100: Tasks around home/yard past 30 days (1 = Yes, 2 = No)         ;
*  PAD120: # times past 30 days (range of values: 1 to 300)               ; 
*  PAD160: How long each time (minutes) (range of values: 1 to 600)	      ;	  
*  Use "4.33" as the average number of weeks in a month.        		  ;
*-------------------------------------------------------------------------; 

	if RPAQ100 = 2 then HHMINW = 0;
	if RPAQ100 = 2 then HHMMPW = 0;

	if RPAQ100 = 1 and (PAD120 = 99999 or PAD120 = 77777) then HHMINW = .;
	if RPAQ100 = 1 and (PAD120 = 99999 or PAD120 = 77777) then HHMMPW = .;

	if RPAQ100 = 1 and (PAD160 = 99999 or PAD160 = 77777) then HHMINW = .;
	if RPAQ100 = 1 and (PAD160 = 99999 or PAD160 = 77777) then HHMMPW = .;

		else if RPAQ100 = 1 and (1 <= PAD120 <= 300) and 
               (1 <= PAD160 <= 600)
		then do;

			HHMINW = (PAD120*PAD160)/4.33;
			HHMMPW = (HHMINW)*4.5;

		end;


 		label 	HHMINW = 'Household and Yard Work min/wk'
				HHMMPW = 'Household and Yard Work MET min/wk';

*-------------------------------------------------------------------------;
* Create Transportation MET minutes per week (TRMMPW) - use MET score 4.0 ;
* Cap number of times in transportation questions.  Then, calculate       ;   
* MET min/wk and min/wk.	                                              ;
*	    							                                      ;
*  RPAD020: Walked or bicycled over past 30 days (1 = Yes, 2 = No)        ;
*  PAQ050Q: # of times walked or bicycled (range of values: 1 to 124)     ;
*  PAQ050U: Unit of measure (day/week/month)(1 = Day, 2 = Week, 3 = Month);
*  PAD080: How long per day (minutes)(range of values: 1 to 600)          ;
*-------------------------------------------------------------------------; 
   
	*Topcode the maximum number of trips allowable;
	TRNUMTIM = PAQ050Q; 

	if PAQ050U = 2 and TRNUMTIM > 7 then TRNUMTIM = 7;                                                       
		else if PAQ050U = 3 and TRNUMTIM > 30 then TRNUMTIM = 30;                                              
		else if PAQ050U = 1 then TRNUMTIM = 1;                                                                 
  
	if RPAD020 = 2 then TRMINW = 0; 
   	if RPAD020 = 2 then TRMMPW = 0; 

	if RPAD020 = 1 and (PAQ050Q = 99999 or PAQ050Q = 77777) then TRMINW = .;
	if RPAD020 = 1 and (PAQ050Q = 99999 or PAQ050Q = 77777) then TRMMPW = .;

	if RPAD020 = 1 and (PAD080 = 99999 or PAD080 = 77777) then TRMINW = .;
	if RPAD020 = 1 and (PAD080 = 99999 or PAD080 = 77777) then TRMMPW = .;
 
    	else if RPAD020 = 1 and (1 <= PAQ050Q <= 124) and (1 <= PAD080 <= 600)
		then do;         
 
            if PAQ050U = 1 then TRMINW =(PAD080*TRNUMTIM)*7;                                               
          	else if PAQ050U = 2 then TRMINW =(PAD080*TRNUMTIM);                                           
          	else if PAQ050U = 3 then TRMINW =(PAD080*TRNUMTIM/4.33);                                         
          	TRMMPW = TRMINW*4; 

		end;       
 
*Label newly created variables;
		label 	TRMMPW = 'Transportation MET min/wk'                                                             
          		TRMINW = 'Transportation min/wk'                                                                  
          		TRNUMTIM = 'Recoded/capped number of times for transportation';  
run;


*-------------------------------------------------------------------------;
* Create Leisure-time MET minutes per week (LTMMPW) - use MET values in   ;
* PAQIAF data (PADMETS).  Also create leisure-time min/wk (LTMINW)        ;
*  PADMETS: MET score for activity                                        ;
*  PADTIMES: # of times did activity in past 30 days                      ;
*  PADDURAT: Average duration of activity in minutes                      ;
*-------------------------------------------------------------------------; 

**************************************************************************;

*Note: We calculate Leisure-time activity separately from Transportation
and Household/Yard because participants are only found in the PAQIAF file
if they were indicated in the PAQ as having engaged in leisure activity;

**************************************************************************;

data paqiaf;
 set paqiaf_c.paqiaf_c paqiaf_d.paqiaf_d;

*Calculate Mod/Vig MET minutes per month for each activity;
*initialize values to zero;
  MOD_LTMINM = 0;
  MOD_LTMMPM = 0;
  VIG_LTMINM = 0;
  VIG_LTMMPM = 0;

  
*moderate activities;
  if PADLEVEL = 1 then do;
    MOD_LTMINM = PADTIMES*PADDURAT;
    MOD_LTMMPM = PADMETS*MOD_LTMINM;
  end;

*vigorous activities;
  else if PADLEVEL = 2 then do;
    VIG_LTMINM = PADTIMES*PADDURAT;
    VIG_LTMMPM = PADMETS*VIG_LTMINM; 

  end;

run;

proc sort data = paqiaf;
 by SEQN;
run;

*Sum leisure-time minutes per month and the leisure-time MET minutes per month for 
 each study participant;

proc means data = paqiaf noprint;
 by SEQN;
 var MOD_LTMINM MOD_LTMMPM VIG_LTMINM VIG_LTMMPM;
 output out = byid sum = MOD_LTMINM MOD_LTMMPM VIG_LTMINM VIG_LTMMPM; 
run;


data byid (keep = SEQN MOD_LTMINM MOD_LTMMPM VIG_LTMINM VIG_LTMMPM MOD_LTMINW 
           MOD_LTMMPW VIG_LTMINW VIG_LTMMPW LTMINW LTMMPW);
 set byid;
 by SEQN;

*change per month to per week;
  MOD_LTMINW = MOD_LTMINM/4.33;
  MOD_LTMMPW = MOD_LTMMPM/4.33;
  VIG_LTMINW = VIG_LTMINM/4.33;
  VIG_LTMMPW = VIG_LTMMPM/4.33;

*Sum leisure activity based on moderate+vigorous;

  LTMINW = MOD_LTMINW + VIG_LTMINW;
  LTMMPW = MOD_LTMMPW + VIG_LTMMPW;

*Label newly created variables;
	label MOD_LTMMPW = 'Moderate Leisure-Time MET min/wk'
          MOD_LTMINW = 'Moderate Leisure-Time min/wk'
          VIG_LTMMPW = 'Vigorous Leisure-Time MET min/wk'
          VIG_LTMINW = 'Vigorous Leisure-Time min/wk'
          LTMINW = 'Sum of MVPA Leisure-Time min/wk'
		  LTMMPW = 'Sum of MVPA Leisure-Time MET min/wk'; 
run;


*Merge the "paq" and "byid" datasets to create a new dataset "paq", which includes 
 transportation, household/yard, and leisure-time activity; 

proc sort data = paq; 
 by SEQN; 
run;

proc sort data = byid; 
 by SEQN; 
run;
 
data paq;         
 merge paq byid; 
 by SEQN; 
run; 

data paq;                                                                        
 set paq;                                                                       
 by SEQN;                                                                     
                                                                                  
 if LTMMPW = 0 then LTMINW = 0;                                                      
 if HHMMPW = 0 then HHMINW = 0;                                                      
 if TRMMPW = 0 then TRMINW = 0;      

 if RPAD320 = 2 and RPAD200 = 2 then MOD_LTMINW = 0;
 if RPAD320 = 2 and RPAD200 = 2 then MOD_LTMMPW = 0;

 if RPAD320 = 2 and RPAD200 = 2 then VIG_LTMINW = 0;
 if RPAD320 = 2 and RPAD200 = 2 then VIG_LTMMPW = 0; 

 if RPAD320 = 2 and RPAD200 = 2 then LTMMPW = 0;
 if RPAD320 = 2 and RPAD200 = 2 then LTMINW = 0;

 TOTMMPW = sum(HHMMPW, TRMMPW, LTMMPW);
 label TOTMMPW ='Total MVPA MET min/wk'; 

 TOTMINW = sum(HHMINW, TRMINW, LTMINW);                                                
 label TOTMINW ='Total MVPA min/wk'; 

 *Create a variable to describe Physical Activity Guidelines Minutes per week.  
  Recall that vigorous intensity activities yield twice the benefit of moderate 
  intensity activities;

 PAG_MINW = (VIG_LTMINW*2)+ MOD_LTMINW + HHMINW + TRMINW; 
 label PAG_MINW = 'Physical Activity Guidelines  - Minutes per Week';
     
run;                                                                             

**************************************************************************;
*EVALUATE MISSING DATA                                                    ;
**************************************************************************;

proc freq data=paq;
 where WTINT4CD > 0 and RIDAGEYR >= 12;
 tables RPAD020/list missing; 
run;                                      

proc freq data=paq;
 where WTINT4CD > 0 and RIDAGEYR >= 16;
 tables RPAQ100/list missing; 
run;                                      

proc freq data=paq;
 where WTINT4CD > 0 and RIDAGEYR >= 12;
 tables RPAD200/list missing; 
run;     

proc freq data=paq;
 where WTINT4CD > 0 and RIDAGEYR >= 12;
 tables RPAD320/list missing; 
run;     
                                    
**************************************************************************;
*IDENTIFY OUTLIERS AND EVALUATE THEIR IMPACT                              ;
**************************************************************************;

*Identify study participants with implausible data values (i.e., where 
 TOTMINW > 10080). Notably, no study participant exceeds 10080 total MVPA
 min/wk;

proc freq data=paq;
 tables TOTMINW*SEQN/list;
 where WTINT4CD > 0 and RIDAGEYR >= 16 and TOTMINW > 10080;
run;

data paq;
 set paq;
 if TOTMINW > 10080 then delete;
run;


*Use the PROC UNIVARIATE procedure to get all default descriptive statistics 
 such as mean, minimum and maximum values, standard deviation, and skewness.  
 Use the VAR statement to identify the variable of interest.  Use the ID 
 statement to list the sequence numbers associated with extreme values in 
 the output.;

ods rtf file = "c:/nhanes/output/univariate_TOTMINW.rtf";

proc univariate data=paq normal plot;
 var TOTMINW;
 where WTINT4CD > 0 and RIDAGEYR >= 16;
 id seqn; 
 title 'Distribution of Total MVPA min/wk among study participants aged 16 and older';
run;

ods rtf close;

*Use the PROC GPLOT procedure to plot the Total MVPA
 Minutes per Week (TOTMINW) by the corresponding sample weight for each 
 observation in the dataset.  SYMBOL and HEIGHT are option statements used to
 format the output of the plot. Set 7560 minutes per week as the maximum allowable
 volume of weekly activity based on a maximum of 18 hours per day.;

symbol1 value = dot height= .2;
ods rtf file = "c:/nhanes/output/weight_outliers_TOTMINW.rtf";
title;

proc gplot data = paq;
 plot WTINT4CD*TOTMINW/href = 7560 frame;
 where WTINT4CD > 0 and RIDAGEYR >= 16;
run;

ods rtf close;

*Use the IF, THEN, and DELETE statements in the DATA step to delete the 
 identified outliers where TOTMINW > 7560.  Use the PROC MEANS 
 procedure to determine the mean and standard error for the dataset both with
 and without excluding the outlier values.;

proc freq data=paq;
 tables TOTMINW*SEQN/list;
 where WTINT4CD > 0 and RIDAGEYR >= 16 and TOTMINW > 7560;
run;

data exclude_SP;
 set paq;
 if WTINT4CD > 0 and RIDAGEYR >= 16 and TOTMINW > 7560 then delete;   
run;

proc format;
 value GENDERF 1='Male'
               2='Female';

proc means data = paq mean stderr maxdec = 1;
 title 'No Exclusions';
 var TOTMINW;
 class RIAGENDR;
 weight WTINT4CD;
 format RIAGENDR GENDERF.;
run;

proc means data = exclude_SP mean stderr maxdec = 1;
 title 'Outlier Exclusion';
 var TOTMINW;
 class RIAGENDR;
 weight WTINT4CD;
 format RIAGENDR GENDERF.;
run;

**************************************************************************;
*FORMAT AND LABEL VARIABLES;
**************************************************************************;	

*For the PAQ_MINW variable, assign 3 levels of guideline adherenc to 
 identify study participants who are below, meet, or exceed guideline 
 recommendations. The PROC FORMAT procedure assigns text names to the 
 numeric values of the FOODGRPF format.;

data paq;
 set paq;
 if PAG_MINW < 150 then ADHERENCE = 1;
 if PAG_MINW >= 150 and PAG_MINW < 300 then ADHERENCE = 2;
 if PAG_MINW >= 300 then ADHERENCE = 3;
run;

*The LABEL statement applies a text description to the variable ADHERENCE;
data paq;
 set paq;
 label ADHERENCE = "Level of adherence to 2008 Physical Activity Guidelines for Americans";
run;

proc format;
 value ADHERENCEF
        1 = "Below"
        2 = "Meets"
        3 = "Exceeds";
run;

**************************************************************************;
*SAVE A PERMANENT DATASET                                                 ;
**************************************************************************;

*Save your permanent dataset to the 'nhanes' library created at the start of the tutorial;
data nhanes.paqmstr;   
 set paq;            
run;          


