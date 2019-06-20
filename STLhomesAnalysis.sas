options macrogen mprint dquote dtreset;
options ls=156 ps=44 sysprintfont=( "SAS Monospace" 8 ) pageno=1 orientation="landscape"
    topmargin=0 bottommargin=0 leftmargin=.5 rightmargin=.5 printerpath=(pdf outlist);

*** Set file destination for output "printed" from output window without ods control;

 filename outlist "E:\6345w18\FinalProject\FinalProjectOutput.pdf";

** set path to library (folder) that will contain permanent SAS datasets;

  libname sasds 'E:\6345w18\FinalProject';

**IMPORT HOUSING DATA;

PROC IMPORT OUT= WORK.HousingData1 
            DATAFILE= "E:\6345w18\FinalProject\HousingData1.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
**LISTS ALL VARIABLES AND TYPE;

proc contents data=HousingData1;
title '2008 Apprasial Data from STL County Website';
run;
**SUMMARY STATISTICS;

PROC MEANS DATA=HousingData1 n nmiss sum mean min max;
run;

*********************************************************************************
FULL MODEL - ALL SCHOOL DISTRICTS
*********************************************************************************

* REGRESSION MODEL;
proc reg data=HousingData1 outest=Fullmodel plots=none;
title "Full Comprehensive Model";
model APRTOT = STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_BUNGLOW STYLE_COLONIAL YRBLT RMTOT RMBED FIXBATH FIXHALF FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL FUEL_WOOD FUEL_SOLAR HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER HEATSYS_RADIANT WOODBURN_FP SFLA GRADE_X GRADE_A GRADE_B CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE AFFTON BAYLESS BRENTWOOD CLAYTON PARKWAY ROCKWOOD FERGUSON_FLORISSANT HANCOCK JENNINGS KIRKWOOD LADUE MAPLEWOOD_RICHMOND MEHLVILLE NORMANDY PATTONVILLE UNIVERSITY VALLEY WEBSTER WELLSTON LINDBERGH;
output out=fullmodelfit p=fitted r=residual;
FTest: test RMTOT=0; *test significance of variables;
RUN;
quit;

* MODEL SCORING;
proc score data=HousingData1 score=Fullmodel type=parms predict out=FullModelForecast;
var STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_BUNGLOW STYLE_COLONIAL YRBLT RMTOT RMBED FIXBATH FIXHALF FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL FUEL_WOOD FUEL_SOLAR HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER HEATSYS_RADIANT WOODBURN_FP SFLA GRADE_X GRADE_A GRADE_B CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE AFFTON BAYLESS BRENTWOOD CLAYTON PARKWAY ROCKWOOD FERGUSON_FLORISSANT HANCOCK JENNINGS KIRKWOOD LADUE MAPLEWOOD_RICHMOND MEHLVILLE NORMANDY PATTONVILLE UNIVERSITY VALLEY WEBSTER WELLSTON LINDBERGH;
Run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data Fullmodelfit2; set Fullmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;
quit;

* SUBSET Full OUTLIERS;
DATA Fullmodeloutliers;
set Fullmodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=Fullmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=Fullmodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Fullmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\FullModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
quit;

*********************************************************************************
SCHOOL DISTRICT MODELS ----------------------------------------------------------
*********************************************************************************

*********************************************************************************
(1) AFFTON MODEL
*********************************************************************************
* BREAK OUT DATA;
Data AfftonHouses; 
set HousingData1;
if AFFTON eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS STORIES_3 FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLAR HEATSYS_NONE GRADE_X GRADE_A CDU_UNSOUND;
run;

* REGRESSION MODEL;
proc reg data=AfftonHouses outest=afftonmodel plots=none;
title "Affton Appraisal Model";
AfftonFull: model APRTOT=STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_CAPECOD YRBLT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_B GRADE_C GRADE_D CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD LOTSIZE;
output out=afftonmodelfit p=fitted r=residual;
FTest: test RMTOT=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=AfftonHouses score=afftonmodel type=parms predict out=afftonhousesmodelforecast;
var STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_CAPECOD YRBLT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_B GRADE_C GRADE_D CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD LOTSIZE;
Run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data afftonmodelfit2; set afftonmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;

* SUBSET AFFTON OUTLIERS;
DATA afftonmodeloutliers;
set afftonmodelfit2;
if flag eq 1;
run;


* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=afftonmodelfit2 descending outest=afftonmodelfit3;
title "Affton Logistic Model";
model FLAG = APRTOT STORIES_1 STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT WOODBURN_FP SFLA GRADE_B GRADE_C GRADE_D LOTSIZE;
Run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=afftonmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=afftonmodelfit2 n nmiss sum mean min max;
run;

* EXPORT ALL DATA;
PROC EXPORT DATA= WORK.afftonmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\AfftonModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

*********************************************************************************
(2) BAYLESS MODEL
*********************************************************************************

* BREAKOUT DATA;
Data BaylessHouses;
set HousingData1;
if BAYLESS eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS STORIES_3 STYLE_CONTEMPORARY FIXHALF HEAT_NONE FUEL_NONE FUEL_SOLAR HEATSYS_RADIANT GRADE_X GRADE_A GRADE_B CDU_UNSOUND;
run;

