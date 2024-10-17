* Project: WB Weather
* Created on: oct 16
* Created by: reece
* Edited on: oct 16 2024
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
	global root 	"$data/household_data/tanzania/wave_4/raw"
	global export 	"$data/household_data/tanzania/wave_4/refined"
	global logout 	"$data/household_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wv6_CMSECB", append

	
* ***********************************************************************
**#1 - prepare TZA 2019 (Wave 6) - Community Section B
* ***********************************************************************

* load data
	use 		"$root/COM_SEC_CB", clear
	
	*keep if cboa == "L" | cboa == "M"
	encode cboa, gen(cboa_num)

	replace cboa_num = 12 if cboa == "L"
	replace cboa_num = 13 if cboa == "M"
	
	gen dist_daily = cb3 if cboa_num == 12 
	replace dist_daily = 0 if cb1 == 1 
	
	gen dist_weekly = cb3 if cboa_num == 13 
	replace dist_weekly = 0 if cb1 == 1 
	* do this for the weekly market 
	
* merge in agrodealer and repeat ^ 
	merge m:1 y4_cluster using "$root/com_sec_ce"
	* all matched

* generate year
	gen year = 2014
	
* drop what we don't need
	keep y4_cluster dist_daily dist_weekly cm_e07_2 year occ
	* this file does not have region district ward ea
	* can use occ + hhid as unique identifer

	* rename everything
	*rename id_01 	region
	*rename id_02 	district
	*rename id_03 	ward
	*rename id_04	ea
	rename cm_e07_2 dist_supply
	* generate year 

* prepare for export
	isid			y4_cluster occ
	describe
	summarize 
	save 			"$export/CMSEC.dta", replace
	


* close the log
	log	close

/* END */
	