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

%macro Addr_parse_unit(unitlbl,debug=N);

 %local unitlbllen unitlbl1pl unitlbl2pl;

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
 
 %if %mparam_is_yes( &debug ) %then %do;
   put "Addr_parse_unit: " _ap_temp_ad=;
 %end;
  
%mend Addr_parse_unit;

