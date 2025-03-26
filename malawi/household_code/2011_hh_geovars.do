* Project: lsms risk ag
* Created on: 25 Mar 2025
* Created by: reece
* Edited on: 25 Mar 2025
* Edited by: reece
* Stata v.18

* does
	* cleans community data- daily and weekly market
	* outputs ea level data for merging with extension data
	
* assumes
	* access to all raw data

* TO DO:
	* done
	
	
* **********************************************************************
**#0 - setup
* **********************************************************************

* define paths
	global root 	"$data/raw_lsms_data/nigeria/wave_1/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/nigeria/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/nigeria/logs"

* open log 
	cap log close 
	log using "$logout/2011_hh_geovars", append

	
* ***********************************************************************
**#1 - prepare ethiopia 2011 (Wave 1) - Community Section 4
* ***********************************************************************

* load data
	use 		"$root/NGA_HouseholdGeovariables_Y1", clear
	
	keep zone state lga sector ea hhid lat_dd_mod lon_dd_mod qa_type dist_road dist_popcenter dist_market

* generate year
	gen year = 2011
	lab var year "year of survey- wv1 2011"


	secta5a_harvestw1
	* file for extension to merge in later
	
* prepare for export
	isid			region zone woreda kebele ea
	describe
	summarize 
	save 			"$export/com_sect4.dta", replace
	


* close the log
	log	close

/* END */
	