/* makro, ktere zabije SAS pokud vyhodi error */
%macro runquit;
run; quit;
%if &syserr NE 0 %then %do;
%abort cancel;
%end;
%mend runquit;

/* Makro, ktere odstrani balast a jednoduche uvozovky ze zdrojovych dat */

%macro replaceBalast(inpath,outpath);
data _null_;
infile &inpath recfm=n;
file &outpath recfm=n;
input c $char1. @@;
if c='1a'x then put '20'x @@;
else if c='5c'x then put '20'x @@;
else if c='22'x then put '20'x @@;
else if c='27'x then put '20'x @@;
else if c='91'x then put '20'x @@;
else if c='92'x then put '20'x @@;
else if c='93'x then put '20'x @@;
else if c='94'x then put '20'x @@;
else put c $char1. @@;
%runquit;
%mend replaceBalast;

/* makro, ktere prekodovava nominalni promenne na numericky kod */
%macro strName2Num(data,var);

proc sql;
create table fmt as
select distinct strip(&var) as start
from &data
order by 1;
%runquit;

data fmt;
set fmt;
code = _N_;
%runquit;

proc sql;
select cat("if strip(&var) = '",strip(start),"' then tmp = '",code,"';")
into: stmt separated by ' ' from fmt ;
%runquit;

%put &stmt;

/*
%let fmtname=%sysfunc(cat(%sysfunc(strip(&var)),F));

data fmt;
set fmt;
fmtname="&fmtname.";
label = _N_;
type = 'C';
run;

proc format cntlin=fmt; run; quit;
*/


data &data;
attrib tmp length=$3;
set &data;
&stmt.;
/*tmp = put(&var,$&fmtname..);*/
%runquit;

data &data (drop=&var rename=(tmp = &var));
set &data;
%runquit;

%mend strName2Num;

/* export do csv */
%macro exportCSV(dts,path);
PROC EXPORT 
DATA=&dts
OUTFILE="&path.&dts..csv"
REPLACE; 
delimiter=',';
%runquit;
%mend exportCSV;

/* makro pro odstraneni / prekodovani zbyvajiciho balastu */
%macro recodeBalast(var);
&var = translate(&var,'x','&','x','-','x','(','x',')','le','<=','ge','>=','lt','<','gt','>','','.','',',','',';');
%mend recodeBalast;

/* Makro pro binarizaci kategorialnich promennych */
%macro Binarize(input, restVars);

data reduced;
set &input (obs=0);
%runquit;

proc contents data=reduced /*(drop= &restVars)*/ out=proxy noprint; %runquit;

proc sql noprint;
select count(*) into:m from proxy;
%runquit;

%let dsid=%sysfunc(open(reduced,i));

%do i = 1 %to &m;

	%let n=%sysfunc(VARNAME(&dsid,&i));
	%put &n;

	%let c=%sysfunc(VARTYPE(&dsid,&i));
	%put &c;

	%if %sysevalf(&c=C) %then %do;

	 	proc sql;
		create table proxy_&i as select distinct 
		compress(translate(&n,'x','&','x','-','x','(','x',')','le','<=','ge','>=','lt','<','gt','>','','.','',',','',';')) as &n
		from &input where &n is not null and not compress(&n) = '?';
		%runquit;

		data proxy_&i;
		set proxy_&i;
		rule=strip(
			cat(
				"if compress(&n)='",
				strip(&n),
				"' then &n._",
				strip(&n),
				"=1; else &n._",
				strip(&n),
				"=0;"
			)
		);
		%runquit;
		
		proc sql noprint;
		select strip(rule) into :text_of_score separated by ' ' from proxy_&i;
		%runquit;

		%put &text_of_score;

		data &input;
		set &input;
		&text_of_score.;
		%runquit;

	%end;

%end;

%let rc=%sysfunc(close(&dsid));

%mend Binarize;

/* Macro pro aplikaci obecneho linearniho modelu */
%macro glm(data, dist, inputVars, trgVar, classVars);
ods html body="&path.meta\&data._refModel.html" style=Statistical;
title1 "&data";
ods graphics on;

PROC GENMOD DATA=&data;
	
	CLASS &classVars;
	
	MODEL  &trgVar = &inputVars
		/
		NOINT
		SCALE=DEVIANCE
		DIST=&dist
	TYPE1
	TYPE3
	LRCI
	;
	ODS OUTPUT ParameterEstimates=&data._refModel Modelfit=assessment;
run; quit;

ods graphics off;
title1;
ods html close;
%mend;

/* Makro pro diskretizaci do predem zvoleneho poctu intervalu */
%macro Discretize(dset, var, k);

proc sql;
select 
min(&var), max(&var)
into:min, :max 
from &dset;
%runquit;

%put &min;
%put &max;

data &dset (drop = work_d work_y);
attrib &var._int length = $6;
set &dset;
	work_d = (%sysfunc(putn(&max,best12.8)) - %sysfunc(putn(&min,best12.8))) /&k;
	&var._int = "Int_1";
	%do i = 1 %to &k;

		%put &i;
		%let x=%eval(&i + 1);
		work_y = %sysfunc(putn(&min,best12.8)) + (work_d * &i);
		if &var >= %sysfunc(putn(&min,best12.8)) + (work_d * &i) then &var._int = "Int_&x";
	
	%end;
%runquit;
%mend Discretize;

