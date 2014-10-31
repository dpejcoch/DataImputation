libname imputace "r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\saslib";
%let path=r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\data\imputed\;
%include "r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\sas\toolsMcr.sas";
libname CDM odbc dsn='CDM';

proc sql noprint;
delete from Imputace.Imputbenchmark;
quit;

%macro VarExist(ds,var);
	%local rc dsid result;
	%let dsid=%sysfunc(open(&ds));
	%if %sysfunc(varnum(&dsid,&var)) > 0 %then %do;
		%let result=1;
		%put NOTE: Var &var exists in &ds;
	%end;
	%else %do;
		%let result=0;
		%put NOTE: Var &var not exists in &ds;
	%end;
	%let rc=%sysfunc(close(&dsid));
	&result
%mend VarExist;

%macro strreplace(in_what, from_what, to_what);                                 
    %let s=&in_what;                                                            
    %do %while(%index(&s, &from_what) > 0);                                     
        %let pos_fw = %index(&s, &from_what);                                   
        %if &pos_fw > 0 %then %do;                                              
            %let l_str = %substr(&s, 1, %eval(&pos_fw - 1));                    
            %let r_str = %substr(&s, %eval(&pos_fw + %length(&from_what)));     
            %let s=&l_str&to_what&r_str;                                        
        %end;                                                                   
    %end;                                                                       
    &s                                                                          
%mend strreplace; 

data model;
attrib
dset length=3
distr length=$20
predictors length=$100
target length=$10
classes length = $100
;
				
dset = 1;
distr = "BINOMIAL";
predictors = "a8_miss a10_miss a13_miss a14_miss a12_2_miss a5_1_miss";
target = "a15_miss";
classes = "a8_miss";
output;

dset = 2;
distr = "BINOMIAL";
predictors = "a8_miss a11_miss a4_1_miss a10_1_miss";
target = "a20_miss";
classes = "a8_miss a11_miss";
output;

dset = 3;
distr = "BINOMIAL";
predictors = "a2_miss a5_miss a8_miss a9_miss a12_miss";
target = "a14_miss";
classes = "a2_miss a9_miss a12_miss";
output;

dset = 4;
distr = "MULTINOMIAL";
predictors = "a1_miss a2_miss a3_miss a4_miss a5_miss a6_miss a7_miss a8_miss a10_miss a12_miss a13_miss a16_miss a17_miss a18_miss";
target = "a19_miss";
classes = "";
output;

dset = 5;
distr = "NORMAL";
predictors = "a8_miss a10_miss a11_miss a14_miss a16_miss a18_miss a19_miss a20_miss a24_miss a27_miss a28_miss a31_miss a32_miss a34_miss a35_miss";
target = "a36_miss";
classes = "";
output;

dset = 6;
distr = "MULTINOMIAL";
predictors = "a1_miss a2_miss a5_miss a6_miss a7_miss a8_miss a9_miss";
target = "a10_miss";
classes = "";
output;

dset = 7;
distr = "BINOMIAL";
predictors = "a1_miss a2_miss a8_miss a11_miss a12_miss a13_miss";
target = "a15_miss";
classes = "a2_miss a8_miss";
output;

dset = 8;
distr = "BINOMIAL";
predictors = "a2_miss a3_miss a6_miss a7_1_miss a8_1_miss a11_miss a12_miss a13_miss a16_miss";
target = "a17_miss";
classes = "a2_miss a3_miss a11_miss a16_miss";
output;

dset = 9;
distr = "MULTINOMIAL";
predictors = "a1_1_miss a2_4_miss a3_1_miss a4_1_miss a5_1_miss a6_1_miss a7_2_miss";
target = "a9_miss";
classes = "";
output;

dset = 10;
distr = "MULTINOMIAL";
predictors = "a1_miss a2_miss a4_miss a6_miss a7_miss a8_miss a9_miss a10_miss a11_miss";
target = "a12_miss";
classes = "";
output;

dset = 11;
distr = "NORMAL";
predictors = "a4_miss a6_miss a7_miss";
target = "a9_miss";
classes = "a7_miss";
output;

