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
**#1 - prepare uganda 2010 (Wave 2) - Community Section 2A
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
	
* merge in location idenitfiers 
	*merge 1:1 comcod using "$root/CSECTION1"
	*drop	_merge
	*** unlike other uganda waves, csect1 lacks location identifiers
	*** location identifers exist in gsect1
	*** will use those identifers for this wave
	
	keep comcod dist_supply dist_agprod dist_nonagprod extension
	rename comcod comm
	

* relabel 
	lab var dist_supply "distance to agrodealer"
	lab var dist_agprod "distance to market selling agricultural produce"
	lab var dist_nonagprod "distance to market selling nonag produce"
	lab var extension "distance to extension"
	
	
* prepare for export
	isid			comm 
	describe
	summarize 
	save 			"$export/com_sect2a.dta", replace
	


* close the log
	log	close

/* END */
	