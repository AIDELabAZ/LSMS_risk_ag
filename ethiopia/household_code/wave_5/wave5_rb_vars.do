* Project: lsms risk ag
* Created on: January 2025
* Created by: reece
* Edited on: 14 Jan 2025
* Edited by: reece
* Stata v.18

* does
	* merges dist market vars, dist to supplier, and extension var
	
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
	global root 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_5"
	global export 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_5"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/wave5_rb_vars", append

	
* ***********************************************************************
**#1 - load agsec12a and merge cmsec 
* ***********************************************************************

* load data- starting with extension
	use 		"$root/pp_sect7", clear
	
* merge in markets and agrodealer vars
	merge m:1 region zone woreda kebele ea ea_id using "$root/com_sect4"
	/* 
	
    Result                      Number of obs
    -----------------------------------------
    Not matched                           280
        from master                        47  (_merge==1)
        from using                        233  (_merge==2)

    Matched                             2,063  (_merge==3)
    -----------------------------------------
*/
	* pretty good
	
* keep what we need
	keep holder_id hhid region zone woreda kebele ea extension year dist_weekly  
	rename hhid hh_id_merge
	
* create manager_id_merge for lsms_base merge	
	gen manager_id_merge = substr(holder_id, 1, length(holder_id) - 2) + "-" + substr(holder_id, -1, 1)

* dropping these for isid error "... should never be missing"
	drop if missing(manager_id_merge) | missing(hh_id_merge) | missing(region) | missing(zone) | missing(woreda) | missing(kebele) | missing(ea)
	* 233 obs dropped

* final preparations to export
	isid 		manager_id_merge hh_id_merge region zone woreda ea kebele 
	compress
	describe
	summarize
	save		"$export/wave5_rb_vars.dta", replace

* close the log
	log	close
	
