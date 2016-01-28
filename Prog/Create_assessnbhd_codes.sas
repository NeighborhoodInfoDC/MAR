/**************************************************************************
 Program:  Create_assessnbhd_codes.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/27/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create assessment neighorhood codes from MAR data.

 Modifications:
**************************************************************************/

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

proc summary data=Mar.Address_points_2016_01 nway;
  class assessment_nbhd;
  output out=A;
run;

data B;

  set A;
  
  length Code $ 3 assessnbhd_xfer $ 80;
  
  retain NCode 10;
  
  Code = put( Ncode, z3. );
  
  assessnbhd_xfer = upcase( compress( assessment_nbhd, ' .-/' ) );
  
  Ncode + 10;
  
  drop Ncode;
  
run;

%Data_to_format(
  FmtLib=MAR,
  FmtName=$marassessnbhd,
  Desc="Assessment neighborhood",
  Data=B,
  Value=Code,
  Label=assessment_nbhd,
  OtherLabel=,
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=Y,
  Contents=N
  )

%Data_to_format(
  FmtLib=MAR,
  FmtName=$martext_to_assessnbhd,
  Desc="Convert text to assessment neighborhood code",
  Data=B,
  Value=assessnbhd_xfer,
  Label=Code,
  OtherLabel=' ',
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=Y,
  Contents=Y
  )

