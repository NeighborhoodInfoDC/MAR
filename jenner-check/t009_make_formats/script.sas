/**************************************************************************
 Jenner compatibility bundle for: Prog/Make_formats.sas
 Upstream library: MAR (DC Master Address Repository), NeighborhoodInfo DC.

 Make_formats.sas builds the core set of MAR character formats that label
 the coded columns of the address repository: address type, status,
 residential type, lot type, unit type, and point-of-interest status.
 The upstream program writes these to a permanent MAR format catalog via
 the NeighborhoodInfo DC standard-library include; this bundle keeps the
 PROC FORMAT value definitions exactly as written, writes them to WORK,
 and applies them to a small sample of coded address records so the
 labelling is exercised end to end.
**************************************************************************/

proc format;

  value $maraddrtyp
    'A' = 'Address'
    'P' = 'Place';

  value $marstatus
    'A' = 'Active'
    'S' = 'Assigned'
    'R' = 'Retired'
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

/** Apply the MAR formats to a small sample of coded address records **/

data addresses;
  length addrtyp $ 1 status $ 1 restyp $ 1 lottyp $ 6 unittyp $ 1;
  input addrtyp $ status $ restyp $ lottyp $ unittyp $;
  addrtyp_lbl = put( addrtyp, $maraddrtyp. );
  status_lbl  = put( status,  $marstatus. );
  restyp_lbl  = put( restyp,  $marrestyp. );
  lottyp_lbl  = put( lottyp,  $marlottyp. );
  unittyp_lbl = put( unittyp, $marunittyp. );
datalines;
A A R RECORD N
P S N TAXLOT C
A R M CONDO R
A T R PARCEL N
;
run;

proc print data=addresses;
  var addrtyp addrtyp_lbl status status_lbl restyp restyp_lbl
      lottyp lottyp_lbl unittyp unittyp_lbl;
run;

/** Confirm the lot-type text-to-code crosswalk format as well **/

data lots;
  length lottyp_text $ 12;
  infile datalines truncover;
  input lottyp_text $char12.;
  code = put( lottyp_text, $marlottyp_to_code. );
  label = put( code, $marlottyp. );
datalines;
RECORD LOT
TAX LOT
CONDO
PARCEL
RESERVATION
;
run;

proc print data=lots;
  var lottyp_text code label;
run;
