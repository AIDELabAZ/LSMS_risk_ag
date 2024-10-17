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
	global root 	"$data/household_data/tanzania/wave_3/raw"
	global export 	"$data/household_data/tanzania/wave_3/refined"
	global logout 	"$data/household_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wv3_CMSECB", append

	
* ***********************************************************************
**#1 - prepare TZA 2012 (Wave 3) - Community Section B
* ***********************************************************************

* load data
	use 		"$root/COM_SEC_CB", clear
	
	drop cm_b02 
	
	keep if cm_b0a == "L" | cm_b0a == "M"
	encode cm_b0a, gen(cboa_num)

	replace cboa_num = 12 if cm_b0a == "L"
	replace cboa_num = 13 if cm_b0a == "M"
	
	gen dist_daily = cm_b03 if cboa_num == 12 
	replace dist_daily = 0 if cm_b01 == 1 
	
	gen dist_weekly = cm_b03 if cboa_num == 13 
	replace dist_weekly = 0 if cm_b01 == 1 
	* do this for the weekly market 
	
* merge in agrodealer and repeat ^ 
	merge m:1 id_01 id_02 id_03 id_04 using "$root/COM_SEC_CE"
	* all matched

* generate year
	gen year = 2012
	
* drop what we don't need
	keep id_01 id_02 id_03 id_04 y3_cluster dist_daily dist_weekly cm_e07_2 year
	
	* add for ce file 
	* drop everything that isn't the distance to the input dealer 
	* save it 
	
	* merge together the cb and ce 
	
	* rename everything
	rename id_01 	region
	rename id_02 	district
	rename id_03 	ward
	rename id_04	ea
	rename cm_e07_2 dist_supply
	* generate year 

* prepare for export
	isid			region district ward ea
	describe
	summarize 
	save 			"$export/CMSEC.dta", replace
	


* close the log
	log	close

/* END */
	