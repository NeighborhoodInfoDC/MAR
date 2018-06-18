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

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

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

  ** Address ID:  **;
  zip = .;
  address = '500 West Virginia B 24';
  output;

  ** Address ID: -none- **;
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
  geo_match = Y,
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

