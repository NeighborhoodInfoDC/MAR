/**************************************************************************
 Program:  38_Fix_geocoding.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  12/17/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  38
 
 Description:  https://github.com/NeighborhoodInfoDC/MAR/issues/38
 
 Problem addresses
   849 H R Drive SE
   5042 Queen's Stroll Place SE
   3033 West Lane Keys NW
   3150 South Street NW
   4400 Falls Terrace SE
   2915 Chancellor's Way Northeast
   1999 9 1/2 Street Northwest
   4355 Forest Lane NW
   403 GUETHLER'S WAY SE
   3336 Cady's Alley NW
   8425 East Beach Drive NW
   907 Barry Place NW [RETIRED ADDRESS]

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

/*********
data WestLaneKeys;

  set Mar.Address_points_view (obs=1);
  *where lowcase( stname ) contains "west lane";
  
    length
    Name Name2 $ 100
    Mapidnameabrv $ 2
    First Last Zcta 8
    Predirabrv Sufdirabrv Pretypabrv Suftypabrv $ 15 
    City City2 $ 50 
    Side $ 1
    Fromadd Toadd N Start 8;
    

    if scan( upcase( stname ), 1, ' ' ) in ( 'NORTH', 'SOUTH', 'EAST', 'WEST' ) and
       scan( upcase( stname ), 2, ' ' ) ~= '' then do;
      Predirabrv = substr( scan( upcase( stname ), 1, ' ' ), 1, 1 );
      Name = substr( stname, length( scan( stname, 1, ' ' ) ) + 2 );
      Name2 = upcase( left( compress( Name, ' ' ) ) );
      OUTPUT;
    end;
    else if stname in ( 'S', 'N', 'E', 'W' ) then do;
      Name2 = '~' || trim( stname ) || '~';
      Name = Name2;
    end;
    else do;
      Name = propcase( left( stname ) );
      Name2 = upcase( left( compress( stname, ' ' ) ) );
    end;
    
run;


proc freq data=WestLaneKeys;
  tables stname * Name2 /list;
run;
***************/
/*
proc print data=Mar.Address_points_view (obs=10);
  where upcase( stname ) = 'EAST';
  id address_id;
  var fulladdress;
run;
*/

  ** Create format for temporary recoding of street names that match direction abbreviations;
  ** Workaround for Proc Geocode problem matching these streets;
  
  %Format_dcg_strecode()
  
  /*
  proc format;
    value $_dcg_strecode (default=40)
      'E', 'N', 'S', 'W',
      'NORTH', 'SOUTH', 'EAST', 'WEST', 
      'WEST LANE', 'EAST BEACH', 'WEST BEACH', 
      'FOREST', 'FALLS'
      = 'YES'
      other = ' ';
  run;
  */



**** CREATE NEW GEOCODING FILES ****;

%** Geography variables to include in geocoding file **;
%let geo_vars = 
  Geo2000 Geo2010 Geo2020
  GeoBg2020 GeoBlk2020
  Ward2002 Ward2012 Ward2022 
  Psa2004 Psa2012 Psa2019
  Cluster2000 Cluster_tr2000 Cluster2017
  Latitude Longitude SSL
  VoterPre2012 Anc2002 Anc2012 Anc2023
  Bridgepk stantoncommons;

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
  data=Mar.Address_points_view 
    (keep=address_id address_type fulladdress addrnum addrnumsuffix stname street_type quadrant zipcode x y
          &geo_vars
     where=(address_type = 'A' and fulladdress ~= ''))
  out=Mar_parse;
  by stname zipcode street_type quadrant addrnum addrnumsuffix;
run;

** Create geocoding data sets for Proc Geocode (v9.4) **;

