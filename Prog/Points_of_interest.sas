/**************************************************************************
 Program:  Points_of_interest.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  07/12/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  86
 
 Description:  Read in MAR Points_of_interest data set. 
 
 Source: https://opendata.dc.gov/datasets/DCGIS::points-of-interest/about
 
 Note: Drop X/Y coordinate variable because not needed and have invalid values.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

filename fimport "&_dcdata_r_path\MAR\Raw\2025-07-11\Points_of_Interest.csv" lrecl=1000;


proc import out=Points_of_interest_import
    datafile=fimport
    dbms=csv replace;
  datarow=2;
  getnames=yes;
  guessingrows=max;
run;

filename fimport clear;

data Points_of_interest;

  set Points_of_interest_import;
  
  label
    MAR_ID = "Address identifier [source file MAR_ID]"
    BEFORE_DATE = "MAR point of interest, before date [NO DATA]"
    BEFORE_DATE_SOURCE = "MAR point of interest, before date source [NO DATA]"
    BEGIN_DATE = "MAR point of interest, begin date [NO DATA]"
    BEGIN_DATE_SOURCE = "MAR point of interest, begin date source [NO DATA]"
    CREATED_DATE = "MAR point of interest, created date"
    FIRST_KNOWN_DATE = "MAR point of interest, first known date [NO DATA]"
    FIRST_KNOWN_DATE_SOURCE = "MAR point of interest, first known date source [NO DATA]"
    LAST_EDITED_DATE = "MAR point of interest, last edited date"
    METADATA_ID = "Metadata ID"
    NAME = "MAR point of interest, name (alias)"
    OBJECTID = "Object ID"
    PLACE_NAME_ID = "MAR point of interest, ID"
    SE_ANNO_CAD_DATA = "SE ANNO CAD DATA [NO DATA]"
    STATUS = "MAR point of interest, status"
  ;
  
  format _all_ ;
  informat _all_ ;
  
  format created_date last_edited_date mmddyys10. STATUS $poistatus.;
  
  drop X Y;
 
  rename MAR_ID=address_id NAME=PLACE_NAME;
  
run;

%Finalize_data_set( 
  data=Points_of_interest,
  out=Points_of_interest,
  outlib=MAR,
  label="Master address repository, DC points of interest (address aliases)",
  sortby=address_id,
  revisions=%str(Update with latest Points_of_interest file.),
  printobs=20,
  freqvars=status
)

run;

