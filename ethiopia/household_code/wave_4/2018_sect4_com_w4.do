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
	global root 	"$data/raw_lsms_data/ethiopia/wave_4/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_4"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/sect4_com_w4", append

	
* ***********************************************************************
**#1 - prepare ethiopia 2018 (Wave 4) - Community Section 4
* ***********************************************************************

* load data
	use 		"$root/sect04_com_w4", clear
	
	*keep saq01 saq02 saq03 saq06 saq07 cs4q14 cs4q15 ea_id
	
* distance to weekly market? (only weekly available)
	
	rename cs4q15 dist_weekly
	replace dist_weekly = 0 if cs4q14 == 1 
	
	drop cs4q14
	

* generate year
	gen year = 2018
	lab var year "year of survey- wv4 2018"
	
* rename vars
	rename saq01 region
	rename saq02 zone
	rename saq03 woreda
	rename saq04 town
	rename saq05 subcity
	rename saq06 kebele
	rename saq07 ea

* gen ea_id_merge for lsms_base 
	gen region_str = cond(region < 10, "0" + string(region, "%12.0f"), string(region, "%12.0f"))
	*gen zone_str = cond(zone < 10, "0" + string(zone, "%12.0f"), string(zone, "%12.0f"))
	*gen woreda_str = cond(woreda < 10, "0" + string(woreda, "%12.0f"), string(woreda, "%12.0f"))
	gen town_str = cond(town < 10, "0" + string(town, "%12.0f"), string(town, "%12.0f"))
	gen subcity_str = cond(subcity < 10, "0" + string(subcity, "%12.0f"), string(subcity, "%12.0f"))
	*gen kebele_str = cond(kebele < 10, "0" + string(kebele, "%12.0f"), string(kebele, "%12.0f"))
	*gen ea_str = cond(ea < 10, "0" + string(ea, "%12.0f"), string(ea, "%12.0f"))

	gen ea_id_merge = region_str + zone + woreda + town_str + subcity_str + kebele + ea
	
	keep region zone woreda town subcity kebele ea ea_id_merge dist_weekly year ea_id
	
	
* prepare for export
	isid			region zone woreda kebele ea ea_id
	describe
	summarize 
	save 			"$export/com_sect4.dta", replace
	


* close the log
	log	close

/* END */
	