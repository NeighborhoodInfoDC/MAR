/**************************************************************************
 Program:  Address_points_yyyy_mm.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  11/2/2024
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  68
 
 Description:  Read address_points data set.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )


%Read_address_points_2024( filedate='02nov2024'd ) /* Filedate should be in the SASdate format such as '01jan2017'd */


%File_info( data=Address_points_2024_11, freqvars=STREET_TYPE ADDRESS_TYPE STATUS RES_TYPE PLACEMENT SSL_ALIGNMENT )


proc datasets;
  copy in=MAR out=work memtype=data;
  select Address_points_2023_04;
quit;

proc sort data=Address_points_2023_04;
  by address_id;
run;

%Compare_file_struct( file_list=Address_points_2023_04 Address_points_2024_11, print=n, csv_out="&_dcdata_default_path\mar\prog\temp\compare_file_struct.csv" )

proc compare base=Address_points_2023_04 compare=Address_points_2024_11 maxprint=(40,32000);
  id address_id;
run;



/*****
proc print data=Address_points_2023_04 (obs=40);
  ***where active_res_occupancy_count ~= active_res_unit_count and active_res_occupancy_count > 1;
  where address_id in ( 316365, 336393, 301233, 301232, 259693, 259696, 274794, 274870, 259695,
     273989,  273996,  242370,  242375,  242779,  242773,  242783,  242780,  218462 );
  id address_id;
  var active_res_occupancy_count active_res_unit_count;
run;

proc print data=Address_points_2024_11;
  where mar_id in ( 316365, 336393, 301233, 301232, 259693, 259696, 274794, 274870, 259695,
     273989,  273996,  242370,  242375,  242779,  242773,  242783,  242780,  218462 );
  id mar_id;
  var housing_unit_count residential_unit_count;
run;

