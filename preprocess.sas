libname imputace "r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\saslib";
%let path=r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\;
%include "r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\sas\toolsMcr.sas";

/* vytvori auditni tabulku pro porovnani modelu */
data Imputace.ImputBenchmark;
attrib
tstmp length=3 format=datetime.
dst length=3
nmiss length=3
method length=3
LL length=8
FLL length=8
AIC length=8
AICC length=8
BIC length=8
;
%runquit;

/* load files into SAS data sets ===================================== */

data imputace.DS1;
attrib
a1 length=$1
a2 length=8
a3 length=8
a4 length=$1
a5 length=$2
a6 length=$2
a7 length=8
a8 length=$1
a9 length=$1
a10 length=8
a11 length=$1
a12 length=$1
a13 length=8
a14 length=8
a15 length=$1
;
infile "&path.src\DS001.dat" delimiter=" " dsd missover lrecl=6000;
input
a1 $
a2
a3
a4 $
a5 $
a6 $
a7
a8 $
a9 $
a10
a11 $
a12 $
a13
a14
a15 $
;
/*
if strip(a5)='1' then a5='01';
if strip(a5)='2' then a5='02';
if strip(a5)='3' then a5='03';
if strip(a5)='4' then a5='04';
if strip(a5)='5' then a5='05';
if strip(a5)='6' then a5='06';
if strip(a5)='7' then a5='07';
if strip(a5)='8' then a5='08';
if strip(a5)='9' then a5='09';

if strip(a6)='1' then a6='01';
if strip(a6)='2' then a6='02';
if strip(a6)='3' then a6='03';
if strip(a6)='4' then a6='04';
if strip(a6)='5' then a6='05';
if strip(a6)='6' then a6='06';
if strip(a6)='7' then a6='07';
if strip(a6)='8' then a6='08';
if strip(a6)='9' then a6='09';
*/

a2 = log(a2);
a3 = log(a3 + 0.000001);
a7 = log(a7 + 0.000001);
a10 = log(a10 + 0.000001);
a13 = log(a13 + 0.000001);
a14 = log(a14);

%recodeBalast(a4);
%recodeBalast(a5);
%recodeBalast(a6);
%recodeBalast(a12);
idx = _N_;
%runquit;


data imputace.DS2;
attrib
a1 length=$3
a2 length=8
a3 length=$3
a4 length=$3
a5 length=8
a6 length=$3
a7 length=$3
a8 length=$1
a9 length=$3
a10 length=$4
a11 length=$1
a12 length=$4
a13 length=8
a14 length=$4
a15 length=$4
a16 length=$1
a17 length=$4
a18 length=$1
a19 length=$4
a20 length=$4
;
infile "&path.src\DS002.dat" delimiter=" " dsd missover lrecl=6000;
input
a1 $
a2
a3 $
a4 $
a5
a6 $
a7 $
a8 $
a9 $
a10 $
a11 $
a12 $
a13
a14 $
a15 $
a16 $
a17 $
a18 $
a19 $
a20 $
;

a2 = log(a2);
a5 = log(a5);
a13 = log(a13);

%recodeBalast(a1);
%recodeBalast(a3);
%recodeBalast(a4);
%recodeBalast(a6);
%recodeBalast(a7);
%recodeBalast(a9);
%recodeBalast(a10);
%recodeBalast(a12);
%recodeBalast(a14);
%recodeBalast(a15);
%recodeBalast(a17);
%recodeBalast(a19);
%recodeBalast(a20);
idx = _N_;
%runquit;

%strName2Num(imputace.ds2,a1);
%strName2Num(imputace.ds2,a3);
%strName2Num(imputace.ds2,a4);
%strName2Num(imputace.ds2,a6);
%strName2Num(imputace.ds2,a7);
%strName2Num(imputace.ds2,a9);
%strName2Num(imputace.ds2,a10);
%strName2Num(imputace.ds2,a12);
%strName2Num(imputace.ds2,a14);
%strName2Num(imputace.ds2,a15);
%strName2Num(imputace.ds2,a17);
%strName2Num(imputace.ds2,a19);
%strName2Num(imputace.ds2,a20);

data imputace.DS3;
attrib
a1 length=8
a2 length=$1
a3 length=$1
a4 length=8
a5 length=8
a6 length=$1
a7 length=$1
a8 length=8
a9 length=$1
a10 length=8
a11 length=$1
a12 length=$1
a13 length=$1
a14 length=$1
;
infile "&path.src\DS003.dat" delimiter=" " dsd missover lrecl=6000;
input
a1
a2 $
a3 $
a4
a5
a6 $
a7 $
a8
a9 $
a10
a11 $
a12 $
a13 $
a14 $
;

