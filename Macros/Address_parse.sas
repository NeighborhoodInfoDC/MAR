/**************************************************************************
 Program:  Address_parse.sas
 Library:  MAR
 Project:  NeigborhoodInfo DC
 Author:   P. Tatian (with code from B. Bajaj)
 Created:  1/24/16
 Version:  SAS 9.2
 
 Description:  Autocall macro for parsing DC addresses.
 
 Adapted from %Parse() macro created by Beata Bajaj (ver. 7/25/03).

 Modifications:
  01/24/16 PAT Adapted from RealProp macro %Address_parse().
**************************************************************************/

%macro Address_parse(
  address= ,
  var_prefix= addr_,
  debug=N
  );

 %if %mparam_is_yes( &debug ) %then %do;
   PUT "STARTING ADDRESS_PARSE() MACRO / " &address;
 %end;
 
 length &var_prefix.begnum &var_prefix.endnum 8 &var_prefix.numsuffix $ 16;
 length &var_prefix.street &var_prefix.apt &var_prefix.streetname &var_prefix.streettype &var_prefix.quad $ 200;

 **PT 08/21/05:  Added to suppress INFO: messages  **;
 length wrd1 wrd2 wrd3 d1_wrd d2_wrd /*fract1 fract2*/ _dcg_adr_apt $ 200;

 length _ap_temp_ad _ap_temp_ad_b $ 500;
 length pad pad1 $200. apt num num2 num3 numsuf $32. pflag $20.;

 _ap_temp_ad = trim(left(upcase(compbl(&address.)))) || "";

 ***************DELETE SELECT EXPRESSIONS ENCLOSED IN PAR. AND THEN REMOVE ALL REMAINING PARENTHASIS*;

 _ap_temp_ad =tranwrd(_ap_temp_ad ,"(R)", "");
 _ap_temp_ad =tranwrd(_ap_temp_ad ,"(D)", "");
 _ap_temp_ad =tranwrd(_ap_temp_ad ,"(UP)", "");
 _ap_temp_ad =tranwrd(_ap_temp_ad ,"(DOWN)", "");
 _ap_temp_ad =tranwrd(_ap_temp_ad ,"(UPPER)", "");
 _ap_temp_ad =tranwrd(_ap_temp_ad ,"(UPPER UNIT)", "");
 _ap_temp_ad =tranwrd(_ap_temp_ad ,"(LOWER)", "");
 _ap_temp_ad =tranwrd(_ap_temp_ad ,"(LOWER UNIT)", "");
 _ap_temp_ad =tranwrd(_ap_temp_ad ,"(RIGHT)", "");
 _ap_temp_ad =tranwrd(_ap_temp_ad ,"(LEFT)", "");
 _ap_temp_ad =tranwrd(_ap_temp_ad ,"(REAR)", "");
 _ap_temp_ad =tranwrd(_ap_temp_ad ,"(FRONT)", "");
 _ap_temp_ad =tranwrd(_ap_temp_ad ,"(HOUSE)", "");

 _ap_temp_ad =translate(_ap_temp_ad ,"","(");
 _ap_temp_ad =translate(_ap_temp_ad ,"",")");
 _ap_temp_ad =translate(_ap_temp_ad ,"",")");

 _ap_temp_ad =translate(_ap_temp_ad ,"/","\");
 /*_ap_temp_ad =tranwrd(_ap_temp_ad,"# ","#");*/
 _ap_temp_ad =tranwrd(_ap_temp_ad,"#"," # ");

 ***************REMOVE QUOTES*;

 _ap_temp_ad =compress(_ap_temp_ad,"`'");
 _ap_temp_ad =tranwrd(_ap_temp_ad ,'"ST',' ST');
 _ap_temp_ad =tranwrd(_ap_temp_ad ,'"NE',' NE');
 _ap_temp_ad =tranwrd(_ap_temp_ad ,'"SE',' SE');
 _ap_temp_ad =tranwrd(_ap_temp_ad ,'"NO',' NO');
 _ap_temp_ad =tranwrd(_ap_temp_ad ,'"SO',' SO');
 _ap_temp_ad =compress(_ap_temp_ad,'"');

 ***************REPLACE ZERO WITH A LETTER 'O' IN CASES WHERE THERE IS A MISSPELLING, e.g.0ld,0ak*;

 if index(_ap_temp_ad," 0")>0 then
  do;
         %***[PAT, 03/04/06]***  REMOVED (DO THIS LATER AFTER ABBREVIATIONS CORRECTED *******
	 if index(_ap_temp_ad,"0 STREET")=0 then _ap_temp_ad =tranwrd(_ap_temp_ad ," 0 ","");
         %***********************************************************************************;

	 _ap_temp_ad =tranwrd(_ap_temp_ad ,"01ST","1ST");
	 _ap_temp_ad =tranwrd(_ap_temp_ad ,"02ND","2ND");
	 _ap_temp_ad =tranwrd(_ap_temp_ad ,"03RD","3RD");
	 _ap_temp_ad =tranwrd(_ap_temp_ad ,"04TH","4TH");
	 _ap_temp_ad =tranwrd(_ap_temp_ad ,"05TH","5TH");
	 _ap_temp_ad =tranwrd(_ap_temp_ad ,"06TH","6TH");
	 _ap_temp_ad =tranwrd(_ap_temp_ad ,"07TH","7TH");
	 _ap_temp_ad =tranwrd(_ap_temp_ad ,"08TH","8TH");
	 _ap_temp_ad =tranwrd(_ap_temp_ad ,"09TH","9TH");

	**** Changed BB 4/19/05 ****************************;
	*Added an exception to the following rule. Where zero, entirely by mistake, precedes the unit;
	*number, e.g. 1756 COLUMBIA RD NW Unit: 0C101, we do not want it changed to a letter O;

  	 if indexc(substr(_ap_temp_ad,index(_ap_temp_ad," 0")+2,1),"ABCDEFGHIJKLMNOPQRSTUVWXYZ")=1 
  	 	and indexc(substr(_ap_temp_ad,index(_ap_temp_ad," 0")+3,1),"0123456789")=0 then
  	 	_ap_temp_ad = tranwrd(_ap_temp_ad," 0"," O");

  	 **f_zero = 1;
  end;

 _ap_temp_ad = trim(left(compbl(_ap_temp_ad)));

 **** Changed BB 4/4/05 ****************************;
 *Beata: should not comment the next 4 stmts out, even if the one immediately above is*;

 _ap_temp_ad = tranwrd(_ap_temp_ad," .",".");

 _ap_temp_ad = tranwrd(_ap_temp_ad,"NUM.","NUM ");
 _ap_temp_ad = tranwrd(_ap_temp_ad," APT."," APT ");
 _ap_temp_ad = tranwrd(_ap_temp_ad,"POBX."," POBOX ");
 *************************************************BB;
 
 **** PT 08/21/05 ***;
 _ap_temp_ad = tranwrd(_ap_temp_ad," APT#"," APT ");
 _ap_temp_ad = tranwrd(_ap_temp_ad," APT #"," APT ");
 *******************;

 ***************STANDARDIZE STREET NAME ABBREVIATIONS AND OTHER CHARACTERISTICS WORDS*;
/*
 _ap_temp_ad =tranwrd(_ap_temp_ad ," ST ", " STREET ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," STR ", " STREET ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," STRE ", " STREET ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," STREE ", " STREET ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," STREET-", " STREET ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," STREETS ", " STREET ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," STRET ", " STREET ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," STRETT ", " STREET ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," STRRE ", " STREET ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," STREEET ", " STREET ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," SSTREET ", " STREET ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," RD ", " ROAD ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," ROAD-", " ROAD ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," ROADS ", " ROAD ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," DR ", " DRIVE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," DRI ", " DRIVE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," DRV ", " DRIVE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," DRIV ", " DRIVE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," AV ", " AVENUE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," AVE ", " AVENUE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," AVEN ", " AVENUE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," AVENU ", " AVENUE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," AVN ", " AVENUE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," AVENUE-", " AVENUE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," AVENUES ", " AVENUE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," AVEUE ", " AVENUE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," AVNEUE ", " AVENUE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," AENUE ", " AVENUE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," PKWY ", " PARKWAY ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," PKWAY ", " PARKWAY ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," PKW ", " PARKWAY ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," PKY ", " PARKWAY ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," PRKWAY ", " PARKWAY ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," PRKWY ", " PARKWAY ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," PL ", " PLACE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," PLC ", " PLACE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," PLA ", " PLACE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," PLAC ", " PLACE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," TR ", " TERRACE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," TER ", " TERRACE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," TERR ", " TERRACE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," TERRA ", " TERRACE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," TERRAC ", " TERRACE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," TERACE ", " TERRACE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," TERRANCE ", " TERRACE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," HWY ", " HIGHWAY ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," HIGHW ", " HIGHWAY ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," HIGHWA ", " HIGHWAY ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," HIWAY ", " HIGHWAY ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," CT ", " COURT ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," CRT ", " COURT ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," CIR ", " CIRCLE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," CIRC ", " CIRCLE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," CIRCL ", " CIRCLE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," CR ", " CIRCLE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," LA ", " LANE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," LN ", " LANE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," BLVD ", " BOULEVARD ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," BVLD ", " BOULEVARD ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," BUOLEVARD ", " BOULEVARD ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," PK ", " PARK ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," PRK ", " PARK ");
*/

 if substr(_ap_temp_ad,1,4) = "R R " then _ap_temp_ad =tranwrd(_ap_temp_ad ,"R R ", " RR ");
 else _ap_temp_ad =tranwrd(_ap_temp_ad ," R R ", " RR ");

 if substr(_ap_temp_ad,1,4) = "U S " then _ap_temp_ad =tranwrd(_ap_temp_ad ,"U S ", " US ");
 else _ap_temp_ad =tranwrd(_ap_temp_ad ," U S ", " US ");

 %***[PAT 03/04/06]***;
 _ap_temp_ad =tranwrd(_ap_temp_ad ," 0 STREET "," O STREET ");

 **DEBUG** PUT _ap_temp_ad=;
 i = 1;
 wrd1 = scan( _ap_temp_ad, i, ' ' );
 do while ( wrd1 ~= '' );
   if put( put( wrd1, $maraltquadrant40. ), $marvalidquadrant. ) ~= '' then
     _ap_temp_ad_b = trim( _ap_temp_ad_b ) || ' ' || put( wrd1, $maraltquadrant. );
   else
     _ap_temp_ad_b = trim( _ap_temp_ad_b ) || ' ' || wrd1;
   i = i + 1;
   wrd1 = scan( _ap_temp_ad, i, ' ' );
 end;
 _ap_temp_ad = _ap_temp_ad_b;
 PUT _ap_temp_ad=;
 
 /*
 _ap_temp_ad =tranwrd(_ap_temp_ad ," SOUTHWEST ", " SW ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," NORTHWEST ", " NW ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," SOUTHEAST ", " SE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," NORTHEAST ", " NE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," SOUTHW ", " SW ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," NORTHW ", " NW ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," SOUTHE ", " SE ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," NORTHE ", " NE ");
 */

 _ap_temp_ad =tranwrd(_ap_temp_ad ," FIRST ", " 1ST ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," SECOND ", " 2ND ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," THIRD ", " 3RD ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," FOURTH ", " 4TH ");
 _ap_temp_ad =tranwrd(_ap_temp_ad ," FIFTH ", " 5TH ");

 ***************GET RID OF DASHES IF PRECEDED BY A LETTER AND FOLLOWED BY A LETTER OR A NUMBER*;

 _ap_temp_ad = tranwrd(_ap_temp_ad,"--","-");
 _ap_temp_ad = tranwrd(_ap_temp_ad," -","-");
 _ap_temp_ad = tranwrd(_ap_temp_ad,"- ","-");

 i_dash  = indexc(_ap_temp_ad,"-");

 if i_dash >1 then
  do;
  	 if indexc(substr(_ap_temp_ad,i_dash-1,1),"ABCDEFGHIJKLMNOPQRSTUVWXYZ")>0 and
  	 	indexc(substr(_ap_temp_ad,i_dash-2,1),"ABCDEFGHIJKLMNOPQRSTUVWXYZ ")>0 and
  	 	indexc(substr(_ap_temp_ad,i_dash+1,1),"ABCDEFGHIJKLMNOPQRSTUVWXYZ#")>0 and
  	 	indexc(substr(_ap_temp_ad,i_dash+2,1),"ABCDEFGHIJKLMNOPQRSTUVWXYZ")>0 then
  	  do;
  	     _ap_temp_ad = trim(substr(_ap_temp_ad,1,i_dash-1)) || "" || substr(_ap_temp_ad,i_dash+1);
  	     **f_dash = 1;
      end;
     **else if indexc(substr(_ap_temp_ad,i_dash-1,1),"ABCDEFGHIJKLMNOPQRSTUVWXYZ")>0 and
  	 	indexc(substr(_ap_temp_ad,i_dash+1,1),"1234567890")>0 then
  	  do;
  	     **f_dash = 2;
      **end;
  end;

 drop i_dash;

 _ap_temp_ad = trim(left(compbl(_ap_temp_ad)));

 ***************REMOVE POBOX NUMBERS FROM ADDRESS*;

 _ap_temp_ad =tranwrd(_ap_temp_ad, "POBOX ","POBOX");
 _ap_temp_ad =tranwrd(_ap_temp_ad, "PO BX", "P O BOX");
 _ap_temp_ad =tranwrd(_ap_temp_ad, "P O BX", "P O BOX");
 _ap_temp_ad =tranwrd(_ap_temp_ad, "PO BOX", "P O BOX");
 _ap_temp_ad =tranwrd(_ap_temp_ad, "P 0 BOX ","POBOX"); *P O BOX with a zero in place of first 'o';
 _ap_temp_ad =tranwrd(_ap_temp_ad, "P O BOX ","POBOX");

 pob_i = index(_ap_temp_ad,"POBOX");

 if pob_i = 1 then
  do;
	 _ap_temp_ad = substr(_ap_temp_ad, indexc(_ap_temp_ad," /")+1);
  	 **f_box = 0;
  end;
 else if pob_i > 1 then
  do;
  	 first = substr(_ap_temp_ad, 1, pob_i-1);**first part of address (w/o po box);
  	 temp  = substr(_ap_temp_ad, pob_i); **last part of address (w/ po box);
  	 last  = substr(temp,indexc(temp," /")+1); **last part of address (w/ po box removed);
  	 if last = "" then
  	  do;
  	  	 _ap_temp_ad = trim(left(first));
  	  	 **f_box = 1;
  	  end;
  	 else if last ^= "" then
  	  do;
  	  	 _ap_temp_ad = trim(left(first))||""||left(last);
  	 	 **f_box = 2;
  	  end;
  end;

 drop pob_i first temp last;

 _ap_temp_ad = trim(left(compbl(_ap_temp_ad))) || "";

 if _ap_temp_ad = "" then goto _address_parse_end;

 **** Changed BB 4/4/05 ****************************;
 *Beata: Changed the following comment from REMOVE APT NUMBERS FROM THE BEGINNING OR THE END OF ADDRESS;
 
 ***************REMOVE APT NUMB. FROM THE BEGINNING, BUT MOVE THOSE APT OR UNIT NUMB. FROM THE END OF ADDRESS TO SEPARATE FIELD*;
 *************************************************BB;

/***************
 _ap_temp_ad = tranwrd(_ap_temp_ad,"LOT#","LOT #");

 _ap_temp_ad = tranwrd(_ap_temp_ad," STAPT "," STREET APT ");
 _ap_temp_ad = tranwrd(_ap_temp_ad," AVEAPT "," AVENUE APT ");
 _ap_temp_ad = tranwrd(_ap_temp_ad," STREETAPT"," STREET APT");
 _ap_temp_ad = tranwrd(_ap_temp_ad," AVENUEAPT"," AVENUE APT");
 _ap_temp_ad = tranwrd(_ap_temp_ad," PARKWAYAPT"," PARKWAY APT");
 _ap_temp_ad = tranwrd(_ap_temp_ad,"APARTAMENTOS","APT");
 _ap_temp_ad = tranwrd(_ap_temp_ad,"APARTAMENTO","APT");
 _ap_temp_ad = tranwrd(_ap_temp_ad," APARTMENT"," APT");
 _ap_temp_ad = tranwrd(_ap_temp_ad," APMT"," APT");

 _ap_temp_ad = tranwrd(_ap_temp_ad," UNT"," UNIT");

 _ap_temp_ad = tranwrd(_ap_temp_ad," STE "," SUITE ");

 %Addr_parse_unit( APT, debug=&debug )
 %Addr_parse_unit( UNIT, debug=&debug )
 %Addr_parse_unit( SUITE, debug=&debug )
*************/ 

 _ap_temp_ad = tranwrd(_ap_temp_ad,"1ST FLOOR"," 1STFL");
 _ap_temp_ad = tranwrd(_ap_temp_ad,"2ND FLOOR"," 2NDFL");
 _ap_temp_ad = tranwrd(_ap_temp_ad,"3RD FLOOR"," 3RDFL");
 _ap_temp_ad = tranwrd(_ap_temp_ad,"4TH FLOOR"," 4THFL");
 _ap_temp_ad = tranwrd(_ap_temp_ad,"1ST FL"," 1STFL");
 _ap_temp_ad = tranwrd(_ap_temp_ad,"2ND FL"," 2NDFL");
 _ap_temp_ad = tranwrd(_ap_temp_ad,"3RD FL"," 3RDFL");
 _ap_temp_ad = tranwrd(_ap_temp_ad,"4TH FL"," 4THFL");

 _ap_temp_ad = trim(left(compbl(_ap_temp_ad))) || "";

 _ap_temp_ad = tranwrd(_ap_temp_ad,"2ND & 3RDFL"," 2ND&3RDFL");

 _ap_temp_ad = trim(left(compbl(_ap_temp_ad))) || "";

 i_1stfl = index(_ap_temp_ad,"1STFL");
 i_2ndfl = index(_ap_temp_ad,"2NDFL");
 i_3rdfl = index(_ap_temp_ad,"3RDFL");
 i_4thfl = index(_ap_temp_ad,"4THFL");

 %Addr_parse_floor(1st);
 %Addr_parse_floor(2nd);
 %Addr_parse_floor(3rd);
 %Addr_parse_floor(4th);
 
 PUT '[345] ' _ap_temp_ad=;

 drop i_1stfl i_2ndfl i_3rdfl i_4thfl;

/*************************************************************
 **** Added BB 4/4/05 ******************************;
 *Beata: added length statement for rev, as well as units and apts appearing at the end of address*;
 
 length rev revcut $50. revend end_apt $25.;
 *************************************************BB;
 
 rev = trim(left(reverse(_ap_temp_ad)));

 if substr(rev,1,6) in ("TRF PU") or substr(rev,1,7) in ("RAER PU","PU RAER","TRF RWL")
 	or substr(rev,1,8) in ("PU TNORF","SRIATSPU","RAER RWL")
 	or substr(rev,1,9) in ("RAER NWOD","NWOD RAER","EDIS TFEL")
 	or substr(rev,1,10) in ("SRIATSNWOD","RAER REPPU","TFEL REPPU","TALF REPPU","EDIS THGIR","TINU REPPU")
 	or substr(rev,1,11) in ("THGIR REPPU","TNORF REWOL") then
  do;
     _ap_temp_ad = tranwrd(_ap_temp_ad,"UP FRT"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"UP REAR"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"REAR UP"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"LWR FRT"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"FRONT UP"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"UPSTAIRS"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"LWR REAR"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"DOWN REAR"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"REAR DOWN"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"LEFT SIDE"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"DOWNSTAIRS"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"UPPER REAR"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"UPPER LEFT"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"UPPER FLAT"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"RIGHT SIDE"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"UPPER UNIT"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"UPPER RIGHT"," ");
     _ap_temp_ad = tranwrd(_ap_temp_ad,"LOWER FRONT"," ");

     **f_remov = 1;
  end;

 rev = trim(left(reverse(_ap_temp_ad)));

 ri_num = index(scan(rev,1,""),"#");
 ri_apt = index(scan(rev,1,""),"TPA");

 **** Added BB 4/4/05 ******************************;
 *Beata: add this assignment stmt to scan the last segment of the address to identify if unit is provided*;
 
 ri_unit = index(scan(rev,1,""),"TINU");
 *************************************************BB;

 **** Changed BB 4/4/05 ****************************;
 *Beata: pulled revcut out of the conditional stmts below because it was repetitive, it is clearer to have it up front*;
 
 revcut = trim(left( substr(rev, indexc(rev,"")) ));

 *Beata: added an assignment stmt to identify the part of address that contains unit or apt number information*;
 
 revend = trim(left( substr(rev, 1, indexc(rev,"")) ));
 *************************************************BB;

 
 **** Changed BB 4/4/05 ****************************;
 *Beata: add if..then.. condition for units, and also shift the order of if..then.. stmts by moving if ri_apt>0 before if ri_num>0*;
 *Beata: added var - end_apt - that retain unit and apt info (apt var created later on has to be reconciled with end_apt)*;
 
 if ri_unit > 0 then 
  do;
 	 _ap_temp_ad = trim(left(reverse(revcut))); *address part without unit at the end;
	 end_apt = trim(left(reverse(revend))); *the end part of address with unit number;
	 
	 **f_rev = 2;
  end;
 else if ri_apt > 0 then
  do;
 	 _ap_temp_ad = trim(left(reverse(revcut)));

  	 *Beata: added this stmt to retain the apt number from the end segment of address;

	 end_apt = trim(left(reverse(revend))); *the end part of address with apt number;

 	 **f_rev = 2;
  end;
 else if ri_num > 0 then
  do;
	 if substr(revcut,1,5)^="ETUOR" and substr(revcut,1,3)^="TOL" and substr(revcut,1,3)^="YWH"
 	 	and substr(revcut,1,2)^="TR" and substr(revcut,1,2)^="RR" and substr(revcut,1,2)^="SU" then
 	  do;
 	  	 _ap_temp_ad = trim(left(reverse(revcut)));
 	  	 
 	  	 *Beata: added this stmt to retain the number from the end segment of address;

		 end_apt = trim(left(reverse(revend))); *the end part of address with number that can be treated as apt;

 	  	 **f_rev = 1;
 	  end;
  end;

 drop rev ri_num ri_apt ri_unit revcut revend;
 *************************************************BB;

 _ap_temp_ad = trim(left(compbl(_ap_temp_ad)));
 
 ***********************************************************************/

 PUT '[448] ' _AP_TEMP_AD=;

 ***************ELIMINATE SPECIAL CHARACTERS FROM THE BEGINNIG OF ADDR STRING*;

 wrd1 = scan(_ap_temp_ad,1,"");
 wrd2 = scan(_ap_temp_ad,2,"");

 **If addr string is not null, and 1st word is garbage then reassign address starting with 2nd word;
 if wrd2 ^= "" and indexc(wrd1,"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")=0 then
  do;
 	 _ap_temp_ad = substr(_ap_temp_ad, indexc(_ap_temp_ad,"")+1) ;
 	 **f_wrd2 = 1;
  end;

 wrd1 = scan(_ap_temp_ad,1,"");
 l1_wrd1 = substr(wrd1,1,1);

 **If 1st letter is a spec char then remove it and any subseq chars from the beg of addr string;
 if indexc(l1_wrd1,"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.")=0 then
  do;
 	 _ap_temp_ad = substr(_ap_temp_ad,indexc(_ap_temp_ad,"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789."));
 	 **f_ltr1 = 1;
  end;

 ***************REPLACE '&' OR 'AND' WITH '-' IF IN SECOND WORD*;

 wrd1 = scan(_ap_temp_ad,1,"");
 wrd2 = scan(_ap_temp_ad,2,"");
 wrd3 = scan(_ap_temp_ad,3,"");

 i_wrd2 = indexc(_ap_temp_ad,"")+1;
 if wrd2 ^= "" then i_wrd3 = i_wrd2 + length(wrd2) + 1;
 else i_wrd3 = i_wrd2;

 _ap_temp_ad = tranwrd(_ap_temp_ad," AND "," & ");

 if wrd2 in ("&","AND") then
  do;
  	 if indexc(wrd1,"1234567890")>0
  	  and index(wrd1,"ST")=0 and index(wrd1,"ND")=0 and index(wrd1,"RD")=0 and index(wrd1,"TH")=0 then
  	  do;
  	  	 _ap_temp_ad = trim(wrd1) || "-" || trim(left(substr(_ap_temp_ad,i_wrd3)));
  	  	 f_and2 = 1;
  	  end;
  	  f_and2 = 2;
  end;

 _ap_temp_ad = tranwrd(_ap_temp_ad," -","-");
 _ap_temp_ad = tranwrd(_ap_temp_ad,"- ","-");

 _ap_temp_ad = trim(left(compbl(_ap_temp_ad)));

 %if %mparam_is_yes( &debug ) %then %do;
  PUT "A: " _AP_TEMP_AD= ;
 %end;

 ***************START DEFINING VARIOUS COMPONENTS OF ADDR STRING*;

 wrd1 = scan(_ap_temp_ad,1,"");
 abc_wrd1 = indexc(wrd1,"ABCDEFGHIJKLMNOPQRSTUVWXYZ");

 wrd2 = scan(_ap_temp_ad,2,"");
 abc_wrd2 = indexc(wrd2,"ABCDEFGHIJKLMNOPQRSTUVWXYZ");
 i_wrd2 = indexc(_ap_temp_ad,"")+1;

 wrd3 = scan(_ap_temp_ad,3,"");
 if wrd2 ^= "" then i_wrd3 = i_wrd2 + length(wrd2) + 1;
 else i_wrd3 = i_wrd2;

 l1_wrd1 = substr(wrd1,1,1);
 l2_wrd1 = substr(wrd1,2,1);
 l3_wrd1 = substr(wrd1,3,1);
 l1_wrd2 = substr(wrd2,1,1);

 i_dash1 = indexc(wrd1,"-");
 i_dash2 = indexc(substr(wrd1,i_dash1+1),"-");

 d1_wrd = scan(wrd1,2,"-"); *char string following the 1st dash in the first word;
 abc_d1w = indexc(d1_wrd,"ABCDEFGHIJKLMNOPQRSTUVWXYZ");
 d2_wrd = scan(wrd1,3,"-"); *char string following the 2nd dash in the first word;
 abc_d2w = indexc(d2_wrd,"ABCDEFGHIJKLMNOPQRSTUVWXYZ");
 

 ***************START PARSING PROCESS***************;

 %***[PAT] Separate street number (NUM) from street name (PAD) ***;

 
 if l1_wrd1 in ("0","1","2","3","4","5","6","7","8","9") then
  do; **first word starts with a number;
     if indexc(wrd1,"/-")=0 then
      do; **and neither dash- nor slash/ exist in the first word;
         if abc_wrd1=0 then
          do; ***there are also no letters in the first word;
             if wrd2 in ( "1/2", "REAR", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "R" ) and 
                ( put( put( compress( wrd3, '-' ), $maraltsttyp. ), $marvalidsttyp. ) = '' and
                  wrd3 not in ( 'NE', 'NW', 'SE', 'SW' ) ) then
              do; ***wrd2 is address number suffix;
                num = wrd1;
                numsuf = wrd2;
                pad = substr(_ap_temp_ad,i_wrd3);
              end;
             else if abc_wrd2=0 and input(wrd1,12.)>1000000 then
              do;
                 num = substr(wrd2,1,indexc(wrd2,"&-/ "));
                 pad = substr(_ap_temp_ad,i_wrd3);
                 pflag = "N 123.0";
              end;
             else
              do;
             	 ***includes cases where wrd2 in ("MILES","MILE","MI") e.g. 5 MILE RD;
             	 num = wrd1;
             	 pad = substr(_ap_temp_ad,i_wrd2);
             	 pflag = "N 123.3";
              end;
          end;
         else
          do; ***there are letters in the first word;
             if substr(_ap_temp_ad,abc_wrd1,3) in ("ST ","ND ","RD ","TH ") then
              do; ***these are ST, ND or TH which point to a street name not number;
                 num = "";
                 pad = _ap_temp_ad;
                 pflag = "N ABC.1";
              end;
             else if substr(_ap_temp_ad,abc_wrd1,2) in ("NE","NW","SE","SW") then
              do; ***these are abbreviations for street directions;
                 num = substr(_ap_temp_ad,1,abc_wrd1-1);
                 pad = substr(_ap_temp_ad,abc_wrd1);
                 pflag = "N ABC.2";
              end;
             else if substr(wrd1,abc_wrd1) in 
               ( "REAR", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "R" ) and
               put( put( compress( wrd2, '-' ), $maraltsttyp. ), $marvalidsttyp. ) = '' then
              do; **wrd1 text is an address number suffix;
                 num = substr(wrd1,1,abc_wrd1-1);
                 numsuf = substr(wrd1,abc_wrd1);
                 pad = substr(_ap_temp_ad,i_wrd2);
              end;
             else if substr(wrd1,abc_wrd1) in 
               ( "REAR", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "R" ) and
               put( put( compress( wrd2, '-' ), $maraltsttyp. ), $marvalidsttyp. ) ~= '' then
              do; **wrd1 text is street name;
                 num = substr(wrd1,1,abc_wrd1-1);
                 pad = substr(_ap_temp_ad,abc_wrd1);
              end;
             else if length(substr(wrd1,abc_wrd1))>=3
                      and indexc(substr(wrd1,abc_wrd1),"1234567890")=0 then
              do; ***the text is long and has no numbers in it hence it belongs to a street name;
                 num = substr(_ap_temp_ad,1,abc_wrd1-1);
                 pad = substr(_ap_temp_ad,abc_wrd1);
                 pflag = "N ABC.3";
              end;
             else
              do; ***the text such as 5A, or some other;
                 num = substr(wrd1,1,abc_wrd1-1);
                 apt = substr(wrd1,abc_wrd1);
                 pad = substr(_ap_temp_ad,i_wrd2);
                 pflag = "N ABC.4";
              end;
          end;
      end;
     else
      do; ***- or / exist in the first word;
         if i_dash1>0 and indexc(wrd1,"/")>0 then
          do; ***both - and / exist in the first word, e.g. 1513-1/2 E GERMAN LN, 430-1/2/10TH AVE;
             num = substr(wrd1,1,i_dash1-1);
             if substr(_ap_temp_ad,indexc(wrd1,"/")+1,1) = "" then pad = substr(_ap_temp_ad,indexc(wrd1,"/")+2);
             else pad = substr(_ap_temp_ad,indexc(wrd1,"/")+3);
             pflag = "N -/";
          end;
         else if i_dash1=0 and indexc(wrd1,"/")>0 then
          do; ***only / exists, cases where - also exists are dealt with above;
                   if substrn(wrd1,length(wrd1)-2) = "1/2" then
                    do; ***1/2 is combined with address number;
                      num = substrn( wrd1, 1, length(wrd1)-3 );
                      numsuf = substrn(wrd1,length(wrd1)-2);
             	    pad = substr(_ap_temp_ad,i_wrd2);
                    end;

			 else if index(wrd1,"0/1")>0 or index(wrd1,"1/2")>0 or index(wrd1,"1/4")>0
			 	or index(wrd1,"1/8")>0 or index(wrd1,"3/4")>0 then
			  do;
				 if indexc(substr(wrd1,1,indexc(wrd1,"/")-2),"ABCDEFGHIJKLMNOPQRSTUVWXYZ")>0 then
				  do;
				     num = "";
				     pad = trim(substr(wrd1,1,indexc(wrd1,"/")-2)) ||""||
				             trim(substr(wrd1,indexc(wrd1,"/")-1)) ||""|| substr(_ap_temp_ad,i_wrd2);
				     pflag = "N /.0a";
				  end;
				 else if indexc(substr(wrd1,indexc(wrd1,"/")+2),"ABCDEFGHIJKLMNOPQRSTUVWXYZ")>0 then
				  do;
				     num = "";
				     pad = trim(substr(wrd1,1,indexc(wrd1,"/")+1)) ||""||
				             trim(substr(wrd1,indexc(wrd1,"/")+2)) ||""|| substr(_ap_temp_ad,i_wrd2);
				     pflag = "N /.0b";
				  end;
				 else if wrd2 in ("MILE","MILES","ML","MI","M","BLOCK","BLK","LT") then
				  do; ***e.g. 1/4 MILE E LOTT RD, 1/4 M S OLIVAREZ;
					 num = "";
					 pad = _ap_temp_ad;
					 pflag = "N /.1";
				  end;
				 else if indexc(wrd1,"&")>0 then
				  do; ***e.g. 1518&1/2 NEWPORT AVE;
					 num = substr(wrd1,1,indexc(wrd1,"&")-1);
					 pad = substr(_ap_temp_ad,i_wrd2);
					 pflag = "N /.2";
				  end;
				 else
				  do; ***e.g. 2071/2 LAKESHORE DR;
					 num = substr(wrd1,1,indexc(wrd1,"/")-1);
					 num2 = substr(wrd1,indexc(wrd1,"/")+1);
					 pad = substr(_ap_temp_ad,i_wrd2);
					 pflag = "N /.3";
				  end;
			  end;
          end;
         else if i_dash1>0 and indexc(wrd1,"/")=0 then
          do; ***only - exists;
			 if indexc(substr(wrd1,1,i_dash1-1),"ABCDEFGHIJKLMNOPQRSTUVWXYZ")^=0 then
			  do; ***any combination of -,ltrs in 1st p.of 1st wrd, e.g. 214C-2 LAWRENCE DR,2B-13-1 EST MARIEN;
				 if abc_wrd1 > 1 and abc_wrd1 < i_dash1 then
				  do; ***separate the num from the letter;
					 num = substr(wrd1,1,abc_wrd1-1);
					 apt = substr(wrd1,abc_wrd1);
					 pad = substr(_ap_temp_ad,i_wrd2);
					 pflag = "N ABC-.1";
				  end;
				 else
				  do;
					 apt = wrd1;
					 pad = substr(_ap_temp_ad,i_wrd2);
					 pflag = "N ABC-.2";
				  end;
			  end;
			 else
			  do; ***the first part of the first word is strictly number e.g. 1727-9TH AVE N;
				 if i_dash2 = 0 then
				  do; ***only one dash in the first word;
					 num = substr(wrd1,1,i_dash1-1);
					 if substr(d1_wrd,1,1) in ("0","1","2","3","4","5","6","7","8","9") then
					  do; ***word after the first dash starts with a number;
						 if indexc(d1_wrd,"ABCDEFGHIJKLMNOPQRSTUVWXYZ") = 0 then
						  do; ***and it is purely a number, no letters;
							 if wrd2 = "1/2" and wrd3 in ("AV","ST","LN") then
							  do; ***e.g. 1416-5 1/2 AVE;
								 pad = trim(d1_wrd) || "" || left(substr(_ap_temp_ad,i_wrd2));
								 pflag = "N 123-123.1";
							  end;
							 else if wrd2 in ("ST","ND","TH","RD","MILE") then
							  do; ***e.g. 14687-11 MILE ROAD, 1416-5 1/2 AVE;
								 pad = trim(d1_wrd) || "" || left( substr(_ap_temp_ad,i_wrd2));
								 pflag = "N 123-123.2";
							  end;
							 else
							  do; ***e.g. 410-412 1/2 ESSEX ST;
								 num2 = d1_wrd;
								 pad = substr(_ap_temp_ad,i_wrd2);
								 pflag = "N 123-123.3";
							  end;
						  end;
						 else
						  do; ***there are nums and letters in the word after the first dash;
							 if substr(d1_wrd,abc_d1w,3) in ("ST ","ND ","RD ","TH ","MT ") then
							  do; ***letters are ST, ND, TH endings of a street name;
								 pad = trim(substr(d1_wrd,1))||""||left(substr(_ap_temp_ad,i_wrd2));
								 pflag = "N 123-#ABC.1";
							  end;
							 else if substr(d1_wrd,abc_d1w,2) in ("NE","NW","SE","SW","SO") then
							  do; ***these are abbreviations for street directions;
								 num2 = substr(d1_wrd,1,(abc_d1w-1));
								 pad = trim(substr(d1_wrd,abc_d1w))||""||left(substr(_ap_temp_ad,i_wrd2));
								 pflag = "N 123-#ABC.2";
							  end;
							 else if length(substr(d1_wrd,abc_d1w))>=3
									  and indexc(substr(d1_wrd,abc_d1w),"1234567890")=0 then
							  do; ***the text is long, no num in it, it belongs to a street name;
								 num2 = substr(d1_wrd,1,(abc_d1w-1));
								 pad = trim(substr(d1_wrd,abc_d1w))||""||left(substr(_ap_temp_ad,i_wrd2));
								 pflag = "N 123-#ABC.3";
							  end;
							 else
							  do; ***the text aft first dash such as 5A, or some other;
								 num2 = substr(d1_wrd,1,(abc_d1w-1));
								 apt  = substr(d1_wrd,abc_d1w);
								 pad  = substr(_ap_temp_ad,i_wrd2);
								 pflag = "N 123-#ABC.4";
							  end;
						  end;
					  end;
					 else if indexc(substr(d1_wrd,1,1),"1234567890")=0 then
					  do; ***word aft 1st dash starts w/ ltr or other non-num e.g. 440-#B SYCAM ST;
						 if length(d1_wrd)>=3 and indexc(d1_wrd,"1234567890")=0 then
						  do;
							 pad = trim(d1_wrd) ||""|| left(substr(_ap_temp_ad,i_wrd2));
							 pflag = "N 123-ABC.1";
						  end;
						 else if d1_wrd in ("N","S","E","W") then
						  do;
							 pad = trim(d1_wrd) ||""|| left(substr(_ap_temp_ad,i_wrd2));
							 pflag = "N 123-ABC.2";
						  end;
						 else
						  do;
							 apt = d1_wrd;
							 pad = substr(_ap_temp_ad,i_wrd2);
							 pflag = "N 123-ABC.3";
						  end;
					  end;
				  end;
				 else if i_dash2 > 0 then
				  do; ***there is a second dash in the first word;
					 num = substr(wrd1,1,i_dash1-1);
					 if indexc(d1_wrd,"ABCDEFGHIJKLMNOPQRSTUVWXYZ") = 0 then
					  do; ***2nd part of the 1st word is purely a number, even if missing its ok;
						 if substr(d2_wrd,1,1) in ("0","1","2","3","4","5","6","7","8","9") then
						  do; ***3rd part of the 1st word starts with a number;
							 if indexc(d2_wrd,"ABCDEFGHIJKLMNOPQRSTUVWXYZ") = 0 then
							  do; ***and it is purely a number, no letters;
								 num2 = d1_wrd;
								 num3 = d2_wrd;
								 pad = substr(_ap_temp_ad,i_wrd2);
								 pflag = "N 123-123-123.1";
							  end;
							 else
							  do; ***not a pure number, has letters;
								 if substr(d2_wrd,abc_d2w,3) in ("ST ","ND ","RD ","TH ") then
								  do; ***e.g. 1415-16-15TH AVE;
									 num2 = d1_wrd;
									 pad = trim(d2_wrd) ||""|| left(substr(_ap_temp_ad,i_wrd2));
									 pflag = "N 123-123-#ABC.1";
								  end;
								 else
								  do; ***e.g. 1415-16-2B BARTER LN;
									 num2 = d1_wrd;
									 apt = d2_wrd;
									 pad = substr(_ap_temp_ad,i_wrd2);
									 pflag = "N 123-123-#ABC.2";
								  end;
							  end;
						  end;
						 else
						  do; ***3rd part of the 1st word starts with non-number;
							 if length(d2_wrd)>=3 and indexc(d2_wrd,"1234567890")=0 then
							  do; ***e.g. 2302-3-HOLLANDALE CR;
								 num2 = d1_wrd;
								 pad = trim(substr(d2_wrd,1)) ||""|| left(substr(_ap_temp_ad,i_wrd2));
								 pflag = "N 123-123-ABC.1";
							  end;
							 else
							  do; ***where d2_wrd=N,E,W,S or oth e.g. 22-3-N BOSTON DR, 22-3-B BOSTON DR;
								 num2 = d1_wrd;
								 apt  = d2_wrd;
								 pad = substr(_ap_temp_ad,i_wrd2);
								 pflag = "N 123-123-ABC.2";
							  end; *substr(wrd1,i_dash1) same as trim(d1_wrd)||""||left(d2_wrd);
						  end;
					  end;
					 else
					  do; ***2nd part not a pure num - single letter or a mix of num and lettr;
						 if substr(d2_wrd,1,1) in ("0","1","2","3","4","5","6","7","8","9") then
						  do; ***3rd part of the 1st word starts with a number;
							 if indexc(d2_wrd,"ABCDEFGHIJKLMNOPQRSTUVWXYZ") = 0 then
							  do; ***and it is purely a number, no letters;
								 apt = substr(wrd1,i_dash1);
								 pad = substr(_ap_temp_ad,i_wrd2);
								 pflag = "N 123-ABC-123.1";
							  end;
							 else
							  do; ***not a pure number, has letters;
								 if substr(d2_wrd,abc_d2w,3) in ("ST ","ND ","RD ","TH ") then
								  do; ***e.g. 21-15B-1ST AVE;
									 apt = d1_wrd;
									 pad = trim(d2_wrd) ||""|| left(substr(_ap_temp_ad,i_wrd2));
									 pflag = "N 123-ABC-#ABC.1";
								  end;
								 else
								  do;
									 apt = substr(wrd1,i_dash1);
									 pad = substr(_ap_temp_ad,i_wrd2);
									 pflag = "N 123-ABC-#ABC.2";
								  end;
							  end;
						  end;
						 else
						  do; ***3rd part of the 1st word starts with non-number;
							 if length(d2_wrd)>=3 and indexc(d2_wrd,"1234567890")=0 then
							  do; ***e.g. 2302-3B-HOLLANDALE CR, 504-A1-DAUGHTERY ST;
								 apt = d1_wrd;
								 pad = trim(d2_wrd) ||""|| left(substr(_ap_temp_ad,i_wrd2));
								 pflag = "N 123-ABC-ABC.1";
							  end;
							 else if d2_wrd in ("N","E","W","S") then
							  do; ***e.g. 185-A-W HILLSDALE BLVD;
								 apt = d1_wrd;
								 pad = trim(d2_wrd) ||""|| left(substr(_ap_temp_ad,i_wrd2));
								 pflag = "N 123-ABC-ABC.2";
							  end;
							 else
							  do; ***e.g. 6024-2A-B MAUSSER DR;
								 apt = substr(wrd1,i_dash1);
								 pad = substr(_ap_temp_ad,i_wrd2);
								 pflag = "N 123-ABC-ABC.3";
							  end;
						  end;
					  end;
				  end;
			  end;
          end;
      end;
  end;
 else if l1_wrd1 in ("A","B","C","D","E","F","G","H",
                      "I","J","K","L","M","N","O","P","Q",
                       "R","S","T","U","V","W","X","Y","Z") then
  do; ***the first word starts with a letter;
     num = "";
     pad = _ap_temp_ad;
     pflag = "L";
  end;
 else if _ap_temp_ad = "" then pflag = "E";

 pad = trim(left(compbl(pad)));
 num = trim(left(compbl(num)));

 %if %mparam_is_yes( &debug ) %then %do;
   PUT "B: " _AP_TEMP_AD= NUM= PAD= APT=;
 %end;

 ***************REMOVE SPEC CHARS FROM THE BEGINNING OF THE STREET NAME PORTION OF ADDR STRING*;

 **If 1st letter is a spec char then remove it and any subseq chars from the beg of pad string;
 if indexc(substr(pad,1,1),"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.")=0 then
  do;
 	 pad = substr(pad,indexc(pad,"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789."));
 	 **f_pad1 = 1;
  end;

 pad = trim(left(compbl(pad)));

 %if %mparam_is_yes( &debug ) %then %do;
   PUT "B2: " PAD=;
   LENGTH _XDEBUG $ 1000;
   _XDEBUG = scan(pad,1,"");
   PUT 'scan(pad,1,"")=' _XDEBUG;
   _XDEBUG = scan(pad,2,"");
   PUT 'scan(pad,2,"")=' _XDEBUG;
 %end;

 %***[PAT]****
  Test if first word in street name contains a number
  If so, do something ????
 *************;

 if indexc(substr(pad,1,1),"0123456789")>0
 	and indexc(scan(pad,1,""),"/")=0 and indexc(scan(pad,2,""),"/")=0
 	and index(scan(pad,1,""),"ST")=0 and index(scan(pad,1,""),"ND")=0
 		and index(scan(pad,1,""),"RD")=0 and index(scan(pad,1,""),"TH")=0
    and index(scan(pad,2,""),"AV")=0 and index(scan(pad,2,""),"ST")=0
    	and index(scan(pad,2,""),"LN")=0 and index(scan(pad,2,""),"RD")=0
    	and index(scan(pad,2,""),"PLZ")=0 and index(scan(pad,2,""),"TH")=0
    	and index(scan(pad,2,""),"ND")=0 and index(scan(pad,2,""),"RD")=0
    and index(scan(pad,2,""),"MILE")=0 and index(scan(pad,2,""),"OAKS")=0
    	and index(scan(pad,2,""),"SEASONS")=0 and index(scan(pad,2,""),"FEATHERS")=0
    	and index(scan(pad,2,""),"FOOT")=0 and index(scan(pad,2,""),"NOTCH")=0
    	and index(scan(pad,2,""),"RIVER")=0 and index(scan(pad,2,""),"SPRINGS")=0
    	and index(scan(pad,2,""),"HILLS")=0 and index(scan(pad,2,""),"WINDS")=0
    	and index(scan(pad,2,""),"TOWERS")=0 and index(scan(pad,2,""),"PINES")=0
    	and index(scan(pad,2,""),"BUCKS")=0 and index(scan(pad,2,""),"ARPENT")=0
    	and index(scan(pad,2,""),"BROECK")=0 and index(scan(pad,2,""),"GEORGES")=0
    	and index(scan(pad,2,""),"EAGLES")=0 and index(scan(pad,2,""),"HAWKS")=0
    	and index(scan(pad,2,""),"ROD")=0 and index(scan(pad,2,""),"POINT")=0
    	and index(scan(pad,2,""),"CROSSES")=0 and index(scan(pad,2,""),"FORKS")=0
    	and index(scan(pad,2,""),"GRAND")=0 and index(scan(pad,2,""),"WHEEL")=0
    	and index(scan(pad,2,""),"IRON")=0 and index(scan(pad,2,""),"COLONY")=0
    	and index(scan(pad,2,""),"TREES")=0 and index(scan(pad,2,""),"EYCK")=0
    	and index(scan(pad,2,""),"BRIDGES")=0 and index(scan(pad,2,""),"POLE")=0
    	and index(scan(pad,2,""),"LAKES")=0 and index(scan(pad,2,""),"POLE")=0
    	and index(scan(pad,2,""),"GABLES")=0 and index(scan(pad,2,""),"MISSIONS")=0
    	and index(scan(pad,2,""),"OCLOCK")=0 and index(scan(pad,2,""),"CREEK")=0
    	and index(scan(pad,2,""),"WOODS")=0 and index(scan(pad,2,""),"GALLON")=0
    	and index(scan(pad,2,""),"PALMS")=0 and index(scan(pad,2,""),"COVES")=0
    	and index(scan(pad,2,""),"CHOPT")=0 and index(scan(pad,2,""),"TURNPIKE")=0
    then
  do;
    %***[PAT, 03/04/06]***
      If first word of street name is only a number and second word is a street type, then
      assume that first word should be an ordinal number (1st, 2nd, etc.)
    ************;
    if indexc(scan(pad,1,""),"ABCDEFGHIJKLMNOPQRSTUVWXYZ") = 0 and 
       put( upcase( scan(pad,2,"") ), $marvalidsttyp. ) ~= "" then do;
      select ( substr( reverse( scan(pad,1,"") ), 1, 1 ) );
        when ( "1" ) pad1 = scan(pad,1,"") || "ST";
        when ( "2" ) pad1 = scan(pad,1,"") || "ND";
        when ( "3" ) pad1 = scan(pad,1,"") || "RD";
        when ( "4", "5", "6", "7", "8", "9", "0" ) pad1 = scan(pad,1,"") || "TH";
        otherwise pad1 = scan(pad,1,"");
      end;
      pad = trim( pad1 ) || " " || substr( pad, length( scan(pad,1,"") ) + 1 );
    end;

    else do;
    
  	 if length(substr(scan(pad,1,""),indexc(scan(pad,1,""),"ABCDEFGHIJKLMNOPQRSTUVWXYZ")))>2 then
  	  do;
  	  	 pad = substr(pad,indexc(pad,"ABCDEFGHIJKLMNOPQRSTUVWXYZ"));
  	  	 **f_scan1=2;
  	  end;
  	 else
  	  do;
  	  	 pad = substr(pad,indexc(pad,""));
  	  	 **f_scan1 = 1;
  	  end;
    end;
  end;

 pad = trim(left(compbl(pad)));

 **if indexc(scan(pad,1,""),"-")>0 then f_hyph1 = 1;

 %if %mparam_is_yes( &debug ) %then %do;
   PUT "C: " _AP_TEMP_AD= NUM= PAD= APT=;
 %end;

 ***************REMOVE FRACTIONS FROM THE BEGINNING OF THE STREET NAME PORTION OF ADDR STRING*;

 pad = trim(left(compbl(pad)));

/******* SHOULD NOT NEED THIS ANYMORE ********
 fract1=scan(pad, 1, "");
 fract2=scan(pad, 2, "");

 if substr(fract1,1,3) in ("1/2","1/4","3/4") and put( upcase( fract2 ), $marvalidsttyp. ) = "" then
  do;
     if length(fract1)<=4 then
      do;
      	 street = substr(pad,5);
      	 **f_fract = 1;
      end;
     else if length(fract1)<=5 and substr(fract1,4,1)="-" then
      do;
      	 street = substr(pad,7);
      	 **f_fract = 2;
      end;
     else
      do;
         street = substr(pad,4);
         **f_fract = 3;
      end;
 end;
 else do;
   street=pad;
 end;

 drop fract1 fract2 ;
*****************************/

 %if %mparam_is_yes( &debug ) %then %do;
   PUT "D: " _AP_TEMP_AD= NUM= PAD= APT=;
 %end;


 ***Create Addr Elements: Beg and End Str Numbers, Street Name and Apt Number***;
 
 ** Remove unit number **;

  %Addr_parse_unit( debug=&debug )

 pad1 = '';
 &var_prefix.apt = '';

 _ap_i = 1;
 wrd1 = scan( pad, _ap_i, ' ' );
 
 do while ( wrd1 ~= '' );
 
   PUT _AP_I= WRD1= PAD1=;
 
   if put( wrd1, $marvalidunit. ) ~= '' then do;
     &var_prefix.apt = trim( wrd1 ) || ' ' || scan( pad, _ap_i + 1, ' ' );
     _ap_i = _ap_i + 1;
   end;
   else do;
     pad1 = trim( pad1 ) || ' ' || wrd1;
   end;
   
   _ap_i = _ap_i + 1;
   wrd1 = scan( pad, _ap_i, ' ' );
   
 end;
  
 PUT pad= pad1= &var_prefix.apt= _ap_i=;
 
 pad = left( compbl( pad1 ) );
 
 **** PT: Separate quadrant from street name ****;

 _ap_i = max( indexw( pad, "NW" ), indexw( pad, "NE" ), 
              indexw( pad, "SW" ), indexw( pad, "SE" ) );

 if _ap_i > 0 then do;
   &var_prefix.street = substr( pad, 1, _ap_i - 2 );
   &var_prefix.quad = substr( pad, _ap_i, 2 );
 end;
 else do;
   &var_prefix.street = pad;
   &var_prefix.quad = "";
 end;

/**********************************
 **** PT: Remove APT# from street name:
 ****     Ex: 2330 GOOD HOPE RD APT 110 SE  parses to street name GOOD HOPE RD APT#
 ****     Added 08/21/05;

 &var_prefix.street = tranwrd( &var_prefix.street, "APT#", "" );

 **** PT: Check for number at the end of street name and remove;
 ****     Problem when street quadrant is missing from address;
 ****     Ex:  CONNECTICUT AV 123 ;
 ***      Added 08/21/05 ;

 _ap_i = length( &var_prefix.street );
 
 do while( indexc( substr( &var_prefix.street, _ap_i, 1 ), '0123456789' ) and _ap_i > 0 ); 
   _ap_i = _ap_i - 1;
 end;
 
 &var_prefix.street = substr( &var_prefix.street, 1, _ap_i );
**************************************************************************/

 **** PT:  End of code added 08/21/05 ****************;
 
 ** Separate street type from street name (new for Proc Geocode geocoding) **;
 
 &var_prefix.streettype = put( compress( scan( &var_prefix.street, -1, ' ' ), '-' ), $maraltsttyp. );
 
 if put( &var_prefix.streettype, $marvalidsttyp. ) ~= ""  then do;
   &var_prefix.streetname = 
     substr( &var_prefix.street, 1, length( &var_prefix.street ) - ( length( scan( &var_prefix.street, -1, ' ' ) ) + 1 ) );
 end;
 else do;
   &var_prefix.streettype = "";
   &var_prefix.streetname = &var_prefix.street;
 end;

/*********
 **** Changed BB 4/18/05 ****************************;
 *Beata: there are two sources of apt or unit info - end_apt and apt. NOTE: Have to test it further but here end_apt takes precedence over apt*;
 
 if end_apt ~= "" then
  do;
  	 if substr(end_apt,1,4) = "UNIT" then &var_prefix.apt = trim(left( tranwrd(end_apt,"UNIT#","") )); *drop UNIT# from the unit/apt field;
  	 else if substr(end_apt,1,3) = "APT" then &var_prefix.apt = trim(left( tranwrd(end_apt,"APT#","") )); *drop APT# from the unit/apt field;
  end;
 else &var_prefix.apt = trim(left( tranwrd(apt,"#","") )); *drop APT# from the field;

 
 *Beata: remove dashes from the unit/apt field if found between a number and a letter, e.g. 1-A, B-3, but not two letters or two numbers*;
 
 &var_prefix.apt = tranwrd(&var_prefix.apt,"--","-");
 &var_prefix.apt = tranwrd(&var_prefix.apt," -","-");
 &var_prefix.apt = tranwrd(&var_prefix.apt,"- ","-");

 a_dash  = indexc(&var_prefix.apt,"-");

 if a_dash >1 then
  do;
  	 if ( indexc( substr( &var_prefix.apt, a_dash-1, 1 ), "1234567890" )>0 
  	 		and indexc( substr( &var_prefix.apt, a_dash+1, 1 ), "ABCDEFGHIJKLMNOPQRSTUVWXYZ" )>0 )
  	 	or ( indexc( substr( &var_prefix.apt, a_dash-1, 1), "ABCDEFGHIJKLMNOPQRSTUVWXYZ" )>0 
  	 		and indexc( substr( &var_prefix.apt, a_dash+1, 1), "1234567890" )>0 )
		then &var_prefix.apt = trim(substr( &var_prefix.apt, 1, a_dash-1 ) ) || substr( &var_prefix.apt, a_dash+1 );
  end;

 drop a_dash;

 &var_prefix.apt = trim( left( compbl( &var_prefix.apt) ) );
 
 *************************************************BB;
 *********************************************************/
 
 &var_prefix.begnum  = input(num, 8.0);
 if input(num3,8.0)=. then &var_prefix.endnum = input(num2,8.0);
 else if input(num3,8.0)^=. then &var_prefix.endnum = input(num3,8.0);
 &var_prefix.numsuffix = numsuf;

 ***Drop other variables***;
 drop num num2 num3 apt pad pad1 /*street*/
      wrd1 abc_wrd1 wrd2 abc_wrd2 i_wrd2 wrd3 i_wrd3
      l1_wrd1 l2_wrd1 l3_wrd1 l1_wrd2
      i_dash1 i_dash2 d1_wrd abc_d1w d2_wrd abc_d2w 
      _ap_: pflag f_and2;

  _address_parse_end:

 %if %mparam_is_yes( &debug ) %then %do;
   PUT "EXITING ADDRESS_PARSE() MACRO" /;
 %end;

%mend Address_parse;

