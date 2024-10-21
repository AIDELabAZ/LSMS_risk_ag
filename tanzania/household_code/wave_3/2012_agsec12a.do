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
	global root 	"$data/raw_lsms_data/tanzania/wave_3/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_3"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"

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


* did respondant receive advice
	drop if sourceid == .
	drop		ag12a_02_2 ag12a_02_3 ag12a_02_4 ag12a_02_5 ag12a_02_6 ag12a_03_1 ag12a_03_2 ag12a_03_3 ag12a_03_4 ag12a_04 ag12a_05 ag12a_06 ag12a_07
	drop 		 occ sourcename ag12a_01
	
	replace ag12a_02_1 = 0 if ag12a_02_1 == 2
	
	reshape wide ag12a_02_1, i(y3_hhid) j(sourceid)
	
	egen extension = rowtotal(ag12a_02_11 ag12a_02_12 ag12a_02_13 ag12a_02_14 ag12a_02_15)
	replace extension = 1 if extension > 0
	
	
* must merge in regional identifiers from HHSECA
	merge		1:1 y3_hhid using "$export/HH_SECA"
	tab			_merge
	* 66 percent matched
	
* generate year
	gen 		year = 2012
	
	lab var year "year of survey- wv3 2012"
	lab var extension "does respondent have access to extension?"

* drop what we don't need 
	keep y3_hhid extension year region ward ea district 
	
	
* prepare for export
	isid			y3_hhid
	describe
	summarize 
	save 			"$export/AGSEC12A.dta", replace
	


* close the log
	log	close

/* END */