a10 = log(a10 + 0.000001);

%recodeBalast(a3);
%recodeBalast(a7);
%recodeBalast(a11);
%recodeBalast(a13);
idx = _N_;
%runquit;

%strName2Num(imputace.ds3,a3);
%strName2Num(imputace.ds3,a7);
%strName2Num(imputace.ds3,a11);
%strName2Num(imputace.ds3,a13);

data imputace.DS4;
attrib
a1 length=8
a2 length=8
a3 length=8
a4 length=8
a5 length=8
a6 length=8
a7 length=8
a8 length=8
a9 length=8
a10 length=8
a11 length=8
a12 length=8
a13 length=8
a14 length=8
a15 length=8
a16 length=8
a17 length=8
a18 length=8
a19 length=$4
;
infile "&path.src\DS004.dat" delimiter=" " dsd missover lrecl=6000;
input
a1
a2
a3
a4
a5
a6
a7
a8
a9
a10
a11
a12
a13
a14
a15
a16
a17
a18
a19 $
;

a6 = log(a6);
a15 = log(a15 + 0.000001);
a16 = log(a16 + 0.000001);

%recodeBalast(a19);
idx = _N_;
%runquit;

%strName2Num(imputace.ds4,a19);

data imputace.DS5;
attrib
a1 length=8
a2 length=8
a3 length=8
a4 length=8
a5 length=8
a6 length=8
a7 length=8
a8 length=8
a9 length=8
a10 length=8
a11 length=8
a12 length=8
a13 length=8
a14 length=8
a15 length=8
a16 length=8
a17 length=8
a18 length=8
a19 length=8
a20 length=8
a21 length=8
a22 length=8
a23 length=8
a24 length=8
a25 length=8
a26 length=8
a27 length=8
a28 length=8
a29 length=8
a30 length=8
a31 length=8
a32 length=8
a33 length=8
a34 length=8
a35 length=8
a36 length=8
;
infile "&path.src\DS005.dat" delimiter=" " dsd missover lrecl=6000;
input
a1
a2
a3
a4
a5
a6
a7
a8
a9
a10
a11
a12
a13
a14
a15
a16
a17
a18
a19
a20
a21
a22
a23
a24
a25
a26
a27
a28
a29
a30
a31
a32
a33
a34
a35
a36
;
idx = _N_;
%runquit;

data imputace.DS6;
attrib
a1 length=8
a2 length=8
a3 length=8
a4 length=8
a5 length=8
a6 length=8
a7 length=8
a8 length=8
a9 length=8
a10 length=$1
;
infile "&path.src\DS006.dat" delimiter=" " dsd missover lrecl=6000;
input
a1
a2
a3
a4
a5
a6
a7
a8
a9
a10 $
;

a8 = log(a8);

idx = _N_;
%runquit;

data imputace.DS7;
attrib
a1 length=8
a2 length=$20
a3 length=8
a4 length=$20
a5 length=8
a6 length=$30
a7 length=$30
a8 length=$30
a9 length=$30
a10 length=$10
a11 length=8
a12 length=8
a13 length=8
a14 length=$30
a15 length=$20
;
infile "&path.src\DS007.dat" delimiter="," dsd missover lrecl=6000;
input
a1
a2 $
a3
a4 $
a5
a6 $
a7 $
a8 $
a9 $
a10 $
a11
a12
a13
a14 $
a15 $
;

a1 = log(a1);
a3 = log(a3);
a11 = log(a11 + 0.000001);

%recodeBalast(a2);
%recodeBalast(a4);
%recodeBalast(a6);
%recodeBalast(a7);
%recodeBalast(a8);
%recodeBalast(a9);
%recodeBalast(a10);
%recodeBalast(a14);
%recodeBalast(a15);
idx = _N_;
%runquit;

%strName2Num(imputace.ds7,a2);
%strName2Num(imputace.ds7,a4);
%strName2Num(imputace.ds7,a6);
%strName2Num(imputace.ds7,a7);
%strName2Num(imputace.ds7,a8);
%strName2Num(imputace.ds7,a9);
%strName2Num(imputace.ds7,a10);
%strName2Num(imputace.ds7,a14);
%strName2Num(imputace.ds7,a15);

