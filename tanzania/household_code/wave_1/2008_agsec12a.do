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
	global root 	"$data/raw_lsms_data/tanzania/wave_1/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wv1_AGSEC13A", append
	
* ***********************************************************************
**#1 - prepare TZA 2010 (Wave 2) - ag sec 12a
* ***********************************************************************

* load data
	use 		"$root/SEC_13A", clear
	
	
* ***********************************************************************
**#2 - extension access
* ***********************************************************************

* did respondant receive advice
	drop if source == .
	drop		s13q2_b s13q2_c s13q2_d s13q2_e s13q2_f s13q3 s13q4 s13q5 s13q6 s13q1

	
	replace s13q2_a = 0 if s13q2_a == 2
	
	reshape wide s13q2_a, i(hhid) j(source)
	
	egen extension = rowtotal(s13q2_a1 s13q2_a2 s13q2_a3 s13q2_a4 s13q2_a5)
	replace extension = 1 if extension > 0
	
	
* must merge in regional identifiers from HHSECA
	merge		1:1 hhid using "$export/HH_SECA"
	tab			_merge
	* 74 percent matched
	
* generate year
	gen 		year = 2008
	
	lab var year "year of survey- wv1 2008"
	lab var extension "does respondent have access to extension?"

* drop what we don't need 
	keep hhid extension year region ward ea district 
	
	
* prepare for export
	isid			hhid
	describe
	summarize 
	save 			"$export/AGSEC12A.dta", replace
	


* close the log
	log	close

/* END */