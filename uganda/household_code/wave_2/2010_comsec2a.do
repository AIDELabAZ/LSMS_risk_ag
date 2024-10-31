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
	global root 	"$data/raw_lsms_data/uganda/wave_2/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/uganda/wave_2"
	global logout 	"$data/lsms_risk_ag_data/refined_data/uganda/logs"

* open log 
	cap log close 
	log using "$logout/2010_csect2a", append
	
* ***********************************************************************
**#1 - prepare ethiopia 2009 (Wave 1) - Community Section 4
* ***********************************************************************

* load data
	use 		"$root/CSECTION2A", clear
	
	keep comcod c2asn  c2aq3 c2aq5
	
* reshape
	
	keep if c2asn == 15 | c2asn == 16 | c2asn == 17 | c2asn == 24
	duplicates drop comcod c2asn, force
	
	reshape wide c2aq3 c2aq5, i(comcod) j(c2asn) 
	
	rename		c2aq515 dist_supply
	rename  	c2aq516 dist_agprod
	rename 		c2aq517 dist_nonagprod
	rename 		c2aq524 extension
	
	replace dist_supply = 0 if c2aq315 == 1 
	replace dist_agprod = 0 if c2aq316 == 1 
	replace dist_nonagprod = 0 if c2aq317 == 1
	replace extension = 0 if c2aq324 == 1
	* yes in village is always 0, to avoid unreasonable in-village values
	
	drop		c2aq3*
	
	merge 1:1 comcod using "$root/CSECTION1"
	drop	_merge
	* 311 matched 11 not matched
	
	keep comcod dist_agprod dist_nonagprod dist_supply extension c1aq1 c1aq2 c1aq3 c1aq4 c1aq5 

	
* rename vars
	rename c1aq1 district
	rename c1aq2 county
	rename c1aq3 subcounty
	rename c1aq4 parish
	rename c1aq5 ea
	
	drop if county == .
	* dropping 1 observation, isid does not run if we don't
	* the district and ea for this obs are unique, don't think we can identify what this county is through other identifiers 
	
* relabel 
	lab var dist_supply "distance to agrodealer"
	lab var dist_agprod "distance to market selling agricultural produce"
	lab var dist_nonagprod "distance to market selling nonag produce"
	lab var extension "distance to extension"
	
	
* prepare for export
	isid			district county subcounty parish ea Comcod
	describe
	summarize 
	save 			"$export/com_sect4.dta", replace
	


* close the log
	log	close

/* END */
	