data 
  Geocode_94_dc_m
    (keep=Name Name2 City City2 Mapidnameabrv Zipcode Zcta First Last
     rename=(Zipcode=Zip)
     label="Primary street lookup data for Proc Geocode 9.4 (DC MAR)")
  Geocode_94_dc_s 
    (keep=Address_id Predirabrv Pretypabrv Sufdirabrv Suftypabrv Side Fromadd Toadd N Start &geo_vars
     label="Secondary street lookup data for Proc Geocode 9.4 (DC MAR)")
  Geocode_94_dc_p
    (keep=X Y
     label="Tertiary street lookup data for Proc Geocode 9.4 (DC MAR)");

  length
    Name Name2 $ 100
    Mapidnameabrv $ 2
    First Last Zcta 8
    Predirabrv Sufdirabrv Pretypabrv Suftypabrv $ 15 
    City City2 $ 50 
    Side $ 1
    Fromadd Toadd N Start 8;
    
  retain Mapidnameabrv 'DC' Side ' ' City 'Washington' City2 'WASHINGTON' Pretypabrv ' ';
  retain First 1 Last 0 Start 0 N 1;

  set Mar_parse;
  by stname zipcode street_type quadrant addrnum;
  
    /* if upcase( stname ) in ( 'S', 'N', 'E', 'W', 'NORTH', 'SOUTH', 'EAST', 'WEST', 'WEST LANE', 'EAST BEACH', 'WEST BEACH', 'FOREST', 'FALLS' ) then do; */
    if not( missing( put( upcase( stname ), $_dcg_strecode. ) ) ) then do;
      ** These street names have to be masked to be handled properly by Proc Geocode **;
      Name = cats( '~', propcase( stname ), '~' );
    end;
    else if stname = '9 1/2' then do;
      Name = '~Nineandahalf~';
    end;
    else if scan( upcase( stname ), 1, ' ' ) in ( 'NORTH', 'SOUTH', 'EAST', 'WEST' ) and
       scan( upcase( stname ), 2, ' ' ) ~= '' then do;
      Predirabrv = substr( scan( upcase( stname ), 1, ' ' ), 1, 1 );
      Name = substr( stname, length( propcase( scan( stname, 1, ' ' ) ) ) + 2 );
    end;
    else do;
      Name = propcase( left( stname ) );
    end;

    ** Proc Geocode does not handle street names with single quotes (') **;
    Name = compress( name, "'" );
    
    Name2 = upcase( left( compress( Name, ' ' ) ) );
    
    Sufdirabrv = upcase( quadrant );
    Suftypabrv = put( upcase( street_type ), $streettype_to_uspsabv. );
    
  ** FOR NOW: Only keep first address for places with addrnumsuffix ~= '' **;

  if first.addrnum then do;
    
    Fromadd = addrnum;
    Toadd = addrnum;
    
    Start + 1;

    output Geocode_94_dc_p;
    
    output Geocode_94_dc_s;
        
    Last + 1;    
  
  end;
  
  if last.zipcode then do;
    Zcta = Zipcode;
    output Geocode_94_dc_m;
    First = Last + 1;
  end;

  label
    City = "City name"
    City2 = "City name (all uppercase)"
    First = "First observation for street in Geocode_94_dc_s"
    Last  = "Last observation for street in Geocode_94_dc_s"
    Mapidnameabrv = "State abbreviation"
    Name = "Street name"
    Name2 = "Street name (all uppercase)"
    Zcta = "ZIP code tabulation area"
    Zipcode = "ZIP code (5-digit)"
    Fromadd = "Start of address number range"
    N = "Number of address points in Geocode_94_dc_p"
    Predirabrv = "Street direction prefix abbreviation"
    Side = "Side of street"
    Start = "Starting observation for address in Geocode_94_dc_p"
    Sufdirabrv = "Street direction suffix abbreviation"
    Pretypabrv = "Street type prefix abbreviation"
    Suftypabrv = "Street type suffix abbreviation"
    Toadd = "End of address number range"
    LATITUDE = "Latitude of address (GCS North American Datum, 1983)"
    LONGITUDE = "Longitude of address (GCS North American Datum, 1983)"
    X = "X coordinate of address point (MD State Plane Coord., NAD 1983 meters)"
    Y = "Y coordinate of address point (MD State Plane Coord., NAD 1983 meters)"
  ;    

run;

proc datasets lib=Work noprint;
    modify Geocode_94_dc_m;
      index create Name2_Zip        = (name2 zip);             /* street+zip search */
      index create Name2_Zcta        = (name zcta);             /* street+zcta search */
      index create Name2_MapIDNameAbrv_City2 = (name2 Mapidnameabrv City2); /* street+city+state search */
    run;
quit;

/*
proc print data=Geocode_94_dc_m;
  where lowcase( name ) contains ( "falls" );
  ***where name contains '~';
run;


proc print data=Geocode_94_dc_s (firstobs=67337 obs=67376);
  var Predirabrv Sufdirabrv Pretypabrv Suftypabrv Side Fromadd Toadd;
run;
/*
proc print data=Geocode_94_dc_s (firstobs=94722 obs=94918);
  var Predirabrv Sufdirabrv Pretypabrv Suftypabrv Side Fromadd Toadd;
run;
*/


data A;

  retain city 'WASHINGTON' st 'DC';
  
  length address $ 80;
  
  infile datalines dsd;
  
  input address;

/****
datalines;
   5042 Queen's Stroll Place SE
   2915 Chancellor's Way Northeast
   403 GUETHLER'S WAY SE
   3336 Cady's Alley NW
   849 H R Drive SE
   3033 West Lane Keys NW
   3150 South Street NW
   4400 Falls Terrace SE
   1999 9 1/2 Street Northwest
   4355 Forest Lane NW
   8425 East Beach Drive NW
****/

/*********************************
datalines;
   5042 Queen's Stroll Place SE
   2915 Chancellor's Way Northeast
   403 GUETHLER'S WAY SE
   3336 Cady's Alley NW
   3033 ~West Lane~ Keys NW
   3150 ~South~ Street NW
   3850 ~NORTH~ ROAD NW
   1580 ~WEST~ ROAD NW
   2516 ~EAST~ PLACE NW
   8425 ~East Beach~ Drive NW
   7932 ~WEST BEACH~ DRIVE NW
   701 EAST BASIN DRIVE SW
   4923 EAST CAPITOL STREET SE
   777 North Capitol St NE
   1415 NORTH CAROLINA AVENUE NE
   6000 North Dakota Avenue NW
   2817 North Glade St NW
   1605 NORTH PORTAL DRIVE NW
   4001 SOUTH CAPITOL STREET SW
   622 SOUTH CAROLINA AVENUE SE
   4501 SOUTH DAKOTA AVENUE NE
   400 WEST BASIN DRIVE SW
   1713 WEST VIRGINIA AVENUE NE
   1999 ~Nineandahalf~ Street Northwest
   4355 ~Forest~ Lane NW   
   849 H R Drive SE
   4400 ~Falls~ Terrace SE
   2911 ~N~ STREET SE
   1252 ~E~ STREET NE
   27 ~W~ STREET NW
   900 ~S~ Street NW
********************************/

datalines;
   5042 Queen's Stroll Place SE
   2915 Chancellor's Way Northeast
   403 GUETHLER'S WAY SE
   3336 Cady's Alley NW
   3033 West Lane Keys NW
   3150 South Street NW
   3850 NORTH ROAD NW
   1580 WEST ROAD NW
   2516 EAST PLACE NW
   8425 East Beach Drive NW
   7932 WEST BEACH DRIVE NW
   701 EAST BASIN DRIVE SW
   4923 EAST CAPITOL STREET SE
   777 North Capitol St NE
   1415 NORTH CAROLINA AVENUE NE
   6000 North Dakota Avenue NW
   2817 North Glade St NW
   1605 NORTH PORTAL DRIVE NW
   4001 SOUTH CAPITOL STREET SW
   622 SOUTH CAROLINA AVENUE SE
   4501 SOUTH DAKOTA AVENUE NE
   400 WEST BASIN DRIVE SW
   1713 WEST VIRGINIA AVENUE NE
   1999 9 1/2 Street Northwest
   4355 Forest Lane NW   
   849 H R Drive SE
   4400 Falls Terrace SE
   2911 N STREET SE
   1252 E STREET NE
   27 W STREET NW
   900 S Street NW
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
  basefile=Geocode_94_dc_m,
  streetalt_file=C:\DCData\Libraries\MAR\Prog\StreetAlt_38_Fix_geocoding.txt,
  listunmatched=Y,
  debug=Y
)

title2 'B_DC_mar_geocode';
proc print data=B_DC_mar_geocode;
  id address;
  var m_addr address_id _score_ _notes_;
run;
title2;

