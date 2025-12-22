/**************************************************************************
 Program:  Geocode_94_dc_source.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/23/16
 Editted:  08/24/17
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create Proc Geocode source data sets from MAR address
 points. File format compatible with SAS ver 9.4 and later. 
 
 Also updates $marvalidstnm format and ValidStreets.html file.

 Modifications: RP Updated to add post-2020 geographies and use %Finalize_data_set
				7/8/25 RP Added ANC2023 to geo list
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

%let revisions = Updated with latest address points.;

%let revisions = Implement address geocoding fixes.;  /** Delete this statement for next regular address update **/


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

** Create format for temporary recoding of street names that match direction abbreviations;
** Workaround for Proc Geocode problem matching these streets;

%Format_dcg_strecode()

** Prep address list **;

data Mar_parse;

  set Mar.Address_points_view 
    (keep=address_id address_type fulladdress addrnum addrnumsuffix stname street_type quadrant zipcode x y
          &geo_vars
     where=(address_type = 'A' and fulladdress ~= ''));
     
    ** Proc Geocode does not handle street names with single quotes (') **;
    stname = compress( stname, "'" );
    
run;     

proc sort data=Mar_parse;
  by stname zipcode street_type quadrant addrnum addrnumsuffix;
run;

proc freq data=Mar_parse;
  tables street_type quadrant;
run;


** Create $marvalidstnm (valid street names) format for %Dc_geocode() macro **;

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
  Contents=N
  )


** Export list of valid street names **;

%fdate()

ods listing close;
ods html body="&_dcdata_default_path\Mar\Doc\ValidStreets.html" style=Minimal;
ods csvall body="&_dcdata_default_path\Mar\Doc\ValidStreets.csv";

proc print data=Mar_streetnames noobs label;
  var stname;
  label stname = "Valid street names (&fdate)";
run;

ods html close;
ods csvall close;
ods listing;


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
  
  ** Deal with street names that require special handling or recoding **;

  if not( missing( put( upcase( stname ), $_dcg_strecode. ) ) ) then do;
    ** These street names have to be masked to be handled properly by Proc Geocode **;
    Name = cats( '~', propcase( stname ), '~' );
  end;
  else if stname = '9 1/2' then do;
    ** 9 1/2 Street requires special recode **;
    Name = '~Nineandahalf~';
  end;
  else if scan( upcase( stname ), 1, ' ' ) in ( 'NORTH', 'SOUTH', 'EAST', 'WEST' ) and
     scan( upcase( stname ), 2, ' ' ) ~= '' then do;
    ** Street names like NORTH CAPITOL, which have a direction and another part to the name **;
    ** The direction part is assigned to Predirabrv and the rest of the name to Name **;
    ** Note that there are exceptions to these cases in the $_dcg_strecode. list in the first IF stmt **;
    Predirabrv = substr( scan( upcase( stname ), 1, ' ' ), 1, 1 );
    Name = substr( stname, length( propcase( scan( stname, 1, ' ' ) ) ) + 2 );
  end;
  else do;
    ** Street names that needs no special handling **;
    Name = propcase( left( stname ) );
  end;

  ** NAME2 var is all uppercase and no spaces **;
  
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

**** NOTE: DO NOT SORT THE OUTPUT DATA SETS ****;

%Finalize_data_set( 
	data=Geocode_94_dc_m,
	out=Geocode_94_dc_m,
	outlib=MAR,
	label="Primary street lookup data for Proc Geocode 9.4 (DC MAR)",
	sortby=,
	restrictions=None,
      revisions=%str(&revisions),
	printobs=40, 
    stats=n nmiss min max,
    freqvars=name2 zip zcta Mapidnameabrv City2
	)

%Finalize_data_set( 
	data=Geocode_94_dc_s,
	out=Geocode_94_dc_s,
	outlib=MAR,
	label="Secondary street lookup data for Proc Geocode 9.4 (DC MAR)",
	sortby=,
	restrictions=None,
      revisions=%str(&revisions),
	stats=n nmiss min max,
	printobs=5
	)

%Finalize_data_set( 
	data=Geocode_94_dc_p,
	out=Geocode_94_dc_p,
	outlib=MAR,
	label="Tertiary street lookup data for Proc Geocode 9.4 (DC MAR)",
	sortby=,
	restrictions=None,
      revisions=%str(&revisions),
	printobs=40, 
    stats=n nmiss min max
	)


proc datasets lib=Mar noprint;
    modify Geocode_94_dc_m;
      index create Name2_Zip        = (name2 zip);             /* street+zip search */
      index create Name2_Zcta        = (name zcta);             /* street+zcta search */
      index create Name2_MapIDNameAbrv_City2 = (name2 Mapidnameabrv City2); /* street+city+state search */
    run;
quit;

/* End of program */
