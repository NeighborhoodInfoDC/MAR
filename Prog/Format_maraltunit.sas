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

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

proc format library=MAR;
  value $maraltunit (default=40)
    
    "APARTAMENTO" = "APT"
    "APARTAMENTOS" = "APT"
    "APARTMENT" = "APT"
    "APMNT" = "APT"
    "APMT" = "APT"
    "APRT" = "APT"
    "APRTMNT" = "APT"
    "APT" = "APT"
    "UNIT" = "APT"

    "APARTMENTNO" = "APT"
    "APMNTNO" = "APT"
    "APMTNO" = "APT"
    "APRTNO" = "APT"
    "APRTMNTNO" = "APT"
    "APTNO" = "APT"
    "UNITNO" = "APT"

    "APARTMENTNUM" = "APT"
    "APMNTNUM" = "APT"
    "APMTNUM" = "APT"
    "APRTNUM" = "APT"
    "APRTMNTNUM" = "APT"
    "APTNUM" = "APT"
    "UNITNUM" = "APT"

    "SUITE" = "STE"
    "STE" = "STE"
  ;
run;

proc catalog catalog=MAR.Formats;
  modify maraltunit (desc="MAR geocoding/alt. unit spellings") / entrytype=formatc;
  contents;
quit;

run;
