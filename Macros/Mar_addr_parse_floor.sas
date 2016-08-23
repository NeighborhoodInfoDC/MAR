/**************************************************************************
 Program:  Mar_addr_parse_floor.sas
 Library:  MAR
 Project:  NeigborhoodInfo DC
 Author:   P. Tatian (with code from B. Bajaj)
 Created:  1/24/16
 Version:  SAS 9.2
 
 Description:  Autocall macro used by %Mar_address_parse() macro to
 process floor specifications.

 Modifications:
  01/24/16 PAT Adapted from RealProp macro %Addr_parse_floor().
**************************************************************************/

%macro Mar_addr_parse_floor(num);

	 if i_&num.fl = 1 then
	  do;
		 _ap_temp_ad = substr(_ap_temp_ad, indexc(_ap_temp_ad," ")+1);
	  end;
	 else if i_&num.fl > 1 then
	  do;
		 _ap_temp_ad = trim(left( substr(_ap_temp_ad, 1, i_&num.fl-1) )); **first part of address (w/o fl);
	  end;
	  
%mend Mar_addr_parse_floor;

