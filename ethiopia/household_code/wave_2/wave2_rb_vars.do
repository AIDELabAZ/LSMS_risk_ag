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

/*
	* looks good
	