* Project: WB Weather
* Created on: March 2024
* Created by: reece
* Edited on: oct 8 2024
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
	global root 	"$data/household_data/tanzania/wave_7/raw"
	global export 	"$data/household_data/tanzania/wave_7/refined"
	global logout 	"$data/household_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wv7_CMSECB", append

	
* ***********************************************************************
**#1 - prepare TZA 2020 (Wave 7) - Community Section B
* ***********************************************************************

* load data
	use 		"$root/cm_sec_b", clear
	
	
	drop cm_b01 cm_b02 cm_b04 interview__id
	
	keep if service_id == 12 | service_id == 13
	
	reshape wide cm_b03, i(interview__key) j(service_id)
	
	*gen dist_mkt = cm_b0312
	*replace dist_mkt = cm_b0313 if dist_mkt == .
	
	rename		cm_b0312 dist_daily
	rename 		cm_b0313 dist_weekly
	
	merge 1:1 interview__key using "$root/cm_sec_a"

	

	
	duplicates tag id_01 id_02 id_03 id_04 id_05, generate(dup)
	
	drop if cm_a05 == "" & dup > 0
	drop if id_05 == . & dup > 0
	
	drop if cm_start == "" & dup >0 
	
	replace id_02 = 129 if id_01 == 12 & id_03 == 121
	drop if id_02 == .
	
	drop if id_03 == .
	drop if id_05 == .
	
	rename id_01 	region
	rename id_02 	district
	rename id_03 	ward
	rename id_05	ea
	gen 	year = 2020
	
	keep region district ward ea dist_daily dist_weekly year interview__key id_04
	
* prepare for export
	isid			region district ward ea id_04
	compress
	describe
	summarize 
	save 			"$export/2020_CMSEC.dta", replace

* close the log
	log	close

/* END */
	
	