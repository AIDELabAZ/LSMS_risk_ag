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
	global root 	"$data/raw_lsms_data/tanzania/wave_2/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_2"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wv2_CMSECB", append

	
* ***********************************************************************
**#1 - prepare TZA 2010 (Wave 2) - Community Section B
* ***********************************************************************

* load data
	use 		"$root/COMSEC_CB", clear
	
	
	drop cm_b02 cb0
	
	keep if cboa == "L" | cboa == "M"
	
	reshape wide cm_b01 cm_b03, i(id_01 id_02 id_03 id_04) j(cboa) string
	
	rename cm_b03L dist_daily
	rename cm_b03M dist_weekly
	
	replace dist_daily = 0 if cm_b01L == 1 
	replace dist_weekly = 0 if cm_b01M == 1 
	* do this for the weekly market 
	
	drop cm_b01*
	
* merge in agrodealer and repeat ^ 
	merge 1:1 id_01 id_02 id_03 id_04 using "$root/COMSEC_CE"
	* 360 merged 33 didnt

* generate year
	gen year = 2010
	

* is it possible to buy improved seeds in village? if possible dist = 0
	replace cm_e07_d = 0 if cm_e05 == 1
	
	
* drop what we don't need
	keep id_01 id_02 id_03 id_04 dist_daily dist_weekly cm_e07_d year
	
	* add for ce file 
	* drop everything that isn't the distance to the input dealer 
	* save it 
	
	* merge together the cb and ce 
	
	* rename everything
	rename id_01 	region
	rename id_02 	district
	rename id_03 	ward
	rename id_04	ea
	rename cm_e07_d out_supply
	
	lab var year "year of survey- wv2 2010"
	* generate year 

* prepare for export
	isid			region district ward ea
	describe
	summarize 
	save 			"$export/CMSEC.dta", replace
	


* close the log
	log	close

/* END */
	