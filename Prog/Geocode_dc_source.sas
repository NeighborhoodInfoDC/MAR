/**************************************************************************
 Program:  Geocode_dc_source.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/23/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create Proc Geocode source data sets from MAR address
 points. File format compatible with SAS ver 9.2 and 9.3.

 Also updates $marvalidstnm format and ValidStreets.html file.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

%let mar_source = Address_points_2016_01;
%let revisions = Updated with &mar_source..;

%** Geography variables to include in geocoding file **;
%let geo_vars = 
  Ward2002 Ward2012 VoterPre2012 Psa2012 Psa2004 LATITUDE
  LONGITUDE Geo2000 Geo2010 GeoBg2010 GeoBlk2010 Cluster2000
  Cluster_tr2000 Assessnbhd Anc2002 Anc2012 ssl;

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
    "INTERSTATE" = "Interstate"
    "KEYS" = "Kys"
    "LANE" = "Ln"
    "LOOP" = "Loop"
    "MEWS" = "Mews"
    "PARKWAY" = "Pkwy"
    "PIER" = "Pier"
    "PLACE" = "Pl"
    "PLAZA" = "Plz"
    "PROMENADE" = "Promenade"
    "ROAD" = "Rd"
    "SQUARE" = "Sq"
    "STREET" = "St"
    "TERRACE" = "Ter"
    "WALK" = "Walk"
    "WAY" = "Way";
run;

proc sort 
  data=Mar.&mar_source 
    (keep=address_id address_type fulladdress addrnum addrnumsuffix stname street_type quadrant zipcode x y
          &geo_vars
     where=(address_type = 'A' and fulladdress ~= ''))
  out=Mar_parse;
  by stname zipcode street_type quadrant addrnum addrnumsuffix;

proc freq data=Mar_parse;
  tables street_type quadrant;
run;


** Create $marvalidstnm format for %Dc_geocode() macro **;

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


** Export list of valid street names **;

ods listing close;
ods html body="&_dcdata_r_path\Mar\Doc\ValidStreets.html" style=Minimal;

proc print data=Mar_streetnames noobs label;
  var stname;
  label stname = "Valid street names (&mar_source)";
run;

ods html close;
ods listing;


** Create geocoding data sets for Proc Geocode (v9.3) **;

data 
  Mar.Geocode_dc_m
    (keep=Name Namenc Placefp Statefp Zipcode First Last
     rename=(Zipcode=Zip)
     label="Primary street lookup data for Proc Geocode (DC MAR)")
  Mar.Geocode_dc_s 
    (keep=Address_id Predirabrv Sufdirabrv Suftypabrv Side Fromadd Toadd N Start &geo_vars
     label="Secondary street lookup data for Proc Geocode (DC MAR)")
  Mar.Geocode_dc_p
    (keep=X Y
     label="Tertiary street lookup data for Proc Geocode (DC MAR)");

  length
    Name Namenc $ 100
    Placefp Statefp First Last 8
    Predirabrv Sufdirabrv $ 15 
    Suftypabrv $ 50 
    Side $ 1
    Fromadd Toadd N Start 8;
    
  retain Placefp 50000 Statefp 11 Side ' ';
  retain First 1 Last 0 Start 0 N 1;

  set Mar_parse;
  by stname zipcode street_type quadrant addrnum;
  
  if scan( upcase( stname ), 1, ' ' ) in ( 'NORTH', 'SOUTH', 'EAST', 'WEST' ) and
     scan( upcase( stname ), 2, ' ' ) ~= '' then do;
    Predirabrv = substr( scan( upcase( stname ), 1, ' ' ), 1, 1 );
    Name = substr( stname, length( scan( stname, 1, ' ' ) ) + 2 );
    Namenc = propcase( left( Name ) );
    Name = upcase( left( compress( Name, ' ' ) ) );
  end;
  else if stname in ( 'S', 'N', 'E', 'W' ) then do;
    Name = '~' || trim( stname ) || '~';
    Namenc = Name;
  end;
  else do;
    Name = upcase( left( compress( stname, ' ' ) ) );
    Namenc = propcase( left( stname ) );
  end;
  
  Sufdirabrv = upcase( quadrant );
  Suftypabrv = put( upcase( street_type ), $streettype_to_uspsabv. );
  
  ** FOR NOW: Only keep first address for places with addrnumsuffix ~= '' **;

  if first.addrnum then do;

    Fromadd = addrnum;
    Toadd = addrnum;
    
    Start + 1;

    output Mar.Geocode_dc_p;
    
    output Mar.Geocode_dc_s;
        
    Last + 1;    
  
  end;
  
  if last.zipcode then do;
    output Mar.Geocode_dc_m;
    First = Last + 1;
  end;
  
  label
    Name = "Street name (all uppercase)"
    Namenc = "Street name"
    Placefp = "Place FIPS code"
    Statefp = "State FIPS code"
    First = "First observation for street in Geocode_dc_s"
    Last  = "Last observation for street in Geocode_dc_s"
    Fromadd = "Start of address number range"
    N = "Number of address points in Geocode_dc_p"
    Predirabrv = "Street direction prefix abbreviation"
    Side = "Side of street"
    Start = "Starting observation for address in Geocode_dc_p"
    Sufdirabrv = "Street direction suffix abbreviation"
    Suftypabrv = "Street type suffix abbreviation"
    Toadd = "End of address number range"
    LATITUDE = "Latitude of address (GCS North American Datum, 1983)"
    LONGITUDE = "Longitude of address (GCS North American Datum, 1983)"
    X = "X coordinate of address point (GCS North American Datum, 1983)"
    Y = "Y coordinate of address point (GCS North American Datum, 1983)"
   ;

run;

proc datasets lib=Mar;
    modify Geocode_dc_m;
      index create NameZip        = (name zip);             /* street+zip search */
      index create NameStatePlace = (name statefp placefp); /* street+city+state search */
    run;
quit;

%File_info( data=Mar.Geocode_dc_m, printobs=40, contents=y, stats=n nmiss min max, freqvars=name )
%File_info( data=Mar.Geocode_dc_s, printobs=20, contents=y )
%File_info( data=Mar.Geocode_dc_p, printobs=40, contents=y, stats=n nmiss min max )

** Update metadata **;

%Dc_update_meta_file(
  ds_lib=MAR,
  ds_name=Geocode_dc_m,
  creator_process=Geocode_dc_source.sas,
  restrictions=None,
  revisions=%str(&revisions)
)

%Dc_update_meta_file(
  ds_lib=MAR,
  ds_name=Geocode_dc_s,
  creator_process=Geocode_dc_source.sas,
  restrictions=None,
  revisions=%str(&revisions)
)

%Dc_update_meta_file(
  ds_lib=MAR,
  ds_name=Geocode_dc_p,
  creator_process=Geocode_dc_source.sas,
  restrictions=None,
  revisions=%str(&revisions)
)

