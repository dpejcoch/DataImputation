libname imputace "r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\saslib";
%let path=r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\data\missings\;
%include "r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\sas\toolsMcr.sas";

options mprint;

%macro iterLoad;
%do i=1 %to /*2*/12;

	/* vsechno relevantni pro model, co neni v roli prediktor a class */

	proc sql;
	select distinct idx, NAME
   	into :idx separated by '', :varlist separated by ' '
   	from Imputace.Metabase
	where lowcase(MEMNAME) = "ds&i" /*and imput_role = 'Y'*/ and mod_role not in ('P','C')
	order by idx;
	%runquit;

	%put &varlist;

	data proxy;
	set imputace.ds&i (keep =  &varlist); 
	idx = _N_;
	%runquit;

	proc sort data=proxy; by idx; %runquit;

	/* promenne, ktere maji byt nacteny ze souboru s missingy */
	proc sql;
	select 
	idx, 
	cat(strip(NAME)," length=", case when TYPE=2 then "$" else "" end,LENGTH),
	cat(strip(NAME), case when TYPE=2 then "$" else "" end)
	into :idx separated by ' ', :atriblist separated by ' ', :infilelist separated by ' '
	from Imputace.Metabase
	where lowcase(MEMNAME) = "ds&i" and miss_role = 'Y'
	order by idx
	;
	%runquit;

	%do j=5 %to 50 %by 5;

		%let src=ds&i._&j;
		%put &src;
		
		/*
		%include "r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\sas\tmpl_ds&i..sas";
		%tmpl_ds&i.(&src,&path);

		*/
		
		/* imputovany data set */
		data imputace.ds&i._&j;
		attrib
		idx length=8
		&atriblist.
		;
		infile "&path.ds&i._&j..csv" dsd missover delimiter=',' firstobs=2  lrecl=6000;
		input
		idx
		&infilelist.
		;
		%runquit;

		proc sort data=imputace.&src; by idx; %runquit;

		data imputace.&src;
		merge imputace.&src (IN=In1) proxy (IN=In2);
		by idx;
		if In1 = 1;
		%runquit;

		proc contents data=imputace.&src out=meta; %runquit;

		proc sql;
		create table bin as select distinct strip(NAME) as name from meta where TYPE=1 and index(strip(NAME),'_') > 0;
		%runquit;

		data bin;
		set bin;
		idx = _N_;
		%runquit;

		proc sql;
		select count(*) into: cnt from bin;
		%runquit;

		%do w = 1 %to &cnt;

			proc sql;
			select strip(name) into: n from bin where idx = &w;
			%runquit;

			%put &n;

			%let cndt =%sysfunc(compress(&n));
			%put &cndt;

			proc sql;
			select cat("if missing(&cndt)=1 then ",strip(scan(NAME,1,'_')),"='';") 
			into: cmd3  separated by ' ' 
			from meta 
			where strip(NAME) = "&cndt" and TYPE=1;
			%runquit;

			%put &cmd3;

			data imputace.&src;;
			set imputace.&src;;
			&cmd3.;
			%runquit;

		%end;

		proc sql;
		create table lovars as select distinct strip(scan(NAME,1,'_')) as name from meta;
		%runquit;

		data lovars;
		set lovars;
		idx = _N_;
		%runquit;

		proc sql;
		select count(*) into: cnt from lovars;
		%runquit;

		%do w = 1 %to &cnt;

			proc sql;
			select strip(name) into: n from lovars where idx = &w;
			%runquit;

			%put &n;

			%let cndt =%sysfunc(compress(&n));
			%put &cndt;
			%let cmd=;
			%let cmd2=;
			
			/* pokryva propagaci missingu v puvodni promenne do jejich binarizovanych klonu */
			/* nastavi na null vsechny numericke promenne, ktere maji stejny prefix jako puvodni promenna */
			proc sql;
			select cat("if missing(&cndt)=1 then ",strip(NAME),"=.;") 
			into: cmd  separated by ' ' 
			from meta 
			where strip(scan(NAME,1,'_')) = "&cndt" and TYPE=1 and not strip(NAME) = "&cndt";
			%runquit;

			%put &cmd;
			
			/* pokryva propagaci missingu z puvodni promenne do diskretizovane promenne */
			proc sql;
			select cat("if missing(&cndt)=1 then ",strip(NAME),"_int ='';") 
			into: cmd2  separated by ' ' 
			from meta 
			where strip(NAME) = "&cndt" and TYPE=1;
			%runquit;

			%put &cmd2;

			data imputace.&src;
			set imputace.&src;
			/* skoring pro binarizovane */
			%if %sysevalf(%superq(cmd)=,boolean) = 1 %then %do;
				%put "No cmd";
			%end;
			%else %do;
				&cmd.;
			%end;

			%if %sysevalf(%superq(cmd2)=,boolean) = 1 %then %do;
				%put "No cmd2";
			%end;
			%else %do;
				&cmd2.;
			%end;
			%runquit;

		%end;
		
		/* vytvor podmineny vystup pro jednotlive metody dle jejich preferenci */
		%do met=1 %to 37;

			%let outvars=;
			%let sortlist=;

			proc sql;
			select 
			distinct 
			idx,
			strip(NAME),
			cat(strip(NAME)," label='",strip(NAME),"'")
	   		into :idx separated by ' ', :outvars separated by ' ', :sortlist separated by ' '
	   		from Imputace.Metabase
			where lowcase(MEMNAME) = "ds&i" and (M&met = 'Y' or M&met._C = 'Y')
			order by idx;
			%runquit;

			data imputace.&src._M&met;
			attrib
			idx label='idx'
			&sortlist.
			;
			set imputace.&src (keep = idx &outvars);
			%runquit;


		/*
		data imputace.&src (drop=idx_int);
		attrib
		idx label='idx'
		&sortlist.
		;
		set imputace.&src;
		run;
		*/

		proc export data=imputace.&src._M&met outfile="&path.&src._M&met._prep.csv" replace; delimiter=','; %runquit;

		%end;
		
	%end;

%end;

%mend iterLoad;
%iterLoad;

/*
proc sql;
create table test as
select * from imputace.metabase where strip(MEMNAME)='DS7' and imput_role = 'Y' order by idx;
quit;
*/
