* Project: WB Weather
* Created on: oct 16
* Created by: reece
* Edited on: oct 21 2024
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
	global root 	"$data/raw_lsms_data/tanzania/wave_5/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_5"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wv5_AGSEC12A", append
	
* ***********************************************************************
**#1 - prepare TZA 2014xp (Wave 5) - ag sec 12a
* ***********************************************************************

* load data
	use 		"$root/AG_SEC_12A", clear
	
* ***********************************************************************
**#2 - extension access
* ***********************************************************************

* did respondant receive advice
	drop if sourceid == .
	drop		ag12a_02 ag12a_03_1 ag12a_03_2 ag12a_03_3 ag12a_03_4 ag12a_04 ag12a_05 ag12a_06 ag12a_07
	drop 		 occ ag12a_01_3 ag12a_01_4 ag12a_01_5 ag12a_01_6 ag12a_01_7 ag12a_01_8
	
	replace ag12a_01_1 = 0 if ag12a_01_1 == 2
	replace ag12a_01_2 = 0 if ag12a_01_2 == 2
	
	 reshape wide ag12a_01_1 ag12a_01_2, i(y4_hhid) j(sourceid)
	 egen extension = rowtotal (ag12a_01_11 ag12a_01_21 ag12a_01_12 ag12a_01_22 ag12a_01_13 ag12a_01_23 ag12a_01_14 ag12a_01_24 ag12a_01_15 ag12a_01_25)
	 
	 replace extension = 1 if extension > 0
	
* must merge in regional identifiers from HHSECA
	merge		1:1 y4_hhid using "$export/HH_SECA"
	tab			_merge	
	* 63 percent matched
* generate year
	gen 		year = 2014
	
	lab var year "year of survey- wv5 2014xp"
	lab var extension "does respondent have access to extension?"

* drop what we don't need 
	keep y4_hhid extension year region ward ea district 
	
	
* prepare for export
	isid			y4_hhid
	describe
	summarize 
	save 			"$export/AGSEC12A.dta", replace
	


* close the log
	log	close

/* END */
	