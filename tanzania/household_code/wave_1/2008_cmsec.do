* Project: LSMS Risk Ag
* Created on: Oct 2024
* Created by: reece
* Edited on: 12 Nov 2024
* Edited by: jdm
* Stata v.18.5

* does
	* reads in Tanzania wave 1 community survey
	* cleans community data
		* daily and weekly market
		* distance to input supplier
	* outputs community file for merging
	
* assumes
	* access to all raw data

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
	log 	using 	"$logout/2008_CMSECB", append

	
************************************************************************
**# 1 - prepare TZA 2008 (Wave 1) - Community Section B
************************************************************************

* load data
	use 		"$root/SEC_B", clear
	
	drop 		cb2 ea_id locality
	
	keep if 	cb0 == 12 | cb0 == 13
	
	drop if 	missing(region) | missing(district) | missing(ward) | missing(ea)
	* 6 obs missing all regional identifiers, dropping these to reshape
	
	reshape 	wide cb1 cb3, i(region district ward ea) j(cb0)
	
	rename 		cb312 dist_daily
	rename 		cb313 dist_weekly
	
	replace 	dist_daily = 0 if cb112 == 1 
	replace 	dist_weekly = 0 if cb113 == 1 
	
	drop 		cb1*
	
* merge in agrodealer and repeat ^ 
	merge 1:1 	region ward district ea using "$root/SEC_E_F_G"
	* 404 matched, 3 not matched from using
	
* drop what we don't need
	keep 		region ward district ea dist_daily dist_weekly ce05
	rename 		ce05 out_supply
	
	replace 	out_supply = 0 if out_supply == 1
	replace 	out_supply = 1 if out_supply == 2
	
	lab var 	out_supply "Buy improved seeds in this village? (0 = in village 1 = out of village)"
	
	
************************************************************************
**# 2 - end matter, clean up to save
************************************************************************
	
* rename political locality vars
	rename		region admin_1
	rename 		district admin_2
	rename 		ward admin_3
	
	lab var		admin_1 "Region Code"
	lab var		admin_2 "District Code"
	lab var		admin_3 "Ward Code"
	lab var		ea "Enumeration Area Code"
	
* prepare for export
	isid			admin_1 admin_2 admin_3 ea

	compress
	
	save 			"$export/2008_CMSEC.dta", replace

* close the log
	log	close

/* END */
	