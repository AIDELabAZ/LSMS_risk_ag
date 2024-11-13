* Project: LSMS Risk Ag
* Created on: Nov 2024
* Created by: jdm
* Edited on: 12 Nov 2024
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

	
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root 	"$data/raw_lsms_data/tanzania/wave_1/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"

* open log 
	cap 	log 	close 
	log 	using 	"$logout/2008_HHSECA", append

************************************************************************
**# 1 - TZA 2008 (Wave 1) - Household Section A
************************************************************************

* load data
	use 		"$root/SEC_A_T", clear
	
* dropping duplicates
	duplicates 	drop
	*** 0 obs dropped

* keep variables of interest
	keep		hhid hh_weight clusterid strataid ///
					region district ward ea ///
					locality
					
* rename variables
	rename		hh_weight wgt
	rename		locality sector
	rename		region admin_1
	rename 		district admin_2
	rename 		ward admin_3
	
	order		hhid admin_1 admin_2 admin_3 ea sector ///
					clusterid strataid wgt
	
* relabel variables
	lab var		hhid "Household Identification NPS Y1"
	lab var		admin_1 "Region Code"
	lab var		admin_2 "District Code"
	lab var		admin_3 "Ward Code"
	lab var		ea "Enumeration Area Code"
	lab var		sector "Urban/Rural Identifier"
	lab var		clusterid "Cluster Identification"
	lab var		strataid "Design Strata"
	lab var		wgt "Household Weights"
	
* prepare for export
	isid			hhid

	compress

* save file		
	save 			"$export/HH_SECA.dta", replace
	

* close the log
	log	close

/* END */
