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
	global root 	"$data/raw_lsms_data/tanzania/wave_6/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_6"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"


* open log 
	cap log close 
	log using "$logout/wv6_CMSECB", append

	
* ***********************************************************************
**#1 - prepare TZA 2019 (Wave 6) - Community Section B
* ***********************************************************************

* load data
	use 		"$root/cm_sec_b", clear
	
	
	drop  cm_b02 cm_b04 interview__id
	
	keep if service_id == 12 | service_id == 13
	
	reshape wide cm_b01 cm_b03, i(interview__key) j(service_id)
	
	*gen dist_mkt = cm_b0312
	*replace dist_mkt = cm_b0313 if dist_mkt == .
	
	rename		cm_b0312 dist_daily
	rename 		cm_b0313 dist_weekly
	drop		cm_b01*
	
	merge 1:1 interview__key using "$root/cm_sec_a"
	drop	_merge

* merge in agrodealer and repeat ^ 
	merge 1:1 interview__key using "$root/CM_SEC_E"
	* all matched

* generate year
	gen year = 2019
	
	keep dist_daily dist_weekly year interview__key cm_e07_2 id_01 id_02 id_03 id_05
	
	rename id_01 	region
	rename id_02 	district
	rename id_03 	ward
	rename id_05	ea
	rename cm_e07_2	dist_supply
	
	lab var region "region"
	lab var district "district"
	lab var ward "ward"
	lab var ea "ea"
	lab var year "year of survey wv6 2019"
	
* prepare for export
	isid			region district ward ea
	* need to revisit, "vars should never be missing"
	compress
	describe
	summarize 
	save 			"$export/2020_CMSEC.dta", replace

* close the log
	log	close

/* END */
	