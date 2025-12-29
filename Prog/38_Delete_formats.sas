/**************************************************************************
 Program:  38_Delete_formats.sas
 Library:  MAR
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  12/29/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  38
 
 Description:  Delete permanent formats that are being replaced by
 temporary ones. 

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( MAR )

proc catalog catalog=MAR;
  delete marvalidsttyp / entrytype=formatc;
  delete marvalidunit / entrytype=formatc;
  delete marvalidquadrant / entrytype=formatc;
  delete maraltsttyp / entrytype=formatc;
  delete maraltunit / entrytype=formatc;
  delete maraltquadrant / entrytype=formatc;
  contents;
quit;

run;
