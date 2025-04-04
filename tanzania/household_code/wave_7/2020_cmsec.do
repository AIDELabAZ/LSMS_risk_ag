* Project: WB Weather
* Created on: oct 16 2014
* Created by: reece
* Edited on: oct 20 2024
* Edited by: reece
* Stata v.18

* does
	* cleans community data- daily and weekly market
	
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
	global root 	"$data/raw_lsms_data/tanzania/wave_7/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_7"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"


* open log 
	cap log close 
	log using "$logout/wv7_CMSECB", append

	
* ***********************************************************************
**#1 - prepare TZA 2020 (Wave 7) - Community Section B
* ***********************************************************************

* load data
	use 		"$root/cm_sec_b", clear
	
	
	drop  cm_b02 cm_b04 interview__id
	
	keep if service_id == 12 | service_id == 13
	
	reshape wide cm_b01 cm_b03, i(interview__key) j(service_id)
	
	rename		cm_b0312 dist_daily
	rename 		cm_b0313 dist_weekly
	
	replace 	dist_daily = 0 if cm_b0112 == 1
	replace 	dist_weekly = 0 if cm_b0113 == 1
	
	drop		cm_b01*
	
	merge 1:1 interview__key using "$root/cm_sec_a"
	drop	_merge
	* all matched

* merge in agrodealer and repeat ^ 
	merge 1:1 interview__key using "$root/CM_SEC_E"
	* all matched

* generate year
	gen year = 2020
	

* is it possible to buy improved seeds in village? if possible dist = 0
	replace cm_e07_2 = 0 if cm_e05 == 1
	
	duplicates tag id_01 id_02 id_03 id_04 id_05, generate(dup)
	drop if cm_a05 == "" & dup > 0
	drop if id_05 == . & dup > 0
	
	drop if cm_start == "" & dup >0 
	
	replace id_02 = 129 if id_01 == 12 & id_03 == 121
	drop if id_02 == .
	
	drop if id_03 == .
	drop if id_05 == .
	
	keep dist_daily dist_weekly year interview__key cm_e07_2 id_01 id_02 id_03 id_05
	gen country = "Tanzania"
	gen wave = 5 
	
	
	rename id_01 	region
	rename id_02 	district
	rename id_03 	ward
	rename id_05	ea
	rename cm_e07_2	out_supply
	
	lab var region "region"
	lab var district "district"
	lab var ward "ward"
	lab var ea "ea"
	lab var dist_daily "distance to daily market"
	lab var dist_weekly "distance to weekly market"
	lab var year "year of survey wv7 2020"
	
* prepare for export
	isid			region district ward ea interview__key
	compress
	describe
	summarize 
	save 			"$export/2020_CMSEC.dta", replace

* close the log
	log	close

/* END */
	