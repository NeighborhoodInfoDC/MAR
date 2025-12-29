/**************************************************************************
 Program:  F_marvalidquadrant.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/24/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create format $marvalidquadrante.

 Modifications:
**************************************************************************/


/** Macro F_marvalidquadrant - Start Definition **/

%macro F_marvalidquadrant(  );

  proc format;
    value $marvalidquadrant (default=40)
      "NE" = "NE"
      "NW" = "NW"
      "SE" = "SE"
      "SW" = "SW"
      other = " ";
  run;

%mend F_marvalidquadrant;

/** End Macro Definition **/

