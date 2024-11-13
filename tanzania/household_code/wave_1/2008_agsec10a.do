* Project: LSMS Risk Ag
* Created on: Nov 2024
* Created by: jdm
* Edited on: 13 Nov 2024
* Edited by: jdm
* Stata v.18.5

* does
	* reads in Tanzania wave 1 livestock info
	* cleans
		* livestock info
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
	use 		"$root/SEC_10A", clear
	
* drop dogs and other
	drop if 	inlist(animal, 15, 16)
	*** 3,562 dropped
	
* generate livestock
	gen			lvstck = 1 if s10aq2 == 1 & animal < 7
	replace		lvstck = 0 if lvstck == .

* generate small animal
	gen			sanml = 1 if s10aq2 == 1 & (animal == 7 | animal == 8 |	///
					animal == 9 | animal == 13 | animal == 14)
	replace		sanml = 0 if sanml == .

* generate poultry
	gen			pltry = 1 if s10aq2 == 1 & animal > 9 & animal < 13
	replace		pltry = 0 if pltry == .
	
* collapse to household
	collapse 	(max)  lvstck sanml pltry, by(hhid) 

	
************************************************************************
**# 2 - end matter, clean up to save
************************************************************************
	
	lab var		lvstck "=1 if household owns livestock"
	lab var		sanml "=1 if household owns small animals"
	lab var		pltry "=1 if household owns poultry"
	
* prepare for export
	isid			hhid

	compress
	
* save file
	save 			"$export/AGSEC10A.dta", replace

* close the log
	log	close

/* END */