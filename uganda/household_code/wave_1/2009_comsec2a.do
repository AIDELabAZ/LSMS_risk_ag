* Project: WB Weather
* Created on: oct 29
* Created by: reece
* Edited on: oct 29 2024
* Edited by: reece
* Stata v.18

* does
	* cleans community data- daily and weekly market, year, region, district, ward, ea
	*harvest
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
	global root 	"$data/raw_lsms_data/uganda/wave_1/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/uganda/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/uganda/logs"

* open log 
	cap log close 
	log using "$logout/2009_csect2a", append
	
* ***********************************************************************
**#1 - prepare ethiopia 2009 (Wave 1) - Community Section 4
* ***********************************************************************

* load data
	use 		"$root/2009_CSECTION2A", clear
	
	keep Comcod C2asn  C2aq3 C2aq5
	
* reshape
	
	keep if C2asn == 15 | C2asn == 16 | C2asn == 17 | C2asn == 24
	
	
	reshape wide C2aq3 C2aq5, i(Comcod) j(C2asn) 
	
	rename		C2aq515 dist_supply
	rename  	C2aq516 dist_agprod
	rename 		C2aq517 dist_nonagprod
	rename 		C2aq524 extension
	
	replace dist_supply = 0 if C2aq315 == 1 
	replace dist_agprod = 0 if C2aq316 == 1 
	replace dist_nonagprod = 0 if C2aq317 == 1
	replace extension = 0 if C2aq324 == 1
	
	drop		C2aq3*
	
	merge 1:1 Comcod using "$root/2009_CSECTION1"
	drop	_merge
	* 299 matched 21 not matched
	
	keep Comcod dist_agprod dist_nonagprod dist_supply extension Year C1aq1 C1aq2 C1aq3 C1aq4 C1aq5 

	
* rename vars
	rename C1aq1 district
	rename C1aq2 county
	rename C1aq3 subcounty
	rename C1aq4 parish
	rename C1aq5 ea
	
* relabel 
	lab var dist_supply "distance to agrodealer"
	lab var dist_agprod "distance to market selling agricultural produce"
	lab var dist_nonagprod "distance to market selling nonag produce"
	lab var extension "distance to extension"
	
	
* prepare for export
	isid			region zone woreda kebele ea ea_id2
	describe
	summarize 
	save 			"$export/com_sect4.dta", replace
	


* close the log
	log	close

/* END */
	