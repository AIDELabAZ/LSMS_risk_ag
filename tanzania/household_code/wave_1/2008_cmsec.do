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
	global root 	"$data/household_data/tanzania/wave_1/raw"
	global export 	"$data/household_data/tanzania/wave_1/refined"
	global logout 	"$data/household_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wv1_CMSECB", append

	
* ***********************************************************************
**#1 - prepare TZA 2010 (Wave 2) - Community Section B
* ***********************************************************************

* load data
	use 		"$root/SEC_B", clear
	
	
	drop cb2 
	
	*keep if cboa == "L" | cboa == "M"
	*encode cboa, gen(cboa_num)

	*replace cboa_num = 12 if cboa == "L"
	*replace cboa_num = 13 if cboa == "M"
	
	gen dist_daily = cb3 if cb0 == 12 
	replace dist_daily = 0 if cb1 == 1 
	
	gen dist_weekly = cb3 if cb0 == 13 
	replace dist_weekly = 0 if cb1 == 1 
	* do this for the weekly market 
	
* merge in agrodealer and repeat ^ 
	merge m:1 id_01 id_02 id_03 id_04 using "$root/COMSEC_CE"
	* 10,819 matched, 997 not matched from master

* generate year
	gen year = 2010
	
* drop what we don't need
	keep id_01 id_02 id_03 id_04 dist_daily dist_weekly cm_e07_d year
	
	* add for ce file 
	* drop everything that isn't the distance to the input dealer 
	* save it 
	
	* merge together the cb and ce 
	
	* rename everything
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
	