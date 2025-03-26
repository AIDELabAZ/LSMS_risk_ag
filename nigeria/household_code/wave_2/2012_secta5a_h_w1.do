* Project: lsms risk ag
* Created on: 25 Mar 2025
* Created by: reece
* Edited on: 26 Mar 2025
* Edited by: reece
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
	global root 	"$data/raw_lsms_data/nigeria/wave_2/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/nigeria/wave_2"
	global logout 	"$data/lsms_risk_ag_data/refined_data/nigeria/logs"

* open log 
	cap log close 
	log using "$logout/2010_secta5a_harvestw2", append

	
* ***********************************************************************
**#1 - prepare nigeria 2012 secta5a_harvestw2
* ***********************************************************************

* load data
	use 		"$root/secta5a_harvestw2", clear
	
	
* ***********************************************************************
**#2 - extension access
* ***********************************************************************

* did respondant participate in extension program
	gen 		extension = 0
	replace		extension = 1 if sa5aq2 == 1 | sa5aq2 == 2 | sa5aq2 == 5	
	
	collapse (sum) topic_cd (max) extension , by(zone state lga sector ea hhid)
	
	isid				zone state lga sector ea hhid 
	
* prepare for export
	isid			zone state lga sector ea hhid
	describe
	summarize 
	save 			"$export/2012_secta5a_harvestw2", replace
	

* close the log
	log	close

/* END */
	


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	