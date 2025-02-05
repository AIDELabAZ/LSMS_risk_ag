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
	global root 	"$data/lsms_risk_ag_data/refined_data/ethiopia//wave_2"
	global export 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_2"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/wave2_rb_vars", append

	
* ***********************************************************************
**#1 - load agsec12a and merge cmsec 
* ***********************************************************************

* load data- starting with extension
	use 		"$root/pp_sect7", clear
	
* merge in markets and agrodealer vars
	merge m:1 region zone woreda kebele ea ea_id2 using "$root/com_sect4"
	/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                            64
        from master                         1  (_merge==1)
        from using                         63  (_merge==2)

    Matched                             3,778  (_merge==3)
    -----------------------------------------

*/

* keep only merged
	keep if			_merge == 3
	drop			_merge
	
* keep what we need
	keep holder_id hhid region zone woreda kebele ea extension year dist_weekly ea_id_merge manager_id_merge
	
	rename hhid hh_id_merge

* dropping these for isid error "... should never be missing"
	drop if missing(manager_id_merge) | missing(hh_id_merge) | missing(region) | missing(zone) | missing(woreda) | missing(kebele) | missing(ea) | missing(ea_id_merge)
	* 149 obs dropped

	
* final preparations to export
	isid 		manager_id_merge hh_id_merge region zone woreda ea kebele ea_id_merge
	compress
	describe
	summarize
	save		"$export/wave2_rb_vars.dta", replace

* close the log
	log	close
