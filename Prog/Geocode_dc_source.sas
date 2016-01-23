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

proc format;
  value $streettype_to_uspsabv
    "ALLEY" = "Aly"
    "AVENUE" = "Ave"
    "BOULEVARD" = "Blvd"
    "CIRCLE" = "Cir"
    "COURT" = "Ct"
    "CRESCENT" = "Cres"
    "DRIVE" = "Dr"
    "GREEN" = "Grn"
    "KEYS" = "Kys"
    "LANE" = "Ln"
    "LOOP" = "Loop"
    "MEWS" = "Mews"
    "PARKWAY" = "Pkwy"
    "PLACE" = "Pl"
    "ROAD" = "Rd"
    "SQUARE" = "Sq"
    "STREET" = "St"
    "TERRACE" = "Ter"
    "WALK" = "Walk"
    "WAY" = "Way";
run;

data Mar_parse;

  set Mar.address_points 
    (keep=address_id fulladdres zipcode ssl
     where=(fulladdres~='' /*AND ( FULLADDRES CONTAINS 'WISCONSIN' OR FULLADDRES CONTAINS 'CAPITOL' )*/));
  
  length xnumber $ 32 number 8 streetname streettype dir $ 40 buff $ 200;
  
  buff = left( compbl( fulladdres ) );
  
  xnumber = scan( buff, 1, ' ' );
  number = input( xnumber, 32. );
  
  buff = substr( buff, length( xnumber ) + 2 );
  
  if scan( buff, 1, ' ' ) in ( '1/2', 'REAR' ) then buff = substr( buff, length( scan( buff, 1, ' ' ) ) + 2 );
  
  if scan( buff, 1, ' ' ) in ( 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'R' ) then do;
    if scan( buff, 2, ' ' ) not in ( 'STREET', 'ROAD', 'COURT', 'PLACE', 'TERRACE' ) then buff = substr( buff, 3 );
  end;
  
  dir = scan( buff, -1, ' ' );
  
  streettype = scan( buff, -2, ' ' );
  
  streetname = substr( buff, 1, length( buff ) - ( length( dir ) + length( streettype ) + 2 ) );
  
  drop buff xnumber;
  
run;

proc sort data=Mar_parse;
  by streetname zipcode number;

proc print data=Mar_parse (obs=40);
run;

proc freq data=Mar_parse;
  tables streetname streettype dir;
run;

data 
  Mar.Geocode_dc_m
    (keep=Name Namenc Placefp Statefp Zip First Last)
  Mar.Geocode_dc_s 
    (keep=Address_id Predirabrv Sufdirabrv Suftypabrv Side Fromadd Toadd N Start ssl)
  Mar.Geocode_dc_p
    (keep=X Y);

  length
    Name Namenc $ 100
    Placefp Statefp Zip First Last 8
    Predirabrv Sufdirabrv $ 15 
    Suftypabrv $ 50 
    Side $ 1
    Fromadd Toadd N Start 8
    X Y 8;
    
  retain Placefp 50000 Statefp 11;
  retain First 1 Last 1 Start 1;

  set Mar_parse;
  by streetname zipcode;
  
  Zip = input( zipcode, best32. );
  Side = ' ';
  
  if scan( upcase( streetname ), 1, ' ' ) in ( 'NORTH', 'SOUTH', 'EAST', 'WEST' ) then do;
    Predirabrv = substr( scan( upcase( streetname ), 1, ' ' ), 1, 1 );
    Name = substr( streetname, length( scan( streetname, 1, ' ' ) ) + 2 );
  end;
  else do;
    Name = streetname;
  end;
  
  Namenc = propcase( left( Name ) );
  Name = upcase( left( compress( Name, ' ' ) ) );
    
  Sufdirabrv = upcase( dir );
  Suftypabrv = put( upcase( streettype ), $streettype_to_uspsabv. );
  
    Fromadd = number;
    Toadd = number;
    
    N = 1;
    X = .;
    Y = .;
    
    output Mar.Geocode_dc_p;
    
    output Mar.Geocode_dc_s;
    
    Start + 1;
    
  if last.zipcode then do;
      output Mar.Geocode_dc_m;
   First = Last + 1;
  end;

  Last + 1;    
  
run;

proc datasets lib=Mar;
    modify Geocode_dc_m;
      index create NameZip        = (name zip);             /* street+zip search */
      index create NameStatePlace = (name statefp placefp); /* street+city+state search */
    run;
quit;

%File_info( data=Mar.Geocode_dc_m, printobs=100, contents=y, stats=, freqvars=name )
%File_info( data=Mar.Geocode_dc_s, printobs=200, contents=n )
%File_info( data=Mar.Geocode_dc_p, printobs=0, contents=n, stats=n nmiss min max )

