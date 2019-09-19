/**************************************************************************
 Program:  Address_points_2019_09.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   Rob Pitingolo
 Created:  05/07/2018
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read address_points data set.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )


%Read_address_points( filedate='19sep2019'd ) /* Filedate should be in the SASdate format such as '01jan2017'd */

