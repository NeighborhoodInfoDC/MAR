/**************************************************************************
 Program:  F_dcg_strecode.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  12/19/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  
 
 Description:  Create format $dcg_strecode for temporary recoding of street
 names that Proc Geocode has trouble matching.


 Modifications:
**************************************************************************/

/** Macro F_dcg_strecode - Start Definition **/

%macro F_dcg_strecode(  );

  %** Enter street names in ALL CAPS **;

  proc format;
    value $dcg_strecode (default=40)
      'E', 'N', 'S', 'W',
      'NORTH', 'SOUTH', 'EAST', 'WEST', 
      'WEST LANE', 'EAST BEACH', 'WEST BEACH', 
      'FOREST', 'FALLS', 'ORCHARD', 'VALLEY', 'CANAL ROAD'
      = 'YES'
      other = ' ';
  run;  

%mend F_dcg_strecode;

/** End Macro Definition **/

