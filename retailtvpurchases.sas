options macrogen mprint dquote dtreset;
options ls=156 ps=44 sysprintfont=( "SAS Monospace" 8 ) pageno=1 orientation="landscape"
    topmargin=0 bottommargin=0 leftmargin=.5 rightmargin=.5 printerpath=(pdf outlist);



 filename outlist "E:\6345w18\examtwo\retailtvpurchases 2017 output.pdf";

ods pdf body='E:\6345w18\examtwo\analysis of retailtvpurchases 2017.pdf'
   style=statdoc;

  libname sasds 'E:\6345w18\examtwo';

proc contents data=sasds.tvfitting2017; 
title tvfitting2017;
run;

proc freq data=sasds.tvfitting2017;
tables extendedwarranty * cardtype  extendedwarranty* storetype cardtype * storetype /chisq;
title Analysis of tvfitting2017;
run;

proc means data= sasds.tvfitting2017 n nmiss min mean max;
title Analysis for tvfitting2017 sample;
run;
proc means data= sasds.tvtesting2017 n nmiss min mean max;
title Analysis for tvtesting2017 sample;
run;


data regfile; set sasds.tvfitting2017;
   if cardtype eq 'creditcard' then creditcard=1; else creditcard=0;
  if cardtype eq 'debitcard' then debitcard=1; else debitcard=0;
  if cardtype eq 'premiumcard' then premiumcard=1; else premiumcard=0;
  

  if storetype eq 'big box' then bigbox=1; else bigbox=0;
  if storetype eq 'department' then department=1; else department=0;
   if storetype eq 'superstore' then superstore=1; else superstore=0;
if estfamilyinc=. then do; estfamilyinc=60000; missingincome=1;
end;
  estfamilyinc=estfamilyinc/1000;  

  if extendedwarranty eq 'yes' then didextend=1; else didextend=0;
 run;
*proc means data=regfile n nmiss sum min mean max;
*title "data with estimated family income"
run;

 proc sort data=regfile; by storetype;
 run;

 proc univariate data= regfile noprint; by storetype;
 var price;
  output out= meanprice
         mean=avprice;
		 run;
proc print data=meanprice;
title Average Price - Sales Outlet;

run;

proc freq data=regfile;
title Payment Method - Sales Outlet;

table cardtype * storetype; 
run;

proc freq data=regfile;
title Extended Warranty - Sales Outlet;
table extendedwarranty * storetype ; 

   run;


data testtree; set sasds.tvtesting2017;

  
* Node 9 ;
IF (price ne .  AND  (price <= 301.66))  AND  (cardtype = "premiumcard" OR cardtype = "debitcard")
THEN do;
	Node = 9;
	Prediction = 'no';
	probchooseew = 1-0.765537;
end;
* Node 10 ;
IF (price ne .  AND  (price <= 301.66))  AND  (cardtype ne "premiumcard"  AND  cardtype ne "debitcard")
THEN do;
	Node = 10;
	Prediction = 'no';
	probchooseew = 1-0.703340;
 end;

* Node 11;
IF (price ne .  AND  (price > 301.66  AND  price <= 346.98))  AND  (cardtype ne "debitcard")
THEN do;
	Node = 11;
	Prediction = 'no';
	probchooseew = 1-0.687762;
 end;

* Node 12 ;
IF (price ne .  AND  (price > 301.66  AND  price <= 346.98))  AND  (cardtype = "debitcard")
THEN do;
	Node = 12;
	Prediction = 'no';
	probchooseew = 1-0.750388;
  end;

* Node 13 ;
IF (price ne .   AND  (price > 346.98  AND  price <= 367.85))  AND  (cardtype = "premiumcard")
THEN do;
	Node = 13;
	Prediction = 'no';
	probchooseew = 1-0.574850;
 end;

* Node 14 ;
IF (price ne .  AND  (price > 346.98  AND  price <= 367.85))  AND  (cardtype ne "premiumcard")
THEN do;
	Node = 14;
	Prediction = 'no';
	probchooseew  = 1-0.678433;
	end;

* Node 15 ;
IF (price eq . OR (price > 367.85  AND  price <= 428.37))  AND  (cardtype = "premiumcard")
THEN do;
	Node = 15;
	Prediction = 'no';
	probchooseew  = 1-0.568182;
	end;

* Node 16 ;
IF (price eq .  OR (price > 367.85  AND  price <= 428.37))  AND  (cardtype ne "premiumcard")
THEN do;
	Node = 16;
	Prediction = 'no';
	probchooseew  = 1-0.653055;
	end;


* Node 17 ;
IF (price ne .   AND  (price > 428.37  AND  price <= 574.27))  AND  (cardtype = "premiumcard")
THEN do;
	Node = 17;
	Prediction = 'no';
	probchooseew = 1-0.523529;
	end;

