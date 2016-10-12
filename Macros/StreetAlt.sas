/**************************************************************************
 Program:  StreetAlt.sas
 Library:  MAR
 Project:  NeigborhoodInfo DC
 Author:   P. Tatian
 Created:  3/26/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)

 Description:  Create $maraltstname format with alternate street spellings
               (i.e., corrections) for geocoding.
               
 Modifications:
**************************************************************************/


%macro StreetAlt( infile=, print=n, lib=work );

  %local stopped;

  %push_option( mprint, quiet=Y )

  options nomprint;
  
  %if not %sysfunc( fileexist( &infile ) ) %then %do;
    %err_mput( macro=StreetAlt, msg=Alternate street name file &infile does not exist. )
    %err_mput( macro=StreetAlt, msg=Default street correction file will be used instead. )
    %goto exit;
  %end;

  %note_mput( macro=StreetAlt, msg=Processing alternate street name file &infile.. )

  filename xin "&infile" lrecl=1000;

  data _StreetAlt;

    length streetname altname $ 50;
    
    infile xin missover dsd firstobs=2;

    input altname streetname;

    streetname = left( compbl( upcase( streetname ) ) );
    altname = left( compbl( upcase( altname ) ) );
    
    if altname = '' or streetname = '' then delete;

  run;
  
  filename xin clear;

  ** Check for conflicting entries of alternate street spellings and
  ** invalid correct street names;
  
  %let stopped = 0;

  proc sort data=_StreetAlt nodupkey;
    by altname streetname;
  run;  

  data _null_;

    set _StreetAlt;
    by altname;

    if not last.altname then do;
      %err_put( macro=StreetAlt, msg="Conflicting entries for correct spelling of street name " altname )
      %err_put( macro=StreetAlt, msg="Please edit &infile and resubmit program." )
      %err_put( macro=StreetAlt, msg="Alternate street name spelling list NOT created." )
      %err_put( macro=StreetAlt, msg="Default street correction file will be used instead." )
      call symput( 'stopped', '1' );
      stop;
    end;
    
    if put( streetname, $marvalidstnm. ) = " " then do;
      %err_put( macro=StreetAlt, msg="Invalid entry for correct spelling of street name " altname " as " streetname )
      %err_put( macro=StreetAlt, msg="Correct street spelling must match names in L:\Libraries\MAR\Doc\ValidStreets.html" )
      %err_put( macro=StreetAlt, msg="Please edit &infile and resubmit program." )
      %err_put( macro=StreetAlt, msg="Alternate street name spelling list NOT created." )
      %err_put( macro=StreetAlt, msg="Default street correction file will be used instead." )
      call symput( 'stopped', '1' );
      stop;
    end;

    if put( altname, $marvalidstnm. ) ~= " " then do;
      %warn_put( macro=StreetAlt, msg="A valid street name cannot be used as an incorrect spelling: " altname " to " streetname )
      %warn_put( macro=StreetAlt, msg="This entry in &infile will be ignored." )
      delete;
    end;

  run;
  
  %if &stopped = 1 %then %goto exit;

  ** Create $MARSTRTALT format for correcting street names **;

  %Data_to_format(
    FmtLib=&lib,
    FmtName=$maraltstname,
    Data=_StreetAlt,
    Value=altname,
    Label=streetname,
    DefaultLen=40,
    print=&print,
    Contents=N
  )

  run;
  
  %exit:
  
  ** Cleanup temporary files **;
  
  proc datasets library=work nolist nowarn;
    delete _StreetAlt /memtype=data;
  quit;
  
  %pop_option( mprint, quiet=Y )

%mend StreetAlt;

