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
	global root 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_5"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_5"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wave5_rb_vars", append

	
* ***********************************************************************
**#1 - load agsec12a and merge cmsec 
* ***********************************************************************

* load data- starting with extension
	use 		"$root/AGSEC12A", clear
	
* merge in markets and agrodealer vars
	merge m:1 region district ward ea using "$root/CMSEC"
	/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                           886
        from master                       863  (_merge==1)
        from using                         23  (_merge==2)

    Matched                               126  (_merge==3)
    -----------------------------------------

/*
	* agsec12a is missing many ward and ea values
	
	