* Node 24 ;
IF (price ne .  AND  (price > 428.37  AND  price <= 574.27))  AND  (cardtype ne "premiumcard")  AND  (storetype ne "superstore")
THEN do;
	Node = 24;
	Prediction = 'no';
	probchooseew = 1-0.581967;
	end;

* Node 25 ;
IF (price ne .  AND  (price > 428.37  AND  price <= 574.27))  AND  (cardtype ne "premiumcard")  AND  (storetype = "superstore")
THEN do;
	Node = 25;
	Prediction = 'no';
	probchooseew = 1-0.636761;
	end;

* Node 19 ;
IF (price ne .  AND  (price > 574.27  AND  price <= 632.4400000000001))  AND  (cardtype = "premiumcard")
THEN do;
	Node = 19;
	Prediction = 'yes';
	probchooseew = 0.552511;
	end;

* Node 20 ;
IF (price ne . AND  (price > 574.27  AND  price <= 632.4400000000001))  AND  (cardtype ne "premiumcard")
THEN do;
	Node = 20;
	Prediction = 'no';
	probchooseew = 1-0.541667;
   end;

* Node 7 ;
IF (price ne .  AND  (price > 632.4400000000001  AND  price <= 784.4400000000001))
THEN do;
	Node = 7;
	Prediction = 'yes';
	probchooseew = 0.524832;
 end;

* Node 21 ;
IF (price ne .   AND  (price > 784.4400000000001))  AND  (cardtype = "premiumcard")
THEN do;
	Node = 21;
	Prediction = 'yes';
	probchooseew = 0.881773;
	end;

* Node 22 ;
IF (price ne .  AND  (price > 784.4400000000001))  AND  (cardtype ne "premiumcard"  AND  cardtype ne "debitcard")
THEN do;
	Node = 22;
	Prediction = 'yes';
	probchooseew = 0.709798;
	end;

* Node 23 ;
IF (price ne .   AND  (price > 784.4400000000001))  AND  (cardtype = "debitcard")
THEN do;
	Node = 23;
	Prediction = 'yes';
	probchooseew = 0.581395;
	end;

 didchooseew=0;

 if extendedwarranty eq 'yes' then didchooseew=1;
 didnotchooseew=1-didchooseew;


run;

proc means data=testtree n nmiss sum min mean max;
title CHAID Decision Tree Module;
run;

proc sort data=testtree; by descending probchooseew;
run;

data testtreesum (keep= cumulativecases numberpredicted numberactual cumulativepredicted cumulativeactual
          percentpredicted cumpercentpredicted cumulativeactual cumpercentactual percentactual dummy)
   avyieldds(keep=avyield dummy); 
  set testtree  end=eof;  
 dummy=1;
   cumulativecases+1;
   groupsize=500;
  retain numberpredicted numberactual cumulativepredicted cumulativeactual;
    numberpredicted+probchooseew;
	cumulativepredicted+probchooseew;
	numberactual+didchooseew;
	cumulativeactual+didchooseew;
	if mod(cumulativecases,groupsize) eq 0 or eof then do;
	  percentpredicted= 100*numberpredicted/groupsize;
	  cumpercentpredicted=100*cumulativepredicted/cumulativecases;
	  percentactual=100*numberactual/groupsize;
	  cumpercentactual=100*cumulativeactual/cumulativecases;
	  output testtreesum;
	   numberpredicted=0;
	   numberactual=0;
	end;
	  if eof then do;
       avyield=cumpercentactual;
       output avyieldds;
	    

      end;
	
  run;

  data testtreesum;merge testtreesum avyieldds; by dummy; 
      CumulativeLift=cumpercentactual/avyield;
	  lift=percentactual/avyield;
      run;

  proc print data = testtreesum;
    title performance of classification tree in predicting EW purchase;
	var cumulativecases numberpredicted numberactual percentpredicted percentactual
	     cumulativepredicted cumulativeactual cumpercentpredicted cumpercentactual lift CumulativeLift;
   run;

   run;
 
 proc reg data=regfile outest=PredictPrice;
   Title Regression model to predict purchase price of the TV;
  PredictPrice: Model Price= department superstore premiumcard creditcard estfamilyinc;
  run;

title "Ftest to check if Sales Outlet improves regression fit for price by statistically significant amount";
ModelFtest: test department = bigbox = 0;
run;
quit;

 /**proc reg data=regfile outest=estpricemodelB;
   Title regression model for estimating sales price of a purchased TV;
  EstpriceB: Model price= premiumcard creditcard  estfamilyinc;
 run; **/;

 proc logistic data=regfile descending outest=logitmodelC;
 Title Logistic Model for the Likelihood that a Person will purchase Extended Warranty;
  model didextend= price department bigbox premiumcard creditcard estfamilyinc;
	 run;
	  PROC EXPORT DATA= WORK.logitmodelC
            OUTFILE= "E:\6345w18\examtwo\exam logistic parameters.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

