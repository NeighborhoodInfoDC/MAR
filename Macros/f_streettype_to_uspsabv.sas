/**************************************************************************
 Program:  f_streettype_to_uspsabv.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  12/29/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  
 
 Description:  Create $streettype_to_uspsabv format.
 Converts street types to std USPS abbreviations.
 Abbreviations can be found in SASHELP.GCTYPE data set. 

 Modifications:
**************************************************************************/


/** Macro f_streettype_to_uspsabv - Start Definition **/

%macro f_streettype_to_uspsabv(  );

  proc format;
    value $streettype_to_uspsabv
      "ALLEY" = "Aly"
      "AVENUE" = "Ave"
      "BOULEVARD" = "Blvd"
      "BRIDGE" = "Brg"
      "CIRCLE" = "Cir"
      "COURT" = "Ct"
      "CRESCENT" = "Cres"
      "DRIVE" = "Dr"
      "ENTRANCE" = "Ent"
      "EXPRESSWAY" = "Expy"
      "GREEN" = "Grn"
      "INTERSTATE" = "Interstate"
      "KEYS" = "Kys"
      "LANE" = "Ln"
      "LOOP" = "Loop"
      "MEWS" = "Mews"
      "PARKWAY" = "Pkwy"
      "PIER" = "Pier"
      "PLACE" = "Pl"
      "PLAZA" = "Plz"
      "PROMENADE" = "Promenade"
      "ROAD" = "Rd"
      "SQUARE" = "Sq"
      "STREET" = "St"
      "TERRACE" = "Ter"
      "WALK" = "Walk"
      "WAY" = "Way";
  run;

%mend f_streettype_to_uspsabv;

/** End Macro Definition **/

