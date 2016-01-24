/**************************************************************************
 Program:  Set_street_arrays.sas
 Library:  MAR
 Project:  NeigborhoodInfo DC
 Author:   P. Tatian (with code from B. Bajaj)
 Created:  1/24/16
 Version:  SAS 9.2
 
 Description:  Autocall macro to create arrays with street type spellings.

 Modifications:
  01/24/16 PAT Adapted from RealProp macro %Set_street_arrays().
**************************************************************************/

%macro set_street_arrays();

	array orig_type[69] $ _temporary_;
	
	orig_type[1]="ALLEY";
	orig_type[2]="ALLEE";
	orig_type[3]="ALLEY";
	orig_type[4]="ALLY";
	orig_type[5]="ALY";
	orig_type[6]="AV";
	orig_type[7]="AVEN";
	orig_type[8]="AVENU";
	orig_type[9]="AVN";
	orig_type[10]="AVNUE";
	orig_type[11]="AVE";
	orig_type[12]="BOUL";
	orig_type[13]="BOULV";
	orig_type[14]="BLVD";
	orig_type[15]="CIRC";
	orig_type[16]="CIRCL";
	orig_type[17]="CIR";
	orig_type[18]="CT";
	orig_type[19]="COURT";
	orig_type[20]="CRES";
	orig_type[21]="CRESCENT";
	orig_type[22]="DRIV";
	orig_type[23]="DRV";
	orig_type[24]="DR";
	orig_type[25]="DRIVE";
	orig_type[26]="EXP";
	orig_type[27]="EXPR";
	orig_type[28]="EXPRESS";
	orig_type[29]="EXPW";
	orig_type[30]="EXPY";
	orig_type[31]="EXPRESSWAY";
	orig_type[32]="GRN";
	orig_type[33]="KEY";
	orig_type[34]="KYS";
	orig_type[35]="KY";
	orig_type[36]="LA";
	orig_type[37]="LN";
	orig_type[38]="LANE";
	orig_type[39]="MDW";
	orig_type[40]="MDWS";
	orig_type[41]="MEADOWS";
	orig_type[42]="MEADOW";
	orig_type[43]="MEWS";
	orig_type[44]="PKWY";
	orig_type[45]="PARKWAYS";
	orig_type[46]="PARKWY";
	orig_type[47]="PARKWAY";
	orig_type[48]="PL";
	orig_type[49]="PLZA";
	orig_type[50]="PLZ";
	orig_type[51]="PLAZA";
	orig_type[52]="PROM";
	orig_type[53]="PRMNDE";
	orig_type[54]="PROMENADE";
	orig_type[55]="RD";
	orig_type[56]="SQUARES";
	orig_type[57]="SQR";
	orig_type[58]="SQRE";
	orig_type[59]="SQRS";
	orig_type[60]="SQU";
	orig_type[61]="SQUARE";
	orig_type[62]="ST";
	orig_type[63]="TER";
	orig_type[64]="TERR";
	orig_type[65]="TERRACE";
	orig_type[66]="WALKS";
	orig_type[67]="WALK";
	orig_type[68]="WAY";
	orig_type[69]="WY";


	array new_type[69] $ _temporary_;
	
	new_type[1]="ALLEY";
	new_type[2]="ALLEY";
	new_type[3]="ALLEY";
	new_type[4]="ALLEY";
	new_type[5]="ALLEY";
	new_type[6]="AVENUE";
	new_type[7]="AVENUE";
	new_type[8]="AVENUE";
	new_type[9]="AVENUE";
	new_type[10]="AVENUE";
	new_type[11]="AVENUE";
	new_type[12]="BOULEVARD";
	new_type[13]="BOULEVARD";
	new_type[14]="BOULEVARD";
	new_type[15]="CIRCLE";
	new_type[16]="CIRCLE";
	new_type[17]="CIRCLE";
	new_type[18]="COURT";
	new_type[19]="COURT";
	new_type[20]="CRESCENT";
	new_type[21]="CRESCENT";
	new_type[22]="DRIVE";
	new_type[23]="DRIVE";
	new_type[24]="DRIVE";
	new_type[25]="DRIVE";
	new_type[26]="EXPRESSWAY";
	new_type[27]="EXPRESSWAY";
	new_type[28]="EXPRESSWAY";
	new_type[29]="EXPRESSWAY";
	new_type[30]="EXPRESSWAY";
	new_type[31]="EXPRESSWAY";
	new_type[32]="GREEN";
	new_type[33]="KEYS";
	new_type[34]="KEYS";
	new_type[35]="KEYS";
	new_type[36]="LANE";
	new_type[37]="LANE";
	new_type[38]="LANE";
	new_type[39]="MEADOW";
	new_type[40]="MEADOWS";
	new_type[41]="MEADOWS";
	new_type[42]="MEADOW";
	new_type[43]="MEADOWS";
	new_type[44]="PARKWAY";
	new_type[45]="PARKWAY";
	new_type[46]="PARKWAY";
	new_type[47]="PARKWAY";
	new_type[48]="PLACE";
	new_type[49]="PLAZA";
	new_type[50]="PLAZA";
	new_type[51]="PLAZA";
	new_type[52]="PROMENADE";
	new_type[53]="PROMENADE";
	new_type[54]="PROMENADE";
	new_type[55]="ROAD";
	new_type[56]="SQUARE";
	new_type[57]="SQUARE";
	new_type[58]="SQUARE";
	new_type[59]="SQUARE";
	new_type[60]="SQUARE";
	new_type[61]="SQUARE";
	new_type[62]="STREET";
	new_type[63]="TERRACE";
	new_type[64]="TERRACE";
	new_type[65]="TERRACE";
	new_type[66]="WALK";
	new_type[67]="WALK";
	new_type[68]="WAY";
	new_type[69]="WAY";
	
	
        array old_dir[69] $ _temporary_;
        array new_dir[69] $ _temporary_;

	    old_dir[1]= "NORTHEAST";
	    old_dir[2]= "N.E.";
	    old_dir[3]= "SOUTHEAST";
	    old_dir[4]= "S.E.";
	    old_dir[5]= "SOUTHWEST";
	    old_dir[6]= "S.W.";
	    old_dir[7]= "NORTHWEST";	
	    old_dir[8]= "N.W."	;
	    old_dir[9]= "NW"	;
	    old_dir[10]= "NE"	;
	    old_dir[11]= "SW"	;
	    old_dir[12]= "SE"	;
	    old_dir[12]= "NORTH"	;


	    new_dir[1]= "NE";
	    new_dir[2]= "NE";
	    new_dir[3]= "SE";
	    new_dir[4]= "SE";
	    new_dir[5]= "SW";
	    new_dir[6]= "SW";
	    new_dir[7]= "NW"	;
	    new_dir[8]= "NW"	;
	    new_dir[9]= "NW"	;
	    new_dir[10]= "NE"	;
	    new_dir[11]= "SW"	;
	    new_dir[12]= "SE"	;
	    new_dir[12]= ""	;

%mend set_street_arrays;

