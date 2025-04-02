* Project: lsms risk ag
* Created on: 25 Mar 2025
* Created by: reece
* Edited on: 26 Mar 2025
* Edited by: reece
* Stata v.18

* does
	* gathers extension variable to be merged with IVs
	
* assumes
	* access to all raw data

* TO DO:
	* done
	
	
* **********************************************************************
**#0 - setup
* **********************************************************************

* define paths
	global root 	"$data/raw_lsms_data/nigeria/wave_4/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/nigeria/wave_4"
	global logout 	"$data/lsms_risk_ag_data/refined_data/nigeria/logs"

* open log 
	cap log close 
	log using "$logout/2018_secta5b_harvestw4", append

	
* ***********************************************************************
**#1 - prepare nigeria 2018 secta5a_harvestw4
* ***********************************************************************

* load data
	use 		"$root/secta5b_harvestw4", clear
	
	
* ***********************************************************************
**#2 - extension access
* ***********************************************************************

* did respondant participate in extension program
	gen extension = 0
	replace extension = 1 if sa5bq1a == 1 & inlist(source_cd, 1, 2, 5)

	collapse (sum) source_cd (max) extension , by(zone state lga sector ea hhid)
	
	drop if 		sector == .
	* missing 25 sector observations
	
	isid				zone state lga sector ea hhid 
	
* prepare for export
	isid			zone state lga sector ea hhid
	describe
	summarize 
	save 			"$export/2018_secta5a_harvestw4", replace
	

* close the log
	log	close

/* END */
	


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	