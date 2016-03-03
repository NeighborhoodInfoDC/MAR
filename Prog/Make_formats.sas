/**************************************************************************
 Program:  Make_formats.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/26/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create MAR formats.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

proc format library=MAR;

  value $maraddrtyp
    'A' = 'Address'
    'P' = 'Place';
    
  value $marstatus
    'A' = 'Active'
    'S' = 'Assigned'
    'R' = 'Retire'
    'T' = 'Temporary';
    
  value $marrestyp
    'M' = 'Mixed use'
    'N' = 'Nonresidential'
    'R' = 'Residential';
    
  value $marentrtyp
    'O' = 'Official';
    
run;

proc catalog catalog=MAR.Formats;
  modify maraddrtyp (desc="MAR address type") / entrytype=formatc;
  modify marstatus (desc="MAR address status") / entrytype=formatc;
  modify marrestyp (desc="MAR residential type") / entrytype=formatc;
  modify marentrtyp (desc="MAR entrance type") / entrytype=formatc;

  contents;
quit;

