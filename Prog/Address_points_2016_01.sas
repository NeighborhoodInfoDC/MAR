/**************************************************************************
 Program:  Address_points_2016_01.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/26/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read address_points data set.

 Modifications:
**************************************************************************/

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

filename fimport "C:\DCData\Libraries\MAR\Raw\Address_Points.csv" lrecl=2000;

data Mar.Address_points_2016_01;

  infile fimport delimiter = ',' missover dsd firstobs=2 OBS=1000000;

  informat X best32. ;
  informat Y best32. ;
  informat OBJECTID_12 best32. ;
  informat SITE_ADDRESS_PK best32. ;
  informat ADDRESS_ID best32. ;
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
  informat ASSESSMENT_NBHD $32. ;
  informat ASSESSMENT_SUBNBHD $80. ;
  informat CFSA_NAME $80. ;
  informat HOTSPOT $2. ;
  informat CLUSTER_ $32. ;
  informat POLDIST $80. ;
  informat ROC $32. ;
  informat PSA $32. ;
  informat SMD $32. ;
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
  
  input
    X
    Y
    OBJECTID_12
    SITE_ADDRESS_PK
    ADDRESS_ID
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
    ;
    
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
    
    Geo2010 = '11001' || left( compress( census_tract ) );
    GeoBg2010 = '11001' || left( compress( census_blockgroup ) );
    GeoBlk2010 = '11001' || left( compress( census_block ) );
    
    if put( Geo2010, $geo10v. ) = "" then do;
      %Err_put( msg="Invalid census tract: " _n_= address_id= census_tract= )
    end;

    if put( GeoBg2010, $bg10v. ) = "" then do;
      %Err_put( msg="Invalid census block group: " _n_= address_id= census_blockgroup= )
    end;

    if put( GeoBlk2010, $blk10v. ) = "" then do;
      %Err_put( msg="Invalid census block: " _n_= address_id= census_block= )
    end;
    
    Ward2002 = scan( ward_2002, 2, ' ' );
    
    if put( Ward2002, $ward02v. ) = "" then do;
      %Err_put( msg="Invalid ward: " _n_= address_id= ward_2002= )
    end;

    Ward2012 = scan( ward_2012, 2, ' ' );

    if put( Ward2012, $ward12v. ) = "" then do;
      %Err_put( msg="Invalid ward: " _n_= address_id= ward_2012= )
    end;

    if cluster_ ~= "" then do;
      Cluster2000 = put( input( scan( cluster_, 2, ' ' ), 8. ), z2. );
    end;
    else do;
      %Block10_to_cluster00()
    end;
    
    if put( Cluster2000, $clus00v. ) = "" then do;
      %Err_put( msg="Invalid neighborhood cluster: " _n_= address_id= cluster_= )
    end;
    
    %Block10_to_cluster_tr00()
    
    Psa2012 = scan( psa, 4, ' ' );
    
    if put( Psa2012, $psa12v. ) = "" then do;
      %Err_put( msg="Invalid PSA: " _n_= address_id= psa= )
    end;
    
    Anc2002 = scan( anc_2002, 2, ' ' );
    Anc2012 = scan( anc_2012, 2, ' ' );
    
    VoterPre2012 = put( input( scan( vote_prcnct, 2, ' ' ), 8. ), z3. );

    if put( VoterPre2012, $vote12v. ) = "" then do;
      %Err_put( msg="Invalid voter precinct: " _n_= address_id= vote_prcnct= )
    end;
    
    Assessnbhd = put( upcase( compress( assessment_nbhd, ' .-/' ) ), $martext_to_assessnbhd. );

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
    ;
    
    rename 
      xStatus=Status
      xRes_type=Res_type
      xEntrancetype=Entrancetype
    ;
    
    drop type_ status res_type entrancetype /*cluster_ psa anc_2002 anc_2012*/;

    label
      ACTIVE_RES_OCCUPANCY_COUNT = "Number of housing units at the primary address"
      ACTIVE_RES_UNIT_COUNT = "Active residential use count"
      ADDRESS_ID = "Address identifier"
      ADDRNUM = "Address location house number"
      ADDRNUMSUFFIX = "Address location house number suffix"
      ANC = "Address location Advisory Neighborhood Commission"
      ASSESSMENT_NBHD = "Address Assessment Neighborhood Name"
      ASSESSMENT_SUBNBHD = "Address Assessment SubNeighborhood Name"
      CENSUS_BLOCK = "Census Block Value Address is in"
      CENSUS_BLOCKGROUP = "Census Block Group value"
      CENSUS_TRACT = "Address location census tract"
      CFSA_NAME = "Address CFSA area name"
      CITY = "Address location city"
      CLUSTER_ = "Address location neighborhood cluster name"
      ENTRANCETYPE = "Address entrance type"
      FOCUS_IMPROVEMENT_AREA = "Focus improvement area name"
      FULLADDRESS = "House number, street name, street type, and quadrant"
      HOTSPOT = "Address location hot spot"
      LATITUDE = "Latitude of address"
      LONGITUDE = "Longitude of Address"
      LOT = "Address location property lot"
      NATIONALGRID = "Address location national grid coordinate"
      NEWCOMMCANDIDATE = "Address location New Community Candidate"
      NEWCOMMSELECT06 = "Address location New Community Selected 2006"
      OBJECTID_12 = "Internal feature number."
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
      SSL = "Address location Square, Suffix, and Lot"
      STATE = "Address location state name"
      xSTATUS = "Address status"
      STNAME = "Address location street name"
      STREET_TYPE = "Address location street type"
      SUFFIX = "Address location property suffix"
      TYPE_ = "Address Type"
      VOTE_PRCNCT = "Address location voting precinct"
      WARD = "Address location Ward name"
      X = "X Coordinate of Address Point"
      Y = "Y Coordinate of Address Point"
      ZIPCODE = "Address location Zip code"
      ;

run;

%File_info( data=Mar.Address_points_2016_01, 
  freqvars=Address_type status res_type entrancetype state city quadrant addrnumsuffix street_type stname 
           Assessnbhd CFSA_NAME NEWCOMMSELECT06  NEWCOMMCANDIDATE hotspot focus_: )
            
%Compare_file_struct( file_list=Address_points Address_points_2016_01, lib=MAR )


/*
proc print data=Mar.Address_points_2016_01;
  ***where stname in ( '12TH ST', 'E ST' );
  where fulladdress = '';
  var address_id type_ status fulladdress addrnum addrnumsuffix stname street_type quadrant;
run;

