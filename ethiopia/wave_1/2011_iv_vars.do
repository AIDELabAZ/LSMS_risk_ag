* Project: lsms risk ag
* Created on: January 2025
* Created by: reece
* Edited on: 5 Feb 25
* Edited by: jdm
* Stata v.18

* does
	* merges dist market vars, dist to supplier, and extension var
	* outputs community and holder iv's for merging with harmonized data
	
* assumes
	* cleaned pp_sect7
	* cleaned com_sect4

* TO DO:
	* done
	
	
* **********************************************************************
**#0 - setup
* **********************************************************************

* define paths
	global root 	"$data/lsms_risk_ag_data/refined_data/ethiopia//wave_1"
	global export 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/wave1_rb_vars", append

	
* ***********************************************************************
**#1 - load agsec12a and merge cmsec 
* ***********************************************************************

* load data- starting with extension
	use 		"$root/pp_sect7", clear
	
	isid		holder_id
	
* merge in markets and agrodealer vars
	merge m:1 region zone woreda kebele ea using "$root/com_sect4"
	/*
	    Result                      Number of obs
    -----------------------------------------
    Not matched                            24
        from master                         0  (_merge==1)
        from using                         24  (_merge==2)

    Matched                             3,239  (_merge==3)
    -----------------------------------------

*/
	
* keep only merged
	keep if			_merge == 3
	drop			_merge
	
* dropping these for isid error "... should never be missing"
	drop if missing(holder_id) | missing(hhid) | missing(region) | missing(zone) | missing(woreda) | missing(kebele) | missing(ea)
	* 24 obs dropped
	
* keep what we need
	keep holder_id hhid region zone woreda kebele ea extension year dist_weekly ea_id_merge
	
	rename hhid hh_id_merge
	rename holder_id manager_id_merge
	
* final preparations to export
	isid 		manager_id_merge
	compress
	describe
	summarize
	save		"$export/wave1_rb_vars.dta", replace

* close the log
	log	close

/* END */