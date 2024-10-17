* Project: WB Weather
* Created on: March 2024
* Created by: reece
* Edited on: oct 8 2024
* Edited by: reece
* Stata v.18

* does
	* cleans Tanzania household variables, wave 7 (NPSY5) Ag sec4a
	* kind of a crop roster, with harvest weights, long rainy season
	* generates weight harvested, harvest month, percentage of plot planted with given crop, value of seed purchases
	* generates crop prices, access to extension, and market (daily and weekly)
	
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
	global root 	"$data/household_data/tanzania/wave_7/raw"
	global export 	"$data/household_data/tanzania/wave_7/refined"
	global logout 	"$data/household_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wv7_AGSEC12A", append

	
* ***********************************************************************
**#1 - prepare TZA 2020 (Wave 7) - Agriculture Section 4A 
* ***********************************************************************

* load data
	use 		"$root/ag_sec_12a", clear

	drop		ag12a_02 ag12a_03_1 ag12a_03_2 ag12a_03_3 ag12a_03_4 ag12a_04 ag12a_05 ag12a_06 ag12a_07
	drop 		interview__key ag12a_01_3 ag12a_01_4 ag12a_01_5 ag12a_01_6 ag12a_01_7 ag12a_01_8
	
	replace ag12a_01_1 = 0 if ag12a_01_1 == 2
	replace ag12a_01_2 = 0 if ag12a_01_2 == 2
	
	/*
	Source ID |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
            GOVERNMENT EXTENSION |      2,810       20.00       20.00
                             ngo |      2,810       20.00       40.00
COOPERATIVE/FARMER'S ASSOCIATION |      2,810       20.00       60.00
              LARGE SCALE FARMER |      2,810       20.00       80.00
                           other |      2,810       20.00      100.00
---------------------------------+-----------------------------------
                           Total |     14,050      100.00

	*/
	 reshape wide ag12a_01_1 ag12a_01_2, i(y5_hhid) j(sourceid)
	 egen access = rowtotal (ag12a_01_11 ag12a_01_21 ag12a_01_12 ag12a_01_22 ag12a_01_13 ag12a_01_23 ag12a_01_14 ag12a_01_24 ag12a_01_15 ag12a_01_25)
	 
	 replace access = 1 if access > 0
	 
	 *should we drop ag12a_01_11 ag12a_01_21 ag12a_01_12 ag12a_01_22 ag12a_01_13 ag12a_01_23 ag12a_01_14 ag12a_01_24 ag12a_01_15 ag12a_01_25?
	 
* must merge in regional identifiers from 2020_HHSECA
	merge		m:1 y5_hhid using "$export/HH_SECA"
	tab			_merge
	 
* prepare for export
	isid			y5_hhid 
	compress
	describe
	summarize 
	save 			"$export/2020_AGSEC12A.dta", replace

* close the log
	log	close

/* END */

	 
	 
	 
