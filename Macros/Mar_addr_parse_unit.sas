/**************************************************************************
 Program:  Mar_addr_parse_unit.sas
 Library:  MAR
 Project:  NeigborhoodInfo DC
 Author:   P. Tatian (with code from B. Bajaj)
 Created:  1/24/16
 Version:  SAS 9.2

 Description:  Autocall macro used by %Mar_address_parse() macro to
 process apartment or unit specifications.

 Modifications: 
  01/24/16 PAT Adapted from RealProp macro %Addr_parse_unit().
  02/28/16 PAT Rewritten to use a new approach.
**************************************************************************/

%macro Mar_addr_parse_unit(debug=N);

  %if %mparam_is_yes( &debug ) %then %do;
    put "Mar_addr_parse_unit: START: " pad=;
  %end;
  
  &var_prefix.apt = '';

  wrd0 = scan( pad, -1, ' ' );
  
  do while ( wrd0 ~= '' );
  
    %if %mparam_is_yes( &debug ) %then %do;
      put pad= wrd0= &var_prefix.apt=;
    %end;
  
    if put( put( pad, $maraltstname. ), $marvalidstnm. ) ~= '' then do;
    
      ** Remaining part of PAD is a valid street name **;
      
      if &var_prefix.apt ~= '' then       
        &var_prefix.apt = 'UNIT' || ' ' || &var_prefix.apt;
      
      leave;
            
    end; 
    if put( put( wrd0, $maraltunit. ), $marvalidunit. ) ~= '' then do;
    
      ** WRD0 is a unit identifier;
     
      &var_prefix.apt = trim( put( wrd0, $maraltunit. ) ) || ' ' || &var_prefix.apt;

      pad = trim( substr( pad, 1, length( pad ) - length( wrd0 ) ) );
      
      leave;
     
    end;
    else if 
      put( put( wrd0, $maraltquadrant. ), $marvalidquadrant. ) ~= '' or
      put( put( wrd0, $maraltsttyp. ), $marvalidsttyp. ) ~= '' 
      then do;
    
      ** WRD0 is a quandrant or street type **;
      
      if &var_prefix.apt ~= '' then       
        &var_prefix.apt = 'UNIT' || ' ' || &var_prefix.apt;
      
      leave;
      
    end;
    else do;
    
      ** WRD0 is part of unit number **;
      
      if length( pad ) > length( wrd0 ) then do;
        ** Still more left to process **;
        pad = trim( substr( pad, 1, length( pad ) - length( wrd0 ) ) );
        %Mar_addr_parse_remv_lead_zero( wrd0 )
        &var_prefix.apt = trim( wrd0 ) || ' ' || &var_prefix.apt;
      end;
      else do;
        ** No unit number was found **;
        pad = trim( pad ) || ' ' || &var_prefix.apt;
        &var_prefix.apt = '';
        leave;
      end;
      
    end;

    wrd0 = scan( pad, -1, ' ' );

  end;
  
  pad = left( compbl( pad ) );

  %if %mparam_is_yes( &debug ) %then %do;
    put "Mar_addr_parse_unit: END: " pad= &var_prefix.apt=;
  %end;

%mend Mar_addr_parse_unit;

