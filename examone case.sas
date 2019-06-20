options macrogen mprint dquote dtreset;
options ls=156 ps=44 sysprintfont=( "SAS Monospace" 8 ) pageno=1 orientation="landscape"
    topmargin=0 bottommargin=0 leftmargin=.5 rightmargin=.5 printerpath=(pdf outlist);
  libname sasds 'E:\6345w18\examone';
   ods pdf body='E:\6345w18\examone\SAS examcase output.pdf' 
   style=statdoc;

ods pdf body='E:\6345w18\examone\SAS examcase output.pdf' 
   style=statdoc;

data deliverycharges;
set sasds.deliverycharges;
run;
proc contents data=sasds.deliverycharges;
run;
**Question-1**;
proc reg data=deliverycharges outest=deliverychargesabc plots=none;
title "Delivery Charges - Models A, B, C";

Model_A: model deliverycost = zone1 zone2 zone3 zone4;
Model_B: model deliverycost = rushhourpickup rushhourdelivery bothrushhour;
Model_C: model deliverycost = packages oversize weight;
run;
quit;
**Question-2**;
proc reg data=deliverycharges outest=deliverychargesmodelD plots=none;
title "Delivery Charges - Regression Model D";

Model_D: model deliverycost = zone1 zone2 zone3 zone4 rushhourpickup rushhourdelivery bothrushhour oversize weight packages;


**Question 5**;
title "Ftest to check if Zones are statistically significant";
ModelD_Ftest: test zone1=zone2=zone3=zone4=0;
run;
quit;

proc reg data=deliverycharges outest=deliverychargesmodelE plots=none;
title "Delivery Charges - Reduced Model (Model - E)";

Model_E: model deliverycost = rushhourpickup rushhourdelivery bothrushhour oversize weight packages;
run;
quit;

**Question6**;
data tempdeliverycharges;
set sasds.deliverycharges;
if(zone5=0) then delete;
run;

proc reg data=tempdeliverycharges outest=deliverychargesmodelF plots=none;
title "Delivery Charges - Model F for Zone5";

Model_F: model deliverycost = rushhourpickup rushhourdelivery bothrushhour oversize weight packages;
run;
quit;

data predictdelivery;
zone1=0; zone2=0; zone3=0; zone4=0; zone5=1; rushhourpickup=1; rushhourdelivery=0; bothrushhour=0; packages=4; weight=42; oversize=1;
output;

proc score data=predictdelivery score=deliverychargesmodeld type=parms predict out=deliveryforecastmodeld;
var zone1 zone2 zone3 zone4 rushhourpickup rushhourdelivery bothrushhour oversize weight packages;
run;

proc score data=predictdelivery score=deliverychargesmodele type=parms predict out=deliveryforecastmodele;
var rushhourpickup rushhourdelivery bothrushhour oversize weight packages;
run;

proc score data=predictdelivery score=deliverychargesmodelf type=parms predict out=deliveryforecastmodelf;
var rushhourpickup rushhourdelivery bothrushhour oversize weight packages;
run;





