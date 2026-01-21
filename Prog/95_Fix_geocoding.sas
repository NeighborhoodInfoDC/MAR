/**************************************************************************
 Program:  95_Fix_geocoding.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  12/17/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  95
 
 Description:  https://github.com/NeighborhoodInfoDC/MAR/issues/95
 
 Problem addresses

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )


data A;

  retain city 'WASHINGTON' st 'DC';
  
  length address $ 80;
  
  infile datalines dsd;
  
  input address;
  
  label
    address = 'TESTING ADDRESS'
    city = 'TESTING CITY'
    st = 'TESTING STATE';

datalines;
955 L'ENFANT PLAZA SW
357 L'ENFANT PROMENADE SW
20 PARKER ROW SW
run;

/*******************
proc geocode method=street nozip data=A out=B_proc_geocode addressvar=address 
addresscityvar=city addressstatevar=st lookupstreet=Geocode_94_dc_m attributevar=(address_id Geo2020 Ward2022 Latitude Longitude);

title2 'B_proc_geocode';
proc print data=B_proc_geocode;
  id address;
  var m_addr address_id _score_ _notes_;
run;
title2;
***************************/


%DC_mar_geocode(
  geo_match=Y,
  data=A,
  out=B_DC_mar_geocode,
  staddr=address,
  zip=,
  /***basefile=Geocode_94_dc_m,***/
  /***streetalt_file=C:\DCData\Libraries\MAR\Prog\StreetAlt_38_Fix_geocoding.txt,***/
  listunmatched=Y,
  debug=N
)

title2 'B_DC_mar_geocode';
proc print data=B_DC_mar_geocode n;
  id address;
  var m_addr address_id M_EXACTMATCH _score_ _notes_ mar_status;
run;
title2;

%File_info( data=B_DC_mar_geocode, printobs=5 )
