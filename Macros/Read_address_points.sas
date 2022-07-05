/**************************************************************************
 Program:  Read_address_points.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/11/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Autocall macro to create an updated Address_points
 data set.

 Modifications:
**************************************************************************/

%macro Read_address_points( filedate=, finalize=Y, revisions=New file. );

  %local filemonth fileyear filedate_fmt outfile;

  %let filemonth = %sysfunc( month( &filedate ) );
  %let fileyear = %sysfunc( year( &filedate ) );
  %let filedate_fmt = %sysfunc( putn( &filedate, yymmddd10. ) );
  
  %let outfile = Address_points_&fileyear._%sysfunc( putn( &filemonth, z2. ) );

  filename fimport "&_dcdata_r_path\MAR\Raw\&filedate_fmt\Address_Points.csv" lrecl=2000;

  data &outfile (label="Master address repository, DC street addresses (%sysfunc( putn( &filedate, mmddyys10. ) ))");

    infile fimport delimiter = ',' missover dsd firstobs=2;

    informat X_in best32. ;
    informat Y_in best32. ;
    informat SITE_ADDRESS_PK best32. ;
    informat ADDRESS_ID best32. ;
	informat ROADWAYSEGID best32. ;
    informat STATUS $32. ;
    informat SSL $17. ;
    informat TYPE_ $32. ;
    informat ENTRANCETYPE $32. ;
    informat ADDRNUM best32. ;
    informat ADDRNUMSUFFIX $8. ;
    informat STNAME $32. ;
    informat STREET_TYPE $32. ;
    informat QUADRANT $2. ;
    informat CITY $10. ;
    informat STATE $2. ;
    informat FULLADDRESS $80. ;
    informat SQUARE $4. ;
    informat SUFFIX $4. ;
    informat LOT $4. ;
    informat NATIONALGRID $32. ;
	informat ZIPCODE4 $10. ;
	informat XCOORD best32. ;
	informat YCOORD best32. ;
	informat STATUS_ID best32. ;	
	informat METADATA_ID	best32. ;
    informat ASSESSMENT_NBHD $32. ;
    informat ASSESSMENT_SUBNBHD $80. ;
    informat CFSA_NAME $80. ;
    informat HOTSPOT $2. ;
    informat CLUSTER_ $32. ;
    informat POLDIST $80. ;
    informat ROC $32. ;
    informat PSA $32. ;
    informat SMD $12. ;
    informat CENSUS_TRACT $32. ;
    informat VOTE_PRCNCT $32. ;
    informat WARD $8. ;
    informat ZIPCODE best32. ;
    informat ANC $32. ;
    informat NEWCOMMSELECT06 $1. ;
    informat NEWCOMMCANDIDATE $1. ;
    informat CENSUS_BLOCK $32. ;
    informat CENSUS_BLOCKGROUP $32. ;
    informat FOCUS_IMPROVEMENT_AREA $2. ;
    informat SE_ANNO_CAD_DATA $1. ;
    informat LATITUDE best32. ;
    informat LONGITUDE best32. ;
    informat ACTIVE_RES_UNIT_COUNT best32. ;
    informat RES_TYPE $32. ;
    informat ACTIVE_RES_OCCUPANCY_COUNT best32. ;
    informat WARD_2002 $32. ;
    informat WARD_2012 $32. ;
    informat ANC_2002 $32. ;
    informat ANC_2012 $32. ;
    informat SMD_2002 $32. ;
    informat SMD_2012 $32. ;
	informat OBJECTID_12 best32. ;
	informat OBJECTID best32. ;
	informat OBJECTID_1 best32. ;
    
    input
      X_in
      Y_in
      SITE_ADDRESS_PK
      ADDRESS_ID
	  ROADWAYSEGID
      STATUS $
      SSL $
      TYPE_ $
      ENTRANCETYPE $
      ADDRNUM
      ADDRNUMSUFFIX $
      STNAME $
      STREET_TYPE $
      QUADRANT $
      CITY $
      STATE $
      FULLADDRESS $
      SQUARE $
      SUFFIX $
      LOT $
      NATIONALGRID $
	  ZIPCODE4 $
	  XCOORD
	  YCOORD
	  STATUS_ID 	
	  METADATA_ID 
      ASSESSMENT_NBHD $
      ASSESSMENT_SUBNBHD $
      CFSA_NAME $
      HOTSPOT $
      CLUSTER_ $
      POLDIST $
      ROC $
      PSA $
      SMD $
      CENSUS_TRACT $
      VOTE_PRCNCT $
      WARD $
      ZIPCODE
      ANC $
      NEWCOMMSELECT06 $
      NEWCOMMCANDIDATE $
      CENSUS_BLOCK $
      CENSUS_BLOCKGROUP $
      FOCUS_IMPROVEMENT_AREA $
      SE_ANNO_CAD_DATA $
      LATITUDE
      LONGITUDE
      ACTIVE_RES_UNIT_COUNT
      RES_TYPE $
      ACTIVE_RES_OCCUPANCY_COUNT
      WARD_2002 $
      WARD_2012 $
      ANC_2002 $
      ANC_2012 $
      SMD_2002 $
      SMD_2012 $
	  OBJECTID_12
	  OBJECTID
	  OBJECTID_1
      ;
      
      length 
        Address_type xStatus xRes_type xEntrancetype $ 1
        Ward2002 Ward2012 $ 1
        Cluster2000 Anc2002 Anc2012 $ 2
        Psa2012 VoterPre2012 $ 3
        Geo2010 $ 11
        GeoBg2010 $ 12
        GeoBlk2010 $ 15
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
      
	  GeoBlk2020 = '11001' || left( compress( census_block ) );
	  GeoBg2020 = substr(GeoBlk2020,1,12);
	  Geo2020 = substr(GeoBlk2020,1,11);
      
      if put( Geo2020, $geo20v. ) = "" then do;
        %Warn_put( msg="Invalid census tract: " _n_= address_id= census_tract= )
      end;

      if put( GeoBg2020, $bg20v. ) = "" then do;
        %Warn_put( msg="Invalid census block group: " _n_= address_id= census_blockgroup= )
      end;

      if put( GeoBlk2020, $blk20v. ) = "" then do;
        %Warn_put( msg="Invalid census block: " _n_= address_id= census_block= )
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

	  if put( Ward2022, $ward22v. ) = "" then do;
        %Warn_put( msg="Invalid ward: " _n_= address_id= ward_2022= )
      end;

      if cluster_ ~= "" then do;
        Cluster2000 = put( input( scan( cluster_, 2, ' ' ), 8. ), z2. );
      end;
      else do;
        %Block20_to_cluster00()
      end;
      
      if put( Cluster2000, $clus00v. ) = "" then do;
        %Warn_put( msg="Invalid neighborhood cluster: " _n_= address_id= cluster_= )
      end;
      
      %Block20_to_cluster_tr00()

	  %Block20_to_cluster17()
      
      %Block20_to_psa04()

	  %Block20_to_psa12()

	  %Block20_to_psa17()
      
      if put( Psa2017, $psa17v. ) = "" then do;
        %Warn_put( msg="Invalid PSA: " _n_= address_id= psa= )
      end;
      
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
        Cluster2000 $clus00a.
        Psa2012 $psa12a.
        Anc2002 $anc02a.
        Anc2012 $anc12a.
        Geo2010 $geo10a.
        GeoBg2010 $bg10a.
        GeoBlk2010 $blk10a.
        VoterPre2012 $vote12a.
        Assessnbhd $marassessnbhd.
        Zip $zipa.
		bridgepk $bpka.
		stantoncommons $stanca.
		cluster2017 $clus17a.
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
        Geo2010 = "Full census tract ID (2010): ssccctttttt"
        GeoBg2010 = "Full census block group ID (2010): sscccttttttb"
        GeoBlk2010 = "Full census block ID (2010): sscccttttttbbbb"
        Psa2012 = "Police Service Area (2012)"
        SMD_2012 = "Single member district, 2012"
        Ward2002 = "Ward (2002)"
        Ward2012 = "Ward (2012)"
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

%mend Read_address_points;


