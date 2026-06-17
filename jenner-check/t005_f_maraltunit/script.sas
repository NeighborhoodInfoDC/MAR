/**************************************************************************
 Jenner compatibility bundle for: Macros/F_maraltunit.sas
 Upstream library: MAR (DC Master Address Repository), NeighborhoodInfo DC.

 The %F_maraltunit() macro defines the $maraltunit. format, which
 normalizes the many ways a unit/apartment designator is written
 (APT, APARTMENT, STE, SUITE, #, NO, NUMBER, ...) to the single token
 "UNIT". This bundle defines the macro verbatim, invokes it, and runs a
 sample of unit designators through it so the normalization is exercised.
**************************************************************************/

/** Macro F_maraltunit - definition copied verbatim from upstream **/

%macro F_maraltunit(  );

  proc format;
    value $maraltunit (default=40)

      "APARTAMENTO" = "UNIT"
      "APARTAMENTOS" = "UNIT"
      "APARTMENT" = "UNIT"
      "APMNT" = "UNIT"
      "APMT" = "UNIT"
      "APRT" = "UNIT"
      "APRTMNT" = "UNIT"
      "APT" = "UNIT"
      "UNIT" = "UNIT"

      "APARTMENTNO" = "UNIT"
      "APMNTNO" = "UNIT"
      "APMTNO" = "UNIT"
      "APRTNO" = "UNIT"
      "APRTMNTNO" = "UNIT"
      "APTNO" = "UNIT"
      "UNITNO" = "UNIT"

      "APARTMENTNUM" = "UNIT"
      "APMNTNUM" = "UNIT"
      "APMTNUM" = "UNIT"
      "APRTNUM" = "UNIT"
      "APRTMNTNUM" = "UNIT"
      "APTNUM" = "UNIT"
      "UNITNUM" = "UNIT"

      "#" = "UNIT"
      "NO" = "UNIT"
      "NUM" = "UNIT"
      "NUMBER" = "UNIT"
      "NUMBR" = "UNIT"
      "NMBER" = "UNIT"

      "SUITE" = "UNIT"
      "STE" = "UNIT"
    ;
  run;

%mend F_maraltunit;

/** Invoke the macro to create the format **/

%F_maraltunit()

/** Exercise normalization against a sample of unit designators **/

data units;
  length raw $ 12;
  input raw $;
  normalized = put( raw, $maraltunit. );
datalines;
APT
APARTMENT
STE
SUITE
NO
NUMBER
UNIT
FLOOR
;
run;

proc print data=units;
  var raw normalized;
run;

proc freq data=units;
  tables normalized;
run;
