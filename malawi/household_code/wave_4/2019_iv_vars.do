* Project: WB Weather
* Created on: nov 8
* Created by: reece
* Edited on: nov 8 2024
* Edited by: reece
* Stata v.18

* does
	* cleans community data- daily and weekly market, distance to input supplier, access to extension, ea
	
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
	global root 	"$data/raw_lsms_data/malawi/wave_6/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/malawi/wave_6"
	global logout 	"$data/lsms_risk_ag_data/refined_data/malawi/logs"

* open log 
	cap log close 
	log using "$logout/wv6_com_cd", append

	
* ***********************************************************************
**#1 - prepare malawi 2019 (Wave 4) - Community Section CD
* ***********************************************************************

* load data
	use 		"$root/com_cd_19", clear
	
	
	keep com_cd15 com_cd16 com_cd17 com_cd18a com_cd19 com_cd20a ea_id 
	
	rename com_cd16 dist_daily
	rename com_cd18a dist_weekly 
	rename com_cd20a out_supply
	
	replace dist_daily = 0 if com_cd15 == 1 
	replace dist_weekly = 0 if com_cd17 == 1 
	replace out_supply = 0 if com_cd19 == 1
	
	drop com_cd*
	
* merge in extension 
	merge 1:1 ea_id using "$root/com_cf1_19"
	* all matched
	
* grab exension var
	rename com_cf08a extension
	replace extension = 0 if com_cf07 == 1

* generate year
	gen year = 2019
	lab var year "year of survey wv4- 2019"
	
* drop what we don't need
	keep ea_id dist_daily dist_weekly out_supply extension year
	rename ea_id ea_id_merge

* prepare for export
	isid			ea_id_merge
	describe
	summarize 
	save 			"$export/com_sec.dta", replace
	


* close the log
	log	close

/* END */
	
