* Project: WB Weather
* Created on: oct 14
* Created by: reece
* Edited on: oct 14 2024
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
	global root 	"$data/household_data/tanzania/wave_2/raw"
	global export 	"$data/household_data/tanzania/wave_2/refined"
	global logout 	"$data/household_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wv2_CMSECB", append

	
* ***********************************************************************
**#1 - prepare TZA 2010 (Wave 2) - Community Section B
* ***********************************************************************

* load data
	use 		"$root/COMSEC_CB", clear
	
	
	drop cm_b01 cm_b02 
	
	keep if cboa == "L" | cboa == "M"
	encode cboa, gen(cboa_num)

	replace cboa_num = 12 if cboa == "L"
	replace cboa_num = 13 if cboa == "M"
	
	reshape wide cm_b03, i(id_01 id_02 id_03 id_04) j(cboa_num)
	
	gen dist_mkt = cm_b0312
	replace dist_mkt = cm_b0313 if dist_mkt == .
	
	drop cm_b0312 cm_b0313
	
	merge 1:1 interview__key using "$root/cm_sec_a"

	

	
	duplicates tag id_01 id_02 id_03 id_04 id_05, generate(dup)
	
	drop if cm_a05 == "" & dup > 0
	drop if id_05 == . & dup > 0
	
	drop if cm_start == "" & dup >0 
	
	replace id_02 = 129 if id_01 == 12 & id_03 == 121
	drop if id_02 == .
	
	drop if id_03 == .
	drop if id_05 == .
	
* prepare for export
	isid			id_01 id_02 id_03 id_04 id_05
	compress
	describe
	summarize 
	save 			"$export/2010_CMSEC.dta", replace

* close the log
	log	close

/* END */
	