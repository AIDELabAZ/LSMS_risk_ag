* Project: LSMS Risk Ag
* Created on: oct 16
* Created by: reece
* Edited on: 24 Jan 25
* Edited by: jdm
* Stata v.18.5

* does
	* reads in Tanzania wave 2 extension info
	* cleans
		* access to extension
	* outputs file for merging
	
* assumes
	* access to all raw data

* TO DO:
	* done
	
	
* **********************************************************************
**#0 - setup
* **********************************************************************

* define paths
	global root 	"$data/raw_lsms_data/tanzania/wave_2/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_2"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wv2_AGSEC12A", append
	
	
* ***********************************************************************
**#1 - prepare TZA 2010 (Wave 2) - ag sec 12a
* ***********************************************************************

* load data
	use 		"$root/AG_SEC12A", clear
	

* did respondant receive advice
	drop if 	sourceid == .
	drop		ag12a_02_2 ag12a_02_3 ag12a_02_4 ag12a_02_5 ag12a_02_6 ///
					ag12a_03 ag12a_04 ag12a_05 ag12a_06	ag12a_0b ag12a_01
	
	replace 	ag12a_02_1 = 0 if ag12a_02_1 == 2 | ag12a_02_1 == .
	
	reshape 	wide ag12a_02_1, i(y2_hhid) j(sourceid)
	
	egen 		exten = rowtotal(ag12a_02_11 ag12a_02_12 ag12a_02_13 ag12a_02_14 ag12a_02_15)
	replace 	exten = 1 if exten > 0
	
	lab var 	exten "=1 if has access to extension?"
	

* drop what we don't need 
	keep 		y2_hhid exten
	
	merge		1:1 y2_hhid using "$export/HH_SECA"
	* 2,769 matched, all matched from master
	
	drop		_merge
	
************************************************************************
**# 2 - end matter, clean up to save
************************************************************************
	
* prepare for export
	isid		y2_hhid

	compress
	
	save 		"$export/AGSEC12A.dta", replace


* close the log
	log	close

/* END */