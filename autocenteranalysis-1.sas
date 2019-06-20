

  **** set output format for landscape pdf file;

* ls is no of characters printed per line and ps is no of lines per page;

options macrogen mprint dquote dtreset;
options ls=156 ps=44 sysprintfont=( "SAS Monospace" 8 ) pageno=1 orientation="landscape"
    topmargin=0 bottommargin=0 leftmargin=.5 rightmargin=.5 printerpath=(pdf outlist);

/** comments can also take this form (without nesting)

The following statement sets the path to your permanent SAS datasets

	*/

  libname sasds 'e:\6345w18\minicase data';

** send output to designated file in pdf format; 

 ods pdf body='e:\6345w18\minicase data\case 1 SAS reports.pdf' 
   style=statdoc;

** put SAS program statements here;

*** import data for case 1 from cvs dataset;

   /**** comment out import 

PROC IMPORT OUT= WORK.case1data 
            DATAFILE= "e:\6345w18\minicase data\qsales16.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
  **************/


   data sasds.case1data;   ** creates a new permanent dataset in the sasds library;
     set case1data;  * brings in data from the temp dataset;

	 run;

** summarize dataset contents;
	 proc contents data=sasds.case1data;
	 run;

	 proc means data=sasds.case1data n nmiss min mean max std;
	 title data for CASE 1;
   run;


    proc print data=sasds.case1data;
   title Raw data provided ;
   var sales period checkouts promotion q1 q2 q3 q4;
   run;


   proc corr data=sasds.case1data;
   title correlations among variables;
   var sales period checkouts promotion q1 q2 q3 q4;
   run;

   **** Model A regression;
** model paramemeters will be saved in SAS dataset named cas1modelaparms;
   ** fitted observations will be placed in SAS dataset named modelafit;

   proc reg data=sasds.case1data outest=case1modelaparms plots=none;
      model sales = checkouts promotion period q1 q2 q3;
	  output out=modelafit p=fitted r=residual;
	run;
    quit;

*** compute percentage deviations of fitted values from actual values;
  data modelafit2; set modelafit;
    pcterror = 100*(fitted-sales)/fitted;
	if abs(pcterror) gt 20 then flag=1; else flag=0;
	run;

	** print out observations with large percentge deviations;
proc print data=modelafit2;
where flag=1;
title observations flagged with large error;
run; 

*** Place multiple models in a single output dataset and export them to Excel;
  proc reg data=sasds.case1data outest=case1modelsAandB plots=none;
      modelA: model  sales = checkouts promotion period q1 q2 q3;
	  modelB: model sales = promotion period q1 q2 q3;
	run;
    quit;










** close the pdf file for externmal access;
ods pdf close;
