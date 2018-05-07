/**************************************************************************
 Program:  Address_points_yyyy_mm.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   Wilton Oliver
 Created:  05/07/2018
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read address_points data set.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )


%Read_address_points( filedate='07may2018'd ) /* Filedate should be in the SASdate format such as '01jan2017'd */

