* Project: LSMS Risk Ag
* Created on: oct 14
* Created by: reece
* Edited on: 24 Jan 25
* Edited by: jdm
* Stata v.18.5

* does
	* reads in Tanzania wave 2 community survey
	* cleans community data
		* daily and weekly market
		* distance to input supplier
	* outputs community file for merging
	
* assumes
	* access to all raw data

* TO DO:
	* done
	
	
* **********************************************************************
**#0 - setup
* **********************************************************************

* define paths
	global root 	"$data/raw_lsms_data/tanzania/wave_2/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_2"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"

* open log 
	cap 	log 	close 
	log 	using 	"$logout/wv2_CMSECB", append

	
* ***********************************************************************
**#1 - prepare TZA 2010 (Wave 2) - Community Section B
* ***********************************************************************

* load data
	use 		"$root/COMSEC_CB", clear
	
	drop 		cm_b02 cb0
	
	keep if 	cboa == "L" | cboa == "M"
	
	reshape 	wide cm_b01 cm_b03, i(id_01 id_02 id_03 id_04) j(cboa) string
	
	rename 		cm_b03L dist_daily
	rename 		cm_b03M dist_weekly
	
	replace 	dist_daily = 0 if cm_b01L == 1 
	replace 	dist_weekly = 0 if cm_b01M == 1 

	
	lab var		dist_daily	"Distance (km) to daily market"
	lab var		dist_weekly	"Distance (km) to weekly market"
	
	drop 		cm_b01*

	
************************************************************************
**# 2 - merge in Community Section CE
************************************************************************
		
* merge in agrodealer and repeat ^ 
	merge 1:1 	id_01 id_02 id_03 id_04 using "$root/COMSEC_CE"
	* 360 merged 33 from master didnt

* is it possible to buy improved seeds in village? if possible dist = 0
	replace 	cm_e07_d = 0 if cm_e05 == 1
		
* drop what we don't need
	keep 		id_01 id_02 id_03 id_04 dist_daily dist_weekly cm_e07_d
	
	rename 		cm_e07_d dist_supply
	
	lab var 	dist_supply "Distance (km) to agrodealer"
	
	
************************************************************************
**# 3 - end matter, clean up to save
************************************************************************

* rename political locality vars
	rename id_01 	admin_1
	rename id_02 	admin_2
	rename id_03 	admin_3
	rename id_04	ea

	lab var		admin_1 "Region Code"
	lab var		admin_2 "District Code"
	lab var		admin_3 "Ward Code"
	lab var		ea "Enumeration Area Code"		

* prepare for export
	isid			admin_1 admin_2 admin_3 ea

	compress

* save ea level cmsec
	save 			"$export/CMSEC_ea.dta", replace

* save ward level cmsec
	drop			ea
	duplicates 		drop
	duplicates 		drop admin_1 admin_2 admin_3, force

	isid			admin_1 admin_2 admin_3

	save 			"$export/CMSEC_ward.dta", replace
	
* close the log
	log	close

/* END */
	