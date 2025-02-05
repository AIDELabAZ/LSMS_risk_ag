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
	global root 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_3"
	global export 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_3"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/wave3_rb_vars", append

	
* ***********************************************************************
**#1 - load agsec12a and merge cmsec 
* ***********************************************************************

* load data- starting with extension
	use 		"$root/pp_sect7", clear
	
* merge in markets and agrodealer vars
	merge m:1  ea_id2 using "$root/com_sect4"
	
/* 

   Result                      Number of obs
    -----------------------------------------
    Not matched                            70
        from master                         1  (_merge==1)
        from using                         69  (_merge==2)

    Matched                             3,798  (_merge==3)
    -----------------------------------------
		
*/
		
* keep only merged
	keep if			_merge == 3
	drop			_merge
	
* keep what we need
	keep region zone woreda kebele ea extension year dist_weekly manager_id_merge hh_id_merge ea_id2
	
* rename for merge 
	rename ea_id2 ea_id_merge

* generate manager id for merging with lsms_base
	rename		manager_id_merge manager_id_old
	
	gen 		manager_id = substr(manager_id_old, 15, 2)
	
	egen		manager_id_merge = concat(hh_id_merge manager_id)
	
* final preparations to export
	isid 		manager_id_merge
	compress
	describe
	summarize
	save		"$export/wave3_rb_vars.dta", replace

* close the log
	log	close
		
