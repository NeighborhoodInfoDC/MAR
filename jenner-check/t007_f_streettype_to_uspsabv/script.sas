/**************************************************************************
 Jenner compatibility bundle for: Macros/f_streettype_to_uspsabv.sas
 Upstream library: MAR (DC Master Address Repository), NeighborhoodInfo DC.

 The %f_streettype_to_uspsabv() macro defines the $streettype_to_uspsabv.
 format, which converts a full street type to its standard USPS
 abbreviation (AVENUE -> Ave, BOULEVARD -> Blvd, PARKWAY -> Pkwy, ...).
 This bundle defines the macro verbatim, invokes it, and runs a sample of
 street types through it so the conversion is exercised end to end.
**************************************************************************/

/** Macro f_streettype_to_uspsabv - definition copied verbatim from upstream **/

%macro f_streettype_to_uspsabv(  );

  proc format;
    value $streettype_to_uspsabv
      "ALLEY" = "Aly"
      "AVENUE" = "Ave"
      "BOULEVARD" = "Blvd"
      "BRIDGE" = "Brg"
      "CIRCLE" = "Cir"
      "COURT" = "Ct"
      "CRESCENT" = "Cres"
      "DRIVE" = "Dr"
      "ENTRANCE" = "Ent"
      "EXPRESSWAY" = "Expy"
      "GREEN" = "Grn"
      "INTERSTATE" = "Interstate"
      "KEYS" = "Kys"
      "LANE" = "Ln"
      "LOOP" = "Loop"
      "MEWS" = "Mews"
      "PARKWAY" = "Pkwy"
      "PIER" = "Pier"
      "PLACE" = "Pl"
      "PLAZA" = "Plz"
      "PROMENADE" = "Promenade"
      "ROAD" = "Rd"
      "ROW" = "Row"
      "SQUARE" = "Sq"
      "STREET" = "St"
      "TERRACE" = "Ter"
      "WALK" = "Walk"
      "WAY" = "Way";
  run;

%mend f_streettype_to_uspsabv;

/** Invoke the macro to create the format **/

%f_streettype_to_uspsabv()

/** Exercise the conversion against a sample of street types **/

data abbrev;
  length sttyp $ 12;
  input sttyp $;
  usps = put( sttyp, $streettype_to_uspsabv. );
datalines;
AVENUE
BOULEVARD
STREET
PARKWAY
PLACE
ROAD
TERRACE
COURT
;
run;

proc print data=abbrev;
  var sttyp usps;
run;
