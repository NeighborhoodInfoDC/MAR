/**************************************************************************
 Jenner compatibility bundle for: Macros/Mar_addr_parse_remv_lead_zero.sas
 Upstream library: MAR (DC Master Address Repository), NeighborhoodInfo DC.

 %Mar_addr_parse_remv_lead_zero() is an autocall DATA-step macro used by
 the MAR unit parser to strip leading zeros from apartment/unit numbers
 (007 -> 7, 0042 -> 42) while leaving all-zero strings untouched. This
 bundle defines the macro verbatim, then drives it from a DATA step over
 a sample of raw apartment numbers so the trimming logic is exercised.
**************************************************************************/

/** Macro Mar_addr_parse_remv_lead_zero - definition copied verbatim from upstream **/

%macro Mar_addr_parse_remv_lead_zero(num);

        ** Remove leading zeros from apt number **;

        &num = left( &num );
        if compress( &num, '0' ) ~= '' then do;
          do while ( &num =: '0' );
            &num = left( substr( &num, 2 ) );
          end;
        end;

%mend Mar_addr_parse_remv_lead_zero;

/** Drive the macro over a sample of raw apartment numbers **/

data units;
  length apt_raw $ 12 apt $ 12;
  input apt_raw $;
  apt = apt_raw;
  %Mar_addr_parse_remv_lead_zero( apt )
datalines;
007
0042
0000
100
00305B
0
0001
0560
;
run;

proc print data=units;
  var apt_raw apt;
run;
