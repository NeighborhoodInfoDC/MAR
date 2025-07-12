/**************************************************************************
 Program:  Address_points_view.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  04/28/2018
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Create SAS View with latest Address_points.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

%let Address_points = Address_points_2025_07;


proc sql noprint;
  create view Mar.Address_points_view (label="Master address repository, Latest Address_points + Points_of_interest.PLACE_NAME") as
    select 
      coalesce( Address_points.address_id, Points_of_interest.address_id ) as address_id label="Address identifier [source file MAR_ID]",
      Address_points.*, 
      Points_of_interest.PLACE_NAME
    from 
      Mar.&Address_points as Address_points 
      left join
      Points_of_interest (keep=Address_id PLACE_NAME)
    on Address_points.Address_id = Points_of_interest.Address_id
    order by Address_points.Address_id;
  quit;

run;

%File_info( data=Mar.Address_points_view )

%Dc_update_meta_file(
  ds_lib=MAR,
  ds_name=Address_points_view,
  creator_process=Address_points_view.sas,
  restrictions=None,
  revisions=%str(Update with &Address_points. and Points_of_interest.)
)


/* End of program */