dset = 12;
distr = "NORMAL";
predictors = "a1_miss a2_miss a3_miss a6_miss a14_miss a17_miss a20_miss a21_miss";
target = "a22_miss";
classes = "a3_miss";
output;

run;
	

/*options mprint;*/

%macro interRes;
	/* pro 12 datasetu */
	%do i=1 %to 12;
		%let dset=ds&i;

		/* vyber referencni promenne pro model z puvodni sady a pridej jim suffix */
		proc sql noprint;
			select 
			cat(strip(NAME)," as ",strip(NAME),"_ref"),
			cat(strip(NAME)," as ",strip(NAME),"_miss")
   			into :reflist separated by ', ', :misslist separated by ', '
   			from Imputace.Metabase
			where lowcase(strip(MEMNAME)) = "ds&i" and mod_role in ('P','C')
			;
		quit;

		proc sql noprint;
			create table &dset as select &reflist., idx from Imputace.&dset order by idx;
		quit;

		/*%put &reflist;*/

		/* pro 34 metod */
		%do j=1 %to /*34*/37;
			%let method=M&j;
			/*%put "start metody: " &j "================================================================================================";*/

			/* nacti vsechny promenne z imputovaneho data setu, jejich typy, delky */
			proc sql noprint;
				select 
				cat(strip(NAME)," length=", case when TYPE=2 then "$" else "" end,LENGTH),
				cat(strip(NAME), case when TYPE=2 then "$" else "" end)
	   			into :atriblist separated by ' ', :infilelist separated by ' '
	   			from Imputace.Metabase
				where lowcase(MEMNAME) = "ds&i" and (M&j = 'Y' or M&j._C = 'Y')
				order by idx
				;
			quit;
			
			/* zredukuj na ty v roli imputovane promenne */
			proc sql noprint;
				select strip(NAME)
				into: restricted separated by ' '
				from Imputace.Metabase
				where lowcase(MEMNAME) = "ds&i" and M&j._C = 'Y'
				;
			quit;
			/*
			%put &restricted;
			%put &atriblist;
			%put &infilelist;
			*/
			/* pro pocty missingu */
			%do k=5 %to 50 %by 5;

				/*%put "start missingu: " &k "============================================================================================";*/
				
				/* imputovany data set */
				data ds&i._M&j (keep = idx &restricted);
				attrib
				idx length=8
				&atriblist.
				;
				infile "&path.ds&i._&k._M&j._imp_.csv" dsd missover delimiter=',' firstobs=2;
				input
				idx
				&infilelist.
				;
				run;

				/*%put &k;*/

				/* data set s missingy */
				proc sql noprint;
				create table &dset._miss as select &misslist., idx from Imputace.&dset._&k order by idx;
				quit;

				/* zaokrouhli binarizovane imputace ================================================================================= */
				proc contents data = ds&i._M&j out=meta noprint; run; quit;

				proc sql noprint;
				delete from meta where strip(NAME) = 'idx';
				delete from meta where strip(NAME) in (select strip(NAME) from Imputace.Metabase where gen_type in ('N','C','D'));
				quit;

				data meta meta1;
				set meta;
				idx = _N_;
				run;

				%let cnt=;

				proc sql noprint;
				select count(*) into: cnt from meta;
				quit;
				
				%if %eval(&cnt > 0) %then %do;
					%do l=1 %to &cnt;

						%let nm=;
						%let nms=;

						proc sql noprint;
						select strip(NAME) into: nm from meta where idx = &l;
						quit;

						%let nms=%sysfunc(compress(&nm));

						data ds&i._M&j cntrl0_&l;
						set ds&i._M&j;
						&nms = round(&nms,1);	
						run;
					%end;
				%end;

				/* zretez data sety dohromady ================================================================================ */
				proc sort data = ds&i._M&j; by idx; run; quit;

				data ds&i._M&j._&k cntrl;
				merge
				ds&i._M&j (IN=In1)
				ds&i (IN=In2)
				&dset._miss (IN=In3)
				;
				by idx;
				if In1 = 1;
				run;

				/* proved doplneni promennych pro model na zaklade imputovanych ================================================ */
				/* imputovane */
				proc contents data = ds&i._M&j out=meta2 noprint; run; quit;
				/* missings */
				proc contents data = &dset._miss out=meta3 noprint; run; quit;

				proc sql noprint;
				delete from meta2 where strip(NAME) = 'idx';
				quit;

				data meta3;
				set meta3;
				name_part=strip(scan(strip(NAME),1,'_'));
				run;

				data meta2;
				set meta2;
				name_part=strip(scan(strip(NAME),1,'_'));
				idx = _N_;
				run;

				%let cnt = ;

				proc sql noprint;
				select count(*) into: cnt from meta2;
				quit;
				
				/* projdi vsechny imputovane a najdi k nim ekvivalent z missings */
				%do l=1 %to &cnt;

					/*%put &l "========================";*/

					proc sql noprint;
						select strip(NAME) into: imputed from meta2 where idx = &l;
					quit;

					%let imputed=%sysfunc(strip(&imputed));

					proc sql noprint;
					select 
					strip(NAME),
					TYPE,
					LENGTH,
					strip(gen_type),
					strip(orig_prom),
					Int_1,
					Int_2,
					Int_3,
					Int_4,
					Int_5,
					Int_6,
					Int_7,
					Int_8,
					Int_9,
					Int_10,
					Int_11,
					Int_12,
					Int_13,
					Int_14,
					Int_15,
					Int_16
					into
					:NAME,
					:TYPE,
					:mLENGTH,
					:gen_type,
					:orig_prom,
					:Int_1,
					:Int_2,
					:Int_3,
					:Int_4,
					:Int_5,
					:Int_6,
					:Int_7,
					:Int_8,
					:Int_9,
					:Int_10,
					:Int_11,
					:Int_12,
					:Int_13,
					:Int_14,
					:Int_15,
					:Int_16
					from Imputace.metabase 
					where lowcase(strip(MEMNAME)) ="ds&i" and strip(NAME) = "&imputed";
					quit;
					
					%let gen_type=%sysfunc(strip(&gen_type));
					%let orig_prom=%sysfunc(strip(&orig_prom));
					%let Int_1=%sysfunc(strip(&Int_1));
					%let Int_2=%sysfunc(strip(&Int_2));
					%let Int_3=%sysfunc(strip(&Int_3));
					%let Int_4=%sysfunc(strip(&Int_4));
					%let Int_5=%sysfunc(strip(&Int_5));
					%let Int_6=%sysfunc(strip(&Int_6));
					%let Int_7=%sysfunc(strip(&Int_7));
					%let Int_8=%sysfunc(strip(&Int_8));
					%let Int_9=%sysfunc(strip(&Int_9));
					%let Int_10=%sysfunc(strip(&Int_10));
					%let Int_11=%sysfunc(strip(&Int_11));
					%let Int_12=%sysfunc(strip(&Int_12));
					%let Int_13=%sysfunc(strip(&Int_13));
					%let Int_14=%sysfunc(strip(&Int_14));
					%let Int_15=%sysfunc(strip(&Int_15));
					%let Int_16=%sysfunc(strip(&Int_16));
					
					
					%let imputed=%sysfunc(scan(&imputed,1,'_'));
					/*%put "imputed" &imputed "================";*/
					
					proc sql noprint;
						create table listOfVars as 
						select strip(NAME) as NAME from meta3 where strip(name_part)="&imputed";
					quit;

					data listOfVars;
					set listOfVars;
					idx = _N_;
					run;

					proc sql noprint;
						select count(*) into: varCnt from listOfVars;
					quit;

					%if %eval(&varCnt > 0) %then %do;
						%do m=1 %to &varCnt;
							proc sql noprint;
								select strip(NAME) into :lkpVar from listOfVars where idx = &m;
							quit;
							
							%let lkpVar=%strreplace(&lkpVar,_miss,);
							%let lkpVar=%sysfunc(strip(&lkpVar));

							proc sql noprint;
							select 
							strip(cat(strip(NAME),"_miss")),
							TYPE,
							LENGTH,
							strip(gen_type),
							strip(orig_prom),
							Int_1,
							Int_2,
							Int_3,
							Int_4,
							Int_5,
							Int_6,
							Int_7,
							Int_8,
							Int_9,
							Int_10,
							Int_11,
							Int_12,
							Int_13,
							Int_14,
							Int_15,
							Int_16
							into
							:mNAME,
							:mTYPE,
							:mLENGTH,
							:mgen_type,
							:morig_prom,
							:mInt_1,
							:mInt_2,
							:mInt_3,
							:mInt_4,
							:mInt_5,
							:mInt_6,
							:mInt_7,
							:mInt_8,
							:mInt_9,
							:mInt_10,
							:mInt_11,
							:mInt_12,
							:mInt_13,
							:mInt_14,
							:mInt_15,
							:mInt_16
							from Imputace.metabase 
							where lowcase(strip(MEMNAME)) ="ds&i" and strip(NAME) = "&lkpVar";
							quit;
							
							%let mgen_type=%sysfunc(strip(&mgen_type));
							%let morig_prom=%sysfunc(strip(&morig_prom));
							%let mInt_1=%sysfunc(strip(&mInt_1));
							%let mInt_2=%sysfunc(strip(&mInt_2));
							%let mInt_3=%sysfunc(strip(&mInt_3));
							%let mInt_4=%sysfunc(strip(&mInt_4));
							%let mInt_5=%sysfunc(strip(&mInt_5));
							%let mInt_6=%sysfunc(strip(&mInt_6));
							%let mInt_7=%sysfunc(strip(&mInt_7));
							%let mInt_8=%sysfunc(strip(&mInt_8));
							%let mInt_9=%sysfunc(strip(&mInt_9));
							%let mInt_10=%sysfunc(strip(&mInt_10));
							%let mInt_11=%sysfunc(strip(&mInt_11));
							%let mInt_12=%sysfunc(strip(&mInt_12));
							%let mInt_13=%sysfunc(strip(&mInt_13));
							%let mInt_14=%sysfunc(strip(&mInt_14));
							%let mInt_15=%sysfunc(strip(&mInt_15));
							%let mInt_16=%sysfunc(strip(&mInt_16));
							
							/* logika imputace */
							%put "logika imputace";
							%if "&gen_type" = "N" %then %do;
								%if "&mgen_type" = "N" %then %do;
								/*
									%put "gen N";
									%put "mgen N";
									*/
									data ds&i._M&j._&k;
									set ds&i._M&j._&k;
									if missing(&mName) = 1 then &mName = &Name;
									run;

								%end;
								
							%end;
							%if "&gen_type" = "B" %then %do;
								%if "&mgen_type" = "C" %then %do;
								/*
									%put "gen B";
									%put "mgen C";
								*/
									%let catStr=;
									%let catStr=%sysfunc(scan(&Name,2,'_'));
									%let catStr=%sysfunc(strip(&catStr));

									data ds&i._M&j._&k;
									set ds&i._M&j._&k;
										if missing(&mName) = 1 then do;
											if &Name = 1 then &mName = strip(&catStr);
											if missing(&mName) = 1 then &mName = 'X';
											%put &catStr;
										end;
									run;

								%end;
								%if "&mgen_type" = "B" %then %do;
								/*
									%put "gen B";
									%put "mgen B";
								*/
									data ds&i._M&j._&k;
									set ds&i._M&j._&k;
									if missing(&mName) = 1 then &mName = &Name;
									run;
								%end;
								
							%end;
							%if "&gen_type" = "C" %then %do;
								%if "&mgen_type" = "C" %then %do;
								/*
									%put "gen C";
									%put "mgen C";
								*/
									data ds&i._M&j._&k;
									set ds&i._M&j._&k;
									if missing(&mName) = 1 then &mName = &Name;
									run;
								%end;
								%if "&mgen_type" = "B" %then %do;
								/*
									%put "gen C";
									%put "mgen B";
								*/
									%let binStr=;
									%let binStr=%sysfunc(scan(&lkpVar,2,'_'));
									%let binStr=%sysfunc(strip(&binStr));

									data ds&i._M&j._&k;
									set ds&i._M&j._&k;
									if missing(&mName) = 1 then do;
									if &Name = "&binStr" then &mName = 1; else &mName = 0;
									end;
									run;

								%end;
								
							%end;
							%if "&gen_type" = "D" %then %do;
								%if "&mgen_type" = "N" %then %do;
								/*
									%put "gen D";
									%put "mgen N";
								*/
									data ds&i._M&j._&k;
									set ds&i._M&j._&k;
									if missing(&mName) = 1 then do;
									if &Name = 'Int_1' then &mName = "&mInt_1";
									if &Name = 'Int_2' then &mName = "&mInt_2";
									if &Name = 'Int_3' then &mName = "&mInt_3";
									if &Name = 'Int_4' then &mName = "&mInt_4";
									if &Name = 'Int_5' then &mName = "&mInt_5";
									if &Name = 'Int_6' then &mName = "&mInt_6";
									if &Name = 'Int_7' then &mName = "&mInt_7";
									if &Name = 'Int_8' then &mName = "&mInt_8";
									if &Name = 'Int_9' then &mName = "&mInt_9";
									if &Name = 'Int_10' then &mName = "&mInt_10";
									if &Name = 'Int_11' then &mName = "&mInt_11";
									if &Name = 'Int_12' then &mName = "&mInt_12";
									if &Name = 'Int_13' then &mName = "&mInt_13";
									if &Name = 'Int_14' then &mName = "&mInt_14";
									if &Name = 'Int_15' then &mName = "&mInt_15";
									if &Name = 'Int_16' then &mName = "&mInt_16";
									end;
									run;

								%end;
																
							%end;

						%end;
					%end;
					
				%end;

				/* vytvor model */

				%let distr=;
				%let pred=;
				%let target=;
				%let classes=;
				
				proc sql noprint;
				select strip(distr), strip(predictors), strip(target), strip(classes)
				into: distr, :pred, :target, :classes
				from model where dset = &i;
				quit;
				/*
				%put &dist;
				%put &predictors;
				%put &target;
				%put &classes;
				*/
				%if %sysevalf(%superq(distr)=,boolean) = 0 %then %do;
					%let sdistr=%sysfunc(compress(&distr));
				%end;
				%else %do;
					%let sdistr=;
				%end;

				%if %sysevalf(%superq(pred)=,boolean) = 0 %then %do;
					%let spred=%sysfunc(compress(&pred));
				%end;
				%else %do;
					%let spred=;
				%end;

				%if %sysevalf(%superq(target)=,boolean) = 0 %then %do;
					%let starget=%sysfunc(compress(&target));
				%end;
				%else %do;
					%let starget=;
				%end;

				%if %sysevalf(%superq(classes)=,boolean) = 0 %then %do;
					%let sclasses=%sysfunc(compress(&classes));
				%end;
				%else %do;
					%let sclasses=;
				%end;

				%glm(ds&i._M&j._&k, &distr, &pred, &target, &classes);

				proc transpose data=Assessment out=out; run; quit;

				proc sql noprint;
				insert into Imputace.ImputBenchmark (tstmp,dst,method,nmiss,LL,FLL,AIC,AICC,BIC)
				select DATETIME(), &i, &j, &k, Col1, Col2, Col3, Col4, Col5
				from out where _NAME_ = 'Value';
				quit;

				proc sql noprint;
					drop table out;
					drop table Assessment;
				quit;
			
							
				/* porovnej hodnoty */

				
			%end;
		%end;
	%end;
%mend interRes;

%interRes;


proc sql noprint;
drop table CDM.Imputbenchmark;
quit;

data CDM.Imputbenchmark;
set Imputace.Imputbenchmark;
%runquit;


