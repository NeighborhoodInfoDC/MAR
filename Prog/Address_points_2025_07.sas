/**************************************************************************
 Program:  Address_points_2025_07.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   Rob Pitingolo
 Created:  7/7/2025
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read address_points data set.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )


%Read_address_points_2024( filedate='07jul2025'd, revisions=%str(Restore addrnum var.) ) /* Filedate should be in the SASdate format such as '01jan2017'd */

