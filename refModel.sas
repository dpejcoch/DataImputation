/* Vytvoreni referencniho modelu a export promennych relevantnich pro model do txt */
/*%glm(Imputace.Ds1, BINOMIAL, a5 a8 a10 a12 a13 a14, a15,);*/
%glm(Imputace.Ds1, BINOMIAL, a8 a10 a13 a14 a12_2 a5_1, a15, a8);
%glm(Imputace.Ds2, BINOMIAL, a8 a11 a4_1 a10_1 , a20, a8 a11);
/*
%glm(Imputace.Ds3, BINOMIAL, a2 a3 a8 a9 a10 a12 a13, a14,);
*/
%glm(Imputace.Ds3, BINOMIAL, a2 a5 a8 a9 a12, a14, a2 a9 a12);

%glm(Imputace.Ds4, MULTINOMIAL, a1 a2 a3 a4 a5 a6 a7 a8 a10 a12 a13 a16 a17 a18, a19,);
%glm(Imputace.Ds5, NORMAL, a8 a10 a11 a14 a16 a18 a19 a20 a24 a27 a28 a31 a32 a34 a35, a36,);
%glm(Imputace.Ds6, MULTINOMIAL, a1 a2 a5 a6 a7 a8 a9, a10,);
/*
%glm(Imputace.Ds7, BINOMIAL, a3 a11 a12 a2_Private a7_Exec_managerial a8_Not_in_family, a15,);
*/
%glm(Imputace.Ds7, BINOMIAL, a1 a2 a8 a11 a12 a13, a15, a2 a8);
/*
%glm(Imputace.Ds8, MULTINOMIAL, a1 a6 a10 a12 a13 a14 a15 a2_blue_collar a3_married a4_primary a7_no a8_no a9_cellular a11_jul a16_success, a17,);
*/
%glm(Imputace.Ds8, BINOMIAL, a2 a3   a6  a7_1 a8_1 a11 a12 a13  a16, a17, a2 a3  a11 a16);

%glm(Imputace.Ds9, MULTINOMIAL, a1_1 a2_4 a3_1 a4_1 a5_1 a6_1 a7_2, a9,);

%glm(Imputace.Ds10, MULTINOMIAL, a1 a2 a4 a6 a7 a8 a9 a10 a11, a12,);
%glm(Imputace.Ds11, NORMAL, a4 a6 a7 , a9, a7 );
%glm(Imputace.Ds12, NORMAL, a1 a2 a3 a6 a14 a17 a20 a21, a22, a3);

libname imputace "r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\saslib";
%let path=r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\;
%include "r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\sas\toolsMcr.sas";

options mprint;

%let path=r:\ROOT\wamp\www\dataqualitycz\vyzkum\Imputace\;

%macro output(i,list);

proc sql;
create view Ds&i as select %sysfunc(translate(&list,' ','"')) from Imputace.Ds&i;
quit;

proc export data=Ds&i outfile="&path.data\Ds&i..csv" replace; delimiter=','; run; quit;

%mend output;

%macro outputIter();
	%do i = 1 %to 12;
		proc sql;
			select distinct NAME
		   	into :varlist separated by ','
		   	from Imputace.Metabase
			where lowcase(MEMNAME) = "ds&i" and miss_role = 'Y' 
			order by idx;
		quit;
		%put "ds"+&i;
		%put &varlist;

		%output(&i,"&varlist");

	%end;
%mend outputIter;

%outputIter;

