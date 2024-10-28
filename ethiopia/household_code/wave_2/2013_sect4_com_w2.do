* Project: WB Weather
* Created on: oct 22
* Created by: reece
* Edited on: oct 27 2024
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
	global root 	"$data/raw_lsms_data/ethiopia/wave_2/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_2"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/sect4_com_w2", append

	
* ***********************************************************************
**#1 - prepare ethiopia 2011 (Wave 1) - Community Section 4
* ***********************************************************************

* load data
	use 		"$root/sect4_com_w2", clear
	
	keep sa1q01 sa1q02 sa1q03 sa1q06 sa1q07 cs4q14 cs4q15 ea_id2
	
* distance to weekly market? (only weekly available)
	
	rename cs4q15 dist_weekly
	replace dist_weekly = 0 if cs4q14 == 1 
	
	drop cs4q14
	

* generate year
	gen year = 2013
	lab var year "year of survey- wv2 2013"
	
* rename vars
	rename sa1q01 region
	rename sa1q02 zone
	rename sa1q03 woreda
	rename sa1q06 kebele
	rename sa1q07 ea
	
	
* prepare for export
	isid			region zone woreda kebele ea ea_id2
	describe
	summarize 
	save 			"$export/com_sect4.dta", replace
	


* close the log
	log	close

/* END */
	