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

%let StreetAlt_files = 
\\sas1\DCDATA\Libraries\MAR\Prog\StreetAlt.txt
\\sas1\DCDATA\Libraries\DHCD\Prog\RCASD\StreetAlt.txt
\\sas1\DCDATA\Libraries\Vital\Prog\StreetAlt_041918_new.txt
\\sas1\DCDATA\Libraries\DHCD\Prog\LIHTC\StreetAlt.txt;

/** Macro Read_files - Start Definition **/

%macro Read_files( File_list= );

%local i v;

%let i = 1;
%let v = %scan( &File_list, &i, %str( ) );

%do %until ( &v = );

  filename f  "&v" lrecl=1000;

  data File&i;
  
    infile f dsd firstobs=2;

    length Incorrect Correct $ 500;
  
    input Incorrect Correct;
    
  run;

  filename f clear;
  
  %File_info( data=File&i, stats= )

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


