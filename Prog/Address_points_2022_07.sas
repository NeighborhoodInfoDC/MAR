/**************************************************************************
 Program:  Address_points_2022_07.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   Elizabeth Burton
 Created:  07/01/2022
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read address_points data set.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )


%Read_address_points( filedate='01jul2022'd ) /* Filedate should be in the SASdate format such as '01jan2017'd */

