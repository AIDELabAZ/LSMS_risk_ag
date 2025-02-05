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
    Not matched                            91
        from master                        91  (_merge==1)
        from using                          0  (_merge==2)

    Matched                            27,880  (_merge==3)
    -----------------------------------------
		
		*/
		
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
		
