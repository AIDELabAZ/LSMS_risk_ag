* Project: LSMS Risk Ag
* Created on: Nov 2024
* Created by: jdm
* Edited on: 12 Nov 2024
* Edited by: jdm
* Stata v.18.5


* does
	* reads Tanzania wave 1 harvest info
	* merges in household locations
	* cleans
		* intercropped
		* harvest date
		* crops
		* output (qty and val)
		* seed and seed type
		* plot shock
	* outputs cleaned harvest date file

* assumes
	* access to the raw data

* TO DO:
	* done

	
* **********************************************************************
* 0 - setup
* **********************************************************************

* define paths
	global root 	"$data/raw_lsms_data/tanzania/wave_1/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"

* open log 
	cap 	log 	close 
	log 	using 	"$logout/wv1_AGSEC4A", append

	
* **********************************************************************
* 1 - prepare TZA 2008 (Wave 1) - Agriculture Section 4A 
* **********************************************************************

* load data
	use 		"$root/SEC_4A", clear
	
* dropping duplicates
	duplicates 		drop
	*** 0 obs dropped

* rename variables of interest
	rename 		zaocode cropid
	
* check for missing values
	mdesc 				cropid s4aq15
	*** 1 obs missing crop code
	*** 522 obs missing harvest weight
	
* drop if crop code is missing
	drop				if cropid == .
	*** 1 observations dropped
	
* check for uniquie identifiers
	drop			if plotnum == ""
	isid			hhid plotnum cropid
	*** 0 obs dropped - none lack plot ids

* generating unique ob id
	gen				pltid = hhid + " " + plotnum
	lab var			pltid "Unique plot identifier"

* harvest start and end dates
	rename			s4aq11_1 harv_str_month
	rename			s4aq11_2 harv_stp_month

* drop observations from plots that did not harvest because crop was immature
	drop if 		s4aq2 < 3
	*** 137 observations deleted

* drop cropid is annual, other, fallow, pasture, and trees
	drop 			if cropid > 43 & cropid < 47
	drop 			if cropid > 52 & cropid < 86
	drop			if cropid == 98 | cropid == 99
	drop			if cropid > 100
	*** 113 observations deleted 
	
***********************************************************************
**# 2 - percentage planted 	
***********************************************************************
	
* create percent of area to crops
	gen				intrcrp = 1 if s4aq6 == 1
	replace			intrcrp = 0 if intrcrp == .
	
	gen				prct_plnt = 0.25 if s4aq4 == 1
	replace			prct_plnt = 0.25 if s4aq4 == .25
	replace			prct_plnt = 0.50 if s4aq4 == 2
	replace			prct_plnt = 0.75 if s4aq4 == 3
	replace			prct_plnt = 1 if prct_plnt == .

	
***********************************************************************
**# 3 - seed
***********************************************************************

* rename variables
	rename			s4aq20 seed_val
	label var		seed_val "Value of purchased seed (TSH)"
	
	rename			s4aq22 seed_type
	
* see how many hh used traditional vs improved seed 
	tab 			seed_type, missing
	* 5,149 used traditional
	* 524 used improved
	* 30 missing
	* missing is mostly trees and tubers
	
	
***********************************************************************
**# 4 - create harvested quantity
***********************************************************************

* create missing harvest dummy
	gen				harv_miss = 1 if s4aq15 == .
	replace			harv_miss = 0 if harv_miss == .					

* create ag shock variable
	gen				plt_shck = 1 if s4aq9 == 1 | s4aq17 == 1
	replace			plt_shck = 0 if plt_shck == .

* create harvest quantity and value
	rename			s4aq16 harv_val
	rename			s4aq15 harv_qty
	mdesc 			harv_qty
	*** 366 missing, same as above
	
* summarize harvest quantity
	sum				harv_qty
	*** mean 401, max 40,000
	*** couple crazy values, mostly potato but some maize
	*** will keep for now

* generate crop price
	gen 		cropprice = harv_val/harv_qty

	
************************************************************************
**# 4 - end matter, clean up to save
************************************************************************
	
* keep what we want, get rid of what we don't
	keep 				hhid plotnum cropid pltid intrcrp prct_plnt harv_miss ///
							plt_shck harv_str_month harv_stp_month harv_qty ///
							harv_val cropprice seed_val seed_type

	order				hhid plotnum pltid cropid harv_str_month harv_stp_month ///
							intrcrp prct_plnt harv_miss plt_shck harv_qty ///
							harv_val cropprice seed_val seed_type
	
* renaming and relabelling variables
	lab var			hhid "Household Identification NPS Y1"
	lab var			plotnum "Plot ID Within household"
	lab var			pltid "Unique Plot Identifier"
	lab var			cropid "Crop code"
	lab var			harv_str_month "Harvest start month"
	lab var			harv_stp_month "Harvest stp month"
	lab var			harv_val "Value of Harvest (TSH)"
	lab var			harv_qty "Harvest quantity (kg)"
	lab var			plt_shck "=1 if pre-harvest shock"
	lab var			harv_miss "=1 if harvest qty missing"
	lab var			intrcrp "=1 if intercropped"
	lab var			seed_type "Traditional/improved"
	lab var			prct_plnt "Percent planted to crop"
	lab var 		cropprice "Crop price (harvest value/ harvest weight)"

* prepare for export
	isid			hhid plotnum cropid
	
	compress

* save file
	save 			"$export/AG_SEC4A.dta", replace

* close the log
	log	close

/* END */
