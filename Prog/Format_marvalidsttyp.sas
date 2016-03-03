/**************************************************************************
 Program:  Format_marvalidsttyp.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/24/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create format $marvalidsttype.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

proc format library=MAR;
  value $marvalidsttyp (default=40)
    "ALLEY" = "ALLEY"
    "AVENUE" = "AVENUE"
    "BOULEVARD" = "BOULEVARD"
    "CIRCLE" = "CIRCLE"
    "COURT" = "COURT"
    "CRESCENT" = "CRESCENT"
    "DRIVE" = "DRIVE"
    "GREEN" = "GREEN"
    "KEYS" = "KEYS"
    "LANE" = "LANE"
    "LOOP" = "LOOP"
    "MEWS" = "MEWS"
    "PARKWAY" = "PARKWAY"
    "PLACE" = "PLACE"
    "ROAD" = "ROAD"
    "SQUARE" = "SQUARE"
    "STREET" = "STREET"
    "TERRACE" = "TERRACE"
    "WALK" = "WALK"
    "WAY" = "WAY"
    other = " ";
run;

proc catalog catalog=MAR.Formats;
  modify marvalidsttyp (desc="MAR geocoding/valid street types") / entrytype=formatc;
  contents;
quit;



run;
