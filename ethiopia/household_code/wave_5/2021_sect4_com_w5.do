* Project: WB Weather
* Created on: oct 28
* Created by: reece
* Edited on: oct 28 2024
* Edited by: reece
* Stata v.18

* does
	* cleans community data- daily and weekly market, year, region, district, ward, ea
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
	global root 	"$data/raw_lsms_data/ethiopia/wave_5/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_5"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/sect4_com_w5", append

	
* ***********************************************************************
**#1 - prepare ethiopia 2021 (Wave 5) - Community Section 4
* ***********************************************************************

* load data
	use 		"$root/sect04_com_w5", clear
	
	keep saq01 saq02 saq03 saq06 saq07 cs4q14 cs4q15 ea_id
	
* distance to weekly market? (only weekly available)
	
	rename cs4q15 dist_weekly
	replace dist_weekly = 0 if cs4q14 == 1 
	
	drop cs4q14
	

* generate year
	gen year = 2021
	lab var year "year of survey- wv5 2021"
	
* rename vars
	rename saq01 region
	rename saq02 zone
	rename saq03 woreda
	rename saq06 kebele
	rename saq07 ea
	
	
* prepare for export
	isid			region zone woreda kebele ea ea_id
	describe
	summarize 
	save 			"$export/com_sect4.dta", replace
	


* close the log
	log	close

/* END */
	