proc logistic data=regfile descending outest=logitmodelD outmodel=parsimoniousmodel;
 Title Parsimonious Logistic Model for estimating the Likelihood that a person will purchase Extended Warranty using Stepwise Option for Selecting Variables;
  model didextend= estfamilyinc price department bigbox premiumcard creditcard
 / selection= stepwise slentry=0.1 slstay=0.1;
	 run;

	 proc logistic data=regfile  descending  outest=multilogitmodelM;
	
 Title Multinomial Logistic Model for Estimating the Likelihood of using Different Payment Options;
 outcome: model cardtype= estfamilyinc department bigbox 
/ link = glogit;
	 run;

	 PROC EXPORT DATA= WORK.multilogitmodelM
            OUTFILE= "E:\6345w18\examtwo\exam multinomial parameters.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
	 

	 proc sort data=regfile; by descending cardtype;
run;

/**proc logistic data=regfile descending;
 title Descending Option in Proc Logistic;
 class cardtype storetype estfamilyinc;
  model cardtype= estfamilyinc storetype;
	 run;**/;



	 data testfile;
    set sasds.tvtesting2017; 
  if cardtype eq 'creditcard' then creditcard=1; else creditcard=0;
  if cardtype eq 'debitcard' then debitcard=1; else debitcard=0;
  if cardtype eq 'premiumcard' then premiumcard=1; else premiumcard=0;
 
  if storetype eq 'big box' then bigbox=1; else bigbox=0;
  if storetype eq 'department' then department=1; else department=0;
  
  if storetype eq 'superstore' then superstore=1; else superstore=0;
 

  if extendedwarranty eq 'yes' then didextend=1; else didextend=0;
  if extendedwarranty eq 'yes' then didextend=1; else didextend=0;
  estfamilyincmv=estfamilyinc;
  if estfamilyincmv eq . then do;
       estfamilyincmv=60000;
       missingincome=1;
	   end;
  estfamilyinc=estfamilyinc/1000;

 didchooseew=0;

 if extendedwarranty eq 'yes' then didchooseew=1;
 didnotchooseew=1-didchooseew;

 run;
 PROC EXPORT DATA= WORK.testfile
            OUTFILE= "E:\6345w18\examtwo\exam testfile.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

proc means data=testfile n nmiss sum min mean max;
title summary statistics from application of the logistic;
run;

proc sort data=testfile; by descending probchooseew;
run;

data testfilesum 
   (keep= cumulativecases numberpredicted numberactual cumulativepredicted cumulativeactual
          percentpredicted cumpercentpredicted cumulativeactual cumpercentactual percentactual dummyvariable)
    randomyieldstat (keep= dummyvariable randomyield); 
    set testfile  end=eof;  
  dummyvariable=1;
   cumulativecases+1;
   groupsize=500;
  retain numberpredicted numberactual cumulativepredicted cumulativeactual;
    numberpredicted+probchooseew;
	cumulativepredicted+probchooseew;
	numberactual+didchooseew;
	cumulativeactual+didchooseew;

	if mod(cumulativecases,groupsize) eq 0 or eof then do;
	  percentpredicted= 100*numberpredicted/groupsize;
	  cumpercentpredicted=100*cumulativepredicted/cumulativecases;
	  percentactual=100*numberactual/groupsize;
	  cumpercentactual=100*cumulativeactual/cumulativecases;
	  output;
	   numberpredicted=0;
	   numberactual=0;
	 end;
	 if eof then do;
	  randomyield=cumpercentactual;
      output randomyieldstat;
	 end;
	;

  run;

data testfilesum2; 
   merge testfilesum randomyieldstat;
   by dummyvariable;
  grouplift=percentactual/cumpercentactual;
  CumulativeLift=cumpercentactual/cumpercentactual;
  run;


  proc print data = testfilesum2;
    title Applying Logistic Model to Predict the Purchase of Extended Warranty - Lift Statistics - Holdout Sample;
	var cumulativecases numberpredicted numberactual percentpredicted percentactual
	     cumulativepredicted cumulativeactual cumpercentpredicted cumpercentactual grouplift CumulativeLift;
   run;

    proc logistic data=regfile descending;
 title Illustration of Using Classification Variables in Proc Logistic;
 class extendedwarranty storetype cardtype;
  model extendedwarranty= estfamilyinc storetype cardtype ;
	 run;
 proc logistic data=regfile descending;
 title Illustration of Using Classification Variables (with price of product purchased) in Proc Logistic;
 class extendedwarranty storetype cardtype;
  model extendedwarranty= estfamilyinc price storetype cardtype 
        ;
	 run;

