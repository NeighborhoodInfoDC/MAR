/**************************************************************************
 Jenner compatibility bundle for: Macros/F_marvalidunit.sas
 Upstream library: MAR (DC Master Address Repository), NeighborhoodInfo DC.

 The %F_marvalidunit() macro defines the $marvalidunit. format, which
 keeps the canonical token "UNIT" and maps everything else to blank.
 Together with $maraltunit. it lets the address parser confirm a token is
 a real unit designator. This bundle defines the macro verbatim, invokes
 it, and runs a small sample through it so the validation is exercised.
**************************************************************************/

/** Macro F_marvalidunit - definition copied verbatim from upstream **/

%macro F_marvalidunit(  );

  proc format;
    value $marvalidunit (default=40)
      "UNIT" = "UNIT"
      other = " ";
  run;

%mend F_marvalidunit;

/** Invoke the macro to create the format **/

%F_marvalidunit()

/** Exercise validation against a small sample **/

data units;
  length tok $ 12;
  input tok $;
  valid = put( tok, $marvalidunit. );
datalines;
UNIT
APT
SUITE
FLOOR
;
run;

proc print data=units;
  var tok valid;
run;

proc freq data=units;
  tables valid / missing;
run;
