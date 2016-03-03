/**************************************************************************
 Program:  StreetAlt.sas
 Library:  MAR
 Project:  NeigborhoodInfo DC
 Author:   P. Tatian (with code from B. Bajaj)
 Created:  1/24/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)

 Description:  Create $maraltstname format with alternate street spellings
               (i.e., corrections) for parcel geocoding.
               
 NB:  The file L:\Libraries\MAR\Prog\Geocode\StreetAlt.xls
      must be open before running this program.
      
 NB:  Do NOT make changes to this program without asking Peter Tatian first.

 Modifications:
  01/24/16 PAT Adapted from RealProp StreetAlt().
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

/*filename xin dde "excel|&_dcdata_r_path\MAR\Prog\[StreetAlt.xls]StreetAlt!r6c1:r5000c2" lrecl=256 notab;*/
filename xin "&_dcdata_r_path\MAR\Prog\StreetAlt.csv" lrecl=256;


data StreetAlt;

  length streetname altname $ 50;
  
  infile xin missover dsd firstobs=6;

  input altname streetname;

  streetname = left( compbl( upcase( streetname ) ) );
  altname = left( compbl( upcase( altname ) ) );
  
  if altname = '' or streetname = '' then delete;

run;

** Check for conflicting entries of alternate street spellings and
** invalid correct street names;

proc sort data=StreetAlt nodupkey;
  by altname streetname;

data _null_;

  set StreetAlt;
  by altname;

  if not last.altname then do;
    %err_put( msg="Conflicting entries for incorrect spelling of " altname " in StreetAlt.xls." )
    %err_put( msg="Alternate street name spelling list NOT updated." )
    %err_put( msg="Please edit StreetAlt.xls and rerun this program." )
    abort return;
  end;
  
  if put( streetname, $marvalidstnm. ) = " " then do;
    %err_put( msg="Invalid entry for correct spelling of " streetname " in StreetAlt.xls." )
    %err_put( msg="Correct street name spelling must match listing in ValidStreets.txt." )
    %err_put( msg="Alternate street name spellings NOT updated." )
    %err_put( msg="Please edit StreetAlt.xls and rerun this program." )
    abort return;
  end;

  if put( altname, $marvalidstnm. ) ~= " " then do;
    %warn_put( msg="A valid street name cannot be used as an incorrect spelling: " altname " to " streetname )
    %warn_put( msg="This entry will be deleted." )
    delete;
  end;

run;

** Create $MARSTRTALT format for correcting street names **;

%Data_to_format(
  FmtLib=MAR,
  FmtName=$maraltstname,
  Data=StreetAlt,
  Value=altname,
  Label=streetname,
  DefaultLen=40,
  Desc="MAR geocoding/alt. street name spellings",
  print=Y,
  Contents=Y
)

run;



