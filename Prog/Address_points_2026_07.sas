/**************************************************************************
 Program:  Address_points_2026_07.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  07/10/2026
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue: 106
 
 Description: Read address_points data set.

 Modifications:
**************************************************************************/

%include "F:\DCDATA\SAS\Inc\StdRemote.sas";

** Define libraries **;
%DCData_lib( MAR )


%Read_address_points_2024( filedate='10jul2026'd ) /* Filedate should be in the SASdate format such as '01jan2017'd */

