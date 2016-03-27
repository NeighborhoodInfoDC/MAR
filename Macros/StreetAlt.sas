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


%macro StreetAlt( infile=, print=n );

  %push_option( mprint, quiet=Y )

  options nomprint;

  filename xin "&infile" lrecl=1000;

  data StreetAlt;

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

  proc sort data=StreetAlt nodupkey;
    by altname streetname;
  run;  

  %note_mput( macro=StreetAlt, msg=Processing alternate street name file &infile.. )

  data _null_;

    set StreetAlt;
    by altname;

    if not last.altname then do;
      %err_put( macro=StreetAlt, msg="Conflicting entries for incorrect spelling of " altname )
      %err_put( macro=StreetAlt, msg="Alternate street name spelling list NOT created." )
      %err_put( macro=StreetAlt, msg="Please edit alternate street name file and resubmit program." )
      abort return;
    end;
    
    if put( streetname, $marvalidstnm. ) = " " then do;
      %err_put( macro=StreetAlt, msg="Invalid entry for correct spelling of " streetname )
      %err_put( macro=StreetAlt, msg="Correct street name spelling must match listing in ValidStreets.txt." )
      %err_put( macro=StreetAlt, msg="Alternate street name spelling list NOT created." )
      %err_put( macro=StreetAlt, msg="Please edit alternate street name file and resubmit program." )
      abort return;
    end;

    if put( altname, $marvalidstnm. ) ~= " " then do;
      %warn_put( macro=StreetAlt, msg="A valid street name cannot be used as an incorrect spelling: " altname " to " streetname )
      %warn_put( macro=StreetAlt, msg="This entry will be deleted." )
      delete;
    end;

  run;
  
  %if &syserr = 0 %then %do;

    ** Create $MARSTRTALT format for correcting street names **;

    %Data_to_format(
      FmtLib=work,
      FmtName=$maraltstname,
      Data=StreetAlt,
      Value=altname,
      Label=streetname,
      DefaultLen=40,
      print=&print,
      Contents=N
    )

    run;
    
  %end;
  
  %pop_option( mprint, quiet=Y )

%mend StreetAlt;

