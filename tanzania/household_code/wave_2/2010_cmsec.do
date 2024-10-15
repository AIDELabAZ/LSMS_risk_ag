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
	
	
	drop cm_b02 
	
	keep if cboa == "L" | cboa == "M"
	encode cboa, gen(cboa_num)

	replace cboa_num = 12 if cboa == "L"
	replace cboa_num = 13 if cboa == "M"
	
	gen dist_daily = cm_b03 if cboa_num == 12 
	replace dist_daily = 0 if cm_b01 == 1 
	
	gen dist_daily = cm_b03 if cboa_num == 13 
	replace dist_daily = 0 if cm_b01 == 1 
	* do this for the weekly market 

	
* merge in agrodealer and repeat ^ 


	
	* add for ce file 
	* drop everything that isn't the distance to the input dealer 
	* save it 
	
	* merge together the cb and ce 
	
	* rename everything
	rename id_01 	region
	rename id_02 	district
	rename id_03 	ward
	rename id_04	ea
	rename cm_b03	dist_mkt
	rename cboa_num market
	* generate year 

* prepare for export
	isid			id_01 id_02 id_03 id_04
	describe
	summarize 
	save 			"$export/2010_CMSEC.dta", replace
	


* close the log
	log	close

/* END */
	