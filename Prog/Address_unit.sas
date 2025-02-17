/**************************************************************************
 Program:  Address_unit.sas
 Library:  MAR
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/19/10
 Version:  SAS 9.1
 Environment:  Local Windows session (desktop)
 
 Description:  Read data for Address_unit data set from CSV file.

 Modifications:
  09/27/14 PAT Updated for SAS1.
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR, local=n )

filename csvFile "&_dcdata_r_path\MAR\Raw\2025-02-17\Address_Residential_Units.csv" lrecl=1000;

data Address_unit;

  infile csvFile dsd stopover firstobs=2 /*OBS=101*/;

  input
    Unit_Id
    Full_Address : $80.
    Primary_Address : $80.
    Unit_Number : $12.
    Condo_Ssl : $17.
    Condo_Square : $8.
    Condo_Suffix : $8.
    Condo_Lot : $8.
    Condo_Book : $8.
    Condo_Page : $8.
    Address_id 
    x_Unit_type : $16.
    x_Status : $16.
    Metadata_Id
    Otr_Premiseadd : $80.
    Otr_Unitnumber : $12.
    Before_Date : $40.
    Before_Date_Source : $40.
    Begin_Date : $40.
    Begin_Date_Source : $40.
    First_Known_Date : $40.
    First_Known_Date_Source : $40.
    Created_Date : $40.
    Created_User : $40.
    Last_Edited_Date : $40.
    Last_Edited_User : $40.
    Objectid
    ;
      
  length Status Unit_type $ 1;
  
  select ( upcase( x_Status ) );
    when ( 'ACTIVE' ) Status = 'A';
    when ( 'ASSIGNED' ) Status = 'S';
    when ( 'RECOMMENDED' ) Status = '1';
    when ( 'RETIRE' ) Status = '2';
    otherwise do;
      %warn_put( msg="Uknown Status code: " _n_= address_id= x_Status= )
    end;
  end;
  
  select ( upcase( x_Unit_type ) );
    when ( 'CONDO' ) Unit_type = 'C';
    when ( 'RENTAL' ) Unit_type = 'R';
    when ( 'NON CONDO' ) Unit_type = 'N';
    otherwise do;
      %warn_put( msg="Uknown Unit_type code: " _n_= address_id= x_Unit_type= )
    end;
  end;
  
  format Status $status. Unit_type $marunittyp.;
  
  label
    Address_id = "MAR address ID no. [MAR_ID]"
    Full_address = "Full street address (without unit)"
    Metadata_id = "Metadata ID no."
    Condo_Ssl = "Property Identification Number (Square/Suffix/Lot) for condo units"
    Status = "Address status"
    Unit_id = "Unit ID no."
    Unit_number = "Unit"
    Unit_type = "Type of unit"
/*
    Condo_bk = 
    Condo_pg = 
*/
    ;

  drop x_: ;
  
run;

%Finalize_data_set( 
  /** Finalize data set parameters **/
  data=Address_unit,
  out=Address_unit,
  outlib=MAR,
  label="MAR residential unit list",
  sortby=address_id condo_ssl,
  /** Metadata parameters **/
  revisions=%str(Update with latest data downloaded 2/17/2025.),
  /** File info parameters **/
  contents=Y,
  printobs=10,
  printchar=N,
  printvars=,
  freqvars=status unit_type,
  stats=n sum mean stddev min max
)

