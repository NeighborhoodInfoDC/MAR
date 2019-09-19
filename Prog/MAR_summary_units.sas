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
%let update_year = 2018;
%let revisions= New file;

/* Create a list of address IDs for condos buildings */
data condolist;
	set mar.address_ssl_xref;
	if lot_type = "CONDO";
run;


/* Merge condo building list onto address pts */
proc sort data = mar.address_points_&address_pt_date. out = addpt_in; by address_id; run;
proc sort data = condolist out = address_ssl_xref (keep = ssl address_id Lot_type) nodupkey; by address_id; run;

data condo_xref;
	merge addpt_in address_ssl_xref;
	by address_id;
run;


/* Merge address pt to parcel base */
proc sort data = condo_xref; by ssl; run;
proc sort data = realprop.parcel_base out = parcel_in (keep = ssl ui_proptype); by ssl; run;

data mar_units;
	merge condo_xref (in=a)
		  /*parcel_in (in=b where=(in_last_ownerpt=1));*/
		  parcel_in (in=b);
	by ssl;

	if a then do;
		if Lot_type = "CONDO" then ui_proptype = "11";
	end;

	/* Flag residential vs. non-residential units */
		if ui_proptype in ("10","11","12","13","19") then res_flag = 1;
			else if ui_proptype ^= " " then res_flag = 0;


	/* Count number of units by property type*/
	if res_flag = 1 then do;
		total_res_units_&update_year. = ACTIVE_RES_OCCUPANCY_COUNT;
		if ui_proptype in ("10") then total_sf_units_&update_year. = ACTIVE_RES_OCCUPANCY_COUNT;
		if ui_proptype in ("13") then total_mfapt_units_&update_year. = ACTIVE_RES_OCCUPANCY_COUNT;
		if ui_proptype in ("11") then total_condo_units_&update_year. = ACTIVE_RES_OCCUPANCY_COUNT;
		if ui_proptype in ("12") then total_mfcoop_units_&update_year. = ACTIVE_RES_OCCUPANCY_COUNT;
		if ui_proptype in ("19") then total_other_units_&update_year. = ACTIVE_RES_OCCUPANCY_COUNT;
	end;

	if res_flag = 0 then do;
		total_nonres_units_&update_year. = ACTIVE_RES_OCCUPANCY_COUNT;
	end;


	/* City variable */
	city = "1";
	format city city.;

run;


%let sumvars = total_res_units_&update_year. total_sf_units_&update_year. total_mfapt_units_&update_year. total_condo_units_&update_year. 
			   total_mfcoop_units_&update_year. total_other_units_&update_year. total_nonres_units_&update_year.;



%macro mar_geo (geo,vfmt);

%let geo_name = %upcase( &geo );
%let geo_var = %sysfunc( putc( &geo_name, $geoval. ) );
%let geo_suffix = %sysfunc( putc( &geo_name, $geosuf. ) );
%let geo_label = %sysfunc( putc( &geo_name, $geodlbl. ) );

proc summary data = mar_units;
	class &geo_var.;
	var &sumvars.;
	output out = mar&geo_suffix. sum = ;
run;

/* Final cleanup */
data mar_units&geo_suffix.;
	set mar&geo_suffix.;
	if _type_ = 1;
	drop _type_ _freq_;

	/* Switch missing cells to zero when applicable */
	%macro missing_zero ();
	%do j=1 %to 7;
	%let var = %scan(&sumvars. , &j., ' ');

	if &var. = . then &var. = 0;

	%end;
	%mend missing_zero;
	%missing_zero;

	label 	total_res_units_&update_year. = "Number of total residential units &update_year."
			total_sf_units_&update_year. = "Number of single-family units &update_year."
			total_mfapt_units_&update_year. = "Number of multi-family apartment units &update_year."
			total_condo_units_&update_year. = "Number of condominium units &update_year."
			total_mfcoop_units_&update_year. = "Number of multi-family coop units &update_year."
			total_other_units_&update_year. = "Number of other residential units &update_year."
			total_nonres_units_&update_year. = "Number of total non-residential units &update_year."
			;

	/* Keep geos where there is a valid format */
	if put( &geo_var., &vfmt. )  ^= " "; 

run;

/** Finalize data set  **/
%Finalize_data_set( 
	  data=mar_units&geo_suffix.,
	  out=mar_sum_units&geo_suffix._&address_pt_date.,
	  outlib=MAR,
	  label="MAR number of housing units as of &address_pt_date., &geo_label.",
	  sortby=&geo ,
	  /** Metadata parameters **/
	  restrictions=None,
	  revisions=%str(&revisions),
	  /** File info parameters **/
	  printobs=0,
	  freqvars=&geo
	  );

%mend mar_geo;
%mar_geo (city, $city.);
%mar_geo (ward2012, $ward12v.);
%mar_geo (geo2010, $geo10v.);
%mar_geo (geo2000, $geo00v.);
%mar_geo (anc2012, $anc12v.);
%mar_geo (anc2002, $anc02v.);
%mar_geo (psa2012, $psa12v.);
%mar_geo (psa2004, $psa04v.);
%mar_geo (zip, $zipv.);
%mar_geo (voterpre2012, $vote12v.);
%mar_geo (bridgepk, $bpkv. );
%mar_geo (cluster2017, $clus17v.);
%mar_geo (cluster2000, $clus00v.);
%mar_geo (stantoncommons, $stancv.);



/* End of program */
