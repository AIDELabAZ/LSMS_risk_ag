* Project: LSMS Risk Ag
* Created on: Nov 2024
* Created by: jdm
* Edited on: 12 Nov 2024
* Edited by: jdm
* Stata v.18.5

* does
	* reads in household roster data (SEC_B)
	* cleans househod member characteristics
		* gender
		* age
		* edu
		* household size
	* outputs file for merging with plot owner/manager (agsec3a)

* assumes
	* access to raw data
	
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
	cap log 		close 
	log 			using 	"$logout/2008_HHSECB", append

* ***********************************************************************
* 1 - TZA 2008 (Wave 1) - Household Section A
* *********************1*************************************************

* load data
	use 		"$root/SEC_B_C_D_E1_F_G1_U", clear
	
* dropping duplicates
	duplicates 	drop
	*** 0 obs dropped
			
* rename variables
	rename		sbmemno pid
	rename		sbq2 gender
	rename		sbq4 age
	rename 		scq2 edu

***********************************************************************
**# 2 - output person data for merge with ag
***********************************************************************
	
	keep 			hhid hh pid gender age edu
	
	order			hhid hh pid gender age edu
	
	lab var			hh "Household ID"
	lab var			pid "Person ID"
	
	compress
	
* save file 
	save 			"$export/2008_hhsecb.dta", replace	
	
	
***********************************************************************
**# 3 - create household size
***********************************************************************
	
* create counting variable for household members
	gen				hh_size = 1
	
* collapse to household level
	collapse		(sum) hh_size, by(hhid)
	
	lab var			hh_size "Household size"
	
***********************************************************************
**# 4 - end matter, clean up to save
***********************************************************************
	
	compress
	
* save file 
	save 			"$export/2008_hhsecbh.dta", replace	
	
* close the log
	log	close

/* END */
	