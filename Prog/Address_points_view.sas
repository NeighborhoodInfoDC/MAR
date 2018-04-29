/**************************************************************************
 Program:  Address_points_view.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  04/28/2018
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Create SAS View with combined 
 latest Address_points and Address_points_xy data sets.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

%let revisions = New file.;

proc sql noprint;
  create view MAR.Address_points_view (label="Master address repository, Address_points + Address_points_xy") as
    select * from 
      Mar.Address_points_2017_08 (drop=X Y) as Address_points 
      left join 
      Mar.Address_points_xy as XY
      on Address_points.Address_id = XY.Address_id
     order by Address_points.Address_id;
  quit;

run;

%File_info( data=Mar.Address_points_view )

%Dc_update_meta_file(
  ds_lib=MAR,
  ds_name=Address_points_view,
  creator_process=Address_points_view.sas,
  restrictions=None,
  revisions=%str(&revisions)
)

