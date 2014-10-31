/*
imputeMcr: SAS Macro Catalogue for imputation
david@pejcoch.com
2014-09-09
*/

/* Step / Pair Wise ============================================================================ */

%macro xWise(input,listOfVars,method);

data reduced;
set &input (keep = &listOfVars obs=0);
run;

proc contents data=reduced out=proxy noprint; run; quit;

proc sql noprint;
select count(*) into:m from proxy;
quit;

%let dsid=%sysfunc(open(reduced,i));

data /*&input._&method._imp_ */ tmp (drop = n);
set &input(keep = &listOfVars);
	n = 0;
	%do a=1 %to &m;
		%put &a;
		%let c=%sysfunc(VARNAME(&dsid,&a));
		%put &c;
		if missing(&c) = 1 then n = n+1;
	%end;

if n = 0 then output tmp;

run;

data &input._&method._imp_;
set tmp;
run;

%let rc=%sysfunc(close(&dsid));

%mend xWise;

/* Simple Mean ============================================================================ */

%macro simpleMean(data,var);
proc means data=&data noprint;
vars &var;
output out=proxy (drop=_TYPE_ _FREQ_) mean=mean;
%runquit;

proc sql noprint;
select mean into :mean from proxy;
%runquit;

data &data;
set &data;
if missing(&var)= 1 then &var = &mean;
%runquit;
%mend simpleMean;

/* Simple Mode ============================================================================ */

%macro simpleMode(data,var);
proc freq data=&data noprint;
table &var / out=proxy;
%runquit;

proc sql noprint;
select max(count) into :modcnt from proxy where &var is not null;
%runquit;

proc sql noprint;
select &var into :mode from proxy where count = &modcnt;
%runquit;

data &data;
set &data;
if missing(&var)= 1 then &var = "&mode"; 
%runquit;
%mend simpleMode;

/* Simple Median ============================================================================ */

%macro simpleMedian(data,var);

proc summary data=&data median nway noprint;
  var &var;
  output out=proxy (drop=_:) median=median;
%runquit;

proc sql noprint;
select median into :median from proxy;
%runquit;

data &data;
set &data;
if missing(&var)= 1 then &var = &median;
%runquit;
%mend simpleMedian;

/* Mid Range ============================================================================ */
/*
Example of usage: %midRange(Imputace.Ds001_0_45,a15);
*/

%macro midRange(data,var);

proc means data=&data max min noprint;
vars &var;
output out=proxy (drop=_TYPE_ _FREQ_) max=max min=min;
%runquit;

proc sql noprint;
select (max - min) / 2 into :midRange from proxy;
%runquit;

data &data;
set &data;
if missing(&var)= 1 then &var = &midRange;
%runquit;

%mend midRange;

/* Conditional Mean ============================================================================ */

%macro condMean(data,listOfVars,impVar);

%put "starting macro";
%put &data;
%put &listOfVars;
%put &impVar;
%put &types;

data reduced;
set &data (keep = &listOfVars obs=0);
%runquit;

proc contents data=reduced varnum out=cm_meta; %runquit;

proc sql;
select strip(NAME) into: cm_names separated by ','
from cm_meta;
%runquit;

proc sql;
create table proxy as select
&cm_names , avg(&impVar) as &impVar
from &data
group by &cm_names;
%runquit;

proc sort data=proxy; by &listOfVars; %runquit;
proc sort data=&data; by &listOfVars; %runquit;

data &data;
merge 
&data (IN=In1)
proxy (IN=In2)
;
by &listOfVars;
if In1 = 1;
%runquit;
/*
proc sql;
drop table proxy;
drop table reduced;
%runquit;
*/
%mend condMean;

/* Procedure MI: individual vars ================================================================= */
%macro miMCMCMono(data, listOfVars, max, min);
%put "List of vars: " &listOfVars;
%put "Data: " &data;

proc mi data = &data nimpute = 1 seed=121 out=&data._tmp maximum=&max minimum=&min;
  var &listOfVars;
  mcmc prior=JEFFREYS IMPUTE=MONOTONE NITER=1000 initial=em(maxiter=1000);
  em  outem = emcovhsb maxiter=1000;
