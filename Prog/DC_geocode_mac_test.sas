/**************************************************************************
 Program:  DC_geocode_mac_test.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/24/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Test new %DC_geocode() macro.

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
  zip = "20007";

  address = '2730 Wisconsin Avenue NW';
  output;
  
  address = '2730 Wisconsin NW';
  output;
  
  address = '2730 Wisconsin';
  output;
  
  address = '2730 Wisc Ave NW';
  output;
  
  address = '2730 Wisconsin Ave NW Apt 24';
  output;
  
  address = '2730 Wawawawa Ave NW';
  output;
  
run;

%DC_geocode(
  data = A,
  staddr = address,
  zip = zip,
  out = B,
  geo_match = N,
  debug = Y,
  mprint = Y
)
  

%File_info( data=B, stats= )
  

run;
