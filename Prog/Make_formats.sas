/**************************************************************************
 Program:  Make_formats.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/26/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create MAR formats.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

proc format library=MAR;

  value $maraddrtyp
    'A' = 'Address'
    'P' = 'Place';
    
  value $marstatus
    'A' = 'Active'
    'S' = 'Assigned'
    'R' = 'Retire'
    'T' = 'Temporary';
    
  value $marrestyp
    'M' = 'Mixed use'
    'N' = 'Nonresidential'
    'R' = 'Residential';
    
  value $marentrtyp
    'O' = 'Official';
    
  value $marlottyp_to_code
    'AIR RIGHT' = 'AIRRIG'
    'CONDO'     = 'CONDO'
    'NA'        = 'NA'
    'PARCEL'    = 'PARCEL'
    'RECORD LOT' = 'RECORD'
    'RESERVATION' = 'RESERV'
    'TAX LOT'    = 'TAXLOT';
    
  value $marlottyp
    'AIRRIG' = 'Air right'
    'CONDO' = 'Condominium'
    'NA' = 'Not applicable'
    'PARCEL' = 'Parcel'
    'RECORD' = 'Record lot'
    'RESERV' = 'Reservation'
    'TAXLOT' = 'Tax lot';
    
  value $marunittyp
    'N' = 'Non-condominium'
    'C' = 'Condominium'
    'R' = 'Rental';

  value $poistatus
    'ACTIVE' = 'Active'
    'ASSIGNED' = 'Assigned';

run;

proc catalog catalog=MAR.Formats;
  modify maraddrtyp (desc="MAR address type") / entrytype=formatc;
  modify marstatus (desc="MAR address status") / entrytype=formatc;
  modify marrestyp (desc="MAR residential type") / entrytype=formatc;
  modify marentrtyp (desc="MAR entrance type") / entrytype=formatc;
  modify marlottyp_to_code (desc="MAR convert lot type text to codes") / entrytype=formatc;
  modify marlottyp (desc="MAR lot type") / entrytype=formatc;
  modify marunittyp (desc="MAR unit type") / entrytype=formatc;
  modify poistatus (desc="MAR point of interest status") / entrytype=formatc;
  contents;
quit;

