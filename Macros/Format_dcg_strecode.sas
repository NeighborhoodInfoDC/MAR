/**************************************************************************
 Program:  Format_dcg_strecode.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  12/19/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  
 
 Description:  Create format for temporary recoding of street
 names that Proc Geocode has trouble matching.


 Modifications:
**************************************************************************/

/** Macro Format_dcg_strecode - Start Definition **/

%macro Format_dcg_strecode(  );

  proc format;
    value $_dcg_strecode (default=40)
      'E', 'N', 'S', 'W',
      'NORTH', 'SOUTH', 'EAST', 'WEST', 
      'WEST LANE', 'EAST BEACH', 'WEST BEACH', 
      'FOREST', 'FALLS'
      = 'YES'
      other = ' ';
  run;  

%mend Format_dcg_strecode;

/** End Macro Definition **/

