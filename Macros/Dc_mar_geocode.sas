/**************************************************************************
 Program:  DC_mar_geocode.sas
 Library:  MAR
 Project:  NeigborhoodInfo DC
 Author:   P. Tatian (with code from B. Bajaj)
 Created:  1/24/16
 Version:  SAS 9.2
 
 Description:  Autocall macro to geocode DC street addresses to
 MAR database using Proc Geocode.

 Modifications:
  01/24/16 PAT Adapted from RealProp macro %DC_geocode().
******************************************************************************/

/** Macro DC_mar_geocode - Start Definition **/

%macro DC_mar_geocode( 

  data= ,                     /* Input data set */
  id= ,                       /* ID var(s) (opt.) */
  staddr= ,                   /* Street address (char. var.) */
  zip= ,                      /* 5-digit ZIP code (char. var., opt.) */

  out= ,                      /* Output data set */
  ds_label= ,                 /* Output data set label (in quotes, opt.) */

  staddr_std=&staddr._std,      /* Standardized address (blank to omit) */

  geo_match=y,                /* Perform geo. matching with parcels (Y/N) */

  keep_geo=address_id Anc2002 Anc2012 Cluster_tr2000 Geo2000   
           Geo2010 GeoBg2010 GeoBlk2010 Psa2004 Psa2012 
           ssl VoterPre2012 Ward2002 Ward2012 
           Bridgepk Stantoncommons Cluster2017
           Latitude Longitude,  /* List of geo vars to keep in geocoded file */

  dcg_match_score=_score_,  /* Match score */

  match_score_min=35,            /** Minimum score for a match **/

  block_match=Y,              /* Match to blocks if address has no exact parcel match (Y/N) */
  unit_match=y,                /* Perform unit matching with parcels (Y/N) */

  max_near_block_dist=500,    /* Maximum difference between street nos. for near block matches */

  basefile=,                  /* Base file for address matching (if not specified, default files are used) */
  stvalidfmt=$marvalidstnm,        /* Format for validating street names */
  streetalt_file=, /* File containing street name spelling corrections (if omitted, default file is used) */
  stnamenotfound_export=,       /* Name for export file of not found street names */
  punct_list=%str(,.*''""<>;[]{}|_+=^$@!~`%:?),    /* List of punctuation to strip (do not include dash '-') */

  listunmatched=Y,              /* List nonmatching addresses (Y/N, def. Y) */
  quiet=N,                     /* Suppress warning messages (Y/N, def. N) */
  debug=N,                     /* Print debugging information (Y/N, def. N) */
  mprint=N                     /* Print resolved macro code in LOG (Y/N, def. N) */
  
  );

  %local mversion mdate mname geo_valid u_keep_geo i gkw dsid rc;

  %let mversion = 1.4;
  %let mdate = 6/18/18;
  %let mname = DC_mar_geocode;

  %push_option( mprint )

  %if not( %mparam_is_yes( &debug ) ) and %mparam_is_no( &mprint ) %then %do;
    options nomprint;
  %end;
  %else %do;
    options mprint;
  %end;

  %note_mput( macro=&mname, msg=&mname macro version &mversion (&mdate) written by %str(Peter Tatian, Beata Bajaj & David DOrio). )
  %note_mput( macro=&mname, msg=(c) 2018 Urban Institute/Urban-Greater DC - All Rights Reserved. )

  %note_mput( macro=&mname, msg=Starting macro. )

  %**** Check for required parameters ****;

  %if &data = %then %do;
    %err_mput( macro=&mname, msg=The macro parameter data= cannot be blank. )
    %goto exit;
  %end;

  %if &out = %then %do;
    %err_mput( macro=&mname, msg=The macro parameter out= cannot be blank. )
    %goto exit;
  %end;

  %if &staddr = %then %do;
    %err_mput( macro=&mname, msg=The macro parameter staddr= cannot be blank. )
    %goto exit;
  %end;

  %if &dcg_match_score = %then %do;
    %err_mput( macro=&mname, msg=The macro parameter dcg_match_score= cannot be blank. )
    %goto exit;
  %end;

  %**** Check for valid keywords in keep_geo= ****;

  %let geo_valid = /address_id/Anc2002/Anc2012/Cluster_tr2000/
                   /Geo2000/Geo2010/GeoBg2010/GeoBlk2010/Psa2004/Psa2012/
                   /ssl/VoterPre2012/Ward2002/Ward2012/Latitude/Longitude/
                   /Bridgepk/Stantoncommons/Cluster2017/;

  %let geo_valid = %upcase( &geo_valid );
  %let u_keep_geo = %upcase( &keep_geo );

  %let i = 1;
  %let gkw = %scan( &u_keep_geo, &i );

  %do %while ( &gkw ~= );

    %if %index( &geo_valid, /&gkw/ ) = 0 %then %do;
      %err_mput( macro=&mname, msg=Invalid keyword %upcase(&gkw) found in KEEP_GEO= parameter. )
      %goto exit;
    %end;
  
    %let i = %eval( &i + 1 );
    %let gkw = %scan( &u_keep_geo, &i );

  %end;

  %**** Complete any previous run blocks before checking for data set ****;

  run;      

  %**** Check for input data set and get label for street address variable ****;

  %let dsid=%sysfunc(open(&data,i));
  %if &dsid %then %do;
      %let staddr_lbl=%qsysfunc(varlabel(&dsid,%sysfunc(varnum(&dsid,&staddr))));
      %let rc=%sysfunc(close(&dsid));
  %end;
  %else %do;
    %err_mput( macro=&mname, msg=The input data set %upcase(&data) does not exist or could not be opened. )
    %goto exit;
  %end;
  
  
  ** Create format for temporary recoding of street names that match direction abbreviations;
  ** Workaround for Proc Geocode problem matching these streets;
  
  proc format;
    value $_dcg_strecode (default=40)
      'E' = '~E~'
      'N' = '~N~'
      'S' = '~S~'
      'W' = '~W~';
  run;
  

  %if &streetalt_file ~= %then %do;
  
    ** Create format for cleaning street name mispellings **;
    
    %StreetAlt( infile=&streetalt_file )
    
  %end;

  
  ** Read, clean, and parse address data **;

  %note_mput( macro=&mname, msg=Cleaning and parsing address data. )

  data _dcg_parse (compress=no drop=_dcg_blank) _dcg_stnamenotfound (keep=_dcg_adr_streetname_clean _dcg_blank);
  
    set &data;
    
    length _dcg_staddr_std $ 80 _dcg_scrub_addr _dcg_adr_streetname_clean _dcg_adr_geocode $ 500 _dcg_zip 8;
    
    retain _dcg_city 'WASHINGTON' _dcg_st 'DC' _dcg_blank ' ';

    _dcg_zip = .;

    if &staddr = "" then goto _DC_mar_geocode_end;
    
    _dcg_scrub_addr = upcase( left( &staddr ) );
    
    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, "N.W.", "NW " );
    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, "N.E.", "NE " );
    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, "S.W.", "SW " );
    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, "S.E.", "SE " );
    
    ** Strip punctuation **;
     
    _dcg_scrub_addr = 
      left( translate( _dcg_scrub_addr, repeat( " ", length( "&punct_list" ) ),
                       "&punct_list" ) );
    
    ** Remove extra spaces **;
    
    _dcg_scrub_addr = compbl( _dcg_scrub_addr );

    ** Correct space-separated quadrant abbreviations **;

    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, " N W ", " NW " );
    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, " S W ", " SW " );
    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, " N E ", " NE " );
    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, " S E ", " SE " );

    ** Parse address **;

    %Mar_address_parse( address=_dcg_scrub_addr, var_prefix=_dcg_adr_, debug=&debug )    

    if _dcg_adr_street = "" then goto _DC_mar_geocode_end;

    ** Clean street names (apply StreetAlt.xls corrections) **;
    ** Only apply if original street name is not valid        **;

    if put( _dcg_adr_streetname, &stvalidfmt.. ) = " " then do;
      _dcg_adr_streetname_clean = put( _dcg_adr_streetname, $maraltstname. );
    end;
    else do;
      _dcg_adr_streetname_clean = _dcg_adr_streetname;
    end;
    
    ** Special handling of PENNSYLVANIA AVE and PENN ST **;
    
    if _dcg_adr_streettype = 'AVENUE' and _dcg_adr_streetname_clean = 'PENN' then 
      _dcg_adr_streetname_clean = 'PENNSYLVANIA';
    else if _dcg_adr_streettype = 'STREET' and _dcg_adr_streetname_clean = 'PENNSYLVANIA' then 
      _dcg_adr_streetname_clean = 'PENN';

    file log;

    ** Check for valid street names **;

    if put( _dcg_adr_streetname_clean, &stvalidfmt.. ) = " " then do;
      if not( %mparam_is_yes( &quiet ) ) then do;
        %warn_put( macro=&mname, 
                   msg="Street not found: " _dcg_adr_streetname_clean "( &staddr=" &staddr "/ " _n_= ")" )
      end;
      output _dcg_stnamenotfound;
    end;
    
    _DC_mar_geocode_end:    

    ** Create address for passing to Proc Geocode **;
    
    if put( _dcg_adr_streetname_clean, &stvalidfmt.. ) = " " then do;
    
      _dcg_adr_geocode = _dcg_scrub_addr;
    
    end;
    else do;

      ** NOTE: Currently not processing address number suffix bcs not supported by Proc Geocode **;
      _dcg_adr_geocode = 
        left( compbl( 
                 trim( _dcg_adr_begnum ) || " " || 
                 trim( put( _dcg_adr_streetname_clean, $_dcg_strecode. ) ) || " " ||
                 trim( _dcg_adr_streettype ) || " " ||
                 trim( _dcg_adr_quad )
               ) );
    
    end;
    
    %if &zip ~= %then %do;
      _dcg_zip = &zip;
    %end;
    %else %do;
      _dcg_zip = .;
    %end;  
    
  
    ** Standardized street address **;    
    ** If street name not valid, set standard address to blank **;

    if put( _dcg_adr_streetname_clean, &stvalidfmt.. ) = " " then do;
      _dcg_staddr_std = "";
    end;
    else do;

      _dcg_staddr_std = left( compbl( 
                       trim( _dcg_adr_begnum ) || " " || 
                       trim( _dcg_adr_numsuffix ) || " " ||
                       trim( _dcg_adr_streetname_clean ) || " " ||
                       trim( _dcg_adr_streettype ) || " " ||
                       trim( _dcg_adr_quad ) || " " ||
                       trim( _dcg_adr_apt )
                     ) );

      _dcg_staddr_std = left( compbl( _dcg_staddr_std ) );
                     
    end;
    
    %if &staddr_std ~= %then %do;
  
      ** Add standardized address to output data set **;

      length &staddr_std $ 80;
      
      &staddr_std = _dcg_staddr_std;

      label &staddr_std = "&staddr_lbl (standardized by %nrstr(%DC_mar_geocode))";
      
    %end;
  
    %** Display parsing results for debugging **;
      
    %if %mparam_is_yes( &debug ) %then %do;

      file print;
      
      if _n_ = 1 then put // "******************  CLEANING & PARSING RESULTS  ******************" //;
      
      put '--------------------------------------------------------------';
      put _n_= / ( &staddr.: ) (= /) / _dcg_scrub_addr= / ( _dcg_adr_: ) (= /);

      file log;

    %end;
    
    output _dcg_parse;
    
  run;
  
  proc sort data=_dcg_stnamenotfound nodupkey;
    by _dcg_adr_streetname_clean;
  run;
  
  %**** Export not found street names if requested ****;
  
  %if %length( &stnamenotfound_export ) > 0 %then %do;

    filename fexport "&stnamenotfound_export" lrecl=256;

    proc export data=_dcg_stnamenotfound
        outfile=fexport
        dbms=csv replace;
      putnames=no;
    run;

    filename fexport clear;
    
  %end;

  %**** Perform geo matching ****;
  
  %if %mparam_is_yes( &geo_match ) %then %do;

    ** Separate geocoding info from other variables **;
    ** Workaround for issue with Proc Geocode v9.4  **;
    
    data 
      _dcg_indat 
        (keep=_dcg_rec_id _dcg_adr_geocode _dcg_city _dcg_st _dcg_zip
         compress=no)
      _dcg_hold
        (drop=_dcg_adr_geocode _dcg_city _dcg_st _dcg_zip
         compress=no);
    
      set _dcg_parse;
     
      _dcg_rec_id = _n_;

    run;

    ** Match cleaned addresses with parcel base file **;

    %push_option( msglevel,quiet=y )
    
    options msglevel=n;
    
    %if &sysver = 9.2 or &sysver = 9.3 %then %do;
    
      %if &basefile = %then %let basefile = Mar.Geocode_dc_m;
    
      %note_mput( macro=&mname, msg=Starting address match. Base file is %upcase(&basefile). )
    
      proc geocode method=street nozip nocity
        data=_dcg_indat     
        out=_dcg_outdat
        addressvar=_dcg_adr_geocode
        addresscityvar=_dcg_city
        addressstatevar=_dcg_st
        addresszipvar=_dcg_zip
        lookupstreet=&basefile
        attributevar=(&keep_geo);
        run;
      quit;
      
    %end;
    %else %if %sysevalf(&sysver >= 9.4) %then %do;
    
      %if &basefile = %then %let basefile = Mar.Geocode_94_dc_m;

      %note_mput( macro=&mname, msg=Starting address match. Base file is %upcase(&basefile). )
      
      proc geocode method=street nozip nocity
        data=_dcg_indat     
        out=_dcg_outdat
        addressvar=_dcg_adr_geocode
        addresscityvar=_dcg_city
        addressstatevar=_dcg_st
        addresszipvar=_dcg_zip
        lookupstreet=&basefile
        attributevar=(&keep_geo);
        run;
      quit;
    
    %end;
    %else %do;
    
      %err_mput( macro=DC_mar_geocode, msg=Geocoding only available for SAS versions 9.2 or later. )
      %pop_option( msglevel, quiet=y )
      %goto exit;
      
    %end;
    
    data &out
          %if %length( &ds_label ) > 0 %then %do;
            (label=&ds_label)
          %end;
    ;
    
      merge _dcg_hold _dcg_outdat;
      by _dcg_rec_id;
      
      M_ADDR = compress( M_ADDR, '~' );
      
      ** Check for exact matches **;
      
      length M_EXACTMATCH 3;
      
      if scan( _dcg_staddr_std, 1 ) = scan( m_addr, 1 ) and &dcg_match_score >= &match_score_min and
        upcase( _MATCHED_ ) = "STREET" and upcase( _STATUS_ ) = "FOUND" then
        M_EXACTMATCH = 1;
      else
        M_EXACTMATCH = 0;
        
      format M_EXACTMATCH dyesno.;

      %if not %mparam_is_yes( &debug ) %then %do;
        drop _dcg_: ;
      %end;
      
      label
        M_ADDR = "Geocoded address (%nrstr(%DC_mar_geocode))"
        M_CITY = "Geocoded city (%nrstr(%DC_mar_geocode))"
        M_OBS = "Geocoded obs from address file (%nrstr(%DC_mar_geocode))"
        M_STATE = "Geocoded state (%nrstr(%DC_mar_geocode))"
        M_ZIP = "Geocoded ZIP code (%nrstr(%DC_mar_geocode))"
        M_EXACTMATCH = "Geocoded street address appears to be an exact match (%nrstr(%DC_mar_geocode))"
        _MATCHED_ = "Geocode matching level (%nrstr(%DC_mar_geocode))"
       _NOTES_ = "Geocode notes (%nrstr(%DC_mar_geocode))"
       _SCORE_ = "Geocode score (%nrstr(%DC_mar_geocode))"
       _STATUS_ = "Geocode result (%nrstr(%DC_mar_geocode))"
       X = "Geocoded longitude (MD State Plane Coord., NAD 1983 meters)"
       Y = "Geocoded latitude (MD State Plane Coord., NAD 1983 meters)"
     ;
     
    run;
    
    %pop_option( msglevel, quiet=y )

    %if %mparam_is_yes( &listunmatched ) %then %do;

      %note_mput( macro=&mname, msg=Printing unmatched addresses to output (LISTUNMATCHED=Y). )

      proc print data=&out n='TOTAL UNMATCHED ADDRESSES: ';
        where &dcg_match_score < &match_score_min;
        var &id &staddr &staddr_std &zip &dcg_match_score;
        title2 "**************** UNMATCHED ADDRESSES (_SCORE_ < &match_score_min) ****************";

      run;
      title2;

    %end;
    %else %do;
      %note_mput( macro=&mname, msg=At users request (LISTUNMATCHED=N) unmatched addresses will not be printed. )
    %end;

  %end;       /** %if %mparam_is_yes( &geo_match ) **/
  %else %do;

    %note_mput( macro=&mname, msg=Address matching will be skipped (%upcase(geo_match)=&geo_match). )

    data &out
            %if %length( &ds_label ) > 0 %then %do;
              (label=&ds_label)
            %end;
      ;

      set _dcg_parse

      (drop=_dcg_: 
        %if %mparam_is_yes( &geo_match ) %then %do;
          end_apt
        %end;
      )
      ;

    run;

  %end;

  %exit:
    
  %if not( %mparam_is_yes( &debug ) ) %then %do;
    ** Cleanup temporary files **;
    proc datasets library=work nolist nowarn;
      delete _dcg_: /memtype=data;
    quit;
  %end;

  %pop_option( mprint )

  %note_mput( macro=&mname, msg=Exiting macro. )

%mend DC_mar_geocode;

/** End Macro Definition **/

