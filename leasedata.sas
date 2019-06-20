NOTE: Copyright (c) 2002-2012 by SAS Institute Inc., Cary, NC, USA.
NOTE: SAS (r) Proprietary Software 9.4 (TS1M4)
      Licensed to THE CURATORS OF THE UNIV OF MISSOURI - T&R, Site 70055358.
NOTE: This session is executing on the W32_10PRO  platform.



NOTE: Updated analytical products:

      SAS/STAT 14.2
      SAS/ETS 14.2
      SAS/OR 14.2
      SAS/IML 14.2
      SAS/QC 14.2

NOTE: Additional host information:

 W32_10PRO WIN 10.0.14393  Workstation

NOTE: SAS initialization used:
      real time           1.29 seconds
      cpu time            0.90 seconds

1    ** Also macros for fitting logit models and writing equations to a specified file;
2    options ps=40 ls=132 pageno=1;
3
4     data logitmod;
5      length option $10;
6      * hypothetical data for employees signing up for medical options;
7
8      do age= 21 to 65;
9       do emp=1 to 100;
10       rnum1=uniform(11111);
11       if  rnum1 lt .5 then female=1; else female=0;
12       logit = .01 + .07* age -.5*female;
13       pinsur= exp(logit) /(1+exp(logit));
14       pnoins=  1/(1+exp(logit));
15        rnum2=uniform(11111);
16        if rnum2 lt pinsur then insur=1;
17         else  insur=0;
18
19
20
21     output;  * to create an observation  with this outcome;
22     end; * of emp;
23     end; * of age     ;
24
25    run;

NOTE: Variable option is uninitialized.
NOTE: The data set WORK.LOGITMOD has 4500 observations and 10 variables.
NOTE: DATA statement used (Total process time):
      real time           0.08 seconds
      cpu time            0.03 seconds


26
27    data sasd.logitmod; set logitmod; run;

ERROR: Libref SASD is not assigned.
NOTE: The SAS System stopped processing this step because of errors.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


28
29     proc print data=logitmod (obs=100);
NOTE: Writing HTML Body file: sashtml.htm
30      var age female pinsur pnoins insur;
31     run;

NOTE: There were 100 observations read from the data set WORK.LOGITMOD.
NOTE: PROCEDURE PRINT used (Total process time):
      real time           0.53 seconds
      cpu time            0.26 seconds


32   proc print data=logitmod (obs=100);
33      var age female pinsur pnoins insur;
34     run;

NOTE: There were 100 observations read from the data set WORK.LOGITMOD.
NOTE: PROCEDURE PRINT used (Total process time):
      real time           0.11 seconds
      cpu time            0.06 seconds


35
36
37
38
39
40
41    proc means data=logitmod n nmiss sum mean min max ;
42    title data used for fitting model;
43    run;

NOTE: There were 4500 observations read from the data set WORK.LOGITMOD.
NOTE: PROCEDURE MEANS used (Total process time):
      real time           0.13 seconds
      cpu time            0.06 seconds


44
45   **** demonstration of results without the descending option;
46
47   proc logistic data=logitmod outest=logitmodparmswithoutdescending plots=none;
48   title logistic function for ln(p(noins)/p(ins)) derived without the descending option;
49      model insur = age female;
50      run;

NOTE: PROC LOGISTIC is modeling the probability that insur=0. One way to change this to model the probability that insur=1 is to
      specify the response variable option EVENT='1'.
NOTE: Convergence criterion (GCONV=1E-8) satisfied.
NOTE: There were 4500 observations read from the data set WORK.LOGITMOD.
NOTE: The data set WORK.LOGITMODPARMSWITHOUTDESCENDING has 1 observations and 9 variables.
NOTE: PROCEDURE LOGISTIC used (Total process time):
      real time           0.23 seconds
      cpu time            0.07 seconds


51
52    **** demonstration of descending option to reverse signs of logit coefficients;
53
54   proc logistic data=logitmod descending  outest=logitmodparmswithdescending plots=none;
55   title logistic function for ln(p(ins)/p(noins)) derived with descending option ;
56      model insur = age female;
57      run;

NOTE: PROC LOGISTIC is modeling the probability that insur=1.
NOTE: Convergence criterion (GCONV=1E-8) satisfied.
NOTE: There were 4500 observations read from the data set WORK.LOGITMOD.
NOTE: The data set WORK.LOGITMODPARMSWITHDESCENDING has 1 observations and 9 variables.
NOTE: PROCEDURE LOGISTIC used (Total process time):
      real time           0.15 seconds
      cpu time            0.09 seconds


58    PROC EXPORT DATA= WORK.LOGITMODPARMSwithdescending
59               OUTFILE= "E:\6345w18\logitmodparmswithdescending.csv"
60               DBMS=CSV LABEL REPLACE;
61
62   RUN;

