/**************************************************************************
 Program:  Address_points_yyyy_mm.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  11/2/2024
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  68
 
 Description:  Read address_points data set.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )


%Read_address_points_2024( filedate='02nov2024'd ) /* Filedate should be in the SASdate format such as '01jan2017'd */

