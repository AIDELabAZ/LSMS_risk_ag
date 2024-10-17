* Project: WB Weather
* Created on: oct 16
* Created by: reece
* Edited on: oct 16 2024
* Edited by: reece
* Stata v.18

* does
	* cleans access to extension
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
	global root 	"$data/household_data/tanzania/wave_3/raw"
	global export 	"$data/household_data/tanzania/wave_3/refined"
	global logout 	"$data/household_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wv3_AGSEC12A", append
	
* ***********************************************************************
**#1 - prepare TZA 2010 (Wave 3) - ag sec 12a
* ***********************************************************************

* load data
	use 		"$root/AG_SEC_12A", clear
	
* ***********************************************************************
**#2 - extension access
* ***********************************************************************

* did respondant receive advice about ag production

	gen		extension = 0
	replace extension = 1 if ag12a_02_1 == 1
	
	gen 	year = 2012
	
	label var extension "did you receive advice for agricultural productivity?"

* drop what we don't need 
	keep y3_hhid sourceid extension year occ
	
* must merge in regional identifiers from 2012_HHSECA 
	merge			m:1 y3_hhid using "$export/HH_SECA"
	tab				_merge
	
	
* prepare for export
	isid			y3_hhid occ 
	describe
	summarize 
	save 			"$export/AGSEC12A.dta", replace
	


* close the log
	log	close

/* END */
	