data imputace.DS8;
attrib
a1 length=8
a2 length=$20
a3 length=$20
a4 length=$20
a5 length=$3
a6 length=8
a7 length=$3
a8 length=$3
a9 length=$10
a10 length=8
a11 length=$3
a12 length=8
a13 length=8
a14 length=8
a15 length=8
a16 length=$10
a17 length=$3
;
infile "&path.src\DS008.csv" delimiter='";' missover lrecl=6000 firstobs=2;
input
a1
a2 $
a3 $
a4 $
a5 $
a6
a7 $
a8 $
a9 $
a10
a11 $
a12
a13
a14
a15
a16 $
a17 $
;

a1 = log(a1);
a12 = log(a12 + 0.000001);
a15 = log(a15 + 0.000001);

%recodeBalast(a2);
%recodeBalast(a3);
%recodeBalast(a4);
%recodeBalast(a5);
%recodeBalast(a7);
%recodeBalast(a8);
%recodeBalast(a9);
%recodeBalast(a11);
%recodeBalast(a16);
%recodeBalast(a17);
idx = _N_;
%runquit;

%strName2Num(imputace.ds8,a2);
%strName2Num(imputace.ds8,a3);
%strName2Num(imputace.ds8,a4);
%strName2Num(imputace.ds8,a5);
%strName2Num(imputace.ds8,a7);
%strName2Num(imputace.ds8,a8);
%strName2Num(imputace.ds8,a9);
%strName2Num(imputace.ds8,a11);
%strName2Num(imputace.ds8,a16);
%strName2Num(imputace.ds8,a17);

data imputace.DS9;
attrib
a1 length=$20
a2 length=$20
a3 length=$20
a4 length=$4
a5 length=$20
a6 length=$20
a7 length=$20
a8 length=$20
a9 length=$20
;
infile "&path.src\DS009.dat" delimiter=',' missover dsd lrecl=6000;
input
a1 $
a2 $
a3 $
a4 $
a5 $
a6 $
a7 $
a8 $
a9 $
;

%recodeBalast(a1);
%recodeBalast(a2);
%recodeBalast(a3);
%recodeBalast(a4);
%recodeBalast(a5);
%recodeBalast(a6);
%recodeBalast(a7);
%recodeBalast(a8);
%recodeBalast(a9);
idx = _N_;
%runquit;

%strName2Num(imputace.ds9,a1);
%strName2Num(imputace.ds9,a2);
%strName2Num(imputace.ds9,a3);
%strName2Num(imputace.ds9,a4);
%strName2Num(imputace.ds9,a5);
%strName2Num(imputace.ds9,a6);
%strName2Num(imputace.ds9,a7);
%strName2Num(imputace.ds9,a8);
%strName2Num(imputace.ds9,a9);

data imputace.DS10;
attrib
a1 length=8
a2 length=8
a3 length=8
a4 length=8
a5 length=8
a6 length=8
a7 length=8
a8 length=8
a9 length=8
a10 length=8
a11 length=8
a12 length=$1
;
infile "&path.src\DS010.csv" delimiter=';' missover lrecl=6000 firstobs=2;
input
a1
a2
a3
a4
a5
a6
a7
a8
a9
a10
a11
a12 $
;

a5 = log(a5);
a6 = log(a6);
a11 = log(a11);

idx = _N_;
%runquit;

%replaceBalast("&path.src\DS011.dat","&path.src\DS011.csv");

data imputace.DS11;
attrib
a1 length=$1
a2 length=8
a3 length=8
a4 length=8
a5 length=8
a6 length=8
a7 length=$1
a8 length=$50
a9 length=8
;
infile "&path.src\DS011.csv" delimiter=';' missover dsd lrecl=6000;
input
a9
a1 $
a2
a3
a4
a5
a6
a7 $
a8 $
;

a4 = log(a4);
a9 = log(a9);

%recodeBalast(a7);
%recodeBalast(a8);
idx = _N_;
%runquit;

data imputace.DS11(drop=a8);
attrib
a10 length=$20
a11 length=$20
;
set imputace.DS11;
a10 = SCAN (upcase(strip(a8)), 1);
a11 = SCAN(upcase(strip(a8)), 2);
/* standardization */
if strip(a10)="CHEVROELT" then a10="CHEVROLET";		
if strip(a10)="CHEVY" then a10="CHEVROLET";			
if strip(a10)="MAXDA" then a10="MAZDA";
if strip(a10)="TOYOUTA" then a10="TOYOTA";			
if strip(a10)="VOKSWAGEN" then a10="VOLKSWAGEN";			
if strip(a10)="VW" then a10="VOLKSWAGEN";
%runquit;

