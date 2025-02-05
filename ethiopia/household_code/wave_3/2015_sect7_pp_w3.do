* Project: WB Weather
* Created on: oct 27
* Created by: reece
* Edited on: oct 27 2024
* Edited by: reece
* Stata v.18

* does
	* cleans access to extension
* assumes
	* access to all raw data
	* mdesc.ado
	* cleaned hh_seca.dta

* TO DO:
	* 
* **********************************************************************
**#0 - setup
* **********************************************************************

* define paths
	global root 	"$data/raw_lsms_data/ethiopia/wave_3/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_3"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/wv3_pp_sect7", append
	
* ***********************************************************************
**#1 - prepare ethiopia (Wave 3) - ag sec 7 post planting
* ***********************************************************************

* load data
	use 		"$root/sect7_pp_w3", clear
	
* ***********************************************************************
**#2 - extension access
* ***********************************************************************


* did respondant participate in extension program
	gen 		extension = 0
	replace		extension = 1 if pp_s7q04 == 1
	replace 	extension = 0 if pp_s7q04 == 2
	
* renaming these so we can rename the following vars
	rename saq01 saq01a
	rename saq02 saq02a
	rename saq03 saq03a
	rename saq04 saq04a
	rename saq05 saq05a
	rename saq06 saq06a
	*rename saq07 saq07a
	*rename saq08 saq08a
	rename holder_id individual_id
	
* rename hh identifiers to match with sect7_pp_w3 so we can merge with sect1_hh_w3
	rename hh_saq01 saq01
	rename hh_saq02 saq02
	rename hh_saq03 saq03
	rename hh_saq04 saq04
	rename hh_saq05 saq05
	rename hh_saq06 saq06
	rename hh_saq07 saq07
	rename hh_saq08 saq08
	
* merge in identifiers to add in ea_id2
		merge m:1 saq01 saq02 saq03 saq04 saq05 saq06 saq07 saq08 household_id household_id2 individual_id using "$root/sect1_hh_w3"	

		/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                        24,222
        from master                        31  (_merge==1)
        from using                     24,191  (_merge==2)

    Matched                             3,799  (_merge==3)
    -----------------------------------------
*/
		
* generate year
	gen 		year = 2015
	
	lab var year "year of survey- wv3 2015"
	lab var extension "does respondent have access to extension?"
	rename saq01 region
	rename  saq02 zone
	rename saq03 woreda
	rename saq04 kebele
	rename saq05 ea	
	rename household_id hh_id_obs
	rename household_id2 hh_id_merge
	rename individual_id manager_id_merge

* drop what we don't need 
	keep hh_id_obs hh_id_merge extension year zone region woreda kebele ea ea_id manager_id_merge ea_id2
	
* drop duplicate manager_id_merge so we can merge later
	duplicates tag manager_id_merge, generate(dups)
	drop if dups > 0
	* 22 obs dropped
	
* dropping these for isid error "... should never be missing"
	drop if missing(manager_id_merge) | missing(region) | missing(zone) | missing(woreda) | missing(kebele) | missing(ea) 
	* 28 obs dropped
	
* prepare for export
	isid			 manager_id_merge region zone woreda kebele ea
	describe
	summarize 
	save 			"$export/pp_sect7.dta", replace
	


* close the log
	log	close

/* END */