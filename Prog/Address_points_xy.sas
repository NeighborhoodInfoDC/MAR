/**************************************************************************
 Program:  Address_points_xy.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/28/18
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create Address_points_xy data set with x/y coordinates
 (MD State Plane) for MAR addresses.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

%let revisions = New file.;

filename inf  "&_dcdata_r_path\MAR\Maps\Address_points_xy.csv" lrecl=2000;

data Address_points_xy;

  infile inf dsd stopover firstobs=2;
  
  length Address_id X Y 8;

  input
    X
    Y
    OBJECTID_1
    SITE_ADDRE
    Address_id;

  label
    Address_id = 'Address identifier'
    X = 'X coordinate of address point (MD State Plane Coord., NAD 1983 meters)'
    Y = 'Y coordinate of address point (MD State Plane Coord., NAD 1983 meters)';

  drop objectid_1 site_addre;

run;

%Finalize_data_set( 
  /** Finalize data set parameters **/
  data=Address_points_xy,
  out=Address_points_xy,
  outlib=MAR,
  label="Master address repository, x/y coordinates (MD state plane)",
  sortby=Address_id,
  /** Metadata parameters **/
  restrictions=None,
  revisions=%str(&revisions),
  /** File info parameters **/
  printobs=40
)