63    /**********************************************************************
64    *   PRODUCT:   SAS
65    *   VERSION:   9.4
66    *   CREATOR:   External File Interface
67    *   DATE:      24FEB18
68    *   DESC:      Generated SAS Datastep Code
69    *   TEMPLATE SOURCE:  (None Specified.)
70    ***********************************************************************/
71       data _null_;
72       %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
73       %let _EFIREC_ = 0;     /* clear export record count macro variable */
74       file 'E:\6345w18\logitmodparmswithdescending.csv' delimiter=',' DSD DROPOVER lrecl=32767;
75       if _n_ = 1 then        /* write column names or labels */
76        do;
77          put
78            '"' "Link function" '"'
79          ','
80            '"' "Type of Statistics" '"'
81          ','
82            '"' "Convergence Status" '"'
83          ','
84            '"' "Row Names for Parameter Estimates and Covariance Matrix" '"'
85          ','
86            '"' "Intercept: insur=1" '"'
87          ','
88            '"' "age" '"'
89          ','
90            '"' "female" '"'
91          ','
92            '"' "Model Log Likelihood" '"'
93          ','
94            '"' "Estimation Type" '"'
95          ;
96        end;
97      set  WORK.LOGITMODPARMSWITHDESCENDING   end=EFIEOD;
98          format _LINK_ $8. ;
99          format _TYPE_ $8. ;
100         format _STATUS_ $11. ;
101         format _NAME_ $5. ;
102         format Intercept best12. ;
103         format age best12. ;
104         format female best12. ;
105         format _LNLIKE_ best12. ;
106         format _ESTTYPE_ $4. ;
107       do;
108         EFIOUT + 1;
109         put _LINK_ $ @;
110         put _TYPE_ $ @;
111         put _STATUS_ $ @;
112         put _NAME_ $ @;
113         put Intercept @;
114         put age @;
115         put female @;
116         put _LNLIKE_ @;
117         put _ESTTYPE_ $ ;
118         ;
119       end;
120      if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
121      if EFIEOD then call symputx('_EFIREC_',EFIOUT);
122      run;

NOTE: The file 'E:\6345w18\logitmodparmswithdescending.csv' is:
      Filename=E:\6345w18\logitmodparmswithdescending.csv,
      RECFM=V,LRECL=32767,File Size (bytes)=0,
      Last Modified=24Feb2018:14:23:14,
      Create Time=24Feb2018:14:23:12

NOTE: 2 records were written to the file 'E:\6345w18\logitmodparmswithdescending.csv'.
      The minimum record length was 85.
      The maximum record length was 192.
NOTE: There were 1 observations read from the data set WORK.LOGITMODPARMSWITHDESCENDING.
NOTE: DATA statement used (Total process time):
      real time           0.09 seconds
      cpu time            0.06 seconds


1 records created in E:\6345w18\logitmodparmswithdescending.csv from WORK.LOGITMODPARMSWITHDESCENDING.


NOTE: "E:\6345w18\logitmodparmswithdescending.csv" file was successfully created.
NOTE: PROCEDURE EXPORT used (Total process time):
      real time           0.82 seconds
      cpu time            0.18 seconds



123   /**********************************************************************
124   *   PRODUCT:   SAS
125   *   VERSION:   9.4
126   *   CREATOR:   External File Interface
127   *   DATE:      24FEB18
128   *   DESC:      Generated SAS Datastep Code
129   *   TEMPLATE SOURCE:  (None Specified.)
130   ***********************************************************************/
131      data _null_;
132      %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
133      %let _EFIREC_ = 0;     /* clear export record count macro variable */
134      file 'E:\6345w18\logitparms.csv' delimiter=',' DSD DROPOVER lrecl=32767;
135      if _n_ = 1 then        /* write column names or labels */
136       do;
137         put
138            "_LINK_"
139         ','
140            "_TYPE_"
141         ','
142            "_STATUS_"
143         ','
144            "_NAME_"
145         ','
146            "Intercept"
147         ','
148            "age"
149         ','
150            "female"
151         ','
152            "_LNLIKE_"
153         ','
154            "_ESTTYPE_"
155         ;
156       end;
157     set  WORK.Logitmodparmswithdescending   end=EFIEOD;
158         format _LINK_ $8. ;
159         format _TYPE_ $8. ;
160         format _STATUS_ $11. ;
161         format _NAME_ $5. ;
162         format Intercept best12. ;
163         format age best12. ;
164         format female best12. ;
165         format _LNLIKE_ best12. ;
166         format _ESTTYPE_ $4. ;
167       do;
168         EFIOUT + 1;
169         put _LINK_ $ @;
170         put _TYPE_ $ @;
171         put _STATUS_ $ @;
172         put _NAME_ $ @;
173         put Intercept @;
174         put age @;
175         put female @;
176         put _LNLIKE_ @;
177         put _ESTTYPE_ $ ;
178         ;
179       end;
180      if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
181      if EFIEOD then call symputx('_EFIREC_',EFIOUT);
182      run;

NOTE: The file 'E:\6345w18\logitparms.csv' is:
      Filename=E:\6345w18\logitparms.csv,
      RECFM=V,LRECL=32767,File Size (bytes)=0,
      Last Modified=24Feb2018:14:25:38,
      Create Time=24Feb2018:14:25:36

NOTE: 2 records were written to the file 'E:\6345w18\logitparms.csv'.
      The minimum record length was 69.
      The maximum record length was 85.
NOTE: There were 1 observations read from the data set WORK.LOGITMODPARMSWITHDESCENDING.
NOTE: DATA statement used (Total process time):
      real time           0.06 seconds
      cpu time            0.03 seconds


1 records created in E:\6345w18\logitparms.csv from WORK.Logitmodparmswithdescending.


NOTE: Exported data successfully.
