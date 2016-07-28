/**************************************************************************
 Program:  Format_maraltsttyp.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/24/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create format $maraltsttype.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

proc format library=MAR;
  value $maraltsttyp (default=40)
    "ALLEE" = "ALLEY"
    "ALLEY" = "ALLEY"
    "ALLY" = "ALLEY"
    "ALY" = "ALLEY"
    "AENUE" = "AVENUE"
    "AV" = "AVENUE"
    "AVE" = "AVENUE"
    "AVEN" = "AVENUE"
    "AVENU" = "AVENUE"
    "AVENUE" = "AVENUE"
    "AVENUES" = "AVENUE"
    "AVEUE" = "AVENUE"
    "AVN" = "AVENUE"
    "AVNEUE" = "AVENUE"
    "AVNUE" = "AVENUE"
    "BLVD" = "BOULEVARD"
    "BOUL" = "BOULEVARD"
    "BOULEVARD" = "BOULEVARD"
    "BOULV" = "BOULEVARD"
    "BUOLEVARD" = "BOULEVARD"
    "BVLD" = "BOULEVARD"
    "BRDGE" = "BRIDGE"
    "BRG" = "BRIDGE"
    "BRIDGE" = "BRIDGE"
    "CIR" = "CIRCLE"
    "CIRC" = "CIRCLE"
    "CIRCL" = "CIRCLE"
    "CIRCLE" = "CIRCLE"
    "CR" = "CIRCLE"
    "CRCL" = "CIRCLE"
    "CRCLE" = "CIRCLE"
    "COURT" = "COURT"
    "COURTS" = "COURT"
    "CRT" = "COURT"
    "CT" = "COURT"
    "CRECENT" = "CRESCENT"
    "CRES" = "CRESCENT"
    "CRESCENT" = "CRESCENT"
    "CRESENT" = "CRESCENT"
    "CRSCNT" = "CRESCENT"
    "CRSENT" = "CRESCENT"
    "CRSNT" = "CRESCENT"
    "DR" = "DRIVE"
    "DRI" = "DRIVE"
    "DRIV" = "DRIVE"
    "DRIVE" = "DRIVE"
    "DRV" = "DRIVE"
    "EXP" = "EXPRESSWAY"
    "EXPR" = "EXPRESSWAY"
    "EXPRESS" = "EXPRESSWAY"
    "EXPRESSWAY" = "EXPRESSWAY"
    "EXPW" = "EXPRESSWAY"
    "EXPY" = "EXPRESSWAY"
    "GREEN" = "GREEN"
    "GRN" = "GREEN"
    "INTERSTATE" = "INTERSTATE"
    "KEYS" = "KEYS"
    "KYS" = "KEYS"
    "LA" = "LANE"
    "LANE" = "LANE"
    "LANES" = "LANE"
    "LN" = "LANE"
    "LOOP" = "LOOP"
    "LOOPS" = "LOOP"
    "MEWS" = "MEWS"
    "PARKWAY" = "PARKWAY"
    "PARKWY" = "PARKWAY"
    "PKW" = "PARKWAY"
    "PKWAY" = "PARKWAY"
    "PKWY" = "PARKWAY"
    "PKY" = "PARKWAY"
    "PRKWAY" = "PARKWAY"
    "PRKWY" = "PARKWAY"
    "PIER" = "PIER"
    "PL" = "PLACE"
    "PLA" = "PLACE"
    "PLAC" = "PLACE"
    "PLACE" = "PLACE"
    "PLC" = "PLACE"
    "PLAZA" = "PLAZA"
    "PLZ" = "PLAZA"
    "PLZA" = "PLAZA"
    "PROMENADE" = "PROMENADE"
    "RD" = "ROAD"
    "ROAD" = "ROAD"
    "ROADS" = "ROAD"
    "SQ" = "SQUARE"
    "SQR" = "SQUARE"
    "SQRE" = "SQUARE"
    "SQU" = "SQUARE"
    "SQUARE" = "SQUARE"
    "DTREET" = "STREET"
    "SREET" = "STREET"
    "SSTREET" = "STREET"
    "ST" = "STREET"
    "STEET" = "STREET"
    "STR" = "STREET"
    "STRE" = "STREET"
    "STREE" = "STREET"
    "STREEET" = "STREET"
    "STREET" = "STREET"
    "STREETS" = "STREET"
    "STRET" = "STREET"
    "STRETT" = "STREET"
    "STRRE" = "STREET"
    "STRT" = "STREET"
    "TEARRACE" = "TERRACE"
    "TER" = "TERRACE"
    "TERACE" = "TERRACE"
    "TERR" = "TERRACE"
    "TERRA" = "TERRACE"
    "TERRAC" = "TERRACE"
    "TERRACE" = "TERRACE"
    "TERRANCE" = "TERRACE"
    "TR" = "TERRACE"
    "WALK" = "WALK"
    "WAY" = "WAY"
    "WY" = "WAY"
  ;
run;

proc catalog catalog=MAR.Formats;
  modify maraltsttyp (desc="MAR geocoding/alt. street type spellings") / entrytype=formatc;
  contents;
quit;

run;
