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

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR, local=n )

filename csvFile "&_dcdata_r_path\MAR\Raw\2013-09-11\VW_ADDRESS_UNIT.txt" lrecl=1000;

data Address_unit;

  infile csvFile dsd stopover firstobs=2 /*OBS=101*/;

  input
    Unit_id
    Address_id
    Fulladdress : $80.
    Ssl : $17.
    x_Status : $15.
    Unitnum : $8.
    x_Unittype : $10.
    Condo_bk 
    Condo_pg
    Metadata_id
  ;
  
  length Status Unittype $ 1;
  
  select ( upcase( x_Status ) );
    when ( 'ACTIVE' ) Status = 'A';
    when ( 'ASSIGNED' ) Status = 'S';
    when ( 'RECOMMENDED' ) Status = '1';
    when ( 'RETIRE' ) Status = '2';
    otherwise do;
      %warn_put( msg="Uknown Status code: " _n_= address_id= x_Status= )
    end;
  end;
  
  select ( upcase( x_Unittype ) );
    when ( 'CONDO' ) Unittype = 'C';
    when ( 'RENTAL' ) Unittype = 'R';
    otherwise do;
      %warn_put( msg="Uknown Unittype code: " _n_= address_id= x_Unittype= )
    end;
  end;
  
  format Status $status. Unittype $unittyp.;
  
  label
    Address_id = "Address ID no."
    Fulladdress = "Full street address (without unit)"
    Metadata_id = "Metadata ID no."
    Ssl = "Property Identification Number (Square/Suffix/Lot)"
    Status = "Address status"
    Unit_id = "Unit ID no."
    Unitnum = "Unit"
    Unittype = "Type of unit"
/*
    Condo_bk = 
    Condo_pg = 
*/
    ;

  drop x_: ;
  
run;

proc sort data=Address_unit out=Mar.Address_unit (label="DC MAR address-unit list");
  by address_id ssl unitnum;

%Dup_check(
  data=Mar.Address_unit,
  by=address_id ssl unitnum,
  id=fulladdress unit_id,
  out=_dup_check,
  listdups=Y
)

%File_info( data=Mar.Address_unit, freqvars=status unittype )

%Dup_check(
  data=Mar.Address_unit,
  by=unit_id,
  id=address_id unittype fulladdress unitnum ssl,
  out=_dup_check,
  listdups=Y,
  count=dup_check_count,
  quiet=N,
  debug=N
)



/*
proc print data=Mar.Address_unit;
  where address_id = 223259;
  id address_id;
run;
