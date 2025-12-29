/**************************************************************************
 Program:  F_marvalidunit.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/27/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create format $marvalidunit.

 Modifications:
**************************************************************************/

/** Macro F_marvalidunit - Start Definition **/

%macro F_marvalidunit(  );

  proc format;
    value $marvalidunit (default=40)
      "UNIT" = "UNIT"
      other = " ";
  run;

%mend F_marvalidunit;

/** End Macro Definition **/

