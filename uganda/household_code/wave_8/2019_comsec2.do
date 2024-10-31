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
	global root 	"$data/raw_lsms_data/uganda/wave_8/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/uganda/wave_8"
	global logout 	"$data/lsms_risk_ag_data/refined_data/uganda/logs"

* open log 
	cap log close 
	log using "$logout/2019_csect2a", append
	
* ***********************************************************************
**#1 - prepare uganda 2019 (Wave 8) - Community Section 2A
* ***********************************************************************

* load data
	use 		"$root/community/CSEC2", clear
	
* reshape
	
	keep if Service_availabilty__id == 15 | Service_availabilty__id == 16 | Service_availabilty__id == 17 | Service_availabilty__id == 24
	drop interview__id

	reshape wide s2aq03, i(Final_EA_code) j(Service_availabilty__id) 
	
	rename		s2aq0315 dist_supply
	rename  	s2aq0316 dist_agprod
	rename 		s2aq0317 dist_nonagprod
	rename 		s2aq0324 extension
	
	replace dist_supply = 0 if dist_supply == 1 
	replace dist_agprod = 0 if dist_agprod == 1 
	replace dist_nonagprod = 0 if dist_nonagprod == 1
	replace extension = 0 if extension == 1
	
	replace dist_supply = 1 if dist_supply == 2 
	replace dist_agprod = 1 if dist_agprod == 2 
	replace dist_nonagprod = 1 if dist_nonagprod == 2
	replace extension = 1 if extension == 2
	* dist = 0 if in village, 1 if out of village
	* missing actualy distance values, only have availability
	
	
	merge 1:1 Final_EA_code using "$root/community/CSEC1A"
	drop	_merge
	* all matched
	
* drop what we dont need
	keep dist_supply dist_agprod dist_nonagprod extension Final_EA_code s1aq01b s1aq02b s1aq03b s1aq04b
	
* generate year
	gen			year = 2019
	lab var year "year of survey- wv8 2019"
	

* relabel 
	lab var dist_supply "distance to agrodealer"
	lab var dist_agprod "distance to market selling agricultural produce"
	lab var dist_nonagprod "distance to market selling nonag produce"
	lab var extension "distance to extension"
	
* rename vars
	rename s1aq01b district
	rename s1aq03b subcounty
	rename s1aq04b parish
	rename s1aq02b county
	rename Final_EA_code ea

	
* prepare for export
	isid			district county subcounty parish ea
	describe
	summarize 
	save 			"$export/com_sect2.dta", replace
	


* close the log
	log	close

/* END */
	