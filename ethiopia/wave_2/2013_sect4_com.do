* Project: lsms risk ag
* Created on: oct 22
* Created by: reece
* Edited on: 5 Feb 25
* Edited by: jdm
* Stata v.18

* does
	* cleans community data- daily and weekly market
	* outputs ea level data for merging with extension data
	
* assumes
	* access to all raw data

* TO DO:
	* done
	
	
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
**#1 - prepare ethiopia 2013 (Wave 2) - Community Section 4
* ***********************************************************************

* load data
	use 		"$root/sect4_com_w2", clear
	
	*keep sa1q01 sa1q02 sa1q03 sa1q06 sa1q07 cs4q14 cs4q15 ea_id2
	
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
	rename sa1q04 town
	rename sa1q05 subcity
	rename sa1q06 kebele
	rename sa1q07 ea

* gen ea_id_merge for lsms_base 
	gen region_str = cond(region < 10, "0" + string(region, "%12.0f"), string(region, "%12.0f"))
	gen zone_str = cond(zone < 10, "0" + string(zone, "%12.0f"), string(zone, "%12.0f"))
	gen woreda_str = cond(woreda < 10, "0" + string(woreda, "%12.0f"), string(woreda, "%12.0f"))
	gen town_str = cond(town < 10, "0" + string(town, "%12.0f"), string(town, "%12.0f"))
	gen subcity_str = cond(subcity < 10, "0" + string(subcity, "%12.0f"), string(subcity, "%12.0f"))
	gen kebele_str = cond(kebele < 10, "0" + string(kebele, "%12.0f"), string(kebele, "%12.0f"))
	gen ea_str = cond(ea < 10, "0" + string(ea, "%12.0f"), string(ea, "%12.0f"))

	gen ea_id_merge = region_str + zone_str + woreda_str + town_str + subcity_str + kebele_str + ea_str
	
	keep region zone woreda town subcity kebele ea ea_id_merge dist_weekly year ea_id2
	
* prepare for export
	isid			region zone woreda kebele ea ea_id2
	describe
	summarize 
	save 			"$export/com_sect4.dta", replace
	


* close the log
	log	close

/* END */