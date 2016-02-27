/**************************************************************************
 Program:  Format_marvalidquadrant.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/24/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create format $marvalidquadrante.

 Modifications:
**************************************************************************/

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

proc format library=MAR;
  value $marvalidquadrant
    "NE" = "NE"
    "NW" = "NW"
    "SE" = "SE"
    "SW" = "SW"
    other = " ";
run;

proc catalog catalog=MAR.Formats;
  modify marvalidquadrant (desc="MAR geocoding/valid quadrant") / entrytype=formatc;
  contents;
quit;

run;
