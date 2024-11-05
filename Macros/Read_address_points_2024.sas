/**************************************************************************
 Program:  Read_address_points_2024.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/2/2024
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Autocall macro to create an updated Address_points
 data set. Modifed from Read_address_points for new 2024 file format. 

 Modifications:
**************************************************************************/

%macro Read_address_points_2024( filedate=, finalize=Y, revisions=New file. );

  %local filemonth fileyear filedate_fmt outfile;

  %let filemonth = %sysfunc( month( &filedate ) );
  %let fileyear = %sysfunc( year( &filedate ) );
  %let filedate_fmt = %sysfunc( putn( &filedate, yymmddd10. ) );
  
  %let outfile = Address_points_&fileyear._%sysfunc( putn( &filemonth, z2. ) );

  filename fimport "&_dcdata_r_path\MAR\Raw\&filedate_fmt\Address_Points.csv" lrecl=2000;

  data &outfile._A ;

    infile fimport delimiter = ',' missover dsd firstobs=2;
    
    input
      X
      Y
      OBJECTID
      MAR_ID
      ADDRESS : $200.
      ADDRESS_NUMBER : $40.
      ADDRESS_NUMBER_SUFFIX : $40.
      STREET_NAME : $40.
      STREET_TYPE : $32.
      QUADRANT : $8.
      ZIPCODE
      CITY_NAME : $10.
      STATE : $2.
      COUNTRY : $20.
      X_COORDINATE
      Y_COORDINATE
      LATITUDE : best32.
      LONGITUDE : best32.
      _ADDRESS_TYPE : $40.
      _STATUS : $40.
      ROUTEID : $40.
      BLOCKKEY : $40.
      SUBBLOCKKEY : $40.
      WARD : $8.
      METADATA_ID
      NATIONAL_GRID : $40.
      _HAS_SSL : $8.
      _HAS_PLACE_NAME : $8.
      _HAS_CONDO : $8.
      _HAS_RESIDENTIAL_UNIT : $8.
      STREET_VIEW_URL : $1000.
      _RESIDENTIAL_TYPE : $40.
      PLACEMENT : $40.
      SSL_ALIGNMENT : $40.
      BUILDING : $40.
      SSL : $17.
      SQUARE : $8.
      SUFFIX : $8.
      LOT : $8.
      MULTIPLE_LAND_SSL : $40.
      GRID_DIRECTION : $40.
      HOUSING_UNIT_COUNT
      RESIDENTIAL_UNIT_COUNT
      BEFORE_DATE : yymmdd10.
      BEFORE_DATE_SOURCE : $80.
      BEGIN_DATE : yymmdd10.
      BEGIN_DATE_SOURCE : $80.
      FIRST_KNOWN_DATE : yymmdd10.
      FIRST_KNOWN_DATE_SOURCE : $80.
      CREATED_DATE : yymmdd10. 
      CREATED_USER : $80.
      LAST_EDITED_DATE : yymmdd10.
      LAST_EDITED_USER : $80.
      SE_ANNO_CAD_DATA : $80.
      SMD : $32.
      ANC : $8.
    ;
    
    format LATITUDE LONGITUDE 12.8;
    
    format BEFORE_DATE BEGIN_DATE FIRST_KNOWN_DATE CREATED_DATE LAST_EDITED_DATE mmddyy10.;
    
    address_id = mar_id;
    
    addrnum = input( address_number, 20. ); 
    
    ** Recoded categorical variables **;
    
    length Address_type Res_type Status $1;
    
    Address_type = left( upcase( _Address_type ) );
    Res_type = left( upcase( _Residential_type ) );
    
    select ( left( upcase( _Status ) ) );
      when ( 'ACTIVE' )
        Status = 'A';
      when ( 'ASSIGNED' )
        Status = 'S';
      when ( 'RETIRE' )
        Status = 'R';
      when ( 'TEMPORARY' )
        Status = 'T';
      otherwise do;
        %Err_put( macro=Read_address_points_2024, msg="Unrecognized STATUS value: " _n_= address_id= _status= )
      end;
    end;
    
    format Address_type $maraddrtyp. Res_type $marrestyp. Status $marstatus.;
    
    array c{*} _HAS_SSL _HAS_PLACE_NAME _HAS_CONDO _HAS_RESIDENTIAL_UNIT;
    array n{*} HAS_SSL HAS_PLACE_NAME HAS_CONDO HAS_RESIDENTIAL_UNIT;
    
    do i = 1 to dim( c );
      select ( left( upcase( c{i} ) ) );
        when ( 'N' ) n{i} = 0;
        when ( 'Y' ) n{i} = 1;
        when ( ' ' ) n{i} = .u;
        otherwise do;
          %Err_put( macro=Read_address_points_2024, msg="Unrecognized Y/N var value: " _n_= address_id= c{i}= )
        end;
      end;
    end;
    
    format has_: dyesno.;
    
    length Zip $ 5;
    
    Zip = put( Zipcode, z5.0 );
    
    format Zip $zipa.;
    
    drop i x y _Address_type _Residential_type _Status _has_: ;
    
    rename 
      housing_unit_count = active_res_occupancy_count
      residential_unit_count = active_res_unit_count
      address_number_suffix = addrnumsuffix
      address = fulladdress
      national_grid = nationalgrid
      street_name = stname
      x_coordinate = x
      y_coordinate = y
    ;

  run;

  proc sort data=&outfile._A;
    by address_id;
  run;

  ** Add block IDs using spatial merge **;

  proc mapimport out=Blocks_2020
    datafile="\\sas1\DCDATA\Libraries\OCTO\Maps\Census_Blocks_in_2020.shp";
  run;

  goptions reset=global border;

  proc ginside includeborder dropmapvars
    data=&outfile._A (keep=address_id latitude longitude rename=(latitude=y longitude=x)) 
    map=Blocks_2020
    out=&outfile._w_blocks;
    id geocode;
  run;

  ** Merge block IDs and create other geos **;
    
  data &outfile;

    merge &outfile._A &outfile._w_blocks (keep=address_id geocode rename=(geocode=GeoBlk2020));
    by address_id;
    
    %Block20_to_anc02()
    %Block20_to_anc12()
    %Block20_to_bg20()
    %Block20_to_bpk()
    %Block20_to_city()
    %Block20_to_cluster_tr00()
    %Block20_to_cluster00()
    %Block20_to_cluster17()
    %Block20_to_eor()
    %Block20_to_npa19()
    %Block20_to_psa04()
    %Block20_to_psa12()
    %Block20_to_psa19()
    %Block20_to_stantoncommons()
    %Block20_to_tr00()
    %Block20_to_tr10()
    %Block20_to_tr20()
    %Block20_to_vp12()
    %Block20_to_ward02()
    %Block20_to_ward12()
    %Block20_to_ward22()

    format
      GeoBlk2020 $blk20a.
    ;

    label
      ACTIVE_RES_OCCUPANCY_COUNT = "Number of housing units at the primary address [source file HOUSING_UNIT_COUNT]"
      ACTIVE_RES_UNIT_COUNT = "Active residential use count [source file RESIDENTIAL_UNIT_COUNT]"
      ADDRESS_ID = "Address identifier [source file MAR_ID]"
      MAR_ID = "Address identifier"
      ADDRESS_NUMBER = "Address location house number"
      addrnum = "Address location house number [numeric, source file ADDRESS_NUMBER]"
      ADDRNUMSUFFIX = "Address location house number suffix [source file ADDRESS_NUMBER_SUFFIX]"
      ANC = "Address location Advisory Neighborhood Commission [source file]"
      CITY_NAME = "Address location city [source file CITY]"
      FULLADDRESS = "House number, street name, street type, and quadrant"
      LATITUDE = "Latitude of address"
      LONGITUDE = "Longitude of Address"
      LOT = "Address location property lot"
      NATIONALGRID = "Address location national grid coordinate [source file NATIONAL_GRID]"
      OBJECTID = "Internal feature number"
      QUADRANT = "Address location quadrant name"
      RES_TYPE = "Address residential type"
      SE_ANNO_CAD_DATA = "SDO data type"
      SMD = "Address location Single Member District"
      SQUARE = "Address location property square"
      SSL = "Property identification number (square/suffix/lot)"
      STATE = "Address location state abbreviation"
      STATUS = "Address status"
      STNAME = "Address location street name [source file STREET_NAME]"
      STREET_TYPE = "Address location street type"
      SUFFIX = "Address location property suffix"
      Address_type = "Address type"
      WARD = "Address location Ward name [source file]"
      X = "X coordinate of address point (MD State Plane Coord., NAD 1983 meters)"
      Y = "Y coordinate of address point (MD State Plane Coord., NAD 1983 meters)"
      ZIP = "ZIP code (5-digit)"
      ZIPCODE = "ZIP code (5-digit)"
      METADATA_ID = "Internal ID Number"
      before_date = "Address definitely did not exist at this date"
      before_date_source = "Source for Before_Date"
      begin_date = "Date address began"
      begin_date_source = "Source for Begin_Date"
      blockkey = "Block key from DDOT Roads & Highways"
      building = "Is address associated with a building?"
      country = "Country"
      created_date = "Date the address record was created in the MAR database" 
      created_user = "Which agency created address record"
      first_known_date = "Earliest known date, if no Begin_Date"
      first_known_date_source = "Source for First_known_date"
      grid_direction = "Grid direction of the address"
      has_condo = "Address has associated residential condominium unit"
      has_place_name = "Address has place name"
      has_residential_unit = "Address has associated residential unit"
      has_ssl = "Address has property information"
      last_edited_date = "Date address was last edited"
      last_edited_user = "Which agency last edited the address record"
      multiple_land_ssl = "Multiple Land Square, Suffix, Lot"
      placement = "Location of address"
      routeid = "Route ID from DDOT Roads & Highways"
      ssl_alignment = "How well addresses aligns with associated SSL (property)"
      street_view_url = "URL to Google Maps Street View"
      subblockkey = "Sub-block key from DDOT Roads & Highways"
      GeoBlk2020 = "Full census block ID (2020): sscccttttttbbbb"
    ;

  run;

  %Finalize_data_set( 
	data=&outfile.,
	out=&outfile.,
	outlib=MAR,
	label="Master address repository, DC street addresses (%sysfunc( putn( &filedate, mmddyys10. ) ))",
	sortby=address_id,
	restrictions=None,
	revisions=%str(&revisions)
  )

%mend Read_address_points_2024;


