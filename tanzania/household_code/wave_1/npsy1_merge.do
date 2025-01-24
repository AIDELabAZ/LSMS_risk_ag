* Project: LSMS Risk Ag
* Created on: Nov 2024
* Created by: jdm
* Edited on: 24 Jan 25
* Edited by: jdm
* Stata v.18.5

* does
	* merges together community and extension data sets
	* outputs cleaned community vars

* assumes
	* previously cleaned household datasets

* TO DO:
	* done


* **********************************************************************
* 0 - setup
* **********************************************************************
	
* define paths
	global root 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_1"
	global export 	"$data/lsms_risk_ag_data/merged_data/tanzania/wave_1"
	global logout 	"$data/lsms_risk_ag_data/merged_data/tanzania/logs"

* open log 
	cap 	log 	close 
	log 	using 	"$logout/npsy1_merge", append

	
* **********************************************************************
* 1a - merge data sets together
* **********************************************************************

* start by loading in household extension data
	use 			"$root/AGSEC12A", clear

	isid			hhid

* merge in community data
	merge 			m:1 admin_1 admin_2 admin_3 ea using "$root/CMSEC.dta"
	*** matched 3,249
	*** 16 unmatched from master

	drop 			if _merge != 3
	*** 16 dropped	
	
	drop			_merge
	
* generate year variable
	gen				year = 2008
	gen				wave = 1
	
	
* **********************************************************************
* 5 - end matter, clean up to save
* **********************************************************************

	isid			hhid

* order variables
	order			admin_1 admin_2 admin_3 ea sector clusterid strataid ///
						wgt year wave hhid exten dist_daily dist_weekly ///
						out_supply

* label variables
	lab var			year	"Year"
	lab var			wave	"Wave"

	compress
	describe
	summarize 
	
* saving production dataset
	save 			"$export/npsy1_merge.dta", replace

* close the log
	log	close

/* END */
