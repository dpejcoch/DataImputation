libname imputace "r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\saslib";
%let path=r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\data\imputed\;
%include "r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\sas\imputeMcr.sas";
%include "r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\sas\toolsMcr.sas";

%macro iterImpute;
	/* pres vsechny data sety */
	%do i=1 %to 12;
		/* pres vsechny misingy */
		%do j=5 %to 50 %by 5;
			/* nacti vyberane atributy z data setu */

			/* M38 */
			/*
			%let BinVars=;
			%let NumVars=;
			%let snstr1=;
			%let snstr2=;
			
			proc sql;
			select strip(NAME) as NAME
			into: BinVars separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" and M20 = 'Y' and gen_type='B'
			order by idx;
			%runquit;

			proc sql;
			select strip(NAME) as NAME
			into: NumVars separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" and M20 = 'Y' and gen_type='N'
			order by idx;
			%runquit;

			%let min = ;
			%let max = ;
					
			%if %sysevalf(%superq(BinVars)=,boolean) = 1 %then %do;
				%put "No binary records";
			%end;
			%else %do;
				%let snstr1=%sysfunc(strip(&BinVars));
				data proxy1;
				set Imputace.ds&i._&j._M20 (keep= idx &BinVars);
				%runquit;
				%miMCMCMono(proxy1, &snstr1, 1, 0);
			%end;

			%let min = ;
			%let max = ;

			proc sql;
			select min(MIN), max(MAX) 
			into :min, :max
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" and M20 = 'Y' and gen_type='N' and MIN is not NULL and MAX is not NULL
			;
			%runquit;

			%put "Nastavene min a max: " &min &max;

			%if %sysevalf(%superq(NumVars)=,boolean) = 1 %then %do;
				%put "No numeric records";
			%end;
			%else %do;
				%let snstr2=%sysfunc(strip(&NumVars));
				data proxy2;
				set Imputace.ds&i._&j._M20 (keep= idx &NumVars);
				%runquit;
				%miMCMCMono(proxy2, &snstr2, &max, &min);
			%end;
		*/
		
