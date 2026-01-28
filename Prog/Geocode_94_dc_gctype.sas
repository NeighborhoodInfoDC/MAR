/**************************************************************************
 Program:  Geocode_94_dc_gctype.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  01/28/26
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  95
 
 Description:  Create Mar.Geocode_94_dc_gctype data set that adds
 PIER to list of standard street types for geocoding.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

** Create new GCTYPE data set to add missing street type PIER **;

data Geocode_94_dc_gctype;
    set sashelp.gctype;
run;

proc sql;
    insert into Geocode_94_dc_gctype (name, type, group)
    values ('PIER', 'PIER', 900 );
quit;

%Finalize_data_set( 
	data=Geocode_94_dc_gctype,
	out=Geocode_94_dc_gctype,
	outlib=MAR,
	label="Street types for Proc Geocode 9.4 (DC MAR)",
	sortby=name type,
	restrictions=None,
      revisions=%str(New file.),
	printobs=0, 
	freqvars=,
      stats=
	)

run;
