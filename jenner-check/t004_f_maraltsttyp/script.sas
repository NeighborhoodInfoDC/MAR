/**************************************************************************
 Jenner compatibility bundle for: Macros/F_maraltsttyp.sas
 Upstream library: MAR (DC Master Address Repository), NeighborhoodInfo DC.

 The %F_maraltsttyp() macro defines the $maraltsttyp. format, a large
 lookup that normalizes the many alternate and misspelled street-type
 spellings seen in raw address data (AV/AVE/AVEN/AVENU -> AVENUE, BLVD/
 BOUL/BVLD -> BOULEVARD, and so on) to a canonical street type. This
 bundle defines the macro verbatim, invokes it, and runs a sample of
 alternate spellings through it so the full lookup is exercised.
**************************************************************************/

/** Macro F_maraltsttyp - definition copied verbatim from upstream **/

%macro F_maraltsttyp(  );

  proc format;
    value $maraltsttyp (default=40)
      "ALLEE" = "ALLEY"
      "ALLEY" = "ALLEY"
      "ALLY" = "ALLEY"
      "ALY" = "ALLEY"
      "AENUE" = "AVENUE"
      "AV" = "AVENUE"
      "AVE" = "AVENUE"
      "AVEN" = "AVENUE"
      "AVENU" = "AVENUE"
      "AVENUE" = "AVENUE"
      "AVENUES" = "AVENUE"
      "AVERNUE" = "AVENUE"
      "AVEUE" = "AVENUE"
      "AVN" = "AVENUE"
      "AVNEUE" = "AVENUE"
      "AVNUE" = "AVENUE"
      "BLVD" = "BOULEVARD"
      "BOUL" = "BOULEVARD"
      "BOULEVARD" = "BOULEVARD"
      "BOULV" = "BOULEVARD"
      "BUOLEVARD" = "BOULEVARD"
      "BVLD" = "BOULEVARD"
      "BRDGE" = "BRIDGE"
      "BRG" = "BRIDGE"
      "BRIDGE" = "BRIDGE"
      "CIR" = "CIRCLE"
      "CIRC" = "CIRCLE"
      "CIRCL" = "CIRCLE"
      "CIRCLE" = "CIRCLE"
      "CR" = "CIRCLE"
      "CRCL" = "CIRCLE"
      "CRCLE" = "CIRCLE"
      "COURT" = "COURT"
      "COURTS" = "COURT"
      "CRT" = "COURT"
      "CT" = "COURT"
      "CRECENT" = "CRESCENT"
      "CRES" = "CRESCENT"
      "CRESCENT" = "CRESCENT"
      "CRESENT" = "CRESCENT"
      "CRSCNT" = "CRESCENT"
      "CRSENT" = "CRESCENT"
      "CRSNT" = "CRESCENT"
      "DR" = "DRIVE"
      "DRI" = "DRIVE"
      "DRIV" = "DRIVE"
      "DRIVE" = "DRIVE"
      "DRV" = "DRIVE"
      "ENT",
      "ENTR",
      "ENTRA",
      "ENTRAN",
      "ENTRANC",
      "ENTRANCE" = "ENTRANCE"
      "EXP" = "EXPRESSWAY"
      "EXPR" = "EXPRESSWAY"
      "EXPRESS" = "EXPRESSWAY"
      "EXPRESSWAY" = "EXPRESSWAY"
      "EXPW" = "EXPRESSWAY"
      "EXPY" = "EXPRESSWAY"
      "GREEN" = "GREEN"
      "GRN" = "GREEN"
      "INTERSTATE" = "INTERSTATE"
      "KEYS" = "KEYS"
      "KYS" = "KEYS"
      "LA" = "LANE"
      "LANE" = "LANE"
      "LANES" = "LANE"
      "LN" = "LANE"
      "LOOP" = "LOOP"
      "LOOPS" = "LOOP"
      "MEWS" = "MEWS"
      "PARKWAY" = "PARKWAY"
      "PARKWY" = "PARKWAY"
      "PKW" = "PARKWAY"
      "PKWAY" = "PARKWAY"
      "PKWY" = "PARKWAY"
      "PKY" = "PARKWAY"
      "PRKWAY" = "PARKWAY"
      "PRKWY" = "PARKWAY"
      "PIER" = "PIER"
      "PL" = "PLACE"
      "PLA" = "PLACE"
      "PLAC" = "PLACE"
      "PLACE" = "PLACE"
      "PLC" = "PLACE"
      "PLAZA" = "PLAZA"
      "PLZ" = "PLAZA"
      "PLZA" = "PLAZA"
      "PROMENADE" = "PROMENADE"
      "RD" = "ROAD"
      "ROAD" = "ROAD"
      "ROADS" = "ROAD"
      "SQ" = "SQUARE"
      "SQR" = "SQUARE"
      "SQRE" = "SQUARE"
      "SQU" = "SQUARE"
      "SQUARE" = "SQUARE"
      "DTREET" = "STREET"
      "SREET" = "STREET"
      "SSTREET" = "STREET"
      "ST" = "STREET"
      "STEET" = "STREET"
      "STR" = "STREET"
      "STRE" = "STREET"
      "STREE" = "STREET"
      "STREEET" = "STREET"
      "STREET" = "STREET"
      "STREETS" = "STREET"
      "STRET" = "STREET"
      "STRETT" = "STREET"
      "STRRE" = "STREET"
      "STRT" = "STREET"
      "TREET" = "STREET"
      "TEARRACE" = "TERRACE"
      "TER" = "TERRACE"
      "TERACE" = "TERRACE"
      "TERR" = "TERRACE"
      "TERRA" = "TERRACE"
      "TERRAC" = "TERRACE"
      "TERRACE" = "TERRACE"
      "TERRANCE" = "TERRACE"
      "TR" = "TERRACE"
      "WALK" = "WALK"
      "WAY" = "WAY"
      "WY" = "WAY"
    ;
  run;

%mend F_maraltsttyp;

/** Invoke the macro to create the format **/

%F_maraltsttyp()

/** Exercise normalization against a sample of alternate spellings **/

data sttypes;
  length raw $ 12;
  input raw $;
  normalized = put( raw, $maraltsttyp. );
datalines;
AVE
AVEN
AVENU
BLVD
BOUL
DR
DRV
CT
CRT
PL
RD
ST
STR
TER
TERR
WY
;
run;

proc print data=sttypes;
  var raw normalized;
run;

proc freq data=sttypes;
  tables normalized;
run;