%strName2Num(imputace.ds11,a10);
%strName2Num(imputace.ds11,a11);

data imputace.DS12;
attrib
a1 length=8
a2 length=8
a3 length=$1
a4 length=8
a5 length=8
a6 length=8
a7 length=8
a8 length=8
a9 length=8
a10 length=8
a11 length=8
a12 length=8
a13 length=8
a14 length=8
a15 length=8
a16 length=8
a17 length=8
a18 length=8
a19 length=8
a20 length=8
a21 length=8
a22 length=8
;
infile "&path.src\DS012.dat" delimiter=',' missover lrecl=6000 firstobs=2;
input
a1
a2
a3 $
a4
a21
a22
a5
a6
a7
a8
a9
a10
a11
a12
a13
a14
a15
a16
a17
a18
a19
a20
;

a5 = log(a5);
a6 = log(a6);
a7 = log(a7);
a8 = log(a8);
a9 = log(a9);
a10 = log(a10);
a11 = log(a11);
a12 = log(a12);
a13 = log(a13);
a14 = log(a14);
a15 = log(a15);
a16 = log(a16);
a19 = log(a19);

idx = _N_;
%runquit;

/* sample for too large data sets ========================================= */

proc surveyselect data=imputace.DS6
method=srs n=4350 out=imputace.DS6;
%runquit;

proc surveyselect data=imputace.DS7
method=srs n=3250 out=imputace.DS7;
%runquit;

proc surveyselect data=imputace.DS8
method=srs n=4521 out=imputace.DS8;
%runquit;

proc surveyselect data=imputace.DS9
method=srs n=1296 out=imputace.DS9;
%runquit;

data imputace.DS12;
set imputace.DS12;
idx = _N_;
run;

data imputace.DS6;
set imputace.DS6;
idx = _N_;
%runquit;

data imputace.DS7;
set imputace.DS7;
idx = _N_;
%runquit;

%Binarize(imputace.DS1);
%Binarize(imputace.DS2);
%Binarize(imputace.DS3);
%Binarize(imputace.DS4);
%Binarize(imputace.DS7);
%Binarize(imputace.DS8);
%Binarize(imputace.DS9);
%Binarize(imputace.DS11);


/* diskretizace spojitych promennych  */
%Discretize(imputace.DS1,a2,10);
%Discretize(imputace.DS1,a3,10);
%Discretize(imputace.DS1,a7,10);
%Discretize(imputace.DS1,a10,10);
%Discretize(imputace.DS1,a13,10);
%Discretize(imputace.DS1,a14,10);

/*
proc freq data=imputace.DS1;
table a2_int;
table a3_int;
table a7_int;
table a10_int;
table a13_int;
table a14_int;
run; quit;
*/

%Discretize(imputace.DS2,a2,11);
%Discretize(imputace.DS2,a5,11);
%Discretize(imputace.DS2,a13,11);

/*
proc freq data=imputace.DS2;
table a2_int;
table a5_int;
table a13_int;
run; quit;
*/

%Discretize(imputace.DS3,a1,9);
%Discretize(imputace.DS3,a4,9);
%Discretize(imputace.DS3,a5,9);
%Discretize(imputace.DS3,a8,9);
%Discretize(imputace.DS3,a10,9);

/*
proc freq data=imputace.DS3;
table a1_int;
table a4_int;
table a5_int;
table a8_int;
table a10_int;
run; quit;
*/

%macro itds(z,m,n,k);
%do j = &m %to &n;
%put &j;
%Discretize(imputace.DS&z,a&j,&k);
%end;
%mend itds;

%itds(4,1,18,11);

/*
proc freq data=imputace.DS4;
tables a1_int;
tables a5_int;
tables a8_int;
tables a10_int;
tables a18_int;
run; quit;
*/


%itds(5,1,36,13);

/*
proc freq data=imputace.DS5;
tables a1_int;
tables a5_int;
tables a8_int;
tables a10_int;
tables a18_int;
run; quit;
*/

%itds(6,1,9,13);

%Discretize(imputace.DS7,a1,13);
%Discretize(imputace.DS7,a3,13);
%Discretize(imputace.DS7,a5,13);
%itds(7,11,13,13);

/*
proc freq data=imputace.DS7;
tables a1_int;
tables a5_int;
tables a11_int;
tables a12_int;
tables a13_int;
run; quit;
*/

