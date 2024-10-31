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
	global root 	"$data/raw_lsms_data/uganda/wave_7/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/uganda/wave_7"
	global logout 	"$data/lsms_risk_ag_data/refined_data/uganda/logs"

* open log 
	cap log close 
	log using "$logout/2018_csect2a", append
	
* ***********************************************************************
**#1 - prepare uganda 2018 (Wave 7) - Community Section 2A
* ***********************************************************************

* load data
	use 		"$root/community/CSEC2", clear
	
	keep interview__key service_availabilty__id s2aq03_1 s2aq05 
	
* reshape
	
	keep if service_availabilty__id == 15 | service_availabilty__id == 16 | service_availabilty__id == 17 | service_availabilty__id == 24

	reshape wide s2aq03_1 s2aq05, i(interview__key) j(service_availabilty__id) 
	
	rename		s2aq0515 dist_supply
	rename  	s2aq0516 dist_agprod
	rename 		s2aq0517 dist_nonagprod
	rename 		s2aq0524 extension
	
	replace dist_supply = 0 if s2aq03_115 == 1 
	replace dist_agprod = 0 if s2aq03_116 == 1 
	replace dist_nonagprod = 0 if s2aq03_117 == 1
	replace extension = 0 if s2aq03_124 == 1
	* yes in village is always 0, to avoid unreasonable in-village values
	
	drop		s2aq03_1*
	
	merge 1:1 interview__key using "$root/community/CSEC1A"
	drop	_merge
	* 277 matched 28 not matched
	
* drop what we dont need
	keep interview__key dist_supply dist_agprod dist_nonagprod extension EA_code c1aq01b c1aq02b c1aq03b s1aq04b s1aq05b
	
* generate year
	gen			year = 2018
	lab var year "year of survey- wv7 2018"
	

* relabel 
	lab var dist_supply "distance to agrodealer"
	lab var dist_agprod "distance to market selling agricultural produce"
	lab var dist_nonagprod "distance to market selling nonag produce"
	lab var extension "distance to extension"
	
* rename vars
	rename c1aq01b district
	rename EA_code village
	rename c1aq03b subcounty
	rename s1aq04b parish
	rename c1aq02b county
	rename s1aq05b ea

	drop if missing(village) | missing(district) | missing(subcounty) | missing(parish) | missing(county) | missing(ea)
	* 27 obs dropped
	
* prepare for export
	isid			district village subcounty parish ea
	* some observations missing all? dropping for now 
	describe
	summarize 
	save 			"$export/com_sect2a.dta", replace
	


* close the log
	log	close

/* END */
	