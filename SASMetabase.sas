libname imputace "r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\saslib";
libname CDM odbc dsn='CDM';
%include "r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\sas\toolsMcr.sas";

%macro loadMeta;
%do i=1 %to 12;

	proc contents data=Imputace.ds&i varnum out=meta&i (keep = LIBNAME MEMNAME NAME TYPE LENGTH); %runquit;
%end;

data Imputace.Metabase;
set
%do j=1 %to 12;
	meta&j
%end;
;
%runquit;

%mend loadMeta;
%loadMeta;

%macro setMethodFlags;
%do m = 1 %to 37;
M&m length=$1
M&m._C length=$1
M&m._type length=$11
M&m._C_type length=$11
%end;
%mend setMethodFlags;

%macro setRole(
m, 
N_flag,
B_flag,
C_flag,
D_flag,
N_type,
B_type,
C_type,
D_type,
N_cflag,
B_cflag,
C_cflag,
D_cflag,
N_ctype,
B_ctype,
C_ctype,
D_ctype
);
	if gen_type = 'N' then do;
		M&m = &N_flag;
		M&m._type = &N_type;
		M&m._C = &N_cflag;
		M&m._C_type = &N_ctype;
	end;
	else if gen_type = 'B' then do;
		M&m = &B_flag;
		M&m._type = &B_type;
		M&m._C = &B_cflag;
		M&m._C_type = &B_ctype;
	end;
	else if gen_type = 'C' then do;
		M&m = &C_flag;
		M&m._type = &C_type;
		M&m._C = &C_cflag;
		M&m._C_type = &C_ctype;
	end;
	else if gen_type = 'D' then do;
		M&m = &D_flag;
		M&m._type = &D_type;
		M&m._C = &D_cflag;
		M&m._C_type = &D_ctype;
	end;
%mend setRole;

data Imputace.Metabase;
attrib
mod_role length=$1
RM_type length=$11
orig_prom length=$3
Int_1 - Int_16 length = 8
%setMethodFlags
MIN length=8
MAX length=8
;
set Imputace.Metabase;
/*mod_role = 'P';*/
imput_role = 'N';
miss_role = 'N';
mod_role = 'N';

/* nastaveni roli v ramci referencniho modelu */
if strip(MEMNAME)="DS1" and strip(NAME) in ('a8', 'a10', 'a13', 'a14', 'a12_2', 'a5_1') then mod_role="P";
if strip(MEMNAME)="DS1" and strip(NAME) in ('a15') then mod_role="C";

if strip(MEMNAME)="DS2" and strip(NAME) in ('a8', 'a11', 'a4_1', 'a10_1') then mod_role="P";
if strip(MEMNAME)="DS2" and strip(NAME) in ('a20') then mod_role="C";

if strip(MEMNAME)="DS3" and strip(NAME) in ('a2', 'a5', 'a8', 'a9', 'a12') then mod_role="P";
if strip(MEMNAME)="DS3" and strip(NAME) in ('a14') then mod_role="C";

if strip(MEMNAME)="DS4" and strip(NAME) in ('a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7', 'a8', 'a10', 'a12', 'a13', 'a16', 'a17', 'a18') then mod_role="P";
if strip(MEMNAME)="DS4" and strip(NAME) in ('a19') then mod_role="C";

if strip(MEMNAME)="DS5" and strip(NAME) in ('a8', 'a10', 'a11', 'a14', 'a16', 'a18', 'a19', 'a20', 'a24', 'a27', 'a28', 'a31', 'a32', 'a34', 'a35') then mod_role="P";
if strip(MEMNAME)="DS5" and strip(NAME) in ('a36') then mod_role="C";

if strip(MEMNAME)="DS6" and strip(NAME) in ('a1', 'a2', 'a5', 'a6', 'a7', 'a8', 'a9') then mod_role="P";
if strip(MEMNAME)="DS6" and strip(NAME) in ('a10') then mod_role="C";

if strip(MEMNAME)="DS7" and strip(NAME) in ('a1', 'a2', 'a8', 'a11', 'a12', 'a13') then mod_role="P";
if strip(MEMNAME)="DS7" and strip(NAME) in ('a15') then mod_role="C";

if strip(MEMNAME)="DS8" and strip(NAME) in ('a2', 'a3', 'a6', 'a7_1', 'a8_1', 'a11', 'a12', 'a13', 'a16') then mod_role="P";
if strip(MEMNAME)="DS8" and strip(NAME) in ('a17') then mod_role="C";

if strip(MEMNAME)="DS9" and strip(NAME) in ('a1_1', 'a2_4', 'a3_1', 'a4_1', 'a5_1', 'a6_1', 'a7_2') then mod_role="P";
if strip(MEMNAME)="DS9" and strip(NAME) in ('a9') then mod_role="C";