proc univariate data= regfile noprint;
var estfamilyinc didextend;
 output  out=meanfitvals
         mean=avestfamilyinc avdidextend;
run;

data meanfitvals; set meanfitvals; dummy=1; run;



data regfile; set regfile; dummy=1; run;

data regfilewithmv; 
  merge regfile meanfitvals; by dummy;
  missingincome=0;  
  estfamilyincmv=estfamilyinc;
  if estfamilyincmv eq . then do;
       estfamilyincmv=avestfamilyinc;
       missingincome=1;
  end;
 run;

proc means data=regfilewithmv n nmiss sum min mean max;
title data available after missing value replacements;
 run;

  proc logistic data=regfilewithmv descending outest=parsimoniouslogistic outmodel=parsimoniousmodel;
 Title Logistic Model for Purchasing Extended Warranty;
 Title2 Using Mean Value Replacement and Missing value Indicator for Estimated Family Income;
  model didextend= estfamilyincmv missingincome price department superstore
     bigbox debitcard premiumcard creditcard ;
	 run;
proc logistic data=regfilewithmv descending outest=parsimoniouslogistic outmodel=parsimoniousmodel;
 Title Parsimonious Logistic Model for Purchasing Extended Warranty with Stepwise Selection of Variables;
 Title2 Using Mean Value Replacement and Missing value Indicator for Estimated Family Income;
  model didextend= estfamilyincmv missingincome price department superstore
     bigbox debitcard premiumcard creditcard 
       / selection= stepwise slentry=.1 slstay=.1;
	 run;


   data tvtesting2017mv;  
    set sasds.tvtesting2017; 
  if cardtype eq ' ' then  =1; else  =0;
  if cardtype eq 'creditcard' then creditcard=1; else creditcard=0;
  if cardtype eq 'debitcard' then debitcard=1; else debitcard=0;
  if cardtype eq 'premiumcard' then premiumcard=1; else premiumcard=0;

  if storetype eq 'big box' then bigbox=1; else bigbox=0;
  if storetype eq 'department' then department=1; else department=0;
  if storetype eq 'superstore' then superstore=1; else superstore=0;

  if extendedwarranty eq 'yes' then didextend=1; else didextend=0;
  estfamilyincmv=estfamilyinc;
  if estfamilyincmv eq . then do;
       estfamilyincmv=60000;
       missingincome=1;
  end;
  estfamilyinc=estfamilyinc/1000;

  *didchooseew=0;
 if extendedwarranty eq 'yes' then didchooseew=1;
 didnotchooseew=1-didchooseew;

 run;

proc logistic inmodel=parsimoniousmodel ;
   score data=tvtesting2017mv out=testlogit;
   run;

data testlogit; set testlogit;
   probchooseew = p_1;
   dummy=1;  
run;

proc sort data=testlogit;
by descending probchooseew;
run;

proc univariate data=testlogit noprint;
var didchooseew;
  output out=avyieldtestlogit
         n=numnonmissing
		 mean=avdidextend
         sum=sumdidextend;
 run;


 data avyieldtestlogit; set avyieldtestlogit;
   dummy=1;
   run;


proc sort data=testlogit; by descending probchooseew;

run;

data testlogit; merge testlogit avyieldtestlogit; by dummy;
run;

 data testlogitsum; set testlogit end=eof;  ** eof =1 after reading last obs from testtree;

   cumulativecases+1;
   groupsize=500;
  retain numberpredicted numberactual cumulativepredicted cumulativeactual;
    numberpredicted+probchooseew;
	cumulativepredicted+probchooseew;
    numberactual+didchooseew;
	cumulativeactual+didchooseew;
	if mod(cumulativecases,groupsize) eq 0 or eof then do;
	  percentpredicted= 100*numberpredicted/groupsize;
	  cumpercentpredicted=100*cumulativepredicted/cumulativecases;
	  percentactual=100*numberactual/groupsize;
	  cumpercentactual=100*cumulativeactual/cumulativecases;
   lift=percentactual/avdidextend/100;
   CumulativeLift=cumpercentactual/avdidextend/100;
	  output;
	   numberpredicted=0;
	   numberactual=0;
	
     end;

	 keep cumulativecases numberpredicted numberactual cumulativepredicted cumulativeactual
          percentpredicted cumpercentpredicted cumulativeactual cumpercentactual percentactual dummy avdidextend  lift CumulativeLift eof;

  run;

  proc print data = testlogitsum;
    title performance of Parsimonious Logistics in predicting EW purchase;
	title2 Note that all cases were Scored and overall average yield for lift calculation is based on representation in test dataset;
	var cumulativecases numberpredicted numberactual percentpredicted percentactual
	     cumulativepredicted cumulativeactual cumpercentpredicted cumpercentactual lift CumulativeLift;
   run;

quit;

ods pdf close;



