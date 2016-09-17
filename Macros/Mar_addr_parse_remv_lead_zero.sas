/**************************************************************************
 Program:  Mar_addr_parse_remv_lead_zero.sas
 Library:  MAR
 Project:  NeigborhoodInfo DC
 Author:   P. Tatian
 Created:  9/17/16
 Version:  SAS 9.2
 
 Description:  Autocall macro used by %Mar_addr_parse_unit() macro to
 remove leading zeros from apartment numbers.

 Modifications:
**************************************************************************/

%macro Mar_addr_parse_remv_lead_zero(num);

        ** Remove leading zeros from apt number **;

        &num = left( &num );
        if compress( &num, '0' ) ~= '' then do;
          do while ( &num =: '0' );
            &num = left( substr( &num, 2 ) );
          end;
        end;
	  
%mend Mar_addr_parse_remv_lead_zero;

