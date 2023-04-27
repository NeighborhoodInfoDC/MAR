/**************************************************************************
 Program:  Address_ssl_xref.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/27/14
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read in latest MAR address-SSL crosswalk file.
 
 Data downloaded from 
 http://opendata.dc.gov/datasets/address-and-square-suffix-lot-cross-reference

 Modifications: PT 4-26-2018 Updated with 4/26/2018 download.
				LH 3-15-2019 Updated with 3/15/2019 download.
				LH 9-24-2019 Updated with 9/19/2019 download.
				RP 7-7-2022 Updated with 7/5/2022 download.
				RP 7-15-2022 Changed SSL to 17 characters. 
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

%let revisions = Updated with 4/27/2023 download.;


filename fimport "&_dcdata_r_path\MAR\Raw\2023-04-27\Address_and_Square_Suffix_Lot_Cross_Reference.csv" lrecl=256;

data Address_ssl_xref_raw;

  infile fimport dsd stopover firstobs=2;
  
  length 
    ObjectId 8
    Ssl_in $ 25        /** Need to accomodate values like '1179    UNNUMBERED LOT' **/
    Address_Id 8
    MarId 8
    Square $ 4
    Suffix $ 4
    Lot $ 20        /** Need to accomodate values like 'UNNUMBERED LOT' **/
    Col $ 4
    Parcel $ 20
    Reservation $ 20
    Lot_Type_text $ 20
    Lot_type $ 6;

  input
    ObjectId
    Ssl_in
    Address_Id
    MarId
    Square
    Suffix
    Lot
    Col
    Parcel
    Reservation
    Lot_Type_text;

  ** Convert Lot_type to coded values;
  
  Lot_type = left( put( Lot_Type_text, $marlottyp_to_code. ) );
  
  format Lot_type $marlottyp.;

  label
    ObjectId = "Input file ObjectID"
    Ssl_in = "Property identification number (square/suffix/lot) [TEMPORARY]"
    Address_Id = "MAR address ID"
    MarId = "MAR address ID (seems to duplicate Address_Id)"
    Square = "Square map number"
    Suffix = "Square suffix"
    Lot = "Lot number of the property"
    Col = "Col"
    Parcel = "Parcel number"
    Reservation = "Reservation number"
    Lot_Type = "Type of lot";

  drop Lot_type_text;

run;

/* Fix the SSL variable so it's consistent with SSL on other datasets */
data Address_ssl_xref;
   set Address_ssl_xref_raw;

   length ssl $17.;

   if index(ssl_in, 'UNNUMBERED') > 0 then fixssl = 1;
   	else if index(ssl_in, 'KINGS') > 0 then fixssl = 1;
	else if index(ssl_in, 'ORIGINAL') > 0 then fixssl = 1;
	else if index(ssl_in, 'PT') > 0 then fixssl = 1;
	else if index(ssl_in, 'PART') > 0 then fixssl = 1;
	else if index(ssl_in, 'LOT') > 0 then fixssl = 1;

	if fixssl = 1 then do;
		ssl = square || suffix || "XXXX";
	end;
	else do;
		ssl = ssl_in;
	end;
	
	drop ssl_in fixssl;

	label Ssl = "Property identification number (square/suffix/lot)";

run;


%Finalize_data_set( 
  /** Finalize data set parameters **/
  data=Address_ssl_xref,
  out=Address_ssl_xref,
  outlib=MAR,
  label="Master address repository ID to parcel SSL crosswalk",
  sortby=address_id ssl,
  /** Metadata parameters **/
  restrictions=None,
  revisions=%str(&revisions),
  /** File info parameters **/
  printobs=40,
  freqvars=col lot_type
)

run;
