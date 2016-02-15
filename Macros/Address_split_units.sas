/**************************************************************************
 Program:  Address_split_units.sas
 Library:  MAR
 Project:  NeigborhoodInfo DC
 Author:   P. Tatian (with code from B. Bajaj)
 Created:  1/24/16
 Version:  SAS 9.2
 
 Description:  Autocall macro to parse out unit number from street address.

 Modifications:
  01/24/16 PAT Adapted from RealProp macro %Address_split_units().
**************************************************************************/

/*** last step could be added ==> loop through words and match them to the pars already
				 parsed. If word is not St No, Street, Quadrant ...etc,
				 assume its the unit/apt. This would pick up unit/apt 
				 numbers that are nested between street and quadrant.
****/

%macro address_split_units(inlib=work,inds=,outlib=work,outds=, numObs=max, debug=N);

%local MAX_WORDS letter_list;

%let MAX_WORDS = 20;

%let letter_list='-','.','/','1','2','3','4','5','6','7','8','9','0','A','B','C','D','E','F',
                 'G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z';

	data &outlib..&outds;
	set &inlib..&inds ;
	    length word  $ 255  _dcg_adr_apt_unit $5 ;

	    
		_dcg_addr_var=_dcg_scrub_addr || " ";
		_dcg_n_addr_var=trim(_dcg_addr_var) || "|";
			
		num=length(_dcg_n_addr_var);

		wordCnt=0;
		length word1-word&MAX_WORDS. $50;
		array words(*)$ word1-word&MAX_WORDS.;

		do g=1 to &MAX_WORDS.;
			words[g]='';
		end;

	    %if %mparam_is_yes( &debug ) %then %do;
		    put "*******Before********************************************************";
		    put _all_;
		    put "***************************************************************";
		    put "***************************************************************";
	    %end;

	       if num gt 3 then do i=1 to num;
			letter=substr(_dcg_n_addr_var,i,1);
			word=compress(word || letter);
			if upcase(letter) not in (&letter_list)
			then do;	
				x_word=translate(word,'  ','""');
				x_word=translate(x_word,' ',"'");
				x_word=translate(x_word,' ',",");
				x_word=translate(x_word,' ',".");
				x_word=translate(x_word,' ',":");
				x_word=translate(x_word,' ',"|");
				
				word=compress(x_word);
				wordCnt+1;
				if wordCnt > &MAX_WORDS. then do;
				  %err_put( macro=Address_split_units, 
				            msg="Number of words in address exceeds maximum of &MAX_WORDS.. " _n_= _dcg_n_addr_var )
				  %err_put( macro=Address_split_units, 
				            msg="No further words in address will be processed." )
				  leave;
				end;
				words[wordCnt]=word;
				%if %mparam_is_yes( &debug ) %then %do;
					put "================>" words[wordCnt]=;
				%end;
				
				word="";
			end;
			***** keep going ****;
			else do;
			end;
		end;
		numwords=wordCnt;
		
		%set_street_arrays;

		%if %mparam_is_yes( &debug ) %then %do;
			put "starting to process address: " address;
		%end;

		do i = 1 to &MAX_WORDS.;
		
			do j=1 To dim(orig_type);
				if words[i]=orig_type[j] then do;
					words[i]=new_type[j];
				end;
			end;
			do j=1 To dim(orig_type);
				if words[i]=new_type[j] then do;
				   street_type_found_at=i;
				   temp_street_type=words[i];
				end;
			end;
			do j=1 To dim(old_dir);
				if trim(words[i]) ^= '' and upcase(trim(words[i]))=old_dir[j] then do;
				   words[i]=new_dir[j];
				   if new_dir[j] ^= '' then do;
					   quadrant_found_at=i;
					   temp_quad=new_dir[j];
				   end;
				end;
			end;
		end;	
		do i = 1 to &MAX_WORDS.;
			
			if quadrant_found_at < 1 then do j=1 To dim(new_type);
				if words[i]=new_type[j] and trim(new_type[j]) ^='' then do k=i+1 to &MAX_WORDS.;
					if k < &MAX_WORDS. then do;
					  if compress(words[k]) ^='' then do;
						unit_found=1;
				   		temp_apt_unit=words[k];
				   		temp_apt_unit_found_at=j;					
					end;
				end;
				end;
			end;
			if trim(upcase(words[i])) in ('UNIT','APT','NO') then do;
				if i ^= &MAX_WORDS. then do p=i+1 to &MAX_WORDS.;				
				   if compress(words[p]) ^='' then do;
					unit_found=2;
				   	temp_apt_unit=words[p];
				   	temp_apt_unit_found_at=i;
				   end;
				end;
			end;
			if trim(upcase(words[i])) in ('NW','NE','SW','SE') then do;
				temp_quad=trim(upcase(words[i])) ;
				if i ^= &MAX_WORDS. then do p=i+1 to &MAX_WORDS.;	
				   if compress(words[p]) ^='' then do;
					unit_found=3;
				   	temp_apt_unit=words[p];
				   	temp_apt_unit_found_at=p;
				   end;
				end;
				
			
			end;
		end;

		if trim(temp_apt_unit) ^= '' then do;
			_temp_apt_unit=temp_apt_unit;
			Pad=length(trim(_temp_apt_unit));
			endPad=5-pad;
			if pad < 5 then do z=1 to endPad;
				_temp_apt_unit='0'||trim(_temp_apt_unit);
			end;			
		end;			

		if trim(_dcg_adr_apt) ^= '' then do;
			_temp_dcg_adr_apt=_dcg_adr_apt;
			Pad=length(trim(_temp_dcg_adr_apt));
			endPad=5-pad;
			if pad < 5 then do z=1 to endPad;
				_temp_dcg_adr_apt='0'||trim(_temp_dcg_adr_apt);
			end;			
		end;	
		_dcg_adr_apt=_temp_dcg_adr_apt;		


		*** if quadrant gets picked up as unit then reset it *****;
		if temp_apt_unit=_dcg_adr_quad then _temp_apt_unit='';
		
		*** default apt_unit to _apt from original parsing ****;
		if trim(_dcg_adr_apt) ^= '' then _dcg_adr_apt_unit=_dcg_adr_apt; 
		else _dcg_adr_apt_unit=_temp_apt_unit;

		if trim(_dcg_adr_apt) = '' and  trim(_dcg_adr_apt_unit) ^= ''
		then _dcg_adr_apt=_temp_apt_unit;


	    %if %mparam_is_yes( &debug ) %then %do;
		    put "*****************After**********************************************";
		    put _all_;
		    put "***************************************************************";
		    put "***************************************************************";
	    %end;


	    %if %mparam_is_yes( &debug ) %then %do;

		    file print;

		    if _n_ = 1 then put // "****************** UNIT CLEANING & PARSING RESULTS  ******************" //;
	
		    put '--------------------------------------------------------------';
		    put _n_= / &staddr= / _dcg_scrub_addr= / ( _dcg_adr_: ) (= /);
	
		    file log;
		    
	    %end;

		DROP endPad end_apt g i j k letter _dcg_n_addr_var num numwords p 
		     quadrant_found_at street_type_found_at pad
		     temp_apt_unit temp_apt_unit_found_at temp_quad temp_street_type 
		     unit_found word word1 - word&MAX_WORDS. wordCnt x_word z _temp_: ;


	run;
	
%mend address_split_units;
