/**************************************************************************
 Program:  Geocode_exhaustive_test.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  12/29/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  
 
 Description:  Test %%DC_mar_geocode() with every street name, type, 
 and quadrant in MAR. 

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )


** Prepare test addresses **;
** Omit addresses with 1/2, letters or other street number suffixes as these are not matched exactly **;

proc sort 
  data=Mar.Address_points_view 
         (keep=address_id address_type fulladdress addrnumsuffix stname street_type quadrant zipcode
          rename=(address_id=address_id_ref)
          where=(address_type='A' and addrnumsuffix = ''))
  out=Address_test
  nodupkey;
  by stname street_type quadrant;
run;


** Run through geocoder **;

%DC_mar_geocode(
  geo_match=Y,
  data=Address_test,
  out=Address_test_geocode,
  staddr=fulladdress,
  /*zip=zipcode,*/
  listunmatched=N,
  debug=N
)


title2 '** Addresses that do not match exactly **';

proc print data=Address_test_geocode;
  where address_id ~= address_id_ref;
  var fulladdress M_ADDR address_id address_id_ref; 
run;

title2;
