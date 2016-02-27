/**************************************************************************
 Program:  Add_stdaddr_std.sas
 Library:  MAR
 Project:  NeigborhoodInfo DC
 Author:   P. Tatian (with code from B. Bajaj)
 Created:  1/24/16
 Version:  SAS 9.2
 
 Description:  Autocall macro to add standardized address variable to 
               geocoding data set.

 Modifications:
  01/24/16 PAT Adapted from RealProp macro %Add_staddr_std().
**************************************************************************/

%macro add_staddr_std( inds=_dcg_indat, outds=_dcg_indat, staddr_std=&staddr._std );

  data &outds;

    set &inds;

    length &staddr._std $ 80;

    ** Check for valid street names **;

    if put( _dcg_adr_streetname_clean, &stvalidfmt.. ) = " " then do;
      &staddr._std = "";
    end;
    else do;

      &staddr._std = left( compbl( 
                       trim( _dcg_adr_begnum ) || " " || 
                       trim( _dcg_adr_numsuffix ) || " " ||
                       trim( _dcg_adr_streetname_clean ) || " " ||
                       trim( _dcg_adr_streettype ) || " " ||
                       trim( _dcg_adr_quad ) || " " ||
                       trim( _dcg_adr_apt )
                     ) );

/**********
      if _dcg_adr_apt_unit ~= "" then do;

        i = 1;
        _dcg_adr_apt_unit_nopad = _dcg_adr_apt_unit;

        do while ( substr( _dcg_adr_apt_unit_nopad, i, 1 ) = '0' );
          substr( _dcg_adr_apt_unit_nopad, i, 1 ) = ' ';
          i = i + 1;
        end;

        &staddr._std = trim( &staddr._std ) || ' APT ' || left( _dcg_adr_apt_unit_nopad );

      end;
*****************/

      &staddr._std = left( compbl( &staddr._std ) );
                     
    end;

    label &staddr._std = "&staddr_lbl (standardized by %nrstr(%DC_Geocode))";

    drop i;

  run;

%mend add_staddr_std;

