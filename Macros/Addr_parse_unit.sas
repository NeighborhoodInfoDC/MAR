/**************************************************************************
 Program:  Addr_parse_unit.sas
 Library:  MAR
 Project:  NeigborhoodInfo DC
 Author:   P. Tatian (with code from B. Bajaj)
 Created:  1/24/16
 Version:  SAS 9.2

 Description:  Autocall macro used by %Address_parse() macro to
 process apartment or unit specifications.

 Modifications: 
  01/24/16 PAT Adapted from RealProp macro %Addr_parse_unit().
**************************************************************************/

%macro Addr_parse_unit(/*unitlbl,*/debug=N);

  %if %mparam_is_yes( &debug ) %then %do;
    put "Addr_parse_unit: START: " pad=;
  %end;
  
  pad1 = '';

  _ap_i = 1;
  wrd1 = scan( pad, _ap_i, ' ' );
  
  do while ( wrd1 ~= '' );
  
    ** Check for letters followed by numbers and split into separate words;
    ** EX: APT12;
    
    if indexc( wrd1, '0123456789#' ) > 1 then do;
      wrd2 = compress( substr( wrd1, indexc( wrd1, '0123456789#' ) ), '#' );
      wrd1 = substr( wrd1, 1, indexc( wrd1, '0123456789#' ) - 1 );
      wrd3 = scan( pad, _ap_i + 1, ' ' );
      wrd2_i = _ap_i;
      wrd3_i = _ap_i + 1;
    end;
    else do;
      wrd2 = scan( pad, _ap_i + 1, ' ' );
      wrd3 = scan( pad, _ap_i + 2, ' ' );
      wrd2_i = _ap_i + 1;
      wrd3_i = _ap_i + 2;
    end;
    
    PUT _AP_I= WRD1= WRD2= WRD3= PAD1=;
    
   if put( put( wrd1, $maraltunit. ), $marvalidunit. ) ~= '' then do;
    
      ** WRD1 is a unit identifier;
      PUT 'A';
      
      if wrd2 in ( 'NO', 'NUM', 'NUMBER', 'NMBR', 'NMBER', '#' ) then do;
        pad1 = trim( pad1 ) || ' ' || 
               trim( put( put( wrd1, $maraltunit. ), $marvalidunit. ) ) || ' ' ||
               wrd3;
        _ap_i = wrd3_i;
      end;
      else do;
        pad1 = trim( pad1 ) || ' ' || 
               trim( put( put( wrd1, $maraltunit. ), $marvalidunit. ) ) || ' ' ||
               wrd2;
        _ap_i = wrd2_i;
      end;
             
    end;
    else if put( wrd1, $marvalidquadrant. ) ~= '' and put( put( wrd2, $maraltunit. ), $marvalidunit. ) = '' then do;
  
    ** WRD1 is a quadrant but WRD2 is not a unit identifier: assume what follows is unit number;
    PUT 'B';
      
      if wrd2 in ( 'NO', 'NUM', 'NUMBER', 'NMBR', 'NMBER', '#' ) then do;
        pad1 = trim( pad1 ) || ' ' || trim( wrd1 ) || ' APT ' || wrd3;
        _ap_i = wrd3_i;
      end;
      else do;
        pad1 = trim( pad1 ) || ' ' || trim( wrd1 ) || ' APT ' || wrd2;
        _ap_i = wrd2_i;
      end;
      
    end;
    else if put( wrd1, $marvalidsttyp. ) ~= '' and put( wrd2, $marvalidquadrant. ) = '' and put( put( wrd3, $maraltunit. ), $marvalidunit. ) = '' then do;
  
    ** WRD1 is a street type but WRD2 is not a quadrant and WRD3 is not a unit identifier: 
    ** assume what follows WRD1 is unit number;
    PUT 'C';
      
      if wrd2 in ( 'NO', 'NUM', 'NUMBER', 'NMBR', 'NMBER', '#' ) then do;
        pad1 = trim( pad1 ) || ' ' || trim( wrd1 ) || ' APT ' || wrd3;
        _ap_i = wrd3_i;
      end;
      else do;
        pad1 = trim( pad1 ) || ' ' || trim( wrd1 ) || ' APT ' || wrd2;
        _ap_i = wrd2_i;
      end;
      
    end;
    else do;
    
      PUT 'D';
      pad1 = trim( pad1 ) || ' ' || wrd1;
      
    end;
    
    _ap_i = _ap_i + 1;
    wrd1 = scan( pad, _ap_i, ' ' );

  end;
  
  pad = left( compbl( pad1 ) );

  %if %mparam_is_yes( &debug ) %then %do;
    put "Addr_parse_unit: END: " pad=;
  %end;
  
%mend Addr_parse_unit;

