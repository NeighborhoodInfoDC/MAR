/**************************************************************************
 Program:  Addr_parse_unit.sas
 Library:  MAR
 Project:  NeigborhoodInfo DC
 Author:   P. Tatian (with code from B. Bajaj)
 Created:  1/24/16
 Version:  SAS 9.2

 Description:  Autocall macro used by %Address_parse() macro to
 process apartment or unit specifications.

 Modifications: 
  01/24/16 PAT Adapted from RealProp macro %Addr_parse_unit().
**************************************************************************/

%macro Addr_parse_unit(unitlbl);

 *These macro variables denote lengths and character positions and make the macro more dynamic.;
 
 %let unitlbllen = %length(%left(%trim(&unitlbl.))); *length is equal to 3 for APT and 4 for UNIT;
 %let unitlbl1pl = %eval(&unitlbllen. + 1); *first character following unitlbl followed by a space, e.g. APT ?_ or UNIT ?_ ;
 %let unitlbl2pl = %eval(&unitlbllen. + 2); *second character following unitlbl followed by a space, e.g. APT _? or UNIT _?;


 _ap_temp_ad = "" || trim(left(compbl(_ap_temp_ad))) || "";


 _ap_temp_ad = tranwrd(_ap_temp_ad," &unitlbl. NO"," &unitlbl.#");

 *As long as : (colon) is removed before address_parse macro is applied, this line may remain commented-out.;
 *****_ap_temp_ad = tranwrd(_ap_temp_ad," &unitlbl.:"," &unitlbl.#");

 **** Added PT 3/2/05 ******************************;
 _ap_temp_ad =tranwrd(_ap_temp_ad," &unitlbl. #"," &unitlbl.#");
 ***************************************************;
 
 _ap_temp_ad = tranwrd(_ap_temp_ad,"##","#");

 **** Added BB 4/4/05 ******************************;
 *Added the following back in, as it is necessary if the logic of the stmts below is to work properly.;
 
 _ap_temp_ad = tranwrd(_ap_temp_ad," &unitlbl.# "," &unitlbl.#");
 *************************************************BB;

 _ap_temp_ad = tranwrd(_ap_temp_ad,"##","#");

 **** Added BB 4/19/05 ******************************;
 *Simple solution that replaces the complex algorithm shown below (after the mend statement).;
 
 _ap_temp_ad = tranwrd(_ap_temp_ad," &unitlbl. "," &unitlbl.#");
 *************************************************BB;

 _ap_temp_ad = tranwrd(_ap_temp_ad,"##","#");
 
 _ap_temp_ad = trim(left(compbl(_ap_temp_ad)));
  
 **** Added BB 4/19/05 ******************************;
 *If used right at the start of the address, APT was used to refer to apartment number that was actually a street number.;
 
 *NOTE: This may not be a very good solution, because this may not be true for UNIT. Should further inspect such cases;
 *where the word UNIT is at the beginning of address.;
 
 if _ap_temp_ad =: "&unitlbl.#" or _ap_temp_ad =: "&unitlbl.-" then
    do;
       if indexc(substr(_ap_temp_ad,&unitlbl1pl.,1),"1234567890")>0 then _ap_temp_ad = substr(_ap_temp_ad,&unitlbl1pl.);
       **f_apt =2;
    end;
 *************************************************BB;
  
%mend Addr_parse_unit;


 /*
 **** Added BB 4/4/05 ******************************;
 
 *This complex algorithm was initially developed to uniquely resolve variations of apartment or unit number;
 *references that followed words such as APT or UNIT. It came with certain shortcomings. First, it failed;
 *to exhaust the list of possibilities. Moreover, since historically this piece of code was suspicious of;
 *references that could be confused for street directions, it did not resolve cases where letters E, W, S;
 *or N followed APT or UNIT, e.g. APT E-1, or UNIT S.; 
 

 unit_index = index(_ap_temp_ad,"&unitlbl. ");
 
 unit_pl1 = substr(_ap_temp_ad,unit_index+&unitlbl1pl.,1);
 unit_pl2 = substr(_ap_temp_ad,unit_index+&unitlbl2pl.,1);
 
 if unit_index > 0 then
  do;
	 *Check if unitlbl is followed by a letter and then a space, comma, dash or a number, e.g. APT D1, UNIT C-4;
     if indexc(unit_pl1,"ABCDFGHIJKLMOPQRTUVXYZ")=1 and indexc(unit_pl2," ,-123456789")=1 then           
          _ap_temp_ad = tranwrd(_ap_temp_ad,"&unitlbl. "," &unitlbl.#");
     *Check if unitlbl is followed by a letter and nothing after that, e.g. APT B, UNIT C;
     else if indexc(unit_pl1,"ABCDFGHIJKLMOPQRTUVXYZ")=1 and length(substr(_ap_temp_ad,unit_index+&unitlbl1pl.))=1 then
          _ap_temp_ad = tranwrd(_ap_temp_ad,"&unitlbl. "," &unitlbl.#");
     *Check if unitlbl is followed by a number and then a letter, e.g. APT 5A, UNIT 1F;
     else if indexc(unit_pl1,"123456789")=1 and indexc(unit_pl2,"ABCDFGHIJKLMOPQRTUVXYZ")=1 then
          _ap_temp_ad = tranwrd(_ap_temp_ad,"&unitlbl. "," &unitlbl.#");
     *Check if unitlbl is not followed immediately by a letter, e.g. APT 4, UNIT 304-C;
     else if indexc(unit_pl1,"ABCDEFGHIJKLMNOPQRSTUVWXYZ")=0 then
          _ap_temp_ad = tranwrd(_ap_temp_ad,"&unitlbl. "," &unitlbl.#");
          
     **f_apt =1;
  end;
 *************************************************BB;
 */
