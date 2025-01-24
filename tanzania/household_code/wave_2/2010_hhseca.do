* Project: LSMS Risk Ag
* Created on: May 2020
* Created by: McG
* Edited on: 24 Jan 25
* Edited by: jdm
* Stata v.18.5

* does
	* reads in household Location data (SEC_A)
	* cleans
		* political geography locations
		* survey weights
	* outputs file of location for merging with other ag files that lack this info

* assumes
	* access to raw data
	
* TO DO:
	* done


* **********************************************************************
* 0 - setup
* **********************************************************************

* define paths
	global root 	"$data/raw_lsms_data/tanzania/wave_2/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_2"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"
	
* open log
	cap log 			close 
	log					using	"$logout/wv2_HHSECA", append
	

* ***********************************************************************
* 1 - TZA 2010 (Wave 2) - Household Section A
* *********************1*************************************************

* load data
	use 		"$root/HH_SEC_A", clear
	
* dropping duplicates
	duplicates 	drop
	*** 0 obs dropped

* keep variables of interest
	keep 		y2_hhid y2_weight clusterid strataid ///
					region district ward ea ///
					y2_rural hh_a11

* generate mover/stayer
	gen			mover_R1R2 = 1 if hh_a11 == 3
	replace		mover_R1R2 = 0 if mover_R1R2 == .
	lab var	 	mover_R1R2 "Household moved from its original 2008 sample"
	lab def		yesno 0 "No" 1 "Yes"
	lab val		mover_R1R2 yesno
	
* generate location variable
	rename		hh_a11 location_R1_to_R2
	lab var		location_R1_to_R2 "Household location category"
	lab def		location 1 "Original household in same location" ///
					2 "Original household in new location" ///
					3 "Split-off household"
	lab val		location_R1_to_R2 location

* replace two miscoded observations 
	replace 	location_R1_to_R2 = 1 if location_R1_to_R2 == . 
	replace		location_R1_to_R2 = 1 if location_R1_to_R2 == 6 
	
	order		y2_hhid region district ward ea y2_rural ///
					clusterid strataid y2_weight mover_R1R2 location_R1_to_R2
					
	rename		y2_weight wgt
	rename		y2_rural sector
	rename		region admin_1
	rename 		district admin_2
	rename 		ward admin_3
	
* relabel variables
	lab var		y2_hhid "Unique Household Identification NPS Y2"
	lab var		admin_1 "Region Code"
	lab var		admin_2 "District Code"
	lab var		admin_3 "Ward Code"
	lab var		ea "Enumeration Area Code"
	lab var		sector "Urban/Rural Identifier"
	lab var		clusterid "Cluster Identification"
	lab var		strataid "Design Strata"
	lab var		wgt "Household Weights (Trimmed & Post-Stratified)"
	
* prepare for export
	isid		y2_hhid

	compress

* save file			
	save 		"$export/HH_SECA.dta", replace

* close the log
	log	close

/* END */