* REGRESSION MODEL;
proc reg data=BaylessHouses outset=BaylessModel plots=none;
title "Bayless Appraisal Model";
Bayless: model APRTOT= STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
output out=baylessmodelfit p=fitted r=residual;
FTest: test GRADE_C=GRADE_D=0; *test significance of variables;
run;
QUIT;

* MODEL SCORING;
proc score data=BaylessHouses score=Baylessmodel type=parms predict out=Baylesshousesmodelforecast;
var STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;
QUIT;

* Compute percentage deviations of fitted values from actual values;
  data baylessmodelfit2; set baylessmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;
QUIT;


* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=baylessmodelfit2 descending outest=baylessmodelfit3;
title "Bayless Logistic Model";
model FLAG = APRTOT STORIES_1 YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;

* SUBSET BAYLESS OUTLIERS;
DATA baylessmodeloutliers;
set baylessmodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=baylessmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=baylessmodelfit2 n nmiss sum mean min max;
run;

* EXPORT ALL DATA;
PROC EXPORT DATA= WORK.baylessmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\BaylessModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
QUIT;

*********************************************************************************
(3) BRENTWOOD MODEL
*********************************************************************************;

* BREAKOUT DATA;
Data BrentwoodHouses;
set HousingData1;
if brentwood eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS STORIES_3 FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLAR HEATSYS_NONE HEATSYS_ELECTRIC GRADE_X CDU_UNSOUND;
run;

* REGRESSION MODEL;
proc reg data=BrentwoodHouses outset=BrentwoodModel plots=none;
title "Brentwood Appraisal Model";
Brentwood: model APRTOT=STORIES_1 STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FUEL_GAS FUEL_ELECTRIC HEATSYS_WARMAIR HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_B GRADE_C GRADE_D GRADE_E CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
output out=brentwoodmodelfit p=fitted r=residual;
FTest: test RMBED=0; *test significance of variables;
RUN;
QUIT;

* MODEL SCORING;
proc score data=BrentwoodHouses score=brentwoodmodel type=parms predict out=brentwoodhousesmodelforecast;
var STORIES_1 STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FUEL_GAS FUEL_ELECTRIC HEATSYS_WARMAIR HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_B GRADE_C GRADE_D GRADE_E CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
Run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data brentwoodmodelfit2; set brentwoodmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;
QUIT;
* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Brentwoodmodelfit2 descending outest=Brentwoodmodelfit3;
title "Brentwood Logistic Model";
model FLAG = APRTOT STORIES_1 YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC WOODBURN_FP SFLA GRADE_C GRADE_D LOTSIZE;
run;


* SUBSET BRENTWOOD OUTLIERS;
DATA brentwoodmodeloutliers;
set brentwoodmodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=brentwoodmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=brentwoodmodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.brentwoodmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\BrentwoodModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
QUIT;

*********************************************************************************
(4) CLAYTON MODEL
*********************************************************************************;

* BREAKOUT DATA;
Data ClaytonHouses;
set HousingData1;
if clayton eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS STYLE_SPLITFOYER STYLE_SPLITLEVEL FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLAR HEATSYS_NONE GRADE_E CDU_UNSOUND CDU_VERYPOOR;
run;

* REGRESSION MODEL;
proc reg data=ClaytonHouses outset=ClaytonModel plots=none;
title "Clayton Appraisal Model";
Clayton: model APRTOT=STORIES_1 STORIES_2 STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_A GRADE_B GRADE_C GRADE_D CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
output out=claytonmodelfit p=fitted r=residual;
FTest: test RMBED=0; *test significance of variables;
RUN;
QUIT;

* MODEL SCORING;
proc score data=ClaytonHouses score=Claytonmodel type=parms predict out=claytonhousesmodelforecast;
var STORIES_1 STORIES_2 STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_A GRADE_B GRADE_C GRADE_D CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data claytonmodelfit2; set claytonmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;
QUIT;

* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Claytonmodelfit2 descending outest=Claytonmodelfit3;
title "Clayton Logistic Model";
model FLAG = APRTOT STORIES_1 STORIES_2 STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_A GRADE_B GRADE_C GRADE_D CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;

* SUBSET Clayton OUTLIERS;
DATA claytonoutliers;
set claytonmodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=claytonmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=claytonmodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.claytonmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\ClaytonModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
QUIT;


*********************************************************************************
(5) PARKWAY MODEL
*********************************************************************************
* BREAK OUT DATA;
Data ParkwayHouses; 
set HousingData1;
if Parkway eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS STORIES_3 FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLAR HEATSYS_NONE CDU_UNSOUND;
run;

* REGRESSION MODEL;
proc reg data=ParkwayHouses outest=Parkwaymodel plots=none;
title "Parkway Appraisal Model";
Parkway: model APRTOT=STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL YRBLT RMTOT RMBED FIXBATH FIXTOT FUEL_GAS FUEL_ELECTRIC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_X GRADE_A GRADE_B GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
output out=Parkwaymodelfit p=fitted r=residual;
*FTest: test HEAT_CENTRALAC=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=ParkwayHouses score=Parkwaymodel type=parms predict out=Parkwayhousesmodelforecast;
var STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL YRBLT RMTOT RMBED FIXBATH FIXTOT FUEL_GAS FUEL_ELECTRIC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_X GRADE_A GRADE_B GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE; 
Run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data Parkwaymodelfit2; set Parkwaymodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;

* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Parkwaymodelfit2 descending outest=Parkwaymodelfit3;
title "Parkway Logistic Model";
model FLAG = APRTOT STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL YRBLT RMTOT RMBED FIXBATH FIXTOT FUEL_GAS FUEL_ELECTRIC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_X GRADE_A GRADE_B GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE; 
Run;
* SUBSET Parkway OUTLIERS;
DATA Parkwaymodeloutliers;
set Parkwaymodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=Parkwaymodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=Parkwaymodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Parkwaymodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\ParkwayModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

*********************************************************************************
(6) ROCKWOOD MODEL
*********************************************************************************
* BREAK OUT DATA;
Data RockwoodHouses; 
set HousingData1;
if Rockwood eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS STORIES_3 FIXHALF FUEL_SOLAR;
run;

* REGRESSION MODEL;
proc reg data=RockwoodHouses outest=Rockwoodmodel plots=none;
title "Rockwood Appraisal Model";
Rockwood: model APRTOT= STORIES_1 STYLE_SPLITFOYER STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT FUEL_NONE FUEL_GAS FUEL_ELECTRIC FUEL_OIL FUEL_WOOD HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER HEATSYS_RADIANT WOODBURN_FP SFLA GRADE_A GRADE_B GRADE_C GRADE_D GRADE_E CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
output out=Rockwoodmodelfit p=fitted r=residual;
*FTest: test HEAT_BASIC=HEAT_CENTRALAC=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=RockwoodHouses score=Rockwoodmodel type=parms predict out=Rockwoodhousesmodelforecast;
var STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_CAPECOD YRBLT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_B GRADE_C GRADE_D CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD LOTSIZE;
Run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data Rockwoodmodelfit2; set Rockwoodmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;


* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Rockwoodmodelfit2 descending outest=Rockwoodmodelfit3;
title "Rockwood Logistic Model";
model FLAG = APRTOT STORIES_1 YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;

* SUBSET Rockwood OUTLIERS;
DATA Rockwoodmodeloutliers;
set Rockwoodmodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=Rockwoodmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=Rockwoodmodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Rockwoodmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\RockwoodModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

*********************************************************************************
(7) FERGUSON/FLORISSANT MODEL
*********************************************************************************
* BREAK OUT DATA;
Data FergusonFlorissantHouses; 
set HousingData1;
if Ferguson_Florissant eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS STORIES_3 FIXHALF HEAT_NONE FUEL_NONE FUEL_SOLAR HEATSYS_NONE GRADE_X GRADE_A CDU_EXCELLENT;
run;

* REGRESSION MODEL;
proc reg data=FergusonFlorissantHouses outest=FergusonFlorissantmodel plots=none;
title "FergusonFlorissant Appraisal Model";
FergusonFlorissant: model APRTOT=STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL HEATSYS_WARMAIR HEATSYS_HOTWATER HEATSYS_RADIANT SFLA GRADE_C GRADE_D GRADE_E CDU_UNSOUND CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD LOTSIZE;
output out=FergusonFlorissantmodelfit p=fitted r=residual;
FTest: test RMTOT=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=FergusonFlorissantHouses score=FergusonFlorissantmodel type=parms predict out=FergusonFlorissantmodelforecast;
var STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL HEATSYS_WARMAIR HEATSYS_HOTWATER HEATSYS_RADIANT SFLA GRADE_C GRADE_D GRADE_E CDU_UNSOUND CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD LOTSIZE;
Run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data FergusonFlorissantmodelfit2; set FergusonFlorissantmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;

* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=FergusonFlorissantmodelfit2 descending outest=FergusonFlorissantmodelfit3;
title "FergusonFlorissant Logistic Model";
model FLAG = APRTOT STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL HEATSYS_WARMAIR HEATSYS_HOTWATER HEATSYS_RADIANT SFLA GRADE_C GRADE_D GRADE_E CDU_UNSOUND CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD LOTSIZE;
Run;

* SUBSET FergusonFlorissant OUTLIERS;
DATA FergusonFlorissantmodeloutliers;
set FergusonFlorissantmodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=FergusonFlorissantmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=FergusonFlorissantmodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.FergusonFlorissantmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\FergusonFlorissantModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

*********************************************************************************
(8) HANCOCK MODEL
*********************************************************************************
* BREAK OUT DATA;
Data HancockHouses; 
set HousingData1;
if Hancock eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS STORIES_3 STYLE_SPLITLEVEL STYLE_CONTEMPORARY STYLE_COLONIAL STYLE_CAPECOD FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLAR HEATSYS_NONE HEATSYS_ELECTRIC HEATSYS_RADIANT GRADE_X GRADE_A CDU_UNSOUND CDU_EXCELLENT;
run;

* REGRESSION MODEL;
proc reg data=HancockHouses outest=Hancockmodel plots=none;
title "Hancock Appraisal Model";
Hancock: model APRTOT= STORIES_1 STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW YRBLT RMTOT FIXBATH FIXTOT HEAT_CENTRALAC HEATSYS_WARMAIR WOODBURN_FP SFLA GRADE_D GRADE_E CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD LOTSIZE;
output out=Hancockmodelfit p=fitted r=residual;
*FTest: test FUEL_GAS=FUEL_OIL=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=HancockHouses score=Hancockmodel type=parms predict out=Hancockhousesmodelforecast;
var STORIES_1 STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW YRBLT RMTOT FIXBATH FIXTOT HEAT_CENTRALAC HEATSYS_WARMAIR WOODBURN_FP SFLA GRADE_D GRADE_E CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD LOTSIZE;
Run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data Hancockmodelfit2; set Hancockmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;


* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Hancockmodelfit2 descending outest=Hancockmodelfit3;
title "Hancock Logistic Model";
model FLAG = APRTOT STORIES_1 STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW YRBLT RMTOT FIXBATH FIXTOT HEAT_CENTRALAC HEATSYS_WARMAIR WOODBURN_FP SFLA GRADE_D GRADE_E CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD LOTSIZE;
Run;

* SUBSET Hancock OUTLIERS;
DATA Hancockmodeloutliers;
set Hancockmodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=Hancockmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=Hancockmodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Hancockmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\HancockModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;


*********************************************************************************
(9) JENNINGS MODEL
*********************************************************************************
* BREAK OUT DATA;
Data JenningsHouses; 
set HousingData1;
if Jennings eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS STORIES_3 STYLE_CONTEMPORARY STYLE_COLONIAL FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLAR HEATSYS_NONE HEATSYS_RADIANT GRADE_X GRADE_A GRADE_B CDU_VERYGOOD CDU_EXCELLENT;
run;

* REGRESSION MODEL;
proc reg data=JenningsHouses outest=Jenningsmodel plots=none;
title "Jennings Appraisal Model";
Jennings: model APRTOT=STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW YRBLT RMTOT RMBED FIXBATH HEAT_CENTRALAC WOODBURN_FP SFLA GRADE_C GRADE_D CDU_UNSOUND CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE LOTSIZE;  
output out=Jenningsmodelfit p=fitted r=residual;
*FTest: test HEATSYS_ELECTRIC=HEATSYS_WARMAIR=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=JenningsHouses score=Jenningsmodel type=parms predict out=Jenningshousesmodelforecast;
var STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW YRBLT RMTOT RMBED FIXBATH HEAT_CENTRALAC WOODBURN_FP SFLA GRADE_C GRADE_D CDU_UNSOUND CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE LOTSIZE;  
Run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data Jenningsmodelfit2; set Jenningsmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;

* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Jenningsmodelfit2 descending outest=Jenningsmodelfit3;
title "Jennings Logistic Model";
model FLAG = APRTOT STORIES_1 YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD LOTSIZE;
run;

* SUBSET Jennings OUTLIERS;
DATA Jenningsmodeloutliers;
set Jenningsmodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=Jenningsmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=Jenningsmodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Jenningsmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\JenningsModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

*********************************************************************************
(9) KIRKWOOD MODEL
*********************************************************************************
* BREAK OUT DATA;
Data KirkwoodHouses; 
set HousingData1;
if Kirkwood eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLAR HEATSYS_NONE;
run;

* REGRESSION MODEL;
proc reg data=KirkwoodHouses outest=Kirkwoodmodel plots=none;
title "Kirkwood Appraisal Model";
Kirkwood: model APRTOT=STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC WOODBURN_FP SFLA GRADE_A GRADE_B GRADE_C GRADE_D CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
output out=Kirkwoodmodelfit p=fitted r=residual;
FTest: test HEATSYS_WARMAIR=HEATSYS_ELECTRIC=HEATSYS_HOTWATER=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=KirkwoodHouses score=Kirkwoodmodel type=parms predict out=Kirkwoodhousesmodelforecast;
var STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC WOODBURN_FP SFLA GRADE_A GRADE_B GRADE_C GRADE_D CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
Run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data Kirkwoodmodelfit2; set Kirkwoodmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;

* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Kirkwoodmodelfit2 descending outest=Kirkwoodmodelfit3;
title "Kirkwood Logistic Model";
model FLAG = APRTOT STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC WOODBURN_FP SFLA GRADE_A GRADE_B GRADE_C GRADE_D CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
Run;

* SUBSET Kirkwood OUTLIERS;
DATA Kirkwoodmodeloutliers;
set Kirkwoodmodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=Kirkwoodmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=Kirkwoodmodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Kirkwoodmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\KirkwoodModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

*********************************************************************************
(10) LADUE MODEL
*********************************************************************************;
Data LadueHouses; 
set HousingData1;
if Ladue eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLAR HEATSYS_NONE GRADE_E CDU_UNSOUND CDU_VERYPOOR;
run;

* REGRESSION MODEL;
proc reg data=LADUEHouses outest=LADUEmodel plots=none;
title "LADUE Appraisal Model";
LADUE: model APRTOT=STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC WOODBURN_FP
SFLA GRADE_A GRADE_B GRADE_C GRADE_D CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;
output out=LADUEmodelfit p=fitted r=residual;
FTest: test FUEL_GAS=FUEL_ELECTRIC=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=LADUEHouses score=LADUEmodel type=parms predict out=LADUEhousesmodelforecast;
var STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC WOODBURN_FP
SFLA GRADE_A GRADE_B GRADE_C GRADE_D CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data LADUEmodelfit2; set LADUEmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;

* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Laduemodelfit2 descending outest=Laduemodelfit3;
title "Ladue Logistic Model";
model FLAG = APRTOT STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC WOODBURN_FP
SFLA GRADE_A GRADE_B GRADE_C GRADE_D CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;

