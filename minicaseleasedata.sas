options macrogen mprint dquote dtreset;
options ls=156 ps=44 sysprintfont=( "SAS Monospace" 8 ) pageno=1 orientation="landscape"
    topmargin=0 bottommargin=0 leftmargin=.5 rightmargin=.5 printerpath=(pdf outlist);
  libname sasds 'E:\6345w18\minicase data';
   ods pdf body='E:\6345w18\minicase data\SAS case2 output.pdf' 
   style=statdoc;

ods pdf body='E:\6345w18\minicase data\SAS case2 output.pdf' 
   style=statdoc;
  

  data sasds.case2data;
   set case2data;
   **Start Question 1;
   salespcus=totsales/customers;
   run;
   proc contents data=sasds.case2data;
   title Contents of dataset Autocenter Sale 2016 for Second Minicase;
   run;


   data case2data;
   set sasds.case2data;
   run;
   proc corr data=case2data;

   title Correlations Matrix of All Variables;
   run;


   **Start Question 2;

		proc reg data=case2data outest=case2models plots=none;

		title "MiniCase 2 Autocenter Regression Models";

		ModelA: model salespcus = vehicles sqfeet stations mdvlvehic medinc pctsaving totfacil chains yropen;
		ModelB: model customers = vehicles sqfeet stations mdvlvehic medinc pctsaving totfacil chains yropen;
		ModelC: model totsales = vehicles sqfeet stations mdvlvehic medinc pctsaving totfacil chains yropen;
		ModelD: model salespsqft = vehicles sqfeet stations mdvlvehic medinc pctsaving totfacil chains yropen;
		ModelE: model share = vehicles sqfeet stations mdvlvehic medinc pctsaving totfacil chains yropen;
		ModelF: model contrib = vehicles sqfeet stations mdvlvehic medinc pctsaving totfacil chains yropen;
		ModelAreduced: model salespcus = sqfeet stations mdvlvehic medinc pctsaving yropen;
		ModelCreduced: model totsales = vehicles sqfeet stations totfacil;
		ModelDreduced: model salespsqft = vehicles sqfeet stations totfacil;
		run;
		quit;
		**End Question 2;

**Start Question 3;
		proc reg data=case2data outest=ModelB2test plots=none;
		title "Test of removing characteristics of store's catchment area (mdvlvehic,medinc,vehicles)";

		ModelB: model customers = vehicles sqfeet stations mdvlvehic medinc pctsaving totfacil chains yropen;
		catchmenttest: test mdvlvehic=medinc=vehicles=0;
		run;
		quit;
		**End Question 3;

**Start Question 4;
	**Elimination of Model C;
		proc reg data=case2data plots=none;
		title "Model C: totsales = f(vehicles,sqfeet,stations,mdvlvehic,medinc,pctsaving,totfacil,chains,yropen)";
		title2 with backward elimination of variables;
		ModelC: model totsales = vehicles sqfeet stations mdvlvehic medinc pctsaving totfacil chains yropen
     	/ selection = backward   slstay=.1;
		run;

		**Elimination of Model C;
	
	**Elimination of Model A;
		proc reg data=case2data plots=none;
		title "ModelA: salespcus = f(vehicles spfeet stations mdvlvehic medinc pctsaving totfacil chains yropen)";
		title2 with backward elimination of variables;
		ModelA: model salespcus = vehicles sqfeet stations mdvlvehic medinc pctsaving totfacil chains yropen
     	/ selection = backward   slstay=.1;
		run;
	**Elimination of Model A;
		
	**Elimination of Model D;
		proc reg data=case2data plots=none;
		title "ModelD: salespsqft = f(vehicles sqfeet stations mdvlvehic medinc pctsaving totfacil chains yropen)";
		title2 with backward elimination of variables;
		ModelD: model salespsqft = vehicles sqfeet stations mdvlvehic medinc pctsaving totfacil chains yropen
     	/ selection = backward   slstay=.1;
		run;
	**Elimination of Model D;
		**End Question 4;

**End Question 5;
	**Create assumption for new facility to be opened in 2017;
		data newlo2017;
		vehicles=6500; medinc=53500; mdvlvehic=17150; sqfeet=18750; stations=6; totfacil=4; chains=2; pctsaving=7.5; yropen=2017;
		output;
	**Create assumption for new facility to be opened in 2017;
**Forecasting by Model C Reduced directly;
		proc score data=newlo2017 score=case2models type=parms predict out=acsalesforecasts;
		var vehicles medinc mdvlvehic sqfeet stations totfacil chains pctsaving yropen;
		run;
	**Forecasting by Model C Reduced directly;
**Forecasting by Model A Reduced and B;
		data acsalesforecasts; set acsalesforecasts;
		ModelAreducedandB=ModelAreduced*ModelB;
		run;
	**Forecasting by Model A Reduced and B;
**Forecasting by Model D Reduced and Assumed Square Footage;
		data acsalesforecasts; set acsalesforecasts;
		ModelDreducedSales=ModelDreduced*sqfeet;
		run;
	**Forecasting by Model D Reduced and Assumed Square Footage;
	**Print Results;
		proc print data=acsalesforecasts label split='/';
    	Title Alternative Forecasts of Sales for Minicase 2 ;

		var vehicles medinc mdvlvehic sqfeet stations totfacil chains pctsaving yropen ModelCreduced ModelAreducedandB ModelDreducedSales;
		* use comma formatting;
		format vehicles medinc mdvlvehic sqfeet stations totfacil chains pctsaving yropen ModelCreduced ModelAreducedandB ModelDreducedSales comma10.;
		* specify labels;
		label checkouts='1.05 times/2016/checkouts'
        modelIandJ='ModelI/Times/Model J';
   		run;
			** close the pdf file to allow external access;

   		** export forecasted values;
		PROC EXPORT DATA= WORK.acsalesforecasts 
        OUTFILE= "E:\6345w18\minicase data\case2 model forecasts.csv" 
        DBMS=CSV REPLACE;
     	PUTNAMES=YES;
		RUN;
	**Print Results;
**End Question 5;

ods pdf close;
