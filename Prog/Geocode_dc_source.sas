/**************************************************************************
 Program:  Geocode_dc_source.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/23/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create Proc Geocode source data sets from MAR address
 points.

 Modifications:
**************************************************************************/

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

%** Geography variables to include in geocoding file **;
%let geo_vars = ssl;

proc format;
  value $streettype_to_uspsabv
    "ALLEY" = "Aly"
    "AVENUE" = "Ave"
    "BOULEVARD" = "Blvd"
    "BRIDGE" = "Brg"
    "CIRCLE" = "Cir"
    "COURT" = "Ct"
    "CRESCENT" = "Cres"
    "DRIVE" = "Dr"
    "EXPRESSWAY" = "Expy"
    "GREEN" = "Grn"
    "INTERSTATE" = "Intr"  /** ??? **/
    "KEYS" = "Kys"
    "LANE" = "Ln"
    "LOOP" = "Loop"
    "MEWS" = "Mews"
    "PARKWAY" = "Pkwy"
    "PIER" = "Pier"
    "PLACE" = "Pl"
    "PLAZA" = "Plz"
    "PROMENADE" = "Prom"  /** ??? **/
    "ROAD" = "Rd"
    "SQUARE" = "Sq"
    "STREET" = "St"
    "TERRACE" = "Ter"
    "WALK" = "Walk"
    "WAY" = "Way";
run;

proc sort 
  data=Mar.Address_points_2016_01 
    (keep=address_id fulladdress addrnum addrnumsuffix stname street_type quadrant zipcode x y
          &geo_vars
     where=(fulladdress~=''))
  out=Mar_parse;
  by stname zipcode street_type quadrant addrnum addrnumsuffix;

proc freq data=Mar_parse;
  tables street_type quadrant;
run;

proc sort data=Mar_parse out=Mar_streetnames nodupkey;
  by stname;
run;

%Data_to_format(
  FmtLib=Mar,
  FmtName=$marvalidstnm,
  Desc="MAR geocoding/valid street names",
  Data=Mar_streetnames,
  Value=stname,
  Label=stname,
  OtherLabel=' ',
  Print=N,
  Contents=Y
  )

** Create geocoding data sets **;

data 
  /*Mar.*/Geocode_dc_m
    (keep=Name Namenc Placefp Statefp Zipcode First Last
     rename=(Zipcode=Zip))
  /*Mar.*/Geocode_dc_s 
    (keep=Address_id Predirabrv Sufdirabrv Suftypabrv Side Fromadd Toadd N Start &geo_vars)
  /*Mar.*/Geocode_dc_p
    (keep=X Y);

  length
    Name Namenc $ 100
    Placefp Statefp First Last 8
    Predirabrv Sufdirabrv $ 15 
    Suftypabrv $ 50 
    Side $ 1
    Fromadd Toadd N Start 8;
    
  retain Placefp 50000 Statefp 11 Side ' ';
  retain First 1 Last 1 Start 1;

  set Mar_parse;
  **** MAY NOT BE CORRECT SORT ORDER. SHOULD STREET_TYPE BE AFTER ZIP? ****;
  by stname zipcode street_type quadrant addrnum;
  
  ** FOR NOW: Only keep first address for places with addrnumsuffix ~= '' **;
  if not first.addrnum then delete;
  
  if scan( upcase( stname ), 1, ' ' ) in ( 'NORTH', 'SOUTH', 'EAST', 'WEST' ) and
     scan( upcase( stname ), 2, ' ' ) ~= '' then do;
    Predirabrv = substr( scan( upcase( stname ), 1, ' ' ), 1, 1 );
    Name = substr( stname, length( scan( stname, 1, ' ' ) ) + 2 );
  end;
  else do;
    Name = stname;
  end;
  
  Namenc = propcase( left( Name ) );
  Name = upcase( left( compress( Name, ' ' ) ) );
    
  Sufdirabrv = upcase( quadrant );
  Suftypabrv = put( upcase( street_type ), $streettype_to_uspsabv. );
  
  Fromadd = addrnum;
  Toadd = addrnum;
  
  N = 1;
  
  output /*Mar.*/Geocode_dc_p;
  
  output /*Mar.*/Geocode_dc_s;
  
  Start + 1;
  
  if last.zipcode then do;
      output /*Mar.*/Geocode_dc_m;
   First = Last + 1;
  end;

  Last + 1;    
  
run;

proc datasets lib=/*Mar*/Work;
    modify Geocode_dc_m;
      index create NameZip        = (name zip);             /* street+zip search */
      index create NameStatePlace = (name statefp placefp); /* street+city+state search */
    run;
quit;

%File_info( data=/*Mar.*/Geocode_dc_m, printobs=100, contents=y, stats=, freqvars= )

proc print data=/*Mar.*/Geocode_dc_m;
  where name = '';
run;

%File_info( data=/*Mar.*/Geocode_dc_s, printobs=50, contents=y )
%File_info( data=/*Mar.*/Geocode_dc_p, printobs=50, contents=y, stats=n nmiss min max )