* SUBSET LADUE OUTLIERS;
DATA LADUEmodeloutliers;
set LADUEmodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=LADUEmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=LADUEmodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.LADUEmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\LADUEModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

*********************************************************************************
(11)  MAPLEWOOD/RICHMOND HEIGHTS MODEL
*********************************************************************************

*BREAKOUT DATA;
Data MaplewoodHouses; 
set HousingData1;
if Maplewood_Richmond eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLAR HEATSYS_NONE GRADE_E CDU_UNSOUND CDU_VERYPOOR;
run;

* REGRESSION MODEL;
proc reg data=MaplewoodHouses outest=Maplewoodmodel plots=none;
title "Maplewood Appraisal Model";
Maplewood: model APRTOT=STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMBED FIXBATH FIXTOT HEAT_CENTRALAC WOODBURN_FP
SFLA GRADE_A GRADE_B GRADE_C GRADE_D CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT;
run;

output out=Maplewoodmodelfit p=fitted r=residual;
FTest: test STYLE_SPLITFOYER=STYLE_SPLITLEVEL=STYLE_RANCH=STYLE_OLDSTYLE=STYLE_BUNGLOW=STYLE_COLONIAL=STYLE_CAPECOD=0; *test significance of variables;
RUN;


* MODEL SCORING;
proc score data=MaplewoodHouses score=Maplewoodmodel type=parms predict out=Maplewoodhousesmodelforecast;
var STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMBED FIXBATH FIXTOT HEAT_CENTRALAC WOODBURN_FP
SFLA GRADE_A GRADE_B GRADE_C GRADE_D CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT;
run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data Maplewoodmodelfit2; set Maplewoodmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;

* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Maplewoodmodelfit2 descending outest=Maplewoodmodelfit3;
title "Maplewood Logistic Model";
model FLAG = APRTOT STORIES_1 YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;

* SUBSET LINDBERGH OUTLIERS;
DATA Maplewoodmodeloutliers;
set Maplewoodmodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=Maplewoodmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=Maplewoodmodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Maplewoodmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\MaplewoodModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;


*********************************************************************************
(12)  MEHLVILLE MODEL
*********************************************************************************

* BREAKOUT DATA;
Data MehlvilleHouses; 
set HousingData1;
if Mehlville eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLAR HEATSYS_NONE CDU_UNSOUND;
run;

* REGRESSION MODEL;
proc reg data=MehlvilleHouses outest=Mehlvillemodel plots=none;
title "Mehlville Appraisal Model";
Mehlville: model APRTOT=STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMBED FIXBATH FIXTOT HEAT_CENTRALAC WOODBURN_FP
SFLA GRADE_A GRADE_B GRADE_C GRADE_D GRADE_E CDU_VERYPOOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT;
run;
output out=Mehlvillemodelfit p=fitted r=residual;
FTest: test STYLE_SPLITFOYER=STYLE_SPLITLEVEL=STYLE_RANCH=STYLE_OLDSTYLE=STYLE_BUNGLOW=STYLE_COLONIAL=STYLE_CAPECOD=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=MehlvilleHouses score=Mehlvillemodel type=parms predict out=Mehlvillehousesmodelforecast;
var STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMBED FIXBATH FIXTOT HEAT_CENTRALAC WOODBURN_FP
SFLA GRADE_A GRADE_B GRADE_C GRADE_D GRADE_E CDU_VERYPOOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT;
run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data Mehlvillemodelfit2; set Mehlvillemodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;

* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Mehlvillemodelfit2 descending outest=Mehlvillemodelfit3;
title "Mehlville Logistic Model";
model FLAG = APRTOT STORIES_1 YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;

* SUBSET LINDBERGH OUTLIERS;
DATA Mehlvillemodeloutliers;
set Mehlvillemodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=Mehlvillemodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=Mehlvillemodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Mehlvillemodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\MehlvilleModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;


*********************************************************************************
(13)  NORMANDY MODEL
*********************************************************************************

* BREAK OUT DATA;
Data NORMANDYHouses; 
set HousingData1;
if NORMANDY eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLAR HEATSYS_NONE;
run;

* REGRESSION MODEL;
proc reg data=NORMANDYHouses outest=NORMANDYmodel plots=none;
title "NORMANDY Appraisal Model";
NORMANDY: model APRTOT=STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_B GRADE_C GRADE_D GRADE_E CDU_UNSOUND CDU_VERYPOOR CDU_FAIR CDU_AVERAGE CDU_GOOD LOTSIZE;
run;
output out=NORMANDYmodelfit p=fitted r=residual;
FTest: test HEATSYS_WARMAIR=HEATSYS_ELECTRIC=HEATSYS_HOTWATER=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=NORMANDYHouses score=NORMANDYmodel type=parms predict out=NORMANDYhousesmodelforecast;
var STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_B GRADE_C GRADE_D GRADE_E CDU_UNSOUND CDU_VERYPOOR CDU_FAIR CDU_AVERAGE CDU_GOOD LOTSIZE;
run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data NORMANDYmodelfit2; set NORMANDYmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;

* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Normandymodelfit2 descending outest=Normandymodelfit3;
title "Normandy Logistic Model";
model FLAG = APRTOT STORIES_1 YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD LOTSIZE;
run;

