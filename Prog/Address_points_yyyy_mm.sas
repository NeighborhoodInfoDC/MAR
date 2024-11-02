/**************************************************************************
 Program:  Address_points_yyyy_mm.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   
 Created:  
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  
 
 Description:  Read address_points data set.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )


%Read_address_points( filedate='ddmmmyyyy'd ) /* Filedate should be in the SASdate format such as '01jan2017'd */

