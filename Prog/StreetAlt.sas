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
               
               Permanent format saved in MAR library.
               
 Modifications:
  01/24/16 PAT Adapted from RealProp StreetAlt().
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )


%StreetAlt( infile=&_dcdata_r_path\MAR\Prog\StreetAlt.txt, print=y, lib=mar )

