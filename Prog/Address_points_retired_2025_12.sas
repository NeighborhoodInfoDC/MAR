/**************************************************************************
 Program:  Address_points_retired_2025_12.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  12/30/2025
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue: 93
 
 Description:  Read Address_points_retired data set.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )


%Read_address_points_retired( filedate='30dec2025'd ) /* Filedate should be in the SASdate format such as '01jan2017'd */