run; quit;
/*
proc sort data=&data._tmp; by idx; run; quit;
proc sort data=&data; by idx; run; quit;

data 
&data
;
merge &data (IN=In1)
&data._tmp (IN=In2);
by idx;
run;
*/
%mend miMCMCMono;

/* Procedure MI: MCMC ============================================================================ */

%macro miMCMC(data, listOfVars/*, min, max*/);
proc mi data = &data nimpute = 5 seed=12121 out=&data._M20_imp_ /*maximum=&max minimum=&min*/;
  var &listOfVars;
  mcmc;
  em  outem = emcovhsb;
run;

data 
&data._M20_imp_ (drop = _Imputation_)
&data._M20_2 (drop = _Imputation_)
&data._M20_3 (drop = _Imputation_) 
&data._M20_4 (drop = _Imputation_) 
&data._M20_5 (drop = _Imputation_)
;
set &data._M20_imp_;
if _Imputation_ = 1 then output &data._M20_imp_;
if _Imputation_ = 2 then output &data._M20_2;
if _Imputation_ = 3 then output &data._M20_3;
if _Imputation_ = 4 then output &data._M20_4;
if _Imputation_ = 5 then output &data._M20_5;
run;

%mend miMCMC;

/* kombinace regrese a diskriminacni analyzy */

%macro miRegDisc(data, cont, class);
   proc mi data=&data seed=7545417 nimpute=5 out=&data._M35_imp_;
      class Species;
      monotone reg( &cont)
               discrim( &class = &cont / details);
      var &class &cont;
   run;

	data 
	&data._M21_imp_(drop = _Imputation_)
	&data._M21_2 (drop = _Imputation_)
	&data._M21_3 (drop = _Imputation_) 
	&data._M21_4 (drop = _Imputation_) 
	&data._M21_5 (drop = _Imputation_)
	;
	set &data._M21_imp_;
	if _Imputation_ = 1 then output &data._M21_imp_;
	if _Imputation_ = 2 then output &data._M21_2;
	if _Imputation_ = 3 then output &data._M21_3;
	if _Imputation_ = 4 then output &data._M21_4;
	if _Imputation_ = 5 then output &data._M21_5;
	run;

%mend miRegDisc;

/* Procedure MI: Parametric Regression ============================================================================ */

%macro miPReg(data, listOfVars/*, min, max*/);
proc mi data = &data nimpute = 1 seed=12121 out=&data._M21_imp_ /* maximum=&max minimum=&min*/;
  var &listOfVars;
  monotone method=REG;
  em  outem = emcovhsb;
run;
/*
data 
&data._M21_imp_ (drop = _Imputation_)
&data._M21_2 (drop = _Imputation_)
&data._M21_3 (drop = _Imputation_) 
&data._M21_4 (drop = _Imputation_) 
&data._M21_5 (drop = _Imputation_)
;
set &data._M21_imp_;
if _Imputation_ = 1 then output &data._M21_imp_;
if _Imputation_ = 2 then output &data._M21_2;
if _Imputation_ = 3 then output &data._M21_3;
if _Imputation_ = 4 then output &data._M21_4;
if _Imputation_ = 5 then output &data._M21_5;
run;
*/
%mend miPReg;

/* Procedure MI: Propensity Score ============================================================================ */

%macro miPScore(data, listOfVars, min, max);
proc mi data = &data nimpute = 5 seed=12121 out=&data._M22_imp_;
  var &listOfVars;
  monotone method=PROPENSITY;
  em  outem = emcovhsb;
run;

data 
&data._M22_imp_ (drop = _Imputation_)
&data._M22_2 (drop = _Imputation_)
&data._M22_3 (drop = _Imputation_) 
&data._M22_4 (drop = _Imputation_) 
&data._M22_5 (drop = _Imputation_)
;
set &data._M22_imp;
if _Imputation_ = 1 then output &data._M22_imp_;
if _Imputation_ = 2 then output &data._M22_2;
if _Imputation_ = 3 then output &data._M22_3;
if _Imputation_ = 4 then output &data._M22_4;
if _Imputation_ = 5 then output &data._M22_5;
run;

%mend miPScore;


