/**************************************************************************
 Jenner compatibility bundle for: Macros/F_maraltquadrant.sas
 Upstream library: MAR (DC Master Address Repository), NeighborhoodInfo DC.

 The %F_maraltquadrant() macro defines the $maraltquadrant. format, which
 normalizes alternate spellings of DC quadrants (e.g. "NORTHEAST",
 "NORTHEAS", "NEAST") to the canonical two-letter code (NE/NW/SE/SW).
 This bundle defines the macro verbatim, invokes it, and runs a sample of
 alternate spellings through it so the normalization is exercised.
**************************************************************************/

/** Macro F_maraltquadrant - definition copied verbatim from upstream **/

%macro F_maraltquadrant(  );

  proc format;
    value $maraltquadrant (default=40)
      "NE" = "NE"
      "NORTHEAST" = "NE"
      "NORTHEAS" = "NE"
      "NORTHEA" = "NE"
      "NORTHE" = "NE"
      "NEAST" = "NE"
      "NW" = "NW"
      "NORTHWEST" = "NW"
      "NORTHWES" = "NW"
      "NORTHWE" = "NW"
      "NORTHW" = "NW"
      "NWEST" = "NW"
      "SE" = "SE"
      "SOUTHEAST" = "SE"
      "SOUTHEAS" = "SE"
      "SOUTHEA" = "SE"
      "SOUTHE" = "SE"
      "SEAST" = "SE"
      "SW" = "SW"
      "SOUTHWEST" = "SW"
      "SOUTHWES" = "SW"
      "SOUTHWE" = "SW"
      "SOUTHW" = "SW"
      "SWEST" = "SW"
    ;
  run;

%mend F_maraltquadrant;

/** Invoke the macro to create the format **/

%F_maraltquadrant()

/** Exercise the normalization against alternate quadrant spellings **/

data quadrants;
  length raw $ 12;
  input raw $;
  normalized = put( raw, $maraltquadrant. );
datalines;
NORTHEAST
NEAST
NORTHWEST
SOUTHEAST
SOUTHWEST
SWEST
NE
SW
;
run;

proc print data=quadrants;
  var raw normalized;
run;

proc freq data=quadrants;
  tables normalized;
run;