%Discretize(imputace.DS8,a1,13);
%Discretize(imputace.DS8,a6,13);
%Discretize(imputace.DS8,a10,13);
%itds(8,12,15,13);

%itds(10,1,11,13);

%Discretize(imputace.DS11,a2,10);
%Discretize(imputace.DS11,a3,10);
%Discretize(imputace.DS11,a4,10);
%Discretize(imputace.DS11,a5,10);
%Discretize(imputace.DS11,a6,10);
%Discretize(imputace.DS11,a9,10);

%itds(11,2,6,10);

%Discretize(imputace.DS12,a1,10);
%Discretize(imputace.DS12,a2,10);
%itds(12,4,22,10);


/* profiling ============================================================ */

%macro IQAFreqCheck(library,table,col);
title3;
title3 "&table.: &col";
proc freq data=&library..&table;
tables &col;
%runquit;
title3;
PROC GCHART DATA=&library..&table;
VBAR &col;
run; quit;
title3;
%mend IQAFreqCheck;

%macro IQADistCheck(library,table,col);
title3;
title3 "&table.: &col";
OPTIONS DEV=PNG;
ODS GRAPHICS ON;
title3;
PROC UNIVARIATE DATA = &library..&table;
	VAR &col;
	HISTOGRAM / CFRAME=GRAY CAXES=BLACK WAXIS=1 CBARLINE=BLACK CFILL=BLUE PFILL=SOLID;
;
%runquit;
ODS GRAPHICS OFF;
%mend IQADistCheck;

%macro IQAMetaCheck(library,table);


proc contents data=&library..&table varnum out=proxy; %runquit;

proc print data=proxy; %runquit;

proc sort data=proxy; by varnum; %runquit;

proc sql;
select count(*) into:cnt from proxy;
%runquit;

%do i=1 %to &cnt;
	
	%let type=;
	%let name=;


	proc sql noprint;
		select name, type, length, label into:name, :type, :length, :label
		from proxy
		where varnum = &i; 
	%runquit;

	%put &i &name &type &length &label;

	data meta (drop=x);
	attrib 
	x1 length=$30 label="Attribute Name"
	x2 length=$30 label="Attribute Type"
	x3 length=$30 label="Attribute Length"
	x4 length=$30 label="Attribute Label"
	;
	x1=symget('name');
	x=symget('type');
	if x = 1 then x2 = 'Numeric'; else x2 = 'String';
	x3=symget('length');
	x4=symget('label');
	%runquit;

	proc print data=meta label noobs; %runquit;

	%put &type;
	%put &name;
	
	%if %eval(&type = 2) %then %do;	
		%put "String";
		%IQAFreqCheck(&library,&table,&name);
	%end;
	%else %do;
		%IQADistCheck(&library,&table,&name);
	%end;

%end;
%mend IQAMetaCheck;

%macro IQAOutput(output,library,table);

ods html body="&output.meta/&table..html" style=Statistical gpath="&path.meta/images";
title1 "&table";
%IQAMetaCheck(&library,&table);
title1;
ods html close;

	proc contents data=&library..&table out=proxy2 noprint; %runquit;

	proc sql noprint;
	select count(*) into:m from proxy2;
	%runquit;

	%put "opening table";

	%let dsid=%sysfunc(open(&library..&table,i));

	data output;
	set &library..&table;
		n = 0;
		%do a=1 %to &m;
			%put &a;
			%let c=%sysfunc(VARNAME(&dsid,&a));
			%let d=%sysfunc(vartype(&dsid,&a));
			x = "&d";
			if missing(&c) = 1 or ( x = "C" and %sysfunc(strip(&c)) = '?' ) then n = n+1;
		%end;

	if n = 0 then output;

	%runquit;

	%put &syslckrc "closing table" &dsid;

	%let rc=%sysfunc(close(&dsid));

	data &library..&table (drop = n);
	set output;
	idx = _N_;
	%runquit;

%mend IQAOutput;

%IQAOutput(&path,imputace,DS1);
%IQAOutput(&path,imputace,DS2);
%IQAOutput(&path,imputace,DS3);
%IQAOutput(&path,imputace,DS4);
%IQAOutput(&path,imputace,DS5);
%IQAOutput(&path,imputace,DS6);
%IQAOutput(&path,imputace,DS7);
%IQAOutput(&path,imputace,DS8);
%IQAOutput(&path,imputace,DS9);
%IQAOutput(&path,imputace,DS10);
%IQAOutput(&path,imputace,DS11);
%IQAOutput(&path,imputace,DS12);



