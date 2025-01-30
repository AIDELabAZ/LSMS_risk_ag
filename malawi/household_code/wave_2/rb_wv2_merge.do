* Project: lsms risk ag
* Created on: January 2025
* Created by: reece
* Edited on: 29 Jan 2025
* Edited by: reece
* Stata v.18

* does
	* merges community vars with lsms_base 
	
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
	global root 	"$data/lsms_risk_ag_data/refined_data/malawi/wave_2"
	global root2 	"$data/lsms_base/countries/malawi"
	global export 	"$data/lsms_risk_ag_data/refined_data/malawi/wave_2"
	global logout 	"$data/lsms_risk_ag_data/refined_data/malawi/logs"

* open log 
	cap log close 
	log using "$logout/wave2_rb_vars", append

	
* ***********************************************************************
**#1 - load agsec12a and merge cmsec 
* ***********************************************************************

* load data- starting with extension
	use 		"$root2/wave2_clean", clear
	
	
* merge in clean malawi data
	drop _merge
	merge m:1 ea_id_merge using "$root/com_sec

/* 
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                            13,562  (_merge==3)
    -----------------------------------------
yaaaaaaay
/*
