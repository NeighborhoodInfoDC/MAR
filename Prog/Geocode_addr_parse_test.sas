/**************************************************************************
 Program:  Geocode_test.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/23/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Test geocoding against MAR database.

 Modifications:
**************************************************************************/

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

proc format;
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
    "AVERNUE" = "AVENUE"
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
    "TREET" = "STREET"
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
  value $marvalidquadrant (default=40)
    "NE" = "NE"
    "NW" = "NW"
    "SE" = "SE"
    "SW" = "SW"
    other = " ";
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
  value $maraltunit (default=40)
    
    "#" = "UNIT"
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

    "SUITE" = "UNIT"
    "STE" = "UNIT"
  ;
  value $marvalidunit (default=40)
    "UNIT" = "UNIT"
    other = " ";

  VALUE $MARVALIDSTNM (DEFAULT=40)
    "WISCONSIN" = "WISCONSIN"
    "GREEN" = "GREEN"
    "TERRACE" = "TERRACE"
    "WEST VIRGINIA" = "WEST VIRGINIA"
    OTHER = " ";

  VALUE $MARALTSTNAME (DEFAULT=40)
    "WISC" = "WISCONSIN"
    ;
run;



data A;

  retain city 'Washington' state 'DC';

  length address $ 80;
  
  ** Address ID: 262667 **;
  zip = 20007;
  address = '2730 Wisconsin Ave NW';
  output;

  ** Address ID:  **;
  zip = .;
  address = '2337 GREEN ST';
  output;

  ** Address ID: 262667 **;
  zip = 20007;
  address = '2730 Wisconsin Ave NW Apt 38';
  output;

  ** Address ID:  **;
  zip = .;
  address = '2804 Terrace Road SE #100';
  output;

  ** Address ID: 262667 **;
  zip = 20007;
  address = '2730 Wisconsin Ave NW 38';
  output;

  ** Address ID: 262667 **;
  zip = 20007;
  address = '2730 Wisconsin Ave 0038';
  output;

  ** Address ID: 262667 **;
  zip = 20007;
  address = '2730 Wisconsin 38';
  output;

  ** Address ID: 262667 **;
  zip = .;
  address = '500 West Virginia B 24';
  output;

  ** Address ID: 262667 **;
  zip = 20007;
  address = '2730 FOOBAR 38';
  output;

  label address = 'Street address';  
  
run;

options spool;

%DC_mar_geocode(
  data = A,
  staddr = address,
  zip = zip,
  out = A_geo,
  geo_match = N,
  /*
  basefile = SASHELP.GEOEXM,
  keep_geo = TRACTCE00,
  */
  streetalt_file=,
  debug = Y,
  mprint = Y
)

proc contents data=A;
run;

proc contents data=A_geo;
run;

options orientation=landscape;

proc print data=A_geo;
  *var address zip address_std _MATCHED_ _score_ M_ADDR M_ZIP X Y Address_id ssl;
run;

