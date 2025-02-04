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
	global root 	"$data/raw_lsms_data/ethiopia/wave_2/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_2"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/wv1_pp_sect7", append
	
* ***********************************************************************
**#1 - prepare ethiopia (Wave 2) - ag sec 7 post planting
* ***********************************************************************

* load data
	use 		"$root/sect7_pp_w2", clear
	
* ***********************************************************************
**#2 - extension access
* ***********************************************************************


* did respondant participate in extension program
	gen 		extension = 0
	replace		extension = 1 if pp_s7q04 == 1
	replace 	extension = 0 if pp_s7q04 == 2
	
* generate year
	gen 		year = 2013
	
	lab var year "year of survey- wv2 2013"
	lab var extension "does respondent have access to extension?"
	rename saq01 region
	rename  saq02 zone
	rename saq03 woreda
	rename saq04 kebele
	rename saq05 ea	
	rename household_id hhid
	rename household_id2 hhid2
	
* need to create correct manager_id_merge for lsms_base merge
* looks like it is household_id2 + holder id(pp_saq07)
	gen holder_str = cond(pp_saq07 < 10, "0" + string(pp_saq07, "%12.0f"), string(pp_saq07, "%12.0f"))
	gen manager_id_merge = hhid2 + holder_str
	

* drop what we don't need 
	keep hhid hhid2 holder_id manager_id_merge extension year zone region woreda kebele ea ea_id2
	
* prepare for export
	isid			hhid2 holder_id region zone woreda kebele ea
	describe
	summarize 
	save 			"$export/pp_sect7.dta", replace
	


* close the log
	log	close

/* END */