if strip(MEMNAME)="DS10" and strip(NAME) in ('a1', 'a2', 'a4', 'a6', 'a7', 'a8', 'a9', 'a10','a11') then mod_role="P";
if strip(MEMNAME)="DS10" and strip(NAME) in ('a12') then mod_role="C";

if strip(MEMNAME)="DS11" and strip(NAME) in ('a4', 'a6', 'a7') then mod_role="P";
if strip(MEMNAME)="DS11" and strip(NAME) in ('a9') then mod_role="C";

if strip(MEMNAME)="DS12" and strip(NAME) in ('a1', 'a2', 'a3', 'a6', 'a14', 'a17', 'a20', 'a21') then mod_role="P";
if strip(MEMNAME)="DS12" and strip(NAME) in ('a22') then mod_role="C";

/* generuj missingy do promennych, ktere maji roli Predictor nebo Class v referencnim modelu */
if mod_role in ('P','C') then miss_role = 'Y';

/* diskretizovane promenne */
/*
if TYPE=2 and (substr(strip(NAME),3,1) = '_' or substr(strip(NAME),4,1) = '_') then imput_role = 'Y';
*/

/* doplneni obecneho typu promenne */
if TYPE=1 then gen_type = 'N';
if TYPE=2 then gen_type = 'C';
if TYPE=1 and index(strip(NAME),'_') > 0 then gen_type = 'B';
if TYPE=2 and index(strip(NAME),'_') > 0 then gen_type = 'D';

/* data type pro Rapid Miner */
if gen_type = 'N' then RM_type = 'real';
if gen_type = 'C' then RM_type = 'polynominal';
if gen_type = 'B' then RM_type = 'binominal';
if gen_type = 'D' then RM_type = 'polynominal';

/* odvozeni originalni promenne */
orig_prom = strip(scan(NAME,1,'_'));

/* jako promenne vstupujici do metod pro imputaci oznac promenne referencniho modelu a od nich odvozene (diskretizovane, binarizovane) */
if mod_role in ('P','C') then imput_role = 'Y'; else imput_role = 'N';

%runquit;

data metabase;
set Imputace.metabase;
%runquit;

/* oznaci jako kandidaty pro imputaci puvodni promenne pokud je soucasti modelu odvozena promenna */
proc sql;
update Imputace.metabase set imput_role = 'Y' where  compress(cat(MEMNAME,'_',NAME))  in (
select compress(cat(MEMNAME,'_',orig_prom)) 
from metabase where imput_role = 'Y'
) and imput_role = 'N';
%runquit;

data metabase;
set Imputace.metabase;
%runquit;

/* oznaci jako kandidaty pro imputaci odvozene promenne, pokud je soucasti modelu puvodni promenna */
proc sql;
update Imputace.metabase set imput_role = 'Y' where  compress(cat(MEMNAME,'_',scan(strip(NAME),1,'_')))  in (
select compress(cat(MEMNAME,'_',NAME)) 
from metabase where imput_role = 'Y'
) and imput_role = 'N';
%runquit;

/*
%macro MDRiterUpdate;
	%do j = 1 %to 40;
		proc sql;
		update Imputace.metabase set miss_role = 'Y' where strip(NAME)="a&j";
		quit;
	%end;
%mend MDRiterUpdate;
%MDRiterUpdate;
*/

proc freq data=Imputace.metabase;
tables MEMNAME * mod_role / nopercent norow nocol nocum;
tables MEMNAME * imput_role / nopercent norow nocol nocum;
tables MEMNAME * miss_role / nopercent norow nocol nocum;
%runquit;

/* pridani stredu diskretizovanych intervalu pro jednotlive puvodni promenne */
%macro propIntervals();

proc sql;
create table bins as 
select lowcase(strip(MEMNAME)) as MEMNAME, strip(NAME) as NAME, strip(orig_prom) as orig_prom 
from Imputace.metabase 
where gen_type = 'D';
%runquit;

data bins;
set bins;
idx = _N_;
%runquit;

proc sql;
select count(*)
into: cnt from bins;
%runquit;

%do i=1 %to &cnt;

proc sql;
select MEMNAME, NAME, orig_prom
into: MEMNAME, :NAME, :orig_prom
from bins where idx = &i;
%runquit;

%let nm =%sysfunc(compress(&orig_prom));
%let mem =%sysfunc(compress(&MEMNAME));

	%do j=1 %to 16;
		proc means data=Imputace.&MEMNAME (where=(strip(&NAME)="Int_&j")) MEDIAN; 
		var &orig_prom;
		output out=median MEDIAN=MEDIAN;
		%runquit;

		proc sql;
		update Imputace.metabase set Int_&j = (select MEDIAN from median) where strip(NAME)="&nm" and lowcase(strip(MEMNAME)) = "&mem";
		%runquit;

		proc print data=Imputace.metabase (where=(strip(NAME)="&nm" and lowcase(strip(MEMNAME)) = "&mem")); %runquit;
	%end;

