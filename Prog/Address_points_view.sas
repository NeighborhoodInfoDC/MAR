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

%let Address_points = Address_points_2019_09;


  proc sql noprint;
  create view Mar.Address_points_view (label="Master address repository, Address_points + Address_points_xy") as
    select * from 
      Mar.&Address_points (drop=X Y) as Address_points 
     order by Address_points.Address_id;
  quit;

run;

%File_info( data=Mar.Address_points_view )
 
%Dc_update_meta_file(
  ds_lib=MAR,
  ds_name=Address_points_view,
  creator_process=Address_points_view.sas,
  restrictions=None,
  revisions=%str(Update with &Address_points..)
)


/* End of program */
