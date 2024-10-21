* Project: WB Weather
* Created on: oct 14
* Created by: reece
* Edited on: oct 14 2024
* Edited by: reece
* Stata v.18

* does
	* cleans community data- daily and weekly market, distance to input supplier, year, region, district, ward, ea
	
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
	global root 	"$data/raw_lsms_data/tanzania/wave_1/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wv1_CMSECB", append

	
* ***********************************************************************
**#1 - prepare TZA 2008 (Wave 1) - Community Section B
* ***********************************************************************

* load data
	use 		"$root/SEC_B", clear
	
	
	drop cb2 ea_id locality
	
	keep if cb0 == 12 | cb0 == 13
	
	drop if missing(region) | missing(district) | missing(ward) | missing(ea)
	* 6 obs missing all regional identifiers, dropping these to reshape
	
	reshape wide cb1 cb3, i(region district ward ea) j(cb0)
	
	rename cb312 dist_daily
	rename cb313 dist_weekly
	
	replace dist_daily = 0 if cb112 == 1 
	replace dist_weekly = 0 if cb113 == 1 
	
	drop 	cb1*
	
* merge in agrodealer and repeat ^ 
	merge 1:1  using "$root/SEC_E_F_G"
	* 10,819 matched, 997 not matched from master

* generate year
	gen year = 2008
	
* drop what we don't need
	keep id_01 id_02 id_03 id_04 dist_daily dist_weekly cm_e07_d year
	rename cm_e07_d dist_supply
	* generate year 

* prepare for export
	isid			region district ward ea
	describe
	summarize 
	save 			"$export/CMSEC.dta", replace
	


* close the log
	log	close

/* END */
	