* SUBSET NORMANDY OUTLIERS;
DATA NORMANDYmodeloutliers;
set NORMANDYmodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=NORMANDYmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=NORMANDYmodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.NORMANDYmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\NormandyModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

*********************************************************************************
(14)  PATTONVILLE MODEL
*********************************************************************************

* BREAK OUT DATA;
Data PattonvilleHouses; 
set HousingData1;
if Pattonville eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLAR HEATSYS_NONE GRADE_E CDU_UNSOUND CDU_VERYPOOR;
run;

* REGRESSION MODEL;
proc reg data=PattonvilleHouses outest=Pattonvillemodel plots=none;
title "Pattonville Appraisal Model";
Pattonville: model APRTOT=STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP
SFLA GRADE_B GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD LOTSIZE;
run;
output out=Pattonvillemodelfit p=fitted r=residual;
FTest: test HEATSYS_WARMAIR=HEATSYS_ELECTRIC+HEATSYS_HOTWATER=0; *test significance of variables;
RUN;

output out=Pattonvillemodelfit p=fitted r=residual;
FTest: test STYLE_SPLITFOYER=STYLE_SPLITLEVEL=STYLE_RANCH=STYLE_OLDSTYLE=STYLE_BUNGLOW=STYLE_COLONIAL=STYLE_CAPECOD=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=PattonvilleHouses score=Pattonvillemodel type=parms predict out=Pattonvillehousesmodelforecast;
var STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP
SFLA GRADE_B GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD LOTSIZE;
run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data Pattonvillemodelfit2; set Pattonvillemodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;

* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Pattonvillemodelfit2 descending outest=Pattonvillemodelfit3;
title "Pattonville Logistic Model";
model FLAG = APRTOT STORIES_1 YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;

* SUBSET Pattonville OUTLIERS;
DATA Pattonvillemodeloutliers;
set Pattonvillemodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=Pattonvillemodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=Pattonvillemodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Pattonvillemodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\PattonvilleModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

*********************************************************************************
(15) UNIVERSITY MODEL
*********************************************************************************
* BREAK OUT DATA;
Data UniversityHouses; 
set HousingData1;
if University eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS STYLE_SPLITFOYER FIXHALF HEAT_NONE FUEL_NONE FUEL_SOLAR FUEL_WOOD HEATSYS_NONE GRADE_X;
run;

* REGRESSION MODEL;
proc reg data=UniversityHouses outest=Universitymodel plots=none;
title "University Appraisal Model";
University: model APRTOT=STORIES_1 STORIES_2 STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL YRBLT RMBED FIXBATH FIXTOT HEAT_CENTRALAC HEATSYS_WARMAIR HEATSYS_HOTWATER HEATSYS_RADIANT WOODBURN_FP SFLA GRADE_A GRADE_B GRADE_C GRADE_D CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
 output out=Universitymodelfit p=fitted r=residual;
FTest: test RMBED=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=UniversityHouses score=Universitymodel type=parms predict out=Universityhousesmodelforecast;
var STORIES_1 STORIES_2 STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL YRBLT RMBED FIXBATH FIXTOT HEAT_CENTRALAC HEATSYS_WARMAIR HEATSYS_HOTWATER HEATSYS_RADIANT WOODBURN_FP SFLA GRADE_A GRADE_B GRADE_C GRADE_D CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE; 
Run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data Universitymodelfit2; set Universitymodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;
* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Universitymodelfit2 descending outest=Universitymodelfit3;
title "University Logistic Model";
model FLAG = APRTOT STORIES_1 YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;

* SUBSET University OUTLIERS;
DATA Universitymodeloutliers;
set Universitymodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=Universitymodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=Universitymodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Universitymodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\UniversityModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

*********************************************************************************
(16) VALLEY MODEL
*********************************************************************************
* BREAK OUT DATA;
Data ValleyHouses; 
set HousingData1;
if Valley eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS STORIES_3 STYLE_CONTEMPORARY STYLE_COLONIAL FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLAR HEATSYS_NONE HEATSYS_RADIANT GRADE_X GRADE_A GRADE_B CDU_UNSOUND;
run;

* REGRESSION MODEL;
proc reg data=ValleyHouses outest=Valleymodel plots=none;
title "Valley Appraisal Model";
Valley: model APRTOT=STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW YRBLT RMTOT RMBED FIXTOT HEAT_CENTRALAC HEATSYS_WARMAIR HEATSYS_ELECTRIC WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
output out=Valleymodelfit p=fitted r=residual;
FTest: test FUEL_GAS=FUEL_ELECTRIC=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=ValleyHouses score=Valleymodel type=parms predict out=Valleyhousesmodelforecast;
var APRTOT=STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW YRBLT RMTOT RMBED FIXTOT HEAT_CENTRALAC HEATSYS_WARMAIR HEATSYS_ELECTRIC WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
Run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data Valleymodelfit2; set Valleymodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;

* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Valleymodelfit2 descending outest=Valleymodelfit3;
title "Valley Logistic Model";
model FLAG = APRTOT STORIES_1 YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;

* SUBSET Valley OUTLIERS;
DATA Valleymodeloutliers;
set Valleymodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=Valleymodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=Valleymodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Valleymodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\ValleyModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

*********************************************************************************
(17) WEBSTER MODEL
*********************************************************************************
* BREAK OUT DATA;
Data WebsterHouses; 
set HousingData1;
if Webster eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLA HEATSYS_NONE GRADE_X CDU_UNSOUND;
run;

