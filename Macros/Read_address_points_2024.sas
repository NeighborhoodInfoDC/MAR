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
      CITY : $10.
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

RUN;

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

/* %File_info( data=&outfile._w_blocks, freqvars=geocode )
 */
 
data &outfile;

  merge &outfile._A &outfile._w_blocks (keep=address_id geocode rename=(geocode=GeoBlk2020));
  by address_id;
  
  format
    GeoBlk2020 $blk20a.
  ;

  label
    GeoBlk2020 = "Full census block ID (2020): sscccttttttbbbb"
  ;

run;


%MACRO SKIP;      
      length 
        Address_type xStatus xRes_type xEntrancetype $ 1
        Ward2002 Ward2012 Ward2022 $ 1
        Cluster2000 Anc2002 Anc2012 $ 2
        Psa2004 Psa2012 Psa2019 VoterPre2012 $ 3
        Geo2020 $ 11
        GeoBg2020 $ 12
        GeoBlk2020 $ 15
        Assessnbhd $ 3
        Zip $ 5
        nZip 8
      ;
      
      array a{*} Stname Street_type Quadrant City State Smd: Newcomm: Focus_improvement_area;
      
      do i = 1 to dim( a );
        a{i} = left( upcase( compbl( a{i} ) ) );
      end;
      
      Address_type = left( upcase( type_ ) );
      
      select ( left( upcase( Status ) ) );
        when ( 'ACTIVE' )
          xStatus = 'A';
        when ( 'ASSIGNED' )
          xStatus = 'S';
        when ( 'RETIRE' )
          xStatus = 'R';
        when ( 'TEMPORARY' )
          xStatus = 'T';
        otherwise do;
          %Err_put( macro=, msg="Unrecognized STATUS value: " _n_= address_id= status= )
        end;
      end;
      
      xRes_type = left( upcase( Res_type ) );
      
      xEntrancetype = left( upcase( entrancetype ) );
      
      ** Standard geographic vars **;
      
	  if census_block ^= "" then do;
	  	GeoBlk2020 = '11001' || left( compress( census_block ) );
	  end;

	  if put( GeoBlk2020, $blk20v. ) = "" then do;
        %Warn_put( msg="Invalid census block: " _n_= address_id= census_block= )
      end;

	  GeoBg2020 = substr(GeoBlk2020,1,12);

	  if put( GeoBg2020, $bg20v. ) = "" then do;
        %Warn_put( msg="Invalid census block group: " _n_= address_id= census_blockgroup= )
      end;

	  Geo2020 = substr(GeoBlk2020,1,11);
      
      if put( Geo2020, $geo20v. ) = "" then do;
        %Warn_put( msg="Invalid census tract: " _n_= address_id= census_tract= )
      end;

      %Block20_to_tr00()

	  %Block20_to_tr10()
      
      Ward2002 = scan( ward_2002, 2, ' ' );
      
      if put( Ward2002, $ward02v. ) = "" then do;
        %Warn_put( msg="Invalid ward: " _n_= address_id= ward_2002= )
      end;

      Ward2012 = scan( ward_2012, 2, ' ' );

      if put( Ward2012, $ward12v. ) = "" then do;
        %Warn_put( msg="Invalid ward: " _n_= address_id= ward_2012= )
      end;

	  %Block20_to_ward22()

      %Block20_to_cluster00()
      
      %Block20_to_cluster_tr00()

	  %Block20_to_cluster17()
      
      %Block20_to_psa04()

	  %Block20_to_psa12()

	  %Block20_to_psa19()
      
      Anc2002 = scan( anc_2002, 2, ' ' );
      Anc2012 = scan( anc_2012, 2, ' ' );
      
      VoterPre2012 = put( input( scan( vote_prcnct, 2, ' ' ), 8. ), z3. );

      if put( VoterPre2012, $vote12v. ) = "" then do;
        %Warn_put( msg="Invalid voter precinct: " _n_= address_id= vote_prcnct= )
      end;

	  %Block20_to_stantoncommons ()

	  %Block20_to_bpk ()


      Assessnbhd = put( upcase( compress( assessment_nbhd, ' .-/' ) ), $martext_to_assessnbhd. );
      
      Zip = left( zipcode );
      nZip = input( Zip, 5. );

      informat _all_ ;
      
      format
        Address_type $maraddrtyp.
        xStatus $marstatus.
        xRes_type $marrestyp.
        xEntrancetype $marentrtyp.
        Ward2002 $ward02a.
        Ward2012 $ward12a.
		Ward2012 $ward22a.
        Cluster2000 $clus00a.
		cluster2017 $clus17a.
        Psa2004 $psa04a.
		Psa2012 $psa12a.
		Psa2019 $psa19a.
        Anc2002 $anc02a.
        Anc2012 $anc12a.
        Geo2020 $geo20a.
        GeoBg2020 $bg20a.
        GeoBlk2020 $blk20a.
		Geo2010 $geo10a.
		Geo2000 $geo00a.
        VoterPre2012 $vote12a.
        Assessnbhd $marassessnbhd.
        Zip $zipa.
		bridgepk $bpka.
		stantoncommons $stanca.
      ;
      
      rename 
        xStatus=Status
        xRes_type=Res_type
        xEntrancetype=Entrancetype
        nZip=Zipcode
		x_in = lat
		y_in = lon
		xcoord = x
		ycoord = y
      ;
      
      drop 
        i OBJECTID_12 type_ status res_type entrancetype ANC ANC_2002 ANC_2012 
        cluster_ psa census_tract census_blockgroup census_block 
        POLDIST VOTE_PRCNCT ward ward_2002 ward_2012 zipcode;

      label
        ACTIVE_RES_OCCUPANCY_COUNT = "Number of housing units at the primary address"
        ACTIVE_RES_UNIT_COUNT = "Active residential use count"
        ADDRESS_ID = "Address identifier"
		ROADWAYSEGID = "Roadway segment ID"
        ADDRNUM = "Address location house number"
        ADDRNUMSUFFIX = "Address location house number suffix"
        ANC = "Address location Advisory Neighborhood Commission"
        ASSESSMENT_NBHD = "Address Assessment Neighborhood Name (text label)"
        ASSESSMENT_SUBNBHD = "Address Assessment SubNeighborhood Name"
        CENSUS_BLOCK = "Census Block Value Address is in"
        CENSUS_BLOCKGROUP = "Census Block Group value"
        CENSUS_TRACT = "Address location census tract"
        CFSA_NAME = "Address CFSA area name"
        CITY = "Address location city"
        CLUSTER_ = "Address location neighborhood cluster name"
        xENTRANCETYPE = "Address entrance type"
        FOCUS_IMPROVEMENT_AREA = "Focus improvement area name"
        FULLADDRESS = "House number, street name, street type, and quadrant"
        HOTSPOT = "Address location hot spot"
        LATITUDE = "Latitude of address"
        LONGITUDE = "Longitude of Address"
        LOT = "Address location property lot"
        NATIONALGRID = "Address location national grid coordinate"
        NEWCOMMCANDIDATE = "Address location New Community Candidate"
        NEWCOMMSELECT06 = "Address location New Community Selected 2006"
        OBJECTID_12 = "Internal feature number"
		OBJECTID = "Internal feature number"
        POLDIST = "Address location police district"
        PSA = "Address location Police Service Area"
        QUADRANT = "Address location quadrant name"
        xRES_TYPE = "Address residential type"
        ROC = "Address location regional operations command area"
        SE_ANNO_CAD_DATA = "SDO data type"
        SITE_ADDRESS_PK = "Address Identifier"
        SMD = "Address location Single Member District"
        SMD_2002 = "Single member district, 2002"
        SQUARE = "Address location property square"
        SSL = "Property identification number (square/suffix/lot)"
        STATE = "Address location state name"
        xSTATUS = "Address status"
        STNAME = "Address location street name"
        STREET_TYPE = "Address location street type"
        SUFFIX = "Address location property suffix"
        Address_type = "Address type"
        VOTE_PRCNCT = "Address location voting precinct"
        WARD = "Address location Ward name"
        X = "X Coordinate of Address Point (decimal degrees)"
        Y = "Y Coordinate of Address Point (decimal degrees)"
        ZIPCODE = "Address location Zip code"
        Anc2002 = "Advisory Neighborhood Commission (2002)"
        Anc2012 = "Advisory Neighborhood Commission (2012)"
        Assessnbhd = "Assessment neighborhood"
        Geo2020 = "Full census tract ID (2020): ssccctttttt"
        GeoBg2020 = "Full census block group ID (2020): sscccttttttb"
        GeoBlk2020 = "Full census block ID (2020): sscccttttttbbbb"
		Geo2010 = "Full census tract ID (2010): ssccctttttt"
		Geo2000 = "Full census tract ID (2000): ssccctttttt"
		Psa2004 = "Police Service Area (2004)"
        Psa2012 = "Police Service Area (2012)"
		Psa2019 = "Police Service Area (2019)"
        SMD_2012 = "Single member district, 2012"
        Ward2002 = "Ward (2002)"
        Ward2012 = "Ward (2012)"
		Ward2022 = "Ward (2022)"
        VoterPre2012 = "Voting Precinct (2012)"
        Zip = "ZIP code (5-digit)"
        nZip = "ZIP code (5-digit)"
		bridgepk = "11th Street Bridge Park Target Area (2017)"
		stantoncommons = "Stanton Commons (2018)"
		cluster2017 = "Neighborhood Clusters (2017)"
		ZIPCODE4 = "Zip +4"
		XCOORD = "X coordinate of address point (MD State Plane Coord., NAD 1983 meters)"
		YCOORD = "Y coordinate of address point (MD State Plane Coord., NAD 1983 meters)"
		X_in = "X coordinate of address point (decimal degrees)"
		Y_in = "Y coordinate of address point (decimal degrees)"
		STATUS_ID = "Status ID"
		METADATA_ID = "Internal ID Number"
		OBJECTID_1 = "Internal feature number"
        ;

  run;

  %Finalize_data_set( 
	data=&outfile.,
	out=&outfile.,
	outlib=MAR,
	label="Master address repository, DC street addresses (%sysfunc( putn( &filedate, mmddyys10. ) ))",
	sortby=ssl,
	restrictions=None,
	revisions=%str(&revisions)
	)

%MEND SKIP;

%mend Read_address_points_2024;


