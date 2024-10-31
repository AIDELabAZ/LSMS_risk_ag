* Project: WB Weather
* Created on: oct 29
* Created by: reece
* Edited on: oct 29 2024
* Edited by: reece
* Stata v.18

* does
	* cleans community data- ag produce market, non-ag produce market, ag inputs market (agrodealer), extension, year, regional identifiers
	
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
	global root 	"$data/raw_lsms_data/uganda/wave_4/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/uganda/wave_4"
	global logout 	"$data/lsms_risk_ag_data/refined_data/uganda/logs"

* open log 
	cap log close 
	log using "$logout/2013_csect2a", append
	
* ***********************************************************************
**#1 - prepare uganda 2013 (Wave 4) - Community Section 2A
* ***********************************************************************

* load data
	use 		"$root/community/CSEC2a", clear
	
	keep District_Name SubCounty Parish Villagecode CFService_ID C2AQ3 C2AQ5
	
* reshape
	
	keep if CFService_ID == 15 | CFService_ID == 16 | CFService_ID == 17 | CFService_ID == 24
	duplicates drop District_Name SubCounty Parish Villagecode CFService_ID, force
	* drops 44 obs
	
	reshape wide C2AQ3 C2AQ5, i(District_Name SubCounty Parish Villagecode ) j(CFService_ID) 
	
	rename		C2AQ515 dist_supply
	rename  	C2AQ516 dist_agprod
	rename 		C2AQ517 dist_nonagprod
	rename 		C2AQ524 extension
	
	replace dist_supply = 0 if C2AQ315 == 1 
	replace dist_agprod = 0 if C2AQ316 == 1 
	replace dist_nonagprod = 0 if C2AQ317 == 1
	replace extension = 0 if C2AQ324 == 1
	* yes in village is always 0, to avoid unreasonable in-village values
	
	drop		C2AQ3*
	
* generate year
	gen			year = 2013
	lab var year "year of survey- wv4 2013"
	
* rename vars
	rename District_Name district
	rename Villagecode village
	rename SubCounty subcounty
	rename Parish parish

* relabel 
	lab var dist_supply "distance to agrodealer"
	lab var dist_agprod "distance to market selling agricultural produce"
	lab var dist_nonagprod "distance to market selling nonag produce"
	lab var extension "distance to extension"
	
	
* prepare for export
	isid			district village subcounty parish 
	describe
	summarize 
	save 			"$export/com_sect2a.dta", replace
	


* close the log
	log	close

/* END */
	