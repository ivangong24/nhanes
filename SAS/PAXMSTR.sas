***********************************************************************;
***********************************************************************;
* This program was created to calculate several outcome variables from ;
* the minute-by-minute accelerometer data from NHANES 2003-2004 and    ;
* 2005-2006. The outcomes are mean total counts per day, mean          ;
* counts/min per day, and time above specified intensity thresholds,   ;
* in defined bouts and accumulation of every minute above threshold.   ;
***********************************************************************;
***********************************************************************;

* TASK 1 - LOCATE FILES AND VARIABLES;

*-------------------------------------------------------------------------;
* In Task 1, you will locate the demographic and accelerometer data       ; 
* files needed to build the analytic PAM dataset.                         ;
*-------------------------------------------------------------------------;

*TASK 2 - DOWNLOAD DATA;

*-------------------------------------------------------------------------;
* To build the "PAM" dataset, you will need to download the DEMO and      ;
* PAX files from the 2003-2004 and 2005-2006 cycles.                      ;  
* Use the XPORT engine to convert the .xpt files from the SAS transport   ;
* format to the standard SAS dataset format so that the data are useable  ;
* for analysis.  Run a proc contents statement in SAS to check that your  ;
* dataset contains the correct number of observations and variables       ;
* based on information provided in the documentation.                     ;
*-------------------------------------------------------------------------; 

libname demo_c xport   'c:\nhanes\download\demo_c.xpt';
libname paxraw_c xport 'c:\nhanes\download\paxraw_c.xpt';

libname demo_d xport   'c:\nhanes\download\demo_d.xpt';
libname paxraw_d xport 'c:\nhanes\download\paxraw_d.xpt';

*Your final dataset will be stored in this directory;

libname nhanes 'c:\nhanes\data';

*Run proc contents to confirm that your dataset contains the correct      ;
* number of observations/variables                                        ;

proc contents data = demo_c.demo_c;
run;
proc contents data = paxraw_c.paxraw_c;
run;
proc contents data = demo_d.demo_d;
run;
proc contents data = paxraw_d.paxraw_d;
run;



proc sort data = demo_c.demo_c out = demo_c;
by seqn;
run; 
proc sort data = paxraw_c.paxraw_c out = paxraw_c;
by seqn;
run;
proc sort data = demo_d.demo_d out = demo_d;
by seqn;
run;  
proc sort data = paxraw_d.paxraw_d out = paxraw_d;
by seqn;
run; 


*TASK 3 - MERGE AND APPEND DATASETS;

*-------------------------------------------------------------------------;
* In Task 3, you will merge the DEMO and PAXRAW data from the 2003-2004   ; 
* and 2005-2006 cycles. You will also check the PAXRAW data as you merge  ;
* to only include observations that are complete (10080 minutes), where   ;
* the accelerometer was in calibration (PAXCAL=1), and the data is deemed ;
* reliable (PAXSTAT=1).                                                   ;
*-------------------------------------------------------------------------;

* Run proc means to generate a count of the minutes in data for each participant;

proc means noprint data = paxraw_c(where=(PAXSTAT=1 and PAXCAL=1));
    by SEQN;
    var paxn;
    output out=chka n=n;
run;
proc means noprint data = paxraw_d(where=(PAXSTAT=1 and PAXCAL=1));
    by SEQN;
    var paxn;
    output out=chkb n=n;
run;

