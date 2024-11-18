/**************************************************************************
 Program:  Consolidate_StreetAlt_files.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  11/14/24
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  76
 
 Description:  Consolidate StreetAlt file lists.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

%global StreetAlt_ds_list;


/** Macro Read_files - Start Definition **/

%macro Read_files( File_list= );

%local i v;

%let i = 1;
%let v = %scan( &File_list, &i, %str( ) );

%let StreetAlt_ds_list = ;

%do %until ( &v = );

  filename f  "&v" lrecl=1000;

  data File&i;
  
    infile f dsd firstobs=2;

    length Incorrect Correct $ 500;
  
    input Incorrect Correct;
    
    Incorrect = left( upcase( Incorrect ) );
    Correct = left( upcase( Correct ) );
    
  run;

  filename f clear;
  
  %let StreetAlt_ds_list = &StreetAlt_ds_list File&i;

  %let i = %eval( &i + 1 );
  %let v = %scan( &File_list, &i, %str( ) );

%end;


%mend Read_files;

/** End Macro Definition **/


%Read_files( File_list =
\\sas1\DCDATA\Libraries\MAR\Prog\StreetAlt.txt
\\sas1\DCDATA\Libraries\DHCD\Prog\RCASD\StreetAlt.txt
\\sas1\DCDATA\Libraries\Vital\Prog\StreetAlt_041918_new.txt
\\sas1\DCDATA\Libraries\DHCD\Prog\LIHTC\StreetAlt.txt
)

run;


** Combine files and remove invalid corrections **;

data A;

  set &StreetAlt_ds_list;
  
  if put( correct, $marvalidstnm. ) = " " then delete;
  
  ** Manual cleaning **;
  
  if 
    ( incorrect = "QUEENS STROLL" and correct = "QUEEN" ) or 
    ( incorrect = "UNIV" and correct = "UNION" ) or 
    ( incorrect = "IEVING" and correct = "PINEVIEW" ) or
    ( incorrect = "IST" and correct = "VISTA" ) or
    ( indexc( incorrect, '&' ) ) or 
    ( prxmatch( "/WASHINGTON$/", trim(incorrect) ) ) 
  then delete;
  
  label 
    incorrect = "Incorrect spelling"
    correct = "Correct spelling";
  
run;

** Remove duplicate rows **;

proc sort data=A nodupkey;
  by incorrect correct;
run;

** Check for different corrections of same misspelling **;

%Dup_check(
  data=A,
  by=incorrect,
  id=correct,
  out=_dup_check,
  listdups=Y,
  count=dup_check_count,
  quiet=N,
  debug=N
)

** Export new StreetAlt file **;

filename fexport "&_dcdata_default_path\MAR\Prog\StreetAlt.txt" lrecl=256;

proc export data=A
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;



