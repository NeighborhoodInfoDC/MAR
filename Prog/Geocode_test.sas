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

  retain city 'Washington' state 'DC';

  length address $ 80;

  ** Address ID: 262667 **;
  zip = 20007;
  address = '2730 Wisconsin Ave NW';
  output;

  address = '2730 Wisconsin Ave NW Apt 38';
  output;

  address = '2730 Wisconsin Ave NW Apt38';
  output;

  address = '2730 Wisconsin Ave Apt 38 NW';
  output;

  address = '2730 Wisconsin Ave Northwest';
  output;

  address = '2730 Wisconsin Ave Northwest apt 38';
  output;

  address = '2730 Wisconsin Ave NW #38';
  output;

  address = '2730 Wisconsin Ave NW Apt B';
  output;

  address = '2730 Wisconsin Ave NW Apt#38';
  output;

  address = '2730 Wisconsin Ave NW unit 38';
  output;

  address = '2730 Wisconsin Ave NW #38';
  output;

  address = '2730 Wisconsin Ave NW 38';
  output;

  address = '2730 Wisconsin Ave NW Number 38';
  output;

  address = '2730 Wisconsin Ave Number 38';
  output;

  address = '2730 Wisconsin Ave NW 3rd floor';
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
  
  ** Address ID: 57422 **;
  zip = 20002;
  address = '1715 N CAPITOL STREET NE';
    output;
  
  address = '1715 NO CAPITOL STREET NE';
    output;
  
  address = '1715 NOR CAPITOL STREET NE';
    output;
  
  address = '1715 NORTH CAPITOL STREET NE';
    output;
  
  ** Address ID: 79340 **;
  zip = 20002;
  address = '777 N CAPITOL STREET NE';
  output;
  
  ** Address ID: 286132 **;
  zip = 20002;
  address = '1401 New York Avenue NE';
  output;
  
  ** Address ID: 237016 **;
  zip = 20001;
  address = '3 NEW YORK AVENUE NW';
  output;
  
  ** Address ID: 74776 **;
  zip = 20002;
  address = '107 10TH STREET NE';
  output;
  address = '107 10TH STREET NE UNIT 555';
  output;
  
  ** Address ID: 308645 [but should match to 74776] **;
  zip = 20002;
  address = '107 1/2 10TH STR NE';
  output;
  address = '1071/2 10TH STRT NE';
  output;
  
  ** Address ID: 80721 **;
  address = '822 12TH STREET NE';
  output;
  
  ** Address ID: 310609 [but should match to 80721] **;
  address = '822REAR 12TH STREET NE';
  output;
  address = '822 REAR 12TH STREET NE';
  output;
  
  ** Address ID: 225736 **;
  zip = 20005;
  address = '1529 14TH STREET NW';
  output;
  
  ** Address ID: 304947 **;
  address = '1529 A 14TH STREET NW';
  output;
  
  address = '1529A 14TH STREET NW';
  output;
  
  ** Address ID: 61186 **;
  zip = 20002;
  address = '1529 A STREET NE';  
  output;
  
  ** A: Address ID: 298085 **;
  ** B: Address ID: 278477 **;
  zip = 20032;
  address = '4220 9TH STREET SE';
  output;
  address = '4220A 9TH STREET SE';
  output;
  address = '4220B 9TH STREET SE';
  output;
  
  ** Address ID: 311802 **;
  zip = 20319;
  address = '102 a street sw';
  output;
  address = '102a street sw';
  output;
  
  ** CONDO UNIT / Address ID: 226568 / SSL: 0158 0079 **;
  zip = 20036;
  address = '1325 18TH ST NW APT 1012';
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

ods html body="C:\DCData\Libraries\MAR\Prog\Geocode_test.html" style=Analysis;

proc print data=A_geo;
  var address zip address_std _MATCHED_ _score_ M_ADDR M_ZIP X Y Address_id ssl;
  format x y 12.8;
run;

ods html close;


run;