* Create a dataset for complete data and one for incomplete data (n<10080;
* These datasets will be used to determine observations in the master dataset;

data OK notOK;
    set chka chkb;
    if (n=10080) then output OK;
    else output  notOK;
run;

proc contents data = notOK;
run;

proc contents data = OK;
run;

data temp;
    set paxraw_c(where=(PAXSTAT=1 and PAXCAL=1))  paxraw_d(where=(PAXSTAT=1 and PAXCAL=1));
run;

* This step creates the accelerometer dataset with complete records
  and adds a variable for the sequential day of data collection (1-7;

data monitors; 
  merge temp OK(in=inOK drop=n _TYPE_ _FREQ_);
  by SEQN;
  day=ceil(paxn/1440);
  label day='Sequential Day';
  if inOK;
run;

data demo; 
  set demo_c demo_d;
run;

proc sort data=demo;
  by seqn;
run;

* This step merges only the age variable from the demo file because it will be needed to assign certain  ;
* age-specific criteria. The rest of the demo file is not included because of the intensive data         ;
* manipulation steps to follow. Other demographic variables will be added later.                         ;

data monitors;
  merge monitors (in=m) demo (in=d keep=seqn ridageyr);
  by seqn;
  if m and d;
run;


*TASK 4 - CREATE NEW VARIABLES AND REVIEW ;

proc sort data=monitors;
  by seqn day paxn;
run;


*---------------------------------------------------------------------------------------------------------*;
* Macro %nw defines the duration of non-wear periods as well as wear periods within a day based on user   *;
* defined minimum length of non-wear period.                                                              *;
*                                                                                                         *;
* A non-wear period starts at a minute with the intensity count of zero. Minutes with intensity count=0 or*;
* up to 2 consecutive minutes with intensity counts between 1 and 99 are considered to be valid non-wear  *;
* minutes. A non-wear period is established when the specified length of consecutive non-wear minutes is  *;
* reached. The non-wear period stops when any of the following conditions is met:                         *;
*  - one minute with intensity count >99                                                                  *;
*  - one minute with a missing intensity count                                                            *;
*  - 3 consecutive minutes with intensity counts between 1 and 99                                         *;
*  - the last minute of the day                                                                           *;
*                                                                                                         *;
* Macro call %nw(nwperiod=);                                                                              *;
* nwperiod: minimum length for the non-wear period, must be >1 minute.                                    *;
*---------------------------------------------------------------------------------------------------------*;

%macro nw(nwperiod=);
data nw_all;
  set monitors;
  by seqn day paxn;

  if first.day then nw_num=0;    /*non-wear period number*/

  if first.day or reset or stopped then do;
     strt_nw=0;      /*starting minute for the non-wear period*/
     end_nw=0;       /*ending minute for the non-wear period*/
     start=0;        /*indicator for starting to count the non-wear period*/
     dur_nw=0;       /*duration for the non-wear period*/
     reset=0;        /*indicator for resetting and starting over*/
     stopped=0;      /*indicator for stopping the non-wear period*/
     cnt_non_zero=0; /*counter for the number of minutes with intensity between 1 and 99*/
  end;
  retain nw_num strt_nw end_nw stopped reset start cnt_non_zero dur_nw;

  /*The non-wear period starts with a zero count*/
  if paxinten=0 and start=0 then do;
        strt_nw=paxn;    /*assign the starting minute of non-wear*/
        start=1;
  end;

  /*accumulate the number of the non-wear minutes*/
  if start and paxinten=0 then
     end_nw=paxn;         /*keep track of the ending minute for the non-wear period*/

  /*keep track of the number of minutes with intensity between 1-99*/
  if 0<paxinten<=99 then
     cnt_non_zero=cnt_non_zero+1;

  /*before reaching the 3 consecutive minutes of 1-99 intensity, if encounter one minute with zero intensity, reset the counter*/
  if paxinten=0 then cnt_non_zero=0;

  /*duration of non-wear period*/
  dur_nw=end_nw-strt_nw+1;

  /*A non-wear period ends with 3 consecutive minutes of 1-99 intensity, one missing count, or one minute with >99 intensity*/
  if (cnt_non_zero=3 or paxinten=. or paxinten>99 ) then do;
    if dur_nw<&nwperiod then reset=1;       /*reset if less than &nwperiod minutes of non-wear*/
    else stopped=1;
  end;

  /*last minute of the day*/
  if last.day and dur_nw>=&nwperiod then stopped=1;

  /*output one record for each non-wear period*/
  if stopped=1 then do;
       nw_num=nw_num+1;
       keep seqn day nw_num strt_nw end_nw dur_nw;
       output;
  end;
run;

*---------------------------------------------------------------------*;
*summarize the non-wear periods to one record per day                 *;
*---------------------------------------------------------------------*;
proc summary data=nw_all ;
  by seqn day;
  var dur_nw ;
  output out=sum_nw
       sum=tot_dur_nw;
run;

*-------------------------------------------------------------------------*;
*summarize the total number of valid minutes for everyone in the analysis.*;
*-------------------------------------------------------------------------*;
proc summary data=monitors;
  by seqn day ridageyr paxday;
  var paxinten;
  output out=sum_all
         n=tot_min;
run;

*----------------------------------------------------------------------------*;
*create a dataset with one record per minute, for non-wear periods only      *;
*----------------------------------------------------------------------------*;
data nw_minutes(keep=seqn day paxn);
  set nw_all;
  by seqn day nw_num;
  do i=strt_nw to end_nw by 1;
     paxn=i;
     output;
  end;
run;

*----------------------------------------------------------------------------*;
*create a dataset with one record per minute, for wear periods only          *;
*----------------------------------------------------------------------------*;
data wear_minute(keep=seqn day paxn paxinten);
  merge monitors(in=in_all) nw_minutes(in=in_nw);
  by seqn day paxn;
  if in_all and not in_nw;
run;

/*summarize information from wear minutes */
proc summary data=wear_minute;
  by seqn day;
  var paxinten;
  output out=sum_wear
         sum=tot_cnt_wr
         n=tot_min_wr;
run;

*-------------------------------------------------------------------------*;
* creates dataset with one record per day for everyone with monitor data  *;
* that includes summary variables from the non-wear algorithm             *;
*-------------------------------------------------------------------------*;
data nw&nwperiod;
  merge sum_all(in=in_all) sum_nw(in=in_nw) sum_wear;
  by seqn day;
  if in_all;

  if tot_dur_nw=. then tot_dur_nw=0;
  if tot_min_wr=. then tot_min_wr=0;
  if tot_cnt_wr=. then tot_cnt_wr=0;

  wear_hr=tot_min_wr/60;
  tot_dur_nw=tot_dur_nw/60;
  label
  tot_dur_nw='Total duration(hr) of non-wear periods in a day'
  wear_hr='Total number of wear hours for the day'
  tot_min='Total number of valid minutes within a day'
  tot_cnt_wr='Total intensity counts from all wear minutes in a day'
  tot_min_wr='Total number of wear minutes in a day'
  ;
  keep seqn paxday day ridageyr tot_min tot_min_wr wear_hr tot_cnt_wr tot_dur_nw;
run;

%mend nw;

%nw(nwperiod=60);    /* this is where the duration criterion for a non-wear period is set */

*-----------------------------------------------------------------------------------------------*;
* Makes a shell data set the same size as monitors that generates a data flag for every minute  *;
* as a wear minute or a nonwear minute. This flag is merged into the monitors dataset and will  *;
* be used below to classify intensity. The shell data set is then deleted                       *;
*-----------------------------------------------------------------------------------------------*;

data wear_shell; 
    retain last_stop 0; 
    set nw_all(drop=day nw_num dur_nw); 
    by SEQN; 
    if first.SEQN then do; 
        last_stop=0; 
        end; 
    do paxn=last_stop+1 to strt_nw-1; 
        __wear__ = 1; 
        output; 
        end; 
    do paxn=strt_nw to end_nw; 
        __wear__ = 0; 
        output; 
        end; 
    last_stop = end_nw; 
    if last.SEQN then do; 
        if (end_nw < 10080) 
            then do paxn=end_nw+1 to 10080; 
            __wear__=1; 
            output; 
            end; 
        end; 
    keep SEQN paxn __wear__;
run;

data monitors; 
    merge monitors wear_shell; 
    by SEQN paxn; 
run;

proc datasets nolist; 
    delete wear_shell; 
run;

*-----------------------------------------------------------------------------------------------*;
* Code below classifies intensity of each minute of monitor data by comparing paxinten to       *; 
* user-definable intensity thresholds. In some cases, intensity criteria are age-specific.      *;
*                                                                                               *;
* NOTE: to change the intensity thresholds, modify the statements below for these variables     *;
*      sedthresh (sedentary threshold)                                                          *;
*      lightthresh (light threshold)                                                            *;
*      lifethresh (lifestyle moderate threshold)                                                *; 
*      modthresh(moderate threshold) and                                                        *;
*      vigthresh(vigorous threshold).                                                           *;
*-----------------------------------------------------------------------------------------------*;

data monitors;
  set monitors;

  * sedentary threshold *;
  sedthresh=0;

  * light threshold *;
  lightthresh = 100;

 * lifestyle moderate threshold is only defined for adults   ;
  if (ridageyr >= 18 ) then lifethresh = 760;
  else lifethresh=modthresh;

  * moderate threshold *;
  if      ridageyr=6  then modthresh=1400;
  else if ridageyr=7  then modthresh=1515;
  else if ridageyr=8  then modthresh=1638;
  else if ridageyr=9  then modthresh=1770;
  else if ridageyr=10 then modthresh=1910;
  else if ridageyr=11 then modthresh=2059;
  else if ridageyr=12 then modthresh=2220;
  else if ridageyr=13 then modthresh=2393;
  else if ridageyr=14 then modthresh=2580;
  else if ridageyr=15 then modthresh=2781;
  else if ridageyr=16 then modthresh=3000;
  else if ridageyr=17 then modthresh=3239;
  else if ridageyr>=18 then modthresh=2020;

  * vigorous threshold *;
  if      ridageyr=6  then vigthresh=3758;
  else if ridageyr=7  then vigthresh=3947;
  else if ridageyr=8  then vigthresh=4147;
  else if ridageyr=9  then vigthresh=4360;
  else if ridageyr=10 then vigthresh=4588;
  else if ridageyr=11 then vigthresh=4832;
  else if ridageyr=12 then vigthresh=5094;
  else if ridageyr=13 then vigthresh=5375;
  else if ridageyr=14 then vigthresh=5679;
  else if ridageyr=15 then vigthresh=6007;
  else if ridageyr=16 then vigthresh=6363;
  else if ridageyr=17 then vigthresh=6751;
  else if ridageyr>=18 then vigthresh=5999;

  * sedentary activity *;
  if (__wear__ = 1 and sedthresh <= paxinten < lightthresh) then _s=1;
  else if paxinten ne . then _s=0;

  * light activity *;
  if (lightthresh <= paxinten < lifethresh) then _l=1;
  else if paxinten ne . then _l=0;

  * lifestyle moderate activity - for adults only *;
  if ridageyr >= 18 then do;
   if (lifethresh <= paxinten < modthresh) then _ls=1;
   else if paxinten ne . then _ls=0;
  end;

  * moderate or vigorous activity *;
  if paxinten >= modthresh then _mv=1;
  else if paxinten ne . then _mv=0;

  * moderate activity *;
  if modthresh <= paxinten < vigthresh then _m=1;
  else if paxinten ne . then _m=0; 

  * vigorous activity *;
  if paxinten >= vigthresh then _v=1;
  else if paxinten ne . then _v=0;
  
  * non-wear *;
  if __wear__ = 0 then _nw=1;
  else _nw=0;
  
run;

proc sort data=monitors; 
  by seqn day paxn; 
run;

*-----------------------------------------------------------------------------------------------*;
* Activity bouts are defined by specified number of consecutive minutes with intensity count >= *; 
* the relevant intensity threshold.                                                             *;
* Two separate bout macros are used below, the first flags bouts of 1 minute or more to allow   *;
* a sum of all minutes above threshold. The second looks for bouts of 8-10 minutes or more.     *;
*-----------------------------------------------------------------------------------------------*;

*-----------------------------------------------------------------------------------------------*;
* An activity bout starts at a minute with an intensity count greater than or equal to the      *;
* threshold. Minutes with intensity count greater than or equal to the threshold are considered *;
* to be valid minutes for the activity bout. A bout is established when the specified length of *;
* consecutive valid minutes are reached. The activity bout stops when any of the following      *;
* conditions is met:                                                                            *;
*  - one minute with intensity < threshold                                                      *;
*  - one minute with a missing intensity count                                                  *;
*  - the last minute of the day                                                                 *;
*-----------------------------------------------------------------------------------------------*;

*----------------------------------------------------------------------------------*;
* Macro %bouts defines duration of activity bouts based on user defined minimum    *;
* bout length.                                                                     *;
*                                                                                  *;
* Macro call %bouts(bout_flg=,boutperiod=);                                        *;
* bout_flg: variable name for activity bout intensity: _s(sedentary), _l(light),   *;
*  _ls(lifestyle moderate), _mv(moderate or vigorous), _m(moderate), _v(vigorous), *;
* and _nw(non-wear)                                                                *;
* boutperiod: minimum bout length (1 minute, 2 minutes, 3 minutes, etc)            *;
*----------------------------------------------------------------------------------*;
%macro bouts(bout_flg=,boutperiod=);
data out&bout_flg&boutperiod;
  set monitors;
  by seqn day paxn;
  if first.day then mv_num=0;                      * number of activity bouts *;

  if first.day or reset or stopped then do;
     strt_mv=0;     * starting minute for the activity bout *;
     end_mv=0;      * ending minute for the activity bout *;
     start=0;       * indicator for starting the activity bout *;
     reset=0;       * indicator for resetting and starting over *;
     mv_cnt=0;      * number of minutes for the activity bout *;
     stopped=0;     * indicator for stopping the activity bout *;
  end;
  retain mv_num strt_mv end_mv mv_cnt stopped reset start;


  * start the bout when a count with intensity >= the threshold is encountered *;
  if &bout_flg=1 and start=0 then do;
        strt_mv=paxn;     * assign the starting minute of the bout *;
        start=1;
  end;

  * accumulate minutes with intensity counts >= the threshold *;
  if start=1 and &bout_flg=1 then do;
     mv_cnt=mv_cnt+1;
     end_mv=paxn;         * keep track of the ending minute for the bout *;
  end;

  * stop when encounter a minute with intensity < threshold or missing *;
  if &bout_flg in (0,.)  then  do;
     if mv_cnt<&boutperiod then reset=1;     * reset if less than the bout length *;
     else stopped=1;
  end;

  * last minute of the day *;
  if last.day and mv_cnt>=&boutperiod then stopped=1;

  * output one record for each activity bout *;
  if stopped=1 then do;
      dur_mv=end_mv-strt_mv+1;
      mv_num=mv_num+1;
      output;
  label
  strt_mv='Starting minute for the activity bout'
  end_mv='Ending minute for the activity bout'
  dur_mv='Duration(minutes) of activity bout'
  mv_num='Number of activity bout'
  ;
  end;
  keep seqn  day mv_num strt_mv end_mv dur_mv ;
run;

proc sort data=out&bout_flg&boutperiod;
  by seqn day mv_num;
run;

*-----------------------------------------------*;
*calculate total duration of activity bouts for *;
* each intensity for each day.                  *;
*-----------------------------------------------*;
proc summary data=out&bout_flg&boutperiod;
  by seqn day;
  var dur_mv;
  output out=sum_mv
         sum=tot_dur_mv;
run;

*-----------------------------------------------*;
* output one record per day for each person     *;
*-----------------------------------------------*;
data out&bout_flg&boutperiod._sum;
  merge sum_all(in=in_all) sum_mv;
  by seqn day;
  if in_all;
  if tot_dur_mv=. then tot_dur_mv=0;
  label
  %if &bout_flg=_s %then %do;
    tot_dur_mv="Total duration(minutes) of sedentary activity bouts (minimum &boutperiod minute bouts) in a day"
  %end; 
  %if &bout_flg=_l %then %do;
    tot_dur_mv="Total duration(minutes) of light activity bouts (minimum &boutperiod minute bouts) in a day"
  %end;
  %if &bout_flg=_ls %then %do;
    tot_dur_mv="Total duration(minutes) of lifestyle activity bouts (minimum &boutperiod minute bouts) in a day"
  %end;
  %if &bout_flg=_mv %then %do;
    tot_dur_mv="Total duration(minutes) of moderate or vigorous activity bouts (minimum &boutperiod minute bouts) in a day"
  %end;
  %if &bout_flg=_m %then %do;
    tot_dur_mv="Total duration(minutes) of moderate activity bouts (minimum &boutperiod minute bouts) in a day"
  %end;
  %if &bout_flg=_v %then %do;
    tot_dur_mv="Total duration(minutes) of vigorous activity bouts (minimum &boutperiod minute bouts) in a day"
  %end;
   ;

  keep seqn day tot_dur_mv;
  rename
  tot_dur_mv=tot_dur&bout_flg&boutperiod;
run;
%mend bouts;


*-------------------------------------------------------------------------------------*;
* the macro statements below set bout length (currently set to 1 min, which           *;
* accumulates every minute within an intensity category)                              *;
*-------------------------------------------------------------------------------------*;


  %bouts(bout_flg=_s,boutperiod=1);
  %bouts(bout_flg=_l,boutperiod=1);
  %bouts(bout_flg=_ls,boutperiod=1);
  %bouts(bout_flg=_mv,boutperiod=1);
  %bouts(bout_flg=_m,boutperiod=1);
  %bouts(bout_flg=_v,boutperiod=1);
  %bouts(bout_flg=_nw,boutperiod=1);



*---------------------------------------------------------------------------------------------*;
* Macro %bouts_8of10 defines activity bouts for 8 out of 10 minutes with intensity            *;
* count >= the specified threshold.                                                           *;
*                                                                                             *;
* An activity bout starts with a count that is greater than or equal to the threshold.        *;
* A bout is established when 8 minutes out of a 10 minute window have intensity counts greater*;
* than or equal to the threshold. The bout stops when any of the following conditions is met: *;
*   - 3 consecutive minutes with intensity < threshold                                        *;
*   - one minute with a missing intensity count                                               *;
*   - last minute of the day                                                                  *;
*                                                                                             *;
* Macro call %bouts_8of10(bout_flg=);                                                         *;
* bout_flg: variable name for activity bout intensity, _m(moderate), _v(vigorous),            *;
*           _mv(moderate or vigorous)    Other intensities can be specified for inclusion     *;
*---------------------------------------------------------------------------------------------*;
%macro bouts_8of10(bout_flg=);
data out&bout_flg;
  set monitors;
  by seqn day paxn;
  * set up a 10 minute window *;
  array win_paxn(*) win_paxn1-win_paxn10;   * minute *;
  array win_int(*) win_int1-win_int10;      * intensity *;
  array win_flg(*) win_flg1-win_flg10;      * bout flag *;

  if first.day then
     mv_num=0;             * number of activity bouts *;

  if first.day or stopped or reset then do;
     strt_mv=0;     * starting minute for the bout *;
     end_mv=0;      * ending minute for the bout *;
     found=0;       * set to 1 if a bout has been established *;
     reset=0;       * reset the counts and start over *;
     stopped=0;     * indicator for stopping the bout *;
     start=0;       * start set to 1 if one above the threshold count is encountered *;
     mv_cnt=0;      * number of minutes with counts >= the threshold *;
     sum10=.;       * the total intensity counts from the 10 minute window *;
     cnt_below=0;   * counter for number of minutes with intensity below the threshold *; 
     do i=1 to 10;   * initialize the 10 minute window *;
        win_paxn(i)=0;
        win_int(i)=0;
        win_flg(i)=0;
     end;
  end;
  retain mv_num reset strt_mv end_mv start mv_cnt  found stopped sum10 cnt_below;
  retain win_paxn1-win_paxn10;
  retain win_int1-win_int10;
  retain win_flg1-win_flg10;

  * if the intensity count is >= the threshold, start the bout *;
  if &bout_flg=1 and start=0 then
     start=1;

  * accumulate the counts *;
  if start=1 then mv_cnt=mv_cnt+1;

  * set up a moving window of 10 minutes *;
  if 1<=mv_cnt<=10 and not found then do;
       win_paxn(mv_cnt)=paxn;
       win_int(mv_cnt)=paxinten;
       win_flg(mv_cnt)=&bout_flg;
       if paxinten = . then reset=1; * if encounter a missing count before reaching the 10 minute count, reset and start again *;
   end;

   * when reach 10 minutes, count the total number of intensity counts that are >= threshold *;
   if mv_cnt=10 and not reset then sum10=sum(of win_flg1-win_flg10);

   * if 8 out of 10 minutes with intensity counts >= the threshold, a bout is established *;
   if sum10>=8 then found=1;

   * if less than 8 minutes with intensity counts>= the threshold, continue to search *;
   * move the 10-minute window down, one minute at a time *; 
   else if 0<sum10<8 and mv_cnt>10 then do;
     if paxinten=. then reset=1;      * if the 10th minute has a missing count, reset and start again *;
     else do;
          do i=1 to 9;
             win_paxn(i)=win_paxn(i+1);
             win_int(i)=win_int(i+1);
             win_flg(i)=win_flg(i+1);
          end;
          * read in minute 10 *;
          win_paxn(10)=paxn;
          win_int(10)=paxinten;
          win_flg(10)=&bout_flg;
          sum10=sum(of win_flg1-win_flg10);
     end;
   end;
   if sum10 in (0) then reset=1;               * skip the windows with no valid minutes *;

  * after the bout is established *;
  if found then do;
      * assign the starting minute for the activity bout *;
      if strt_mv= 0 then do;
         do i=1 to 10;
            if win_flg(i)=1 then  do;   * find the first minute with intensity count>=the threshold *;
               strt_mv=win_paxn(i);
               i=11;
            end;
         end;
      end;
      * assign the ending minute for the activity bout *;
      if end_mv=0 then do;
         * the last 2 minutes in the 10 minute window are below the threshold *;
         if win_flg(9)=0 and win_flg(10)=0 then do;
            end_mv= win_paxn(8);
            cnt_below=2;
         end;
          * the last minute in the 10 minute window is below the threshold *;
         else if win_flg(10)=0 then do;
            end_mv=win_paxn(9);
            cnt_below=1;
         end;
         else
            end_mv=win_paxn(10);
      end;
      if paxn>win_paxn(10) then do;
         if &bout_flg=1 then do;
            cnt_below=0;
            end_mv=paxn;
         end;
         if &bout_flg=0  then
            cnt_below=cnt_below+1;  * keep track of the number of minutes with intensity counts below the threshold *;
      end;
       * bout terminates if 3 consecutive minutes below the threshold are encountered, or a missing count, or the last minute of the day *;
      if cnt_below=3 or last.day or &bout_flg=. then stopped=1;
  end;
   * output one record for each activity bout *; 
  if stopped=1 then do;
      dur_mv=end_mv-strt_mv+1;
      mv_num=mv_num+1;
      keep seqn day mv_num strt_mv end_mv dur_mv;
      output;
  end;
run;
proc sort data=out&bout_flg;
  by seqn day mv_num;
run;

*------------------------------------------------*;
* calculate total duration of activity bouts for *;
* each day.                                      *;
*------------------------------------------------*;
proc summary data=out&bout_flg;
  by seqn day;
  var dur_mv;
  output out=sum_mv
         sum=tot_dur_mv;
run;

*------------------------------------------------*;
* output one record per day for each person in   *;
* the analysis.                                  *;
*------------------------------------------------*;
data out&bout_flg._sum;
  merge sum_all(in=in_all) sum_mv;
  by seqn day;
  if in_all;
  if tot_dur_mv=. then tot_dur_mv=0;
  label
  %if &bout_flg=_mv %then %do;
    tot_dur_mv="Total duration(min) of moderate or vigorous activity bouts (8 out of 10 minutes) in a day"
  %end;
  %if &bout_flg=_m %then %do;
    tot_dur_mv="Total duration(min) of moderate activity bouts (8 out of 10 minutes) in a day"
  %end;
  %if &bout_flg=_v %then %do;
    tot_dur_mv="Total duration(min) of vigorous activity bouts (8 out of 10 minutes) in a day"
  %end;
   ;

  keep seqn day tot_dur_mv;

  rename
  tot_dur_mv=tot_dur&bout_flg;
run;
%mend bouts_8of10;

%bouts_8of10(bout_flg=_mv);
%bouts_8of10(bout_flg=_v);
%bouts_8of10(bout_flg=_m);

*------------------------------------------------------------*;
* summarize to one record per person per day with duration   *;
* of non-wear and activity bouts                             *;
*------------------------------------------------------------*;

*--------------------------------------------------------------------*;
* The data set name nw60 below is based on the value for nwperiod    *;
* and will change if a non-wear criterion other than 6o min is used  *;
*--------------------------------------------------------------------*;


data pam_perday; 
  merge nw60                
        out_mv_sum out_v_sum out_m_sum
        out_s1_sum out_l1_sum out_ls1_sum out_mv1_sum out_m1_sum out_v1_sum out_nw1_sum;
  by seqn day;
run;

*-------------------------------------------------------------------------------------------*;
* Copy the work dataset pam_perday to the folder referenced by the libname statement above. *;
*-------------------------------------------------------------------------------------------*;
data nhanes.pam_perday;
  set pam_perday;
run;

proc contents data=nhanes.pam_perday;
run;

*------------------------------------------------------------------------------------------*;
* You have now created a dataset that has one record per person per day. It contains the   *;
* variables listed in pam_perday_contents.doc. It will be used to create a dataset with    *;
* one record per person, and it may also be used for other day-level analyses.             *;      
*------------------------------------------------------------------------------------------*;



*-------------------------------------------------------------------------------------------*;
* The code below will summarize valid PAM data into one record per person, add demographic  *;
*          variables, and output a permanent SAS data set.                                  *;
*  A valid day is a day in which the subject wore the monitor for 10+ hours.                *;
*  A valid person is a person with 4+ valid days.                                           *;
*  Please see comments below on how to change the definitions of valid day and valid person.*;
*-------------------------------------------------------------------------------------------*;


*----------------------------------------------------------------*;
*Formats for the PAM analytic data                               *;
*----------------------------------------------------------------*;
proc format;

value yesno
  1='Yes'
  0='No';

value wkday
  1='Sunday'
  2='Monday'
  3='Tuesday'
  4='Wednesday'
  5='Thursday'
  6='Friday'
  7='Saturday';

value gender
  1='Male'
  2='Female';

value agegrp
  0='All'
  1='6-11'
  2='12-15'
  3='16-19'
  4='20-29'
  5='30-39'
  6='40-49'
  7='50-59'
  8='60-69'
  9='70+';
run;

*-----------------------------------------------------------------------*;
* Define a valid day and a valid person.                                *;
* NOTE: to change the definitions on the number of wear hours(wear_hr)  *;
*       required for a valid day, or the number of valid days(valdays)  *;
*       required for a valid person, please modify the statements below.*;
*-----------------------------------------------------------------------*;
data pam_day;
  set pam_perday;
  valid_day=(wear_hr>=10);  * assign valid day hours criterion here *;
  format valid_day yesno.;
  label valid_day='10+ hours of wear (yes/no)';
run;

proc summary data=pam_day;
  by seqn;
  var seqn;
  where valid_day=1;
  output out=valid
         n=valdays;     * number of days with 10+ hours of wear *;
run;

data pam_day;
  merge pam_day(in=inall) valid;
  by seqn;
  if inall;

  if valdays=. then valdays=0;
  label valdays='Number of days with 10+ hours of wear';

  valid_person=(valdays>=4);  * assign valid person days criterion here *;
  format valid_person yesno.;
  label valid_person = 'At least 4 days with 10+ hours of wear (yes/no)';

  drop _freq_ _type_;

run;

*--------------------------------------------------------------------------------------------*;
* Summarize for valid persons (4+ valid days), using only their valid days (10+ hrs of wear) *;
*--------------------------------------------------------------------------------------------*;
proc summary data=pam_day;
  by seqn;
  where valid_person=1 and valid_day=1;
  var tot_dur_mv tot_dur_mv1
      tot_dur_m tot_dur_m1
      tot_dur_v tot_dur_v1
      tot_dur_s1 tot_dur_l1 tot_dur_ls1 tot_dur_nw1
      tot_min_wr tot_cnt_wr;
  output out=valid_days
  mean(tot_dur_mv tot_dur_mv1
      tot_dur_m tot_dur_m1
      tot_dur_v tot_dur_v1
      tot_dur_s1 tot_dur_l1 tot_dur_ls1 tot_dur_nw1
      tot_min_wr tot_cnt_wr)=
      allmean_mv allmean_mv1  
      allmean_m allmean_m1    
      allmean_v allmean_v1    
      allmean_sed1            
      allmean_light1          
      allmean_lifemod1        
      allmean_nonwear1        
      allmean_min_wr        
      allmean_cnt
  sum(tot_min_wr tot_cnt_wr)=all_min_wr all_cnt_wr;
run;



data valid_days;
  set valid_days;
  allmean_cnt_wr=all_cnt_wr/all_min_wr;
  allmean_hr_wr=allmean_min_wr/60;
  label
  allmean_cnt='Mean total counts per day from all valid days'
  allmean_cnt_wr='Mean intensity count per minute for wear periods from all valid days'
  allmean_hr_wr='Mean wear time (hr) per day from all valid days'
  allmean_mv='Mean duration (minutes) of moderate and vigorous activity bouts (8 out of 10 minute bouts) per day from all valid days'
  allmean_m='Mean duration (minutes) of moderate activity bouts (8 out of 10 minute bouts) per day from all valid days'
  allmean_v='Mean duration (minutes) of vigorous activity bouts (8 out of 10 minute bouts) per day from all valid days'
  allmean_mv1='Mean duration (minutes) of accumulated moderate and vigorous activity per day from all valid days'
  allmean_m1='Mean duration (minutes) of accumulated moderate activity per day from all valid days'
  allmean_v1='Mean duration (minutes) of accumulated vigorous activity per day from all valid days'
  allmean_sed1='Mean duration (minutes) of accumulated sedentary activity per day from all valid days'
  allmean_light1='Mean duration (minutes) of accumulated light activity per day from all valid days'
  allmean_lifemod1='Mean duration (minutes) of accumulated lifestyle moderate activity per day from all valid days'
  allmean_nonwear1='Mean duration (minutes) of non-wear per day from all valid days';
  drop _type_  _freq_ allmean_min_wr;
run;

* everyone in the analysis for 2003-2006 *;
proc sort data=pam_day out=pam_all nodupkey;
  by seqn;
run;

* merge with the valid day data and demographic data for final data set *;
data pam;
  merge pam_all(in=in_pam keep=seqn valid_person valdays) demo(in=in_demog) valid_days;
  by seqn;
  if in_pam;
  if not in_demog then put 'error: not in demog' seqn=;

  keep seqn valid_person valdays  allmean_mv allmean_mv1 allmean_m allmean_m1 allmean_v allmean_v1 allmean_cnt_wr allmean_hr_wr
       allmean_sed1 allmean_light1 allmean_lifemod1 allmean_nonwear1 allmean_cnt;
run;

*--------------------------------------------------------------------------*;
* You have now created the dataset with one record per person. It may be   *;
* used in person level analysis for the PAM data.                          *;
*--------------------------------------------------------------------------*;

proc contents varnum data=pam;
run;

* quick check on data;
proc means n nmiss min max mean data=pam;
run;

data nhanes.pam;
  set pam;
  by seqn;
  run;

*Merge remaining demographic data. Set working dataset name as 'paxmstr'.;
data paxmstr;
  merge demo nhanes.pam;
  by seqn;
  if WTMEC2YR < 0 then delete;

run;

*Create appropriate weight variable.;
data paxmstr (DROP = WTMEC2YR);
  set paxmstr;
  WTMEC4CD = WTMEC2YR/2;
run;

*Review data for outliers.;
ods rtf file = "c:/nhanes/output/univariate_ALLMEAN_CNT.rtf";

proc univariate data=paxmstr normal plot;
 var allmean_cnt;
 where ridageyr > 20 and ridageyr <60;
 id seqn; 
 title 'Distribution of Mean total counts per day from all valid days';
run;

ods rtf close;
****;
ods rtf file = "c:/nhanes/output/univariate_ALLMEAN_MV.rtf";

proc univariate data=paxmstr normal plot;
 var allmean_mv;
 where ridageyr > 20 and ridageyr <60;
 id seqn; 
 title 'Distribution of mean duration (minutes) of moderate and vigorous activity bouts (8 out of 10 minute bouts) per day from all valid days';
run;

ods rtf close;
****;

symbol1 value = dot height= .2;

ods rtf file = "c:/nhanes/output/weight_outliers_ALLMEAN_CNT.rtf";
title;

proc gplot data = paxmstr;
 plot WTMEC4CD*allmean_cnt/frame;
 where ridageyr > 20 and ridageyr <60;
run;

ods rtf close;

****;
symbol1 value = dot height= .2;

ods rtf file = "c:/nhanes/output/weight_outliers_ALLMEAN_MV.rtf";
title;

proc gplot data = paxmstr;
 plot WTMEC4CD*allmean_mv/frame;
 where ridageyr > 20 and ridageyr <60;
run;

ods rtf close;

*Save a permanent dataset;
data nhanes.paxmstr;
set paxmstr;
run;

