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
	global root 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_6"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_6"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wave6_rb_vars", append

	
* ***********************************************************************
**#1 - load agsec12a and merge cmsec 
* ***********************************************************************

* load data- starting with extension
	use 		"$root/2019_AGSEC12A", clear
	
* merge in markets and agrodealer vars
	merge m:1 region district ward ea interview__key using "$root/2019_CMSEC"
	/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,270
        from master                     1,184  (_merge==1)
        from using                         86  (_merge==2)

    Matched                                 0  (_merge==3)
    -----------------------------------------
/*
	* agsec12a is missing many ward and ea values
	
	