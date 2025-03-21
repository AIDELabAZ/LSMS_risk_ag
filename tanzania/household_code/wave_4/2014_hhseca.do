* Project: WB Weather
* Created on: May 2020
* Created by: McG
* Edited on: oct 21 2024
* Edited by: reece
* Stata v.18

* does
	* cleans Tanzania household variables, wave 4 hh secA
	* pulls regional identifiers

* assumes
	* access to all raw data

* TO DO:
	* completed

	
* **********************************************************************
* 0 - setup
* **********************************************************************

* define paths
	global root 	"$data/raw_lsms_data/tanzania/wave_4/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_4"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"

* open log
	cap log close 
	log	using	"$logout/wv4_HHSECA", append

*************************************************************************
**#1 - TZA 2014 (Wave 4) - Household Section A
***********************1*************************************************

* load data
	use 		"$root/hh_sec_a", clear
	
* dropping duplicates
	duplicates 	drop
	*** 0 obs dropped
	
	drop y4_rural 
	
* renaming some variables
	rename		hh_a01_1 region
	rename		hh_a02_1 district
	rename		hh_a03_1 ward
	rename		hh_a04_1 ea
	rename		y4_weights y4_weight
	rename		clustertype y4_rural

* keep variables of interest
	keep 		y4_hhid region district ward ea y4_rural ///
					clusterid strataid y4_weight occ

	order		y4_hhid region district ward ea y4_rural ///
					clusterid strataid y4_weight 
	
	rename		y4_weight hhweight
	
* relabel variables
	lab var		y4_hhid "Unique Household Identification NPS Y4"
	lab var		region "Region Code"
	lab var		district "District Code"
	lab var		ward "Ward Code"
	lab var		ea "Village / Enumeration Area Code"
	lab var		y4_rural "Cluster Type"
	lab var		clusterid "Unique Cluster Identification"
	lab var		strataid "Design Strata"
	lab var		hhweight "Household Weights (Trimmed & Post-Stratified)"
					
* prepare for export
	compress
	describe
	summarize
	sort y4_hhid
	
	save 			"$export/HH_SECA.dta", replace


* close the log
	log	close

/* END */
