/**************************************************************************
 Program:  L:\Libraries\MAR\Prog\Address_ssl_xref.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/27/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read in latest MAR address-SSL crosswalk file.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR, local=n )


filename fimport "&_dcdata_r_path\MAR\Raw\2018-04-26\Address_and_Square_Suffix_Lot_Cross_Reference.csv" lrecl=256;

/*
OBJECTID,SSL,ADDRESS_ID,MARID,SQUARE,SUFFIX,LOT,COL,PARCEL,RESERVATION,LOT_TYPE
*/

data Address_ssl_xref;

  infile fimport dsd stopover firstobs=2;
  
  length 
    ObjectId 8
    Ssl $ 17
    Address_Id 8
    MarId 8
    Square $ 4
    Suffix $ 4
    Lot $ 4
    Col $ 4
    Parcel $ 20
    Reservation $ 20
    Lot_Type $ 20;

  input
    ObjectId
    Ssl
    Address_Id
    MarId
    Square
    Suffix
    Lot
    Col
    Parcel
    Reservation
    Lot_Type;

run;

/*
proc sort data=Address_ssl_xref out=Mar.Address_ssl_xref;
  by Address_id;
run;


%File_info( data=Address_ssl_xref, freqvars=col lot_type )
*/

%Finalize_data_set( 
  /** Finalize data set parameters **/
  data=Address_ssl_xref,
  out=Address_ssl_xref,
  outlib=MAR,
  label="MAR address ID to SSL crosswalk",
  sortby=address_id ssl,
  archive=N,
  archive_name=,
  /** Metadata parameters **/
  creator_process=&_program,
  restrictions=None,
  revisions=%str(New file.),
  /** File info parameters **/
  contents=Y,
  printobs=10,
  printchar=N,
  printvars=,
  freqvars=,
  stats=n sum mean stddev min max
)



run;
