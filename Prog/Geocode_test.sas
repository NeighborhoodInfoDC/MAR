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
  
run;

proc geocode method=street /*nozip nocity*/
  data=A
  out=A_geo
  lookupstreet=Mar.Geocode_dc_m
  attributevar=(address_id ssl);
  run;
quit;

options orientation=landscape;

ods html body="C:\DCData\Libraries\MAR\Prog\Geocode_test.html" style=Analysis;

proc print data=A_geo;
  var address zip _MATCHED_ _score_ M_ADDR M_ZIP X Y Address_id ssl;
  format x y 12.8;
run;

ods html close;


run;
