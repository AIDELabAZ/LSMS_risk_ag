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
	
* ***********************************************************************
**#2 - extension access
* ***********************************************************************

* did respondant receive advice about ag production

	gen		extension = 0
	replace extension = 1 if ag12a_02_1 == 1
	
	gen 	year = 2010
	
	label var extension "did you receive advice for agricultural productivity?"

* drop what we don't need 
	keep y2_hhid sourceid extension year
	
* must merge in regional identifiers from 2012_HHSECA to impute
	*merge			m:1 y2_hhid using "$export/HH_SECA"
	*tab				_merge
	*** after merging in regional identifiers, isid no longer runs?
	
* prepare for export
	isid			y2_hhid sourceid
	describe
	summarize 
	save 			"$export/2010_AGSEC12A.dta", replace
	


* close the log
	log	close

/* END */
	