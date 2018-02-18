/**************************************************************************
 Program:  Address_points_yyyy_mm.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   []
 Created:  []
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read address_points data set.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )


%Read_address_points( filedate='ddmmmyyyy'd ) /* Filedate should be in the SASdate format such as '01jan2017'd */

