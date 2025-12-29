/**************************************************************************
 Program:  F_maraltunit.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/27/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create format $maraltunit. for converting alternate
 unit spellings.

 Modifications:
**************************************************************************/

/** Macro F_maraltunit - Start Definition **/

%macro F_maraltunit(  );

  proc format;
    value $maraltunit (default=40)
      
      "APARTAMENTO" = "UNIT"
      "APARTAMENTOS" = "UNIT"
      "APARTMENT" = "UNIT"
      "APMNT" = "UNIT"
      "APMT" = "UNIT"
      "APRT" = "UNIT"
      "APRTMNT" = "UNIT"
      "APT" = "UNIT"
      "UNIT" = "UNIT"

      "APARTMENTNO" = "UNIT"
      "APMNTNO" = "UNIT"
      "APMTNO" = "UNIT"
      "APRTNO" = "UNIT"
      "APRTMNTNO" = "UNIT"
      "APTNO" = "UNIT"
      "UNITNO" = "UNIT"

      "APARTMENTNUM" = "UNIT"
      "APMNTNUM" = "UNIT"
      "APMTNUM" = "UNIT"
      "APRTNUM" = "UNIT"
      "APRTMNTNUM" = "UNIT"
      "APTNUM" = "UNIT"
      "UNITNUM" = "UNIT"
      
      "#" = "UNIT"
      "NO" = "UNIT"
      "NUM" = "UNIT"
      "NUMBER" = "UNIT"
      "NUMBR" = "UNIT"
      "NMBER" = "UNIT"

      "SUITE" = "UNIT"
      "STE" = "UNIT"
    ;
  run;

%mend F_maraltunit;

/** End Macro Definition **/


