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
  
  pad1 = '';
  &var_prefix.apt = '';

  _ap_i = 1;
  wrd1 = scan( pad, _ap_i, ' ' );
  
  do while ( wrd1 ~= '' );
  
    ** Check for letters followed by numbers and split into separate words;
    ** EX: APT12;
    
    if indexc( wrd1, '0123456789#' ) > 1 then do;
      wrd2 = compress( substr( wrd1, indexc( wrd1, '0123456789#' ) ), '#' );
      wrd1 = substr( wrd1, 1, indexc( wrd1, '0123456789#' ) - 1 );
      wrd3 = scan( pad, _ap_i + 1, ' ' );
      i_wrd2 = _ap_i;
      i_wrd3 = _ap_i + 1;
    end;
    else do;
      wrd2 = scan( pad, _ap_i + 1, ' ' );
      i_wrd2 = _ap_i + 1;
      if indexc( wrd2, '0123456789#' ) > 1 then do;
        wrd3 = compress( substr( wrd2, indexc( wrd2, '0123456789#' ) ), '#' );
        wrd2 = substr( wrd2, 1, indexc( wrd2, '0123456789#' ) - 1 );
        i_wrd3 = _ap_i + 1;
      end;
      else do;
        wrd3 = scan( pad, _ap_i + 2, ' ' );
        i_wrd3 = _ap_i + 2;
      end;
    end;
    
    %if %mparam_is_yes( &debug ) %then %do;
      put _ap_i= wrd1= wrd2= wrd3= pad1= &var_prefix.apt=;
    %end;
    
   if put( put( wrd1, $maraltunit. ), $marvalidunit. ) ~= '' then do;
    
      ** WRD1 is a unit identifier;
      
      if wrd2 in ( 'NO', 'NUM', 'NUMBER', 'NMBR', 'NMBER', '#' ) then do;
        %Mar_addr_parse_remv_lead_zero( wrd3 )
        &var_prefix.apt = trim( put( put( wrd1, $maraltunit. ), $marvalidunit. ) ) || ' ' || wrd3;
        _ap_i = i_wrd3;
      end;
      else do;
        %Mar_addr_parse_remv_lead_zero( wrd2 )
        &var_prefix.apt = trim( put( put( wrd1, $maraltunit. ), $marvalidunit. ) ) || ' ' || wrd2;
        _ap_i = i_wrd2;
      end;
             
    end;
    else if put( put( wrd2, $maraltunit. ), $marvalidunit. ) ~= '' or put( put( wrd3, $maraltunit. ), $marvalidunit. ) ~= '' then do;
    
      ** Unit identifier found in WRD2 or WRD3: Defer processing until later iteration;
      
      pad1 = trim( pad1 ) || ' ' || wrd1;

    end;
    else if &var_prefix.apt = '' and put( wrd1, $marvalidquadrant. ) ~= '' and wrd2 ~= '' and put( put( wrd2, $maraltunit. ), $marvalidunit. ) = '' then do;
  
    ** WRD1 is a quadrant but WRD2 is not a unit identifier: assume what follows is unit number;
      
      if wrd2 in ( 'NO', 'NUM', 'NUMBER', 'NMBR', 'NMBER', '#' ) then do;
        %Mar_addr_parse_remv_lead_zero( wrd3 )
        &var_prefix.apt = 'APT ' || wrd3;
        pad1 = trim( pad1 ) || ' ' || wrd1;
        _ap_i = i_wrd3;
      end;
      else do;
        %Mar_addr_parse_remv_lead_zero( wrd2 )
        &var_prefix.apt = 'APT ' || wrd2;
        pad1 = trim( pad1 ) || ' ' || wrd1;
        _ap_i = i_wrd2;
      end;
      
    end;
    else if &var_prefix.apt = '' and put( put( wrd1, $maraltsttyp. ), $marvalidsttyp. ) ~= '' and (
      ( wrd3 ~= '' and put( wrd2, $marvalidquadrant. ) = '' and put( put( wrd3, $maraltunit. ), $marvalidunit. ) = '' ) or
      ( wrd3 = '' and wrd2 ~= '' and put( wrd2, $marvalidquadrant. ) = '' ) )      
      then do;
  
    ** WRD1 is a street type but WRD2 is not a quadrant and WRD3 is not a unit identifier: 
    ** assume what follows WRD1 is unit number;
      
      if wrd2 in ( 'NO', 'NUM', 'NUMBER', 'NMBR', 'NMBER', '#' ) then do;
        %Mar_addr_parse_remv_lead_zero( wrd3 )
        &var_prefix.apt = 'APT ' || wrd3;
        pad1 = trim( pad1 ) || ' ' || wrd1;
        _ap_i = i_wrd3;
      end;
      else do;
        %Mar_addr_parse_remv_lead_zero( wrd2 )
        &var_prefix.apt = 'APT ' || wrd2;
        pad1 = trim( pad1 ) || ' ' || wrd1;
        _ap_i = i_wrd2;
      end;
      
    end;
    else do;
    
      pad1 = trim( pad1 ) || ' ' || wrd1;
      
    end;
    
    _ap_i = _ap_i + 1;
    wrd1 = scan( pad, _ap_i, ' ' );

  end;
  
  pad = left( compbl( pad1 ) );

  %if %mparam_is_yes( &debug ) %then %do;
    put "Mar_addr_parse_unit: END: " pad= &var_prefix.apt=;
  %end;
  
%mend Mar_addr_parse_unit;

