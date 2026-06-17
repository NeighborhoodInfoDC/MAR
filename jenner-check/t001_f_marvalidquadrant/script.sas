/**************************************************************************
 Jenner compatibility bundle for: Macros/F_marvalidquadrant.sas
 Upstream library: MAR (DC Master Address Repository), NeighborhoodInfo DC.

 The %F_marvalidquadrant() macro defines the $marvalidquadrant. format,
 which keeps the four valid DC quadrant codes (NE/NW/SE/SW) and maps
 anything else to blank. This bundle defines the macro exactly as written
 upstream, invokes it, and applies the format to a small sample of
 quadrant values so the validation logic is exercised end to end.
**************************************************************************/

/** Macro F_marvalidquadrant - definition copied verbatim from upstream **/

%macro F_marvalidquadrant(  );

  proc format;
    value $marvalidquadrant (default=40)
      "NE" = "NE"
      "NW" = "NW"
      "SE" = "SE"
      "SW" = "SW"
      other = " ";
  run;

%mend F_marvalidquadrant;

/** Invoke the macro to create the format **/

%F_marvalidquadrant()

/** Exercise the format against a small sample of quadrant values **/

data quadrants;
  length quadrant $ 4;
  input quadrant $;
  valid = put( quadrant, $marvalidquadrant. );
datalines;
NE
NW
SE
SW
XY
ZZ
;
run;

proc print data=quadrants;
  var quadrant valid;
run;

proc freq data=quadrants;
  tables valid / missing;
run;