/*
			%miPReg(ds&i._&j._M20_tmp, &snstr);		

			data ds&i._&j._M38_imp_;
			set ds&i._&j._M21;
			run;

			%exportCSV(ds&i._&j._M38_imp_,&path);

		*/
			/* M20 */ 
			
			proc sql;
			select strip(NAME) 
			into: vars separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" and M20 = 'Y';
			%runquit;

			/*
			proc sql;
			select max(MAX), min(MIN) 
			into: max, :min
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" and M20 = 'Y';
			quit;
			*/

			data ds&i._&j;
			set Imputace.ds&i._&j (keep= idx &vars);
			%runquit;

			%miMCMC(ds&i._&j, &vars /*, &min, &max*/);
			%exportCSV(ds&i._&j._M20_imp_,&path);
			
			
			/* M21 */
			/*
			proc sql;
			select strip(NAME) 
			into: vars separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" and M21 = 'Y';
			quit;

			data ds&i._&j;
			set Imputace.ds&i._&j (keep= idx &vars);
			run;

			%miPReg(ds&i._&j, &vars, 0, 1);
			%exportCSV(ds&i._&j._M21_imp_,&path);
			*/

			/* M22 */
			/*
			proc sql;
			select strip(NAME) 
			into: vars separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" and M22 = 'Y';
			quit;

			data ds&i._&j;
			set Imputace.ds&i._&j (keep= idx &vars);
			run;

			%miPScore(ds&i._&j, &vars, 0, 1);
			%exportCSV(ds&i._&j._M22_imp_,&path);
			*/

			/* M33 */
			/*
			proc sql;
			select strip(NAME) 
			into: vars separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" and M33 = 'Y' and mod_role in ('P','C');
			quit;

			data ds&i._&j;
			set Imputace.ds&i._&j (keep = idx &vars);
			run;

			%xWise(ds&i._&j, idx &vars,M33);

			%exportCSV(ds&i._&j._M33_imp_,&path);
			*/
			/* M35 */
			/*
			proc sql;
			select strip(NAME) 
			into: vars separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" and M35 = 'Y' and gen_type in ('N','B');
			quit;

			proc sql;
			select strip(NAME) 
			into: classes separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" and M35 = 'Y' and gen_type in ('C');
			quit;

			data ds&i._&j;
			set Imputace.ds&i._&j (keep= idx &vars &classes);
			run;

			%miRegDisc(ds&i._&j._M35_imp_, &vars, &classes);

			%exportCSV(ds&i._&j._M35_imp_,&path);
			*/

			/* Metody vyzadujici iterativni prochazeni vsech promennych  */
			
			/* M1 + M37 */
			/*
			%let vars1=;
			%let vars2=;
			
			proc sql;
			select strip(NAME) 
			into: vars1 separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" 
			and M1 = 'Y';
			quit;

			proc sql;
			select strip(NAME) 
			into: vars2 separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" 
			and M37 = 'Y';
			quit;
			
			
			%if %sysevalf(%superq(vars1)=,boolean) = 1 %then %do;
				data proxy1;
				set Imputace.ds&i._&j._M1 (keep = idx);
				run;
			%end;
			%else %do;
				data proxy1;
				set Imputace.ds&i._&j._M1 (keep = idx &vars1);
				run;
			%end;

			%if %sysevalf(%superq(vars2)=,boolean) = 1 %then %do;
				data proxy2;
				set Imputace.ds&i._&j._M37 (keep = idx);
				run;
			%end;
			%else %do;
				data proxy2;
				set Imputace.ds&i._&j._M37 (keep = idx &vars2);
				run;
			%end;
			
			proc contents data=proxy1 out=meta1 varnum; run; quit;
			
			proc sql;
			select count(*) into: cnt1 from meta1;
			quit;

			proc contents data=proxy2 out=meta2 varnum; run; quit;
			
			proc sql;
			select count(*) into: cnt2 from meta2;
			quit;
						
			%do x = 1 %to &cnt1;

			proc sql;
			select strip(NAME) into: name1 from meta1 where VARNUM=&x;
			quit;
			
			%let sname1 = ;
			%let sname1 = %sysfunc(strip(&name1));

			%simpleMean(proxy1,&sname1);

			%end;
			
			%do x = 1 %to &cnt2;

			proc sql;
			select strip(NAME) into: name2 from meta2 where VARNUM=&x;
			quit;
			
			%let sname2 = ;
			%let sname2 = %sysfunc(strip(&name2));

			%simpleMode(proxy2,&sname2);

			%end;

			proc sort data=proxy1; by idx; run; quit;
			proc sort data=proxy2; by idx; run; quit;

			data ds&i._&j._M1_imp_;
			merge proxy1 (IN=In1) proxy2 (IN=In2);
			by idx;
			run;

			%exportCSV(ds&i._&j._M1_imp_,&path);

			proc datasets library=work nodetails;
			delete proxy1 proxy2;
			run; quit;
			*/
			/* M36 + M37 */
			/*
			ods html close;
			ods html;

			%let vars1=;
			%let vars2=;
			
			proc sql noprint;
			select strip(NAME) 
			into: vars1 separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" 
			and M36 = 'Y';
			quit;

			proc sql noprint;
			select strip(NAME) 
			into: vars2 separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" 
			and M37 = 'Y';
			quit;
			
			
			%if %sysevalf(%superq(vars1)=,boolean) = 1 %then %do;
				data proxy1;
				set Imputace.ds&i._&j._M36 (keep = idx);
				run;
			%end;
			%else %do;
				data proxy1;
				set Imputace.ds&i._&j._M36 (keep = idx &vars1);
				run;
			%end;

			%if %sysevalf(%superq(vars2)=,boolean) = 1 %then %do;
				data proxy2;
				set Imputace.ds&i._&j._M37 (keep = idx);
				run;
			%end;
			%else %do;
				data proxy2;
				set Imputace.ds&i._&j._M37 (keep = idx &vars2);
				run;
			%end;
			
			proc contents data=proxy1 out=meta1 varnum noprint; run; quit;
			
			proc sql noprint;
			select count(*) into: cnt1 from meta1;
			quit;

			proc contents data=proxy2 out=meta2 varnum noprint; run; quit;
			
			proc sql noprint;
			select count(*) into: cnt2 from meta2;
			quit;
						
			%do x = 1 %to &cnt1;

			proc sql noprint;
			select strip(NAME) into: name1 from meta1 where VARNUM=&x;
			quit;
			
			%let sname1 = ;
			%let sname1 = %sysfunc(strip(&name1));

			%simpleMedian(proxy1,&sname1);

			%end;
			
			%do x = 1 %to &cnt2;

			proc sql noprint;
			select strip(NAME) into: name2 from meta2 where VARNUM=&x;
			quit;
			
			%let sname2 = ;
			%let sname2 = %sysfunc(strip(&name2));

			%simpleMode(proxy2,&sname2);

			%end;

			proc sort data=proxy1; by idx; run; quit;
			proc sort data=proxy2; by idx; run; quit;

			data ds&i._&j._M36_imp_;
			merge proxy1 (IN=In1) proxy2 (IN=In2);
			by idx;
			run;

			data ds&i._&j._M37_imp_;
			merge proxy1 (IN=In1) proxy2 (IN=In2);
			by idx;
			run;

			%exportCSV(ds&i._&j._M36_imp_,&path);
			*/

			/* M2 + M37 */
			/*
			ods html close;
			ods html;

			%let vars1=;
			%let vars2=;
			%let types=;

			proc sql noprint;
			select strip(NAME) 
			into: vars1 separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" 
			and M2 = 'Y' and not strip(NAME) = 'idx';
			quit;

			proc sql noprint;
			select strip(NAME) 
			into: vars2 separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" 
			and M37 = 'Y' and not strip(NAME) = 'idx';
			quit;

			%if %sysevalf(%superq(vars1)=,boolean) = 1 %then %do;
				data proxy1;
				set Imputace.ds&i._&j._M2 (keep = idx);
				run;
			%end;
			%else %do;
				data proxy1;
				set Imputace.ds&i._&j._M2 (keep = idx &vars1);
				run;
			%end;

			%if %sysevalf(%superq(vars2)=,boolean) = 1 %then %do;
				data proxy2;
				set Imputace.ds&i._&j._M37 (keep = idx);
				run;
			%end;
			%else %do;
				data proxy2;
				set Imputace.ds&i._&j._M37 (keep = idx &vars2);
				run;
			%end;
			
			proc contents data=proxy1 out=meta1 varnum noprint; run; quit;

			proc sql;
			delete from meta1 where strip(NAME)='idx';
			quit;

			data meta1;
			set meta1;
			idx = _N_;
			run;
			
			proc sql noprint;
			select count(*) into: cnt1 from meta1;
			quit;

			proc contents data=proxy2 out=meta2 varnum noprint; run; quit;

			proc sql;
			delete from meta2 where strip(NAME)='idx';
			quit;

			data meta2;
			set meta2;
			idx = _N_;
			run;
			
			proc sql noprint;
			select count(*) into: cnt2 from meta2;
			quit;

			proc sort data=proxy1; by idx; run; quit;
			proc sort data=proxy2; by idx; run; quit;

			data proxy3;
			merge proxy1 (IN=In1) proxy2 (IN=In2);
			by idx;
			run;
				
			%do x = 1 %to &cnt1;

			proc sql noprint;
			select strip(NAME) into: name1 from meta1 where idx=&x;
			quit;

			%let sname1 = %sysfunc(strip(&name1));

			%put &vars2;
			%put &sname1;
			%put &types;

			%condMean(proxy3,&vars2,&sname1);

			%end;
			
			%do x = 1 %to &cnt2;

			proc sql noprint;
			select strip(NAME) into: name2 from meta2 where idx=&x;
			quit;

			%let sname2 = %sysfunc(strip(&name2));

			%simpleMode(proxy2,&sname2);

			%end;

			proc sort data=proxy2; by idx; run; quit;
			proc sort data=proxy3; by idx; run; quit;

			data ds&i._&j._M2_imp_;
			merge proxy3 (IN=In1) proxy2 (IN=In2);
			by idx;
			run;

			%exportCSV(ds&i._&j._M2_imp_,&path);
			*/

			/* M3 + M37 */
			/*
			ods html close;
			ods html;

			%let vars1=;
			%let vars2=;
			
			proc sql noprint;
			select strip(NAME) 
			into: vars1 separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" 
			and M3 = 'Y';
			quit;

			proc sql noprint;
			select strip(NAME) 
			into: vars2 separated by ' '
			from imputace.metabase
			where strip(lowcase(MEMNAME))="ds&i" 
			and M37 = 'Y';
			quit;
			
			
			%if %sysevalf(%superq(vars1)=,boolean) = 1 %then %do;
				data proxy1;
				set Imputace.ds&i._&j._M3 (keep = idx);
				run;
			%end;
			%else %do;
				data proxy1;
				set Imputace.ds&i._&j._M3 (keep = idx &vars1);
				run;
			%end;

			%if %sysevalf(%superq(vars2)=,boolean) = 1 %then %do;
				data proxy2;
				set Imputace.ds&i._&j._M37 (keep = idx);
				run;
			%end;
			%else %do;
				data proxy2;
				set Imputace.ds&i._&j._M37 (keep = idx &vars2);
				run;
			%end;
			
			proc contents data=proxy1 out=meta1 varnum noprint; run; quit;
			
			proc sql noprint;
			select count(*) into: cnt1 from meta1;
			quit;

			proc contents data=proxy2 out=meta2 varnum noprint; run; quit;
			
			proc sql noprint;
			select count(*) into: cnt2 from meta2;
			quit;
						
			%do x = 1 %to &cnt1;

			proc sql noprint;
			select strip(NAME) into: name1 from meta1 where VARNUM=&x;
			quit;
			
			%let sname1 = ;
			%let sname1 = %sysfunc(strip(&name1));

			%midRange(proxy1,&sname1);

			%end;
			
			%do x = 1 %to &cnt2;

			proc sql noprint;
			select strip(NAME) into: name2 from meta2 where VARNUM=&x;
			quit;
			
			%let sname2 = ;
			%let sname2 = %sysfunc(strip(&name2));

			%simpleMode(proxy2,&sname2);

			%end;

			proc sort data=proxy1; by idx; run; quit;
			proc sort data=proxy2; by idx; run; quit;

			data ds&i._&j._M3_imp_;
			merge proxy1 (IN=In1) proxy2 (IN=In2);
			by idx;
			run;

			data ds&i._&j._M37_imp_;
			merge proxy1 (IN=In1) proxy2 (IN=In2);
			by idx;
			run;

			%exportCSV(ds&i._&j._M3_imp_,&path);
			*/
			
		%end;
	%end;
%mend iterImpute;

%iterImpute;










