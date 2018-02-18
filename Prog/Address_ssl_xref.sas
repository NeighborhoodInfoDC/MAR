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


filename fimport "&_dcdata_r_path\MAR\Raw\2013-09-11\VW_ADDRESS_SSL_XREF.txt" lrecl=256;

data Address_ssl_xref;

  infile fimport dsd stopover firstobs=2;
  
  length 
    Ssl $ 17
    Address_Id 8
    Square $ 4
    Suffix $ 4
    Lot $ 4
    Col $ 4
    Parcel $ 20
    Reservation $ 20
    Lot_Type $ 20;

  input
    Ssl
    Address_Id
    Square
    Suffix
    Lot
    Col
    Parcel
    Reservation
    Lot_Type;

run;

proc sort data=Address_ssl_xref out=Mar.Address_ssl_xref;
  by Address_id;
run;

%File_info( data=Address_ssl_xref, freqvars=col lot_type )

run;
