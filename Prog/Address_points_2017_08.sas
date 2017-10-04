/**************************************************************************
 Program:  Address_points_2017_08.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   I Mull
 Created:  08/24/2017
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read address_points data set.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )


%Read_address_points( filedate='24aug2017'd ) /* Filedate should be in the SASdate format such as '01jan2017'd */

