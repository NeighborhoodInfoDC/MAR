/**************************************************************************
 Program:  F_marvalidsttyp.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/24/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create format $marvalidsttype. that defines valid
 street type names.

 Modifications:
**************************************************************************/

/** Macro F_marvalidsttyp - Start Definition **/

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
      "PLACE" = "PLACE"
      "ROAD" = "ROAD"
      "SQUARE" = "SQUARE"
      "STREET" = "STREET"
      "TERRACE" = "TERRACE"
      "WALK" = "WALK"
      "WAY" = "WAY"
      other = " ";
  run;

%mend F_marvalidsttyp;

/** End Macro Definition **/

