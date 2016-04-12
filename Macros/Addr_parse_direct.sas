/**************************************************************************
 Program:  Addr_parse_direct.sas
 Library:  MAR
 Project:  NeigborhoodInfo DC
 Author:   P. Tatian (with code from B. Bajaj)
 Created:  1/24/16
 Version:  SAS 9.2
 
 Description:  Autocall macro used by %Address_parse() macro to
 abbreviate directions if not a part of another word and not followed
 by AVE, RD, etc.

 Modifications:
  01/24/16 PAT Adapted from RealProp macro %Addr_parse_direct().
**************************************************************************/

%macro Addr_parse_direct(d,len,wrd,abbr);

 if &d._index ^=0 then
  do;
     if indexc(substr(_ap_temp_ad,&d._index+&len.,1),"ABCDEFGHIJKLMNOPQRSTUVWXYZ")=0
     	and indexc(substr(_ap_temp_ad,&d._index-1,1),"ABCDEFGHIJKLMNOPQRSTUVWXYZ")=0 then
      do;
         if substr(_ap_temp_ad,&d._index+&len.+1,3)^="AVE" and
            substr(_ap_temp_ad,&d._index+&len.+1,2) not in ("RD","ST","DR","LN") then
          do;
             _ap_temp_ad=tranwrd(_ap_temp_ad, "&wrd.", " &abbr. ");
             **f_dir&d.= 1;
          end;
      end;
  end;

%mend Addr_parse_direct;

