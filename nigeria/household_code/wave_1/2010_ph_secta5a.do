* Project: WB Weather
* Created on: oct 22
* Created by: reece
* Edited on: oct 23 2024
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
	global root 	"$data/raw_lsms_data/nigeria/wave_1/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/nigeria/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/nigeria/logs"

* open log 
	cap log close 
	log using "$logout/wv1_ph_secta5a", append
	
* ***********************************************************************
**#1 - prepare TZA 2010 (Wave 1) - ag sec 5a post harvest
* ***********************************************************************

* load data
	use 		"$root/secta5a_harvestw1", clear
	
* ***********************************************************************
**#2 - extension access
* ***********************************************************************


* did respondant receive advice
	keep if topic_cd == 1 | topic_cd == 2 | topic_cd == 3 | topic_cd == 4 | topic_cd == 5
	drop sa5aq2a sa5aq2b trackingobs
	
	replace sa5aq1 = 0 if sa5aq1 == 2
	
	reshape wide sa5aq1, i(zone state lga sector ea hhid) j(topic_cd)
	
	egen extension = rowtotal(sa5aq11 sa5aq12 sa5aq13 sa5aq14 sa5aq15)
	replace extension = 1 if extension > 0
	
	
* generate year
	gen 		year = 2010
	
	lab var year "year of survey- wv1 2010"
	lab var extension "does respondent have access to extension?"

* drop what we don't need 
	keep hhid extension year zone state lga sector ea
	
	
* prepare for export
	isid			hhid zone state lga sector ea
	describe
	summarize 
	save 			"$export/ph_secta5a.dta", replace
	


* close the log
	log	close

/* END */