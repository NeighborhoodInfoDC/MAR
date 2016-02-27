/**************************************************************************
 Program:  Format_marvalidunit.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/27/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create format $marvalidunit.

 Modifications:
**************************************************************************/

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

proc format library=MAR;
  value $marvalidunit (default=40)
    "APT" = "APT"
    "STE" = "STE"
    other = " ";
run;

proc catalog catalog=MAR.Formats;
  modify marvalidunit (desc="MAR geocoding/valid unit") / entrytype=formatc;
  contents;
quit;

run;
