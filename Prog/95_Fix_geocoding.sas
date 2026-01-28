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

** Create format for converting street types to standard USPS abbreviations **;

%f_streettype_to_uspsabv()

** Create format for temporary recoding of street names that match direction abbreviations;
** Workaround for Proc Geocode problem matching these streets;

%F_dcg_strecode()

** Prep address list **;

data Mar_parse;

  set Mar.Address_points_view 
    (keep=address_id address_type fulladdress addrnum addrnumsuffix stname street_type quadrant zipcode x y
          status &geo_vars
     rename=(status=Mar_status)
     where=(not( missing( fulladdress ) or missing( stname ) or missing( addrnum ) ) ) 
    );
     
    ** Proc Geocode does not handle street names with single quotes (') **;
    ** Remove other stray punctuation **;
    stname = compress( stname, "';" );
    
    ** Manual street name corrections **;    

    stname = prxchange( 's/\bTERMPERANCE\b/ TEMPERANCE /i', 1, stname );
    stname = prxchange( 's/\bALBERMARLE\b/ ALBEMARLE /i', 1, stname );
    stname = prxchange( 's/\bBALDENSBURG\b/ BLADENSBURG /i', 1, stname );
    stname = prxchange( 's/\bMCCULLOUGH\b/ MCCOLLOUGH /i', 1, stname );
    stname = prxchange( 's/\bMERIDAN\b/ MERIDIAN /i', 1, stname );
    stname = prxchange( 's/\bMT PLEASANT\b/ MOUNT PLEASANT /i', 1, stname );
    stname = prxchange( 's/\bST MARYS\b/ SAINT MARYS /i', 1, stname );
    stname = prxchange( 's/\bPEHELPS\b/ PHELPS /i', 1, stname );
        
    stname = left( compbl( stname ) );

    ** Remove directions from street types for retired addresses (does not match) **;
    
    street_type = prxchange( 's/\bNORTH|SOUTH|EAST|WEST\b//i', 1, street_type );
    
    ** Replace ST with STREET for street types **;
    
    if street_type = 'ST' then street_type = 'STREET';

    ** Fill in missing ZIP codes **;
    
    %Block20_to_zip( )
    
    if missing( zipcode ) then zipcode = input( zip, 5. );
    
    label Mar_status = "MAR address status";
    
    drop zip;
    
run;     

proc sort data=Mar_parse;
  by stname zipcode street_type quadrant addrnum addrnumsuffix;
run;

proc freq data=Mar_parse;
  tables street_type quadrant;
run;

/*
PROC PRINT DATA=Mar_parse;
  where stname in ( "B 1/2", "C STREET", "CANAL ROAD", "CAPITOL SQUARE" );
  by stname;
  id stname;
  VAR STREET_TYPE fulladdress;
RUN;

ENDSAS;
*/

** Create $marvalidstnm (valid street names) format for %Dc_geocode() macro **;

proc sort data=Mar_parse out=Mar_streetnames nodupkey;
  by stname;
run;

%Data_to_format(
  FmtLib=WORK, /** TESTING CHANGE **/
  FmtName=$marvalidstnm,
  Desc="MAR geocoding/valid street names",
  Data=Mar_streetnames,
  Value=stname,
  Label=stname,
  OtherLabel=' ',
  Print=N,
  Contents=N
  )

** Create geocoding data sets for Proc Geocode (v9.4) **;

data 
  Geocode_94_dc_m
    (keep=Name Name2 City City2 Mapidnameabrv Zipcode Zcta First Last
     rename=(Zipcode=Zip)
     label="Primary street lookup data for Proc Geocode 9.4 (DC MAR)")
  Geocode_94_dc_s 
    (keep=Address_id Predirabrv Pretypabrv Sufdirabrv Suftypabrv Side Fromadd Toadd N Start Mar_status &geo_vars
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

  if not( missing( put( upcase( stname ), $dcg_strecode. ) ) ) then do;
    ** These street names have to be masked to be handled properly by Proc Geocode **;
    Name = cats( '~', propcase( stname ), '~' );
  end;
  else if prxmatch( '/^([0-9]+|[A-Z]) 1\/2/', stname ) > 0 then do;
    ** Street names with "1/2" in them require special recodes **;
    Name = prxchange( 's/([0-9]+|[A-Z]) 1\/2/~$1~ANDAHALF~/i', 1, stname );
  end;
  else if scan( upcase( stname ), 1, ' ' ) in ( 'NORTH', 'SOUTH', 'EAST', 'WEST' ) and
     scan( upcase( stname ), 2, ' ' ) ~= '' then do;
    ** Street names like NORTH CAPITOL, which have a direction and another part to the name **;
    ** The direction part is assigned to Predirabrv and the rest of the name to Name **;
    ** Note that there are exceptions to these cases in the $dcg_strecode. list in the first IF stmt **;
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

proc datasets lib=WORK noprint;
    modify Geocode_94_dc_m;
      index create Name2_Zip        = (name2 zip);             /* street+zip search */
      index create Name2_Zcta        = (name zcta);             /* street+zcta search */
      index create Name2_MapIDNameAbrv_City2 = (name2 Mapidnameabrv City2); /* street+city+state search */
    run;
quit;


** Create new GCTYPE data set to add missing street type **;

data Geocode_94_dc_gctype;
    set sashelp.gctype;
run;

proc sql;
    insert into Geocode_94_dc_gctype (name, type, group)
    values ('PIER', 'PIER', 900 );
quit;

proc sort data=Geocode_94_dc_gctype;
  by name type;
run;


*************************************************************************;

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
2327 PENNSYLVANIA STREET NW
550 PENN STREET NE
1600 PENN AVENUE NW
916 HAMILTON STREET NW
9 BALDWIN'S ROW NW
101 DISTRICT PIER SW
321 PARK ROW SW
1801 PEHELPS PLACE NW
9 SUMNER ROW NW
160 SUMNER SOUTH ROW NW
917 TEMPERANCE HALL ALLEY NW
1945 TEMPERANCE AVENUE NW
209 B 1/2 STREET SW
721 9TH ST ALLEY SE
1999 9 1/2 Street Northwest
1236 11 1/2 STREET SE
409 13 1/2 STREET NW
248 14 1/2 STREET NE
237 2 1/2 STREET SW 
633 3 1/2 STREET NE 
323 4 1/2 STREET NW 
1014 6 1/2 STREET SE
1718 Corcoran Street NW
955 L'ENFANT PLAZA SW
357 L'ENFANT PROMENADE SW
20 PARKER ROW SW
1525 QUEEN STREET NE
8 QUEENS COURT NW
335 BROAD ALLEY SW
314 BLAGDEN ALY EAST Northwest Apt 207
314 BLAGDEN ALLEY NW
2456 SNOWS COURT NORTH NW
2456 SNOWS COURT NW
1114 SHEPHERD ALLEY EAST NW
1114 SHEPHERD ALLEY NW
1936 WAVERLY TERRACE WEST    NW
1936 WAVERLY TERRACE NW
2516 EAST PLACE NW
4923 EAST CAPITOL STREET SE
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
  typefile=Geocode_94_dc_gctype,
  streetalt_file=C:\DCData\Libraries\MAR\Prog\StreetAlt.txt,
  listunmatched=Y,
  debug=Y
)

title2 'B_DC_mar_geocode';
proc print data=B_DC_mar_geocode n;
  id address;
  var m_addr address_id M_EXACTMATCH _score_ _notes_ mar_status;
run;
title2;

%File_info( data=B_DC_mar_geocode, printobs=5 )
