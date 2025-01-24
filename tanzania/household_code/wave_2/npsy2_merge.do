* Project: LSMS Risk Ag
* Created on: May 2020
* Created by: McG
* Edited on: 24 Jan 25
* Edited by: jdm
* Stata v.18.5

* does
	* merges together community and extension data sets
	* outputs cleaned community vars

* assumes
	* previously cleaned household datasets

* TO DO:
	* need to sort out admin unit numbering


* **********************************************************************
* 0 - setup
* **********************************************************************

* define paths
	global root 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_2"
	global export 	"$data/lsms_risk_ag_data/merged_data/tanzania/wave_2"
	global logout 	"$data/lsms_risk_ag_data/merged_data/tanzania/logs"

* open log 
	cap log 		close 
	log 			using "$logout/npsy2_merge", append


* **********************************************************************
* 1a - merge data sets together
* **********************************************************************

* start by loading in household extension data
	use 			"$root/AGSEC12A", clear

	isid			y2_hhid

	tostring 		clusterid, generate(str_clusterid)
	gen				str_ea = substr(str_clusterid, 5, 3)
	destring		str_ea, replace
	replace			ea = str_ea
	
* merge in community data
	merge 			m:1 admin_1 admin_2 admin_3 ea using "$root/CMSEC_ea.dta", gen(_ea)
	*** matched 580
	*** 3,344 unmatched from master

* merge in community data
	merge 			m:1 admin_1 admin_2 admin_3 ea using "$root/CMSEC_ea.dta", gen(_ward)
	
	drop 			if _merge != 3
	*** 16 dropped	
	
	drop			_merge
	
* generate year variable
	gen				year = 2010
	gen				wave = 2
	
	
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
	save 			"$export/npsy2_merge.dta", replace

* close the log
	log	close

/* END */