* REGRESSION MODEL;
proc reg data=WebsterHouses outest=Webstermodel plots=none;
title "Webster Appraisal Model";
Webster: model APRTOT=STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT FIXBATH FIXTOT HEAT_CENTRALAC HEATSYS_HOTWATER HEATSYS_RADIANT WOODBURN_FP SFLA GRADE_B GRADE_C GRADE_D CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
output out=Webstermodelfit p=fitted r=residual;
FTest: test FUEL_GAS=FUEL_ELECTRIC=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=WebsterHouses score=Webstermodel type=parms predict out=Websterhousesmodelforecast;
var STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT FIXBATH FIXTOT HEAT_CENTRALAC HEATSYS_HOTWATER HEATSYS_RADIANT WOODBURN_FP SFLA GRADE_B GRADE_C GRADE_D CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
Run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data Webstermodelfit2; set Webstermodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;

* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Webstermodelfit2 descending outest=Webstermodelfit3;
title "Webster Logistic Model";
model FLAG = APRTOT STORIES_1 YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;

* SUBSET Webster OUTLIERS;
DATA Webstermodeloutliers;
set Webstermodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=Webstermodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=Webstermodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Webstermodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\WebsterModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

*********************************************************************************
(18) Wellston MODEL
*********************************************************************************
* BREAK OUT DATA;
Data WellstonHouses; 
set HousingData1;
if Wellston eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS STORIES_3 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_CONTEMPORARY STYLE_COLONIAL FIXHALF FUEL_SOLAR HEATSYS_ELECTRIC HEATSYS_RADIANT GRADE_X GRADE_A GRADE_B CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT;
run;

* REGRESSION MODEL;
proc reg data=WellstonHouses outest=Wellstonmodel plots=none;
title "Wellston Appraisal Model";
Wellston: model APRTOT=STORIES_1 STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW YRBLT RMBED FIXBATH FIXTOT HEAT_BASIC HEAT_CENTRALAC FUEL_NONE FUEL_GAS FUEL_OIL SFLA GRADE_D GRADE_E CDU_UNSOUND CDU_VERYPOOR CDU_POOR LOTSIZE;
output out=Wellstonmodelfit p=fitted r=residual;
FTest: test HEAT_BASIC=HEAT_CENTRALAC=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=WellstonHouses score=Wellstonmodel type=parms predict out=Wellstonhousesmodelforecast;
var STORIES_1 STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW YRBLT RMBED FIXBATH FIXTOT HEAT_BASIC HEAT_CENTRALAC FUEL_NONE FUEL_GAS FUEL_OIL SFLA GRADE_D GRADE_E CDU_UNSOUND CDU_VERYPOOR CDU_POOR LOTSIZE;
Run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data Wellstonmodelfit2; set Wellstonmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;

* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Wellstonmodelfit2 descending outest=Wellstonmodelfit3;
title "Wellston Logistic Model";
model FLAG = APRTOT STORIES_1 STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW YRBLT RMBED FIXBATH FIXTOT FUEL_GAS FUEL_OIL SFLA GRADE_D GRADE_E CDU_UNSOUND CDU_VERYPOOR CDU_POOR LOTSIZE;
Run;

* SUBSET Wellston OUTLIERS;
DATA Wellstonmodeloutliers;
set Wellstonmodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=Wellstonmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=Wellstonmodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Wellstonmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\WellstonModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

*********************************************************************************
(19) LINDBERGH MODEL
*********************************************************************************
* BREAK OUT DATA;
Data LindberghHouses; 
set HousingData1;
if Lindbergh eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLAR HEATSYS_NONE GRADE_E CDU_UNSOUND CDU_VERYPOOR;
run;

* REGRESSION MODEL;
proc reg data=LindberghHouses outest=Lindberghmodel plots=none;
title "Lindbergh Appraisal Model";
Lindbergh: model APRTOT=STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMBED FIXBATH FIXTOT HEAT_CENTRALAC WOODBURN_FP
SFLA GRADE_A GRADE_B GRADE_C GRADE_D CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT;
output out=Lindberghmodelfit p=fitted r=residual;
FTest: test FUEL_GAS=FUEL_ELECTRIC=0; *test significance of variables;
RUN;

run;

* MODEL SCORING;
proc score data=LindberghHouses score=Lindberghmodel type=parms predict out=Lindberghhousesmodelforecast;
var STORIES_1 STORIES_2 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMBED FIXBATH FIXTOT HEAT_CENTRALAC WOODBURN_FP
SFLA GRADE_A GRADE_B GRADE_C GRADE_D CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT;
run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data Lindberghmodelfit2; set Lindberghmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;

* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Lindberghmodelfit2 descending outest=Lindberghmodelfit3;
title "Lindbergh Logistic Model";
model FLAG = APRTOT STORIES_1 YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;

* SUBSET Lindbergh OUTLIERS;
DATA Lindberghmodeloutliers;
set Lindberghmodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=Lindberghmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=Lindberghmodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Lindberghmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\LindberghModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;


*********************************************************************************
(20) HAZELWOOD MODEL *NEED TO EDIT*
*********************************************************************************
* BREAK OUT DATA;
Data HazelwoodHouses; 
set HousingData1;
if Hazelwood eq 1;
drop STORIES STYLE CDU GRADE HEAT FUEL HEATSYS STORIES_3 FIXHALF HEAT_NONE FUEL_NONE FUEL_WOOD FUEL_SOLAR HEATSYS_NONE GRADE_X GRADE_E;
run;

