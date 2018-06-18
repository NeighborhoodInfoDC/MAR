/**************************************************************************
 Program:  Format_maraltunit.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/27/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create format $maraltunit. for converting alternate
 unit spellings.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

proc format library=MAR;
  value $maraltunit (default=40)
    
    "APARTAMENTO" = "UNIT"
    "APARTAMENTOS" = "UNIT"
    "APARTMENT" = "UNIT"
    "APMNT" = "UNIT"
    "APMT" = "UNIT"
    "APRT" = "UNIT"
    "APRTMNT" = "UNIT"
    "APT" = "UNIT"
    "UNIT" = "UNIT"

    "APARTMENTNO" = "UNIT"
    "APMNTNO" = "UNIT"
    "APMTNO" = "UNIT"
    "APRTNO" = "UNIT"
    "APRTMNTNO" = "UNIT"
    "APTNO" = "UNIT"
    "UNITNO" = "UNIT"

    "APARTMENTNUM" = "UNIT"
    "APMNTNUM" = "UNIT"
    "APMTNUM" = "UNIT"
    "APRTNUM" = "UNIT"
    "APRTMNTNUM" = "UNIT"
    "APTNUM" = "UNIT"
    "UNITNUM" = "UNIT"
    
    "#" = "UNIT"
    "NO" = "UNIT"
    "NUM" = "UNIT"
    "NUMBER" = "UNIT"
    "NUMBR" = "UNIT"
    "NMBER" = "UNIT"

    "SUITE" = "UNIT"
    "STE" = "UNIT"
  ;
run;

proc catalog catalog=MAR.Formats;
  modify maraltunit (desc="MAR geocoding/alt. unit spellings") / entrytype=formatc;
  contents;
quit;

run;
