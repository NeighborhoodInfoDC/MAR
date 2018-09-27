/**************************************************************************
 Program:  MAR_summary_units.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   Rob and Yipeng
 Created:  9/26/2018
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Create summary file of units from MAR address points. 

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )
%DCData_lib( realprop )

%let address_pt_date = 2018_06;


proc sort data = mar.address_points_&address_pt_date. out = addpt_in; by ssl; run;
proc sort data = realprop.parcel_base out = parcel_in; by ssl; run;


/* Set Address Points dataset from most recent update */
data mar_units;
	merge addpt_in (in=a)
		  parcel_in (in=b);
	by ssl;

	/* If matched to parcel base, flag res and non-res units */
	if b then do;
		if ui_proptype in ("10","11","12","13","19") then res_flag = 1;
			else res_flag = 0;
	end;

	/* Remove non-res units */
	if res_flag = 0 then delete;

	/* Count number of units by property type*/
	total_mar_units = ACTIVE_RES_OCCUPANCY_COUNT;
	if ui_proptype in ("10") then total_sf_units = ACTIVE_RES_OCCUPANCY_COUNT;
	if ui_proptype in ("13") then total_mfapt_units = ACTIVE_RES_OCCUPANCY_COUNT;
	if ui_proptype in ("11"," ") then total_mfcondo_units = ACTIVE_RES_OCCUPANCY_COUNT;
	if ui_proptype in ("12") then total_mfcoop_units = ACTIVE_RES_OCCUPANCY_COUNT;
	if ui_proptype in ("19") then total_other_units = ACTIVE_RES_OCCUPANCY_COUNT;


	/* City variable */
	city = "1";
	format city city.;
run;

proc freq data = mar_units;
	tables match;
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
	var total_mar_units total_sf_units total_mfapt_units total_mfcondo_units total_mfcoop_units total_other_units;
	output out = mar&geo_suffix. sum = ;
run;

/* Final cleanup */
data mar_units&geo_suffix.;
	set mar&geo_suffix.;
	if _type_ = 1;
	drop _type_ _freq_;
	label mar_units = "Number of housing units, &geo_label.";
run;

/** Finalize data set  **/
%Finalize_data_set( 
	  data=mar_units&geo_suffix.,
	  out=mar_sum_units&geo_suffix._&address_pt_date.,
	  outlib=MAR,
	  label="MAR number of housing units, &geo_label.",
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


/* End of program */
