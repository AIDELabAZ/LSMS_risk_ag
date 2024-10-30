* Project: WB Weather
* Created on: oct 16
* Created by: reece
* Edited on: oct 18 2024
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
	global root 	"$data/raw_lsms_data/tanzania/wave_5/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_5"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wv5_CMSECB", append

	
* ***********************************************************************
**#1 - prepare TZA 2014xp (Wave 5) - Community Section B
* ***********************************************************************

* load data
	use 		"$root/COM_SEC_CB", clear
	

	
* drop cost of transportation, basic services, name of service/institution
	drop cb2 cb0 cb4 occ
	
	keep if cboa == "L" | cboa == "M"

	reshape wide cb1 cb3, i( y4_cluster ) j(cboa) string

	rename cb3L dist_daily
	rename cb3M dist_weekly
	
	replace dist_daily = 0 if cb1L == 1 
	replace dist_weekly = 0 if cb1M == 1 

	
	drop cb1*
	
* merge in regional identifiers 
	merge 1:1 y4_cluster using "$root/com_sec_a1a2"
	drop _merge
	* all matched
		
* merge in agrodealer and repeat ^ 
	merge 1:1 y4_cluster using "$root/COM_SEC_CE"
	* all matched

* generate year
	gen year = 2014
	

* is it possible to buy improved seeds in village? if possible dist = 0
	replace cm_e07_2 = 0 if cm_e05 == 1
	
* drop what we don't need
	keep id_01 id_02 id_03 id_05 dist_daily dist_weekly cm_e07_2 year
	
	
* rename everything
	rename id_01 	region
	rename id_02 	district
	rename id_03 	ward
	rename id_05	ea
	rename cm_e07_2 out_supply
	
	lab var year	"year of survey- wv4 2014 extended panel"
	* generate year 

* prepare for export
	isid			region district ward ea
	describe
	summarize 
	save 			"$export/CMSEC.dta", replace
	


* close the log
	log	close

/* END */ 