* REGRESSION MODEL;
proc reg data=HazelwoodHouses outest=Hazelwoodmodel plots=none;
title "Hazelwood Appraisal Model";
Hazelwood: model APRTOT=STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_B GRADE_C GRADE_D CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
output out=Hazelwoodmodelfit p=fitted r=residual;
FTest: test RMTOT=0; *test significance of variables;
RUN;

* MODEL SCORING;
proc score data=HazelwoodHouses score=Hazelwoodmodel type=parms predict out=Hazelwoodhousesmodelforecast;
var STORIES_1 STYLE_SPLITFOYER STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_B GRADE_C GRADE_D CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;
quit;

* Compute percentage deviations of fitted values from actual values;
  data Hazelwoodmodelfit2; set Hazelwoodmodelfit;
    pcterror = 100*(fitted-APRTOT)/fitted;
if abs(pcterror) gt 20 then flag=1; else flag=0;
If pcterror gt 20 then gt20=1; else gt20=0;
run;


* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Hazelwoodmodelfit2 descending outest=Hazelwoodmodelfit3;
title "Hazelwood Logistic Model";
model FLAG = APRTOT STORIES_1 YRBLT RMTOT RMBED FIXBATH FIXTOT HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER WOODBURN_FP SFLA GRADE_C GRADE_D CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE;
run;

* SUBSET Hazelwood OUTLIERS;
DATA Hazelwoodmodeloutliers;
set Hazelwoodmodelfit2;
if flag eq 1;
run;

* SUMMARY STATISTICS;

***OF OUTLIERS (+/- 20% OF APPRAISED VALUE);
PROC MEANS DATA=Hazelwoodmodeloutliers n nmiss sum mean min max;
run;

***OF ALL DATA;
PROC MEANS DATA=Hazelwoodmodelfit2 n nmiss sum mean min max;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Hazelwoodmodelfit2
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\HazelwoodModel_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

*********************************************************************************
LOGISTIC MODEL - PROB OF GREATER THAN 20%
*********************************************************************************

FULL MODEL: LOGISTIC MODEL
*********************************************************************************;
data fullmodelfit3; 
set fullmodelfit2; **This comes from the output of the regression model fit data to show all records out of range (flag) and of those out of range, which are inthe >20 and <20 categories;
if flag eq 1;
run;

* EXPORT DATA;
PROC EXPORT DATA= WORK.Fullmodelfit3
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\Logistic_FullModel3_dataset.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
quit;

* Logistic MODEL, USING FLAG (IF OVER OR UNDER, IN GENERAL);
proc logistic data=Fullmodelfit2 descending outest=Fullmodel3;
title "Logistic Model";
model FLAG = APRTOT STORIES_1 STORIES_2 STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXHALF FIXTOT HEAT_BASIC HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL FUEL_WOOD FUEL_SOLAR HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER HEATSYS_RADIANT WOODBURN_FP SFLA GRADE_A GRADE_B GRADE_C GRADE_D GRADE_E CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE AFFTON BAYLESS BRENTWOOD CLAYTON FERGUSON_FLORISSANT PARKWAY ROCKWOOD HANCOCK JENNINGS KIRKWOOD LADUE MAPLEWOOD_RICHMOND MEHLVILLE NORMANDY PATTONVILLE UNIVERSITY VALLEY WEBSTER WELLSTON LINDBERGH;
Run;

* Logistic MODEL, USING GT20 (CATEGORIZES OVER OR UNDER);
proc logistic data=Fullmodelfit3 descending outest=Fullmodel3;
title "Logistic Model";
model GT20 = APRTOT STORIES_1 STORIES_2 STYLE_SPLITLEVEL STYLE_RANCH STYLE_CONTEMPORARY STYLE_OLDSTYLE STYLE_BUNGLOW STYLE_COLONIAL STYLE_CAPECOD YRBLT RMTOT RMBED FIXBATH FIXHALF FIXTOT HEAT_BASIC HEAT_CENTRALAC FUEL_GAS FUEL_ELECTRIC FUEL_OIL FUEL_WOOD FUEL_SOLAR HEATSYS_WARMAIR HEATSYS_ELECTRIC HEATSYS_HOTWATER HEATSYS_RADIANT WOODBURN_FP SFLA GRADE_A GRADE_B GRADE_C GRADE_D GRADE_E CDU_VERYPOOR CDU_POOR CDU_FAIR CDU_AVERAGE CDU_GOOD CDU_VERYGOOD CDU_EXCELLENT LOTSIZE AFFTON BAYLESS BRENTWOOD CLAYTON FERGUSON_FLORISSANT PARKWAY ROCKWOOD HANCOCK JENNINGS KIRKWOOD LADUE MAPLEWOOD_RICHMOND MEHLVILLE NORMANDY PATTONVILLE UNIVERSITY VALLEY WEBSTER WELLSTON LINDBERGH;
Run;

* EXPORT DATA, UPDATE FIELDS;
PROC EXPORT DATA= WORK.Fullmodel3
            OUTFILE= "E:\6345w18\FinalProject\SchoolDist_Scored\Logistic_FullModel3_Scored.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
quit;
