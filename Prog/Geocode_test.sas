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

  address = '2730 Wisconsin Ave NW Apt B 4';
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
  
  ** No ZIP code provided **;
  
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
  
  ** Wrong ZIP code provided **;

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
  
  ** Street spelling variations **;
  
  zip = 20007;
  
  address = '2730 Wisconsi Ave NW';
  output;

  address = '2730 Wisconsn Ave NW';
  output;

  address = '2730 Wisc Ave NW';
  output;
  
  address = '2730 Wisconson Ave NW';
  output;
  
  ** Invalid street number **;

  zip = 20007;
  address = '2731 Wisconsin Ave NW';
  output;

  ** North Capitol Street variations **;
  
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

  ** Address ID: 	43456 **;
  zip = 20019;
  address = '2911 N STREET SE';
  output;

  ** Address ID: 	69447 **;
  zip = 20002;
  address = '1252 E STREET NE';
  output;

  ** Address ID: 	227984 **;
  zip = 20001;
  address = '27 W STREET NW';
  output;

  ** Address ID: 239696 **;
  zip = 20001;
  address = '900 S Street NW';
  output;
  
  ** Address ID: 307409 **;
  zip = .;
  address = '5010 Kimi Gray Court, SE';
  output;

  ** Apartment number with leading zero (often found in real property data) **;
  zip = .;
  address = '2600 PENNSYLVANIA AV NW Unit: 0504';
  output;
  address = '2600 PENNSYLVANIA AV NW 0504B';
  output;
  address = '2600 PENNSYLVANIA AV NW Apt # 0007';
  output;
  address = '2600 PENNSYLVANIA AV NW 0';
  output;
  address = '2600 PENNSYLVANIA AV 00';
  output;
  
  ** Pennsylvania Ave vs. Penn Street **;
  zip = .;
  address = '2555 PENN AVE NW APT 405';
  output;
  address = '550 PENN ST NE';
  output;
  
  ** Suites **;
  zip = .;
  address = '2405 I ST NW STE 8A';
  output;
  
  ** Street name same as a street type **;
  zip = .;
  address = '2337 GREEN ST';
  output;
  address = '2804 Terrace Road SE #100';
  output;
  
  ** Ambiguous quadrant - could be NE (address id: 286612) or SW (311793) **;
  ** MACRO RETURNS NE ADDRESS, WHICH MAY NOT BE THE DESIRED RESULT. NO SOLUTION FOR THIS AT THE MOMENT **;
  zip = .;
  address = '210 A Street';
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
  debug = N,
  mprint = Y
)

proc contents data=A;
run;

proc contents data=A_geo;
run;

%fdate()

options orientation=landscape;

%let outhtml = %mif_select( %sysevalf(&sysver >= 9.3), Geocode_test_94.html, Geocode_test_92.html );

ods html body="&outhtml" style=Analysis;
ods listing close;

footnote1 "&fdate";

proc print data=A_geo;
  *var address zip address_std _MATCHED_ _score_ M_ADDR M_ZIP X Y Address_id ssl;
  format x y 12.8;
run;

ods html close;
ods listing;

footnote1;

run;
