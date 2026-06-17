/**************************************************************************
 Jenner compatibility bundle for: Macros/F_marvalidsttyp.sas
 Upstream library: MAR (DC Master Address Repository), NeighborhoodInfo DC.

 The %F_marvalidsttyp() macro defines the $marvalidsttyp. format, which
 enumerates the valid street-type names used by the MAR (ALLEY, AVENUE,
 BOULEVARD, ...) and maps anything else to blank. This bundle defines the
 macro verbatim, invokes it, and runs a sample of street types through it
 so the validation is exercised.
**************************************************************************/

/** Macro F_marvalidsttyp - definition copied verbatim from upstream **/

%macro F_marvalidsttyp(  );

  proc format;
    value $marvalidsttyp (default=40)
      "ALLEY" = "ALLEY"
      "AVENUE" = "AVENUE"
      "BOULEVARD" = "BOULEVARD"
      "CIRCLE" = "CIRCLE"
      "COURT" = "COURT"
      "CRESCENT" = "CRESCENT"
      "DRIVE" = "DRIVE"
      "ENTRANCE" = "ENTRANCE"
      "GREEN" = "GREEN"
      "KEYS" = "KEYS"
      "LANE" = "LANE"
      "LOOP" = "LOOP"
      "MEWS" = "MEWS"
      "PARKWAY" = "PARKWAY"
      "PIER" = "PIER"
      "PLACE" = "PLACE"
      "PLAZA" = "PLAZA"
      "PROMENADE" = "PROMENADE"
      "ROAD" = "ROAD"
      "ROW" = "ROW"
      "SQUARE" = "SQUARE"
      "STREET" = "STREET"
      "TERRACE" = "TERRACE"
      "WALK" = "WALK"
      "WAY" = "WAY"
      other = " ";
  run;

%mend F_marvalidsttyp;

/** Invoke the macro to create the format **/

%F_marvalidsttyp()

/** Exercise validation against a sample of street types **/

data sttypes;
  length sttyp $ 12;
  input sttyp $;
  valid = put( sttyp, $marvalidsttyp. );
datalines;
STREET
AVENUE
BOULEVARD
PLACE
ROAD
WAY
PIER
HIGHWAY
BANANA
;
run;

proc print data=sttypes;
  var sttyp valid;
run;

proc freq data=sttypes;
  tables valid / missing;
run;
