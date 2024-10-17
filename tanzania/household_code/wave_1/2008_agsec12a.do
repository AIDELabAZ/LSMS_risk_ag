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
	global root 	"$data/household_data/tanzania/wave_1/raw"
	global export 	"$data/household_data/tanzania/wave_1/refined"
	global logout 	"$data/household_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wv1_AGSEC13A", append
	
* ***********************************************************************
**#1 - prepare TZA 2010 (Wave 2) - ag sec 12a
* ***********************************************************************

* load data
	use 		"$root/SEC_13A", clear
	*13A in wv1
	
* ***********************************************************************
**#2 - extension access
* ***********************************************************************

* did respondant receive advice about ag production

	gen		extension = 0
	replace extension = 1 if s13q2_a == 1
	
	gen 	year = 2008
	
	label var extension "did you receive advice for agricultural productivity?"

* drop what we don't need 
	keep hhid source extension year
	
* must merge in regional identifiers from 2012_HHSECA to impute
	merge			m:1 hhid using "$export/HH_SECA"
	tab				_merge
	
* prepare for export
	isid	
	* cant find unique identifier
	describe
	summarize 
	save 			"$export/2010_AGSEC12A.dta", replace
	


* close the log
	log	close

/* END */