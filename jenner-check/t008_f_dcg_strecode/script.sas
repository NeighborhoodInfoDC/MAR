/**************************************************************************
 Jenner compatibility bundle for: Macros/F_dcg_strecode.sas
 Upstream library: MAR (DC Master Address Repository), Urban-Greater DC.

 The %F_dcg_strecode() macro defines the $dcg_strecode. format, a flag
 lookup that marks the short and ambiguous street names that Proc Geocode
 has trouble matching (single letters E/N/S/W, NORTH/SOUTH/EAST/WEST,
 FOREST, FALLS, CANAL ROAD, ...) with "YES" and everything else with
 blank. This bundle defines the macro verbatim, invokes it, and runs a
 sample of street names through it so the flagging is exercised.
**************************************************************************/

/** Macro F_dcg_strecode - definition copied verbatim from upstream **/

%macro F_dcg_strecode(  );

  %** Enter street names in ALL CAPS **;

  proc format;
    value $dcg_strecode (default=40)
      'E', 'N', 'S', 'W', 'R', 'V',
      'NORTH', 'SOUTH', 'EAST', 'WEST',
      'WEST LANE', 'EAST BEACH', 'WEST BEACH',
      'FOREST', 'FALLS', 'ORCHARD', 'VALLEY', 'CANAL ROAD'
      = 'YES'
      other = ' ';
  run;

%mend F_dcg_strecode;

/** Invoke the macro to create the format **/

%F_dcg_strecode()

/** Exercise the flag lookup against a sample of street names **/

data streets;
  length stname $ 12;
  infile datalines truncover;
  input stname $char12.;
  flag = put( stname, $dcg_strecode. );
datalines;
NORTH
EAST
FOREST
CANAL ROAD
VALLEY
MASSACHUSETTS
WISCONSIN
N
;
run;

proc print data=streets;
  var stname flag;
run;

proc freq data=streets;
  tables flag / missing;
run;