%end;

%mend propIntervals;
%propIntervals; 

proc sql;
delete from Imputace.metabase where strip(NAME)in ('idx','x','work_d','work_y');
%runquit;

proc sql;
create table tst as
select strip(MEMNAME),  count(*) from Imputace.metabase group by 1;
quit;

/* definice vstupu pro jednotlive metody imputace */
data Imputace.metabase;
set Imputace.metabase;
/*%setRole(m, 
N_flag,
B_flag,
C_flag,
D_flag,
N_type,
B_type,
C_type,
D_type,
N_cflag,
B_cflag,
C_cflag,
D_cflag,
N_ctype,
B_ctype,
C_ctype,
D_ctype);*/
/*
if gen_type = 'N' then RM_type = 'real';
if gen_type = 'C' then RM_type = 'polynominal';
if gen_type = 'B' then RM_type = 'binominal';
if gen_type = 'D' then RM_type = 'polynominal';
*/
/* M1: Nepodmineny prumer */
%setRole(
1, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'N',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M2: Buckova metoda */
%setRole(
2, 				/* method */
'N',			/* N prediktor */
'N',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'N',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M3: Midrange */
%setRole(
3, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'N',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M4 */
%setRole(
4, 				/* method */
'N',			/* N prediktor */
'N',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'N',			/* B cilova */
'Y',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);


/* M5 */
%setRole(
5, 				/* method */
'N',			/* N prediktor */
'N',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'N',			/* B cilova */
'Y',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);


/* M6 */
%setRole(
6, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'N',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M7 */
%setRole(
7, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M8 */
%setRole(
8, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'N',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M9 */
%setRole(
9, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M10 */
/* diskutabilni, zda pouzit linearni regresi */
%setRole(
10, 				/* method */
'Y',			/* N prediktor */
'N',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'N',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M11 */
%setRole(
11, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M12 */
%setRole(
12, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M13 */
%setRole(
13, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M14 */
%setRole(
14, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M15 */
%setRole(
15, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M16 */
%setRole(
16, 				/* method */
'Y',			/* N prediktor */
'N',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'N',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M17 */
%setRole(
17, 				/* method */
'Y',			/* N prediktor */
'N',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'N',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M18 */
%setRole(
18, 				/* method */
'Y',			/* N prediktor */
'N',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M19 */
%setRole(
19, 				/* method */
'Y',			/* N prediktor */
'N',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M20: EM+MCMC */
%setRole(
20, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'N',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M21: Parametricka regrese */
if gen_type in ('N','B') then M21 = 'Y'; else M21 = 'N';
%setRole(
21, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'N',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M22: Propensitni skore */
if gen_type in ('N','B') then M22 = 'Y'; else M22 = 'N';
%setRole(
22, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'N',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M23 */
%setRole(
23, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'N',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M24 */
%setRole(
24, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M25 */
%setRole(
25, 				/* method */
'N',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M26 */
%setRole(
26, 				/* method */
'N',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M27 */
%setRole(
27, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M28 */
%setRole(
28, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M29 */
%setRole(
29, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M30 */
%setRole(
30, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M31 */
%setRole(
31, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'N',			/* B cilova */
'N',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M32 */
%setRole(
32, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M33: Listwise Pairwise */
%setRole(
33, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M34 */
%setRole(
34, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M35: Regrese + Diskriminacni analyza */
%setRole(
35, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M36: Median */
%setRole(
36, 				/* method */
'Y',			/* N prediktor */
'Y',			/* B prediktor */
'N',			/* C prediktor */
'N',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'Y',			/* N cilova */
'Y',			/* B cilova */
'N',			/* C cilova */
'N',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* M37: Modus */
%setRole(
37, 				/* method */
'N',			/* N prediktor */
'Y',			/* B prediktor */
'Y',			/* C prediktor */
'Y',			/* D prediktor */
'real',			/* N prediktor type */
'binominal',	/* B prediktor type */
'polynominal',	/* C prediktor type */
'polynominal',	/* D prediktor type */
'N',			/* N cilova */
'Y',			/* B cilova */
'Y',			/* C cilova */
'Y',			/* D cilova */
'real',			/* N cilova type */
'binominal',	/* B cilova type */
'polynominal',	/* C cilova type */
'polynominal'	/* D cilova type */
);

/* pridani jedinecneho order klice */
idx = _N_;

%runquit;

%macro setPreference;
data Imputace.metabase;
set Imputace.metabase;
%do a = 1 %to 37;
	if M&a = 'Y' then do;
		if gen_type = 'N' then M&a._srt_key = 1;
		if gen_type = 'D' then M&a._srt_key = 2;
		if gen_type = 'C' then M&a._srt_key = 1;
		if gen_type = 'B' then M&a._srt_key = 2;
		if mod_role in ('R','C') then M&a._srt_key = 0;
	end;
	if M&a._C = 'Y' then do;
		if gen_type = 'N' then M&a._srt_key_C = 1;
		if gen_type = 'D' then M&a._srt_key_C = 2;
		if gen_type = 'C' then M&a._srt_key_C = 1;
		if gen_type = 'B' then M&a._srt_key_C = 2;
		if mod_role in ('R','C') then M&a._srt_key_C = 0;
	end;
%end;
%runquit;

%do b=1 %to 37;
proc sql;
create table stat_M&b as
select
strip(MEMNAME) as MEMNAME,
strip(orig_prom) as orig_prom,
min(M&b._srt_key) as M&b._srt_key_min
from Imputace.metabase
where M&b = 'Y'
group by 1,2
order by 1,2;
%runquit;
%end;

%do c=1 %to 37;
proc sql;
create table stat_M&c._c as
select
strip(MEMNAME) as MEMNAME,
strip(orig_prom) as orig_prom,
min(M&c._srt_key_C) as M&c._srt_key_C_min
from Imputace.metabase
where M&c._C = 'Y'
group by 1,2
order by 1,2;
%runquit;
%end;

proc sort data=Imputace.metabase; by MEMNAME orig_prom; %runquit;

data Imputace.metabase;
merge Imputace.metabase (IN=In1)
%do d=1 %to 37;
%let e=%eval(&d+1);
stat_M&d (IN=In&e)
%end;
%do f=1 %to 37;
%let g=%eval(&f+38);
stat_M&f._c (IN=In&g)
%end;
;
by MEMNAME orig_prom;
if In1 = 1;
%runquit;

data Imputace.metabase;
set Imputace.metabase;
%do h=1 %to 37;
if missing(M&h._srt_key) = 0 and M&h._srt_key > M&h._srt_key_min then M&h = 'N';
if missing(M&h._srt_key_C) = 0 and M&h._srt_key_C > M&h._srt_key_C_min then M&h._C = 'N';
%end;
%runquit;

/* nastaveni Class aby obsahovala pouze promenne vysvetlovane v modelu */
data Imputace.metabase;
set Imputace.metabase;
%do xx = 1 %to 37;
	if imput_role = 'Y' then do;
		/*if M&xx = 'Y' then M&xx = 'N';*/
		/*if M&xx._C = 'N' then M&xx._C = 'Y';*/
	end;
	else do;
		if M&xx._C = 'Y' then M&xx._C = 'N';
	end;
%end;
%runquit;

%mend setPreference;
%setPreference;



/* pridani zakladnich charakteristik */

%macro minMax;
proc sql;
create table bins as 
select lowcase(strip(MEMNAME)) as MEMNAME, strip(NAME) as NAME
from Imputace.metabase 
where TYPE = 1;
%runquit;

data bins;
set bins;
idx = _N_;
%runquit;

proc sql;
select count(*)
into: cnt from bins;
%runquit;

%do i=1 %to &cnt;

proc sql;
select MEMNAME, NAME
into: MEMNAME, :NAME
from bins where idx = &i;
%runquit;

%let mem=%sysfunc(compress(&MEMNAME));
%let nm=%sysfunc(compress(&NAME));

proc means data=Imputace.&mem MAX MIN; 
var &nm;
output out=median MAX=MAX MIN=MIN;
%runquit;

proc sql;
update Imputace.metabase set MIN = (select MIN from median) where strip(NAME)="&nm" and lowcase(strip(MEMNAME)) = "&mem";
update Imputace.metabase set MAX = (select MAX from median) where strip(NAME)="&nm" and lowcase(strip(MEMNAME)) = "&mem";
%runquit;
	
%end;

%mend minMax;
%minMax;

proc sql;
select MEMNAME, NAME from Imputace.metabase where mod_role is null;
%runquit;

proc sql;
drop table CDM.MDR;
%runquit;

data CDM.MDR;
set Imputace.metabase;
%runquit;

/* nastaveni kontrol */
proc sql;
create table mdr_err_gtype as select * from Imputace.metabase where gen_type is null;
create table mdr_err_stats as select * from Imputace.metabase where TYPE=1 and (MAX is null or MIN is null);
create table mdr_err_ints as select * from Imputace.metabase where gen_type='N' and (Int_1 is null and Int_2 is null and Int_3 is null);
%runquit;

/*
proc sql;
create table tst as
select * from Imputace.metabase where strip(MEMNAME)='DS11' and strip(NAME)='a7';
quit;
*/
