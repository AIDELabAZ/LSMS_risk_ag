* Project: WB Weather
* Created on: Feb 2024
* Created by: reece
* Edited on: 20 oct 2024
* Edited by: reece
* Stata v.18

* does
	* cleans Tanzania household variables, wave 7 (NPSY5) hh secA
	* pulls regional identifiers

* assumes
	* access to all raw data

* TO DO:
	* complete

************************************************************************
**#0 - setup
************************************************************************

* define paths
	global root 	"$data/raw_lsms_data/tanzania/wave_7/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_7"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"
	
* open log
	cap log close 
	log	using	"$logout/wv7_HHSECA", append
	

*************************************************************************
**#1 - TZA 2020 (Wave 7) - Household Section A
***********************1*************************************************

* load data
	use 		"$root/hh_sec_a", clear
	
* dropping duplicates
	duplicates 	drop
	*** 0 obs dropped

* renaming some variables
	rename		hh_a01_1 region
	rename		hh_a02_1 district
	rename		y5_panelweight hhweight
	rename		hh_a10 mover2020
	rename 		hh_a03_1 ward
	rename		hh_a04_1 ea
	

* keep variables of interest
	keep 		y5_hhid region district y5_rural ///
					clusterid strataid hhweight y4_hhid mover2020 ward ea

	order		y4_hhid y5_hhid region district ward ea y5_rural ///
					clusterid strataid hhweight mover2020
	
* relabel variables
	lab var		y5_hhid "Unique Household Identification NPS Y5"
	lab var		region "Region Code"
	lab var		district "District Code"
	lab var		y5_rural "Cluster Type"
	lab var		clusterid "Unique Cluster Identification"
	lab var		strataid "Design Strata"
	lab var		hhweight "Household Weights (Trimmed & Post-Stratified)"
	lab var		mover2020 "Original or split household"
	lab var		ward "Ward Code"
	lab var 	ea "EA Code"
					
* prepare for export
	compress
	describe
	summarize
	sort y5_hhid
	
	save 			"$export/HH_SECA.dta", replace

* close the log
	log	close

/* END */
