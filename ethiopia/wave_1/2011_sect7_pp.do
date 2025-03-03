* Project: lsms risk ag
* Created on: oct 27
* Created by: reece
* Edited on: 5 feb 25
* Edited by: jdm
* Stata v.18

* does
	* reads in sec 7, access to extension by holder
	* outputs holder-level use of extension
	
* assumes
	* access to all raw data

* TO DO:
	* done
	
	
* **********************************************************************
**#0 - setup
* **********************************************************************

* define paths
	global root 	"$data/raw_lsms_data/ethiopia/wave_1/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/wv1_pp_sect7", append
	
	
* ***********************************************************************
**#1 - prepare ethiopia (Wave 1) - ag sec 7 post planting
* ***********************************************************************

* load data
	use 		"$root/sect7_pp_w1", clear
	
* ***********************************************************************
**#2 - extension access
* ***********************************************************************

	isid		holder_id

* did respondant participate in extension program
	gen 		extension = 0
	replace		extension = 1 if pp_s7q04 == 1
	replace 	extension = 0 if pp_s7q04 == 2
	
* generate year
	gen 		year = 2011
	
	lab var 	year "year of survey- wv1 2011"
	lab var 	extension "does respondent have access to extension?"
	rename 		household_id hhid
	rename 		saq01 region
	rename  	saq02 zone
	rename 		saq03 woreda
	rename 		saq04 kebele
	rename 		saq05 ea	
	

* drop what we don't need 
	keep 		hhid holder_id extension year zone region woreda kebele ea
	
* prepare for export
	isid			holder_id
	describe
	summarize 
	save 			"$export/pp_sect7.dta", replace
	
* close the log
	log	close

/* END */