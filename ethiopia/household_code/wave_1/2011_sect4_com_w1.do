* Project: WB Weather
* Created on: oct 22
* Created by: reece
* Edited on: oct 22 2024
* Edited by: reece
* Stata v.18

* does
	* cleans community data- daily and weekly market, distance to input supplier, year, region, district, ward, ea
	*harvest
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
	global root 	"$data/raw_lsms_data/ethiopia/wave_1/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/sect4_com_w1", append

	
* ***********************************************************************
**#1 - prepare Nigeria 2010 (Wave 1) - Community Section B
* ***********************************************************************

* load data
	use 		"$root/sect4_com_w1", clear
	
	
	keep cs4q14 cs4q15_1  sa1q01 sa1q02 sa1q03 sa1q04 sa1q05 sa1q06 sa1q07
	
	reshape wide sc2q1 sc2q3, i(sa1q01 sa1q02 sa1q03 sa1q07) j(is_cd)
	
	rename sc2q3219 dist_market

	
	replace dist_market = 0 if sc2q1219 == 1 

	drop 	sc2q1*
	
* merge in agrodealer and repeat ^ 
	merge 1:1 region ward district ea using "$root/SEC_E_F_G"
	* 404 matched, 3 not matched from using

* generate year
	gen year = 2010
	
* drop what we don't need
	keep region ward district ea dist_daily dist_weekly ce05 year
	rename ce05 out_supply
	
	replace out_supply = 0 if out_supply == 1
	replace out_supply = 1 if out_supply == 2
	
	lab var out_supply "Is it possible to buy improved seeds in this village? (0 = in village 1 = out of village) "
	
* prepare for export
	isid			zone state lga sector ea
	describe
	summarize 
	save 			"$export/ph_sectc.dta", replace
	


* close the log
	log	close

/* END */
	