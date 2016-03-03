/**************************************************************************
 Program:  DC_geocode.sas
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

/** Macro DC_geocode - Start Definition **/

%macro DC_geocode( 

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
           ssl VoterPre2012 Ward2002 Ward2012,  /* List of geo vars to keep in geocoded file */

  dcg_match_score=_score_,  /* Match score */

  match_score_min=35,            /** Minimum score for a match **/

  block_match=Y,              /* Match to blocks if address has no exact parcel match (Y/N) */
  unit_match=y,                /* Perform unit matching with parcels (Y/N) */

  max_near_block_dist=500,    /* Maximum difference between street nos. for near block matches */

  basefile=,                  /* Base file for address matching (if not specified, default files are used) */
  stvalidfmt=$marvalidstnm,        /* Format for validating street names */
  staltfmt=$maraltstname,          /* Format with alternate street name spellings */
  punct_list=%str(,.*''""<>;[]{}|_+=^$@!~`%:?),    /* List of punctuation to strip (do not include dash '-') */

  listunmatched=Y,              /* List nonmatching addresses (Y/N, def. Y) */
  quiet=N,                     /* Suppress warning messages (Y/N, def. N) */
  debug=N,                     /* Print debugging information (Y/N, def. N) */
  mprint=N                     /* Print resolved macro code in LOG (Y/N, def. N) */
  
  );

  %local mversion mdate mname geo_valid u_keep_geo i gkw;

  %let mversion = 2.0;
  %let mdate = 03/2/16;
  %let mname = DC_geocode;

  %push_option( mprint )

  %if not( %mparam_is_yes( &debug ) ) and %mparam_is_no( &mprint ) %then %do;
    options nomprint;
  %end;
  %else %do;
    options mprint;
  %end;

  %note_mput( macro=&mname, msg=&mname macro version &mversion (&mdate) written by %str(Peter Tatian, Beata Bajaj & David DOrio). )
  %note_mput( macro=&mname, msg=(c) 2016 The Urban Institute/NeighborhoodInfo DC - All Rights Reserved. )

  %note_mput( macro=&mname, msg=Starting macro. )

  %** Check for required parameters **;

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

  %** Check for valid keywords in keep_geo= **;

  %let geo_valid = /address_id/Anc2002/Anc2012/Cluster_tr2000/
                   /Geo2000/Geo2010/GeoBg2010/GeoBlk2010/Psa2004/Psa2012/
                   /ssl/VoterPre2012/Ward2002/Ward2012/;

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

  %** Complete any previous run blocks before checking for data set **;         

  run;      

  %** Check for input data set and          **;
  %** get label for street address variable **;

  %let dsid=%sysfunc(open(&data,i));
  %if &dsid %then %do;
      %let staddr_lbl=%qsysfunc(varlabel(&dsid,%sysfunc(varnum(&dsid,&staddr))));
      %let rc=%sysfunc(close(&dsid));
  %end;
  %else %do;
    %err_mput( macro=&mname, msg=The input data set %upcase(&data) does not exist or could not be opened. )
    %goto exit;
  %end;
  
  ** Create format for temporary recoding of street names that match direction abbreviations **;
  
  proc format;
    value $_dcg_strecode (default=40)
      'E' = '~E~'
      'N' = '~N~'
      'S' = '~S~'
      'W' = '~W~';
  run;

  ** Read, clean, and parse address data **;

  %note_mput( macro=&mname, msg=Cleaning and parsing address data. )

  data _dcg_indat (compress=no);
  
    set &data;
    
    retain _dcg_city 'WASHINGTON' _dcg_st 'DC';
    
    length _dcg_scrub_addr _dcg_adr_streetname_clean _dcg_adr_geocode $ 500 _dcg_zip 8;
    
    _dcg_zip = .;

    if &staddr = "" then goto _dc_geocode_end;
    
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

    %Address_parse( address=_dcg_scrub_addr, var_prefix=_dcg_adr_, debug=&debug )    

    if _dcg_adr_street = "" then goto _dc_geocode_end;

    ** Clean street names (apply StreetAlt.xls corrections) **;
    ** Only apply if original street name is not valid        **;

    if put( _dcg_adr_streetname, &stvalidfmt.. ) = " " then do;
      _dcg_adr_streetname_clean = put( _dcg_adr_streetname, &staltfmt.. );
    end;
    else do;
      _dcg_adr_streetname_clean = _dcg_adr_streetname;
    end;

    file log;

    ** Check for valid street names **;

    if put( _dcg_adr_streetname_clean, &stvalidfmt.. ) = " " and not( %mparam_is_yes( &quiet ) ) then do;
      %warn_put( macro=&mname, 
                 msg="Street not found: " _dcg_adr_streetname_clean "( &staddr=" &staddr "/ " _n_= ")" )
    end;
    
    _dc_geocode_end:    

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

    %if %mparam_is_yes( &debug ) %then %do;

      file print;
      
      if _n_ = 1 then put // "******************  CLEANING & PARSING RESULTS  ******************" //;
      
      put '--------------------------------------------------------------';
      put _n_= / &staddr= / _dcg_scrub_addr= / ( _dcg_adr_: ) (= /);

      file log;

    %end;
    
  run;

   %if &staddr_std ~= %then %do;

     %** Add standardized address variable **;
     %add_staddr_std( inds=_dcg_indat, outds=_dcg_indat, staddr_std=&staddr._std )

   %end;

  %if %mparam_is_yes( &geo_match ) %then %do;

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
  
    %err_mput( macro=Dc_geocode, msg=Geocoding only available for SAS versions 9.2 or later. )
    %pop_option( msglevel, quiet=y )
    %goto exit;
    
  %end;
  
  data &out;
  
    set _dcg_outdat;
    
    M_ADDR = compress( M_ADDR, '~' );
    
  run;
  
  %pop_option( msglevel, quiet=y )

  %if %mparam_is_yes( &listunmatched ) %then %do;

  %note_mput( macro=&mname, msg=Printing unmatched addresses to output (LISTUNMATCHED=Y). )

  proc print data=&out n='TOTAL UNMATCHED ADDRESSES: ';
    where &dcg_match_score < &match_score_min;
    var &id &staddr &staddr_std &zip &dcg_match_score;
    title2 '***************** UNMATCHED ADDRESSES *****************';

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

    set _dcg_indat

    (drop=_dcg_: 
      %if %mparam_is_yes( &geo_match ) %then %do;
        end_apt
      %end;
    )
    ;

  run;

  %end;

  %exit:

  %pop_option( mprint )

  %note_mput( macro=&mname, msg=Exiting macro. )

%mend DC_geocode;

/** End Macro Definition **/

