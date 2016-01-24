/**************************************************************************
 Program:  Streets.sas
 Library:  MAR
 Project:  NeigborhoodInfo DC
 Author:   P. Tatian
 Created:  1/24/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)

 Description:  Create data set with list of unique DC street names.
               Create format $MARSTVALID for validating street names.

 Modifications:
  01/24/16 PAT Adapted from RealProp program Streets.sas.
**************************************************************************/

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

*options obs=100;

data Streets;

  infile "C:\DCData\Libraries\MAR\Raw\ValidStreets - 20141013.txt" dsd stopover;

  length ustreetname $ 200;

  input ustreetname;

run;

proc sort
  data=Streets
  nodupkey;
  by ustreetname;

run;

%File_info( data=Streets, printobs=40, stats= );

** Create $STVALID format for validating street names **;

%Data_to_format(
  FmtLib=MAR,
  FmtName=$marstvalid,
  Data=Streets,
  Value=ustreetname,
  Label=ustreetname,
  OtherLabel=" ",
  Print=N,
  Desc="MAR geocoding/valid street names",
  Contents=Y
)

run;

