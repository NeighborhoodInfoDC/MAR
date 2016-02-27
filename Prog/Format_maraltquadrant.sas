/**************************************************************************
 Program:  Format_maraltquadrant.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/24/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create format $maraltquadrante.

 Modifications:
**************************************************************************/

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

proc format library=MAR;
  value $maraltquadrant (default=40)
    "NE" = "NE"
    "NORTHEAST" = "NE"
    "NORTHEAS" = "NE"
    "NORTHEA" = "NE"
    "NORTHE" = "NE"
    "NEAST" = "NE"
    "NW" = "NW"
    "NORTHWEST" = "NW"
    "NORTHWES" = "NW"
    "NORTHWE" = "NW"
    "NORTHW" = "NW"
    "NWEST" = "NW"
    "SE" = "SE"
    "SOUTHEAST" = "SE"
    "SOUTHEAS" = "SE"
    "SOUTHEA" = "SE"
    "SOUTHE" = "SE"
    "SEAST" = "SE"
    "SW" = "SW"
    "SOUTHWEST" = "SW"
    "SOUTHWES" = "SW"
    "SOUTHWE" = "SW"
    "SOUTHW" = "SW"
    "SWEST" = "SW"
  ;
run;

proc catalog catalog=MAR.Formats;
  modify maraltquadrant (desc="MAR geocoding/alt. quadrant spellings") / entrytype=formatc;
  contents;
quit;

run;
