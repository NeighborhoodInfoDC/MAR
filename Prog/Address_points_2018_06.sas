/**************************************************************************
 Program:  Address_points_2018_06.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  06/06/2018
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read address_points data set.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )


%Read_address_points( filedate='06jun2018'd ) /* Filedate should be in the SASdate format such as '01jan2017'd */

