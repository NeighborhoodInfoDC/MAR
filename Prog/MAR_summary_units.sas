/**************************************************************************
 Program:  MAR_summary_units.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   Rob Pitingolo
 Created:  9/26/2018
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Create summary file of units from MAR address points. 

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

%let address_pt_date = 2017_08;


data mar_units;
	set mar.address_points_&address_pt_date.;
	mar_units = ACTIVE_RES_OCCUPANCY_COUNT;
	city = "1";
	format city city.;
run;


%macro mar_geo (geo);

%let geo_name = %upcase( &geo );
%let geo_var = %sysfunc( putc( &geo_name, $geoval. ) );
%let geo_suffix = %sysfunc( putc( &geo_name, $geosuf. ) );
%let geo_label = %sysfunc( putc( &geo_name, $geodlbl. ) );
%let file_lbl = Mar units summary, DC, &geo_label;
%let revisions=.;


proc summary data = mar_units;
	class &geo_var.;
	var mar_units;
	output out = mar&geo_suffix. sum = ;
run;

data mar_units&geo_suffix.;
	set mar&geo_suffix.;
	if _type_ = 1;
	drop _type_ _freq_;
	label mar_units = "Number of housing units, &geo_label.";
run;

%Finalize_data_set( 
	  /** Finalize data set parameters **/
	  data=mar_units&geo_suffix.,
	  out=mar_sum_units&geo_suffix.,
	  outlib=MAR,
	  label="&file_lbl",
	  sortby=&geo ,
	  /** Metadata parameters **/
	  restrictions=None,
	  revisions=%str(&revisions),
	  /** File info parameters **/
	  printobs=0,
	  freqvars=&geo
	  );

%mend mar_geo;
%mar_geo (city);
%mar_geo (ward2012);
%mar_geo (geo2010);
%mar_geo (geo2000);
%mar_geo (anc2012);
%mar_geo (anc2002);
%mar_geo (psa2012);
%mar_geo (psa2004);
%mar_geo (zip);
%mar_geo (voterpre2012);
%mar_geo (bridgepk);
%mar_geo (cluster2017);
%mar_geo (cluster2000);
%mar_geo (stantoncommons);
