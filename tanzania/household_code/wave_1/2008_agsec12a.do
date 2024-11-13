* Project: LSMS Risk Ag
* Created on: Oct 2024
* Created by: reece
* Edited on: 12 Nov 2024
* Edited by: jdm
* Stata v.18.5

* does
	* reads in Tanzania wave 1 extension info
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
	global root 	"$data/raw_lsms_data/tanzania/wave_1/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"

* open log 
	cap 	log 	close 
	log 	using 	"$logout/wv1_AGSEC13A", append
	
	
* ***********************************************************************
**# 1 - prepare TZA 2010 (Wave 2) - ag sec 12a
* ***********************************************************************

* load data
	use 		"$root/SEC_13A", clear
	
* did respondant receive advice
	drop if 	source == .
	drop		s13q2_b s13q2_c s13q2_d s13q2_e s13q2_f s13q3 s13q4 s13q5 s13q6 s13q1
	
	replace 	s13q2_a = 0 if s13q2_a == 2
	
	reshape 	wide s13q2_a, i(hhid) j(source)
	
	egen 		exten = rowtotal(s13q2_a1 s13q2_a2 s13q2_a3 s13q2_a4 s13q2_a5)
	replace 	exten = 1 if exten > 0
	
	lab var 	exten "=1 if has access to extension?"

* drop what we don't need 
	keep 		hhid exten
	
	
************************************************************************
**# 2 - end matter, clean up to save
************************************************************************
	
* prepare for export
	isid			hhid

	compress
	
* save file
	save 			"$export/AGSEC12A.dta", replace

* close the log
	log	close

/* END */