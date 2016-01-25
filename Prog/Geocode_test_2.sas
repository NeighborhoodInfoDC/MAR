/**************************************************************************
 Program:  Geocode_test_2.sas
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


data A;

  length address $ 80;

  city = 'Washington';
  state = 'DC';
  zip = 20007;

  address = '2730 Wisconsin Ave NW';
  output;
  
  address = '2730 Wisconsin Ave';
  output;

  address = '2730 Wisconsin';
  output;

  address = '2730 Wisconsin NW';
  output;

  address = '2730 Wisconsin St NW';
  output;

  address = '2730 Wisconsin Avenue';
  output;

  address = '2730 Wisconsin Ave NE';
  output;
  
  zip = .;

  address = '2730 Wisconsin Ave NW';
  output;
  
  address = '2730 Wisconsin Ave';
  output;

  address = '2730 Wisconsin';
  output;

  address = '2730 Wisconsin NW';
  output;

  address = '2730 Wisconsin St NW';
  output;

  address = '2730 Wisconsin Avenue';
  output;

  address = '2730 Wisconsin Ave NE';
  output;

  zip = 20009;

  address = '2730 Wisconsin Ave NW';
  output;
  
  address = '2730 Wisconsin Ave';
  output;

  address = '2730 Wisconsin';
  output;

  address = '2730 Wisconsin NW';
  output;

  address = '2730 Wisconsin St NW';
  output;

  address = '2730 Wisconsin Avenue';
  output;

  address = '2730 Wisconsin Ave NE';
  output;
  
  zip = 20007;
  
  address = '2730 Wisconsi Ave NW';
  output;

  address = '2730 Wisconsn Ave NW';
  output;

  address = '2730 Wisc Ave NW';
  output;
  
  address = '2730 Wisconson Ave NW';
  output;
  
  zip = 20002;
  address = '1715 N CAPITOL STREET NE';
    output;
  
  zip = 20002;
  address = '777 N CAPITOL STREET NE';
  output;
  
  zip = 20002;
  address = '1401 New York Avenue NE';
  output;
  
  zip = 20001;
  address = '3 NEW YORK AVENUE NW';
  output;
  
run;

%DC_geocode(
  data = A,
  staddr = address,
  zip = zip,
  out = A_geo,
  geo_match = Y,
  debug = Y,
  mprint = Y
)

options orientation=landscape;

ods html body="C:\DCData\Libraries\MAR\Prog\Geocode_test_2.html" style=Analysis;

proc print data=A_geo;
  var address zip _MATCHED_ _score_ M_ADDR M_ZIP X Y Address_id ssl;
  format x y 12.8;
run;

ods html close;


run;
