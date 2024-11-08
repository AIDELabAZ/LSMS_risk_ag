* Project: LSMS_risk_ag
* Created on: Oct 2024
* Created by: rg
* Edited on: 4 nov 2024
* Edited by: reece
* Stata v.18

* does
	* reads Uganda wave 2 crops grown and seed (2010_AGSEC4A) for the 1st season
	* questionaire 4B is for 2nd season
	* cleans
		* planting date
		* seeds
		* crops
	* output cleaned seed and planting date file

* assumes
	* access to raw data
	* mdesc.ado

* TO DO:
	* seed quantity and seed price 
	* last section
	

***********************************************************************
**# 0 - setup
***********************************************************************

* define paths	
	global root 	"$data/raw_lsms_data/uganda/wave_2/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/uganda/wave_2"
	global logout 	"$data/lsms_risk_ag_data/refined_data/uganda/logs"
	
	
* open log	
	cap log 		close
	log using 		"$logout/2010_agsec4a_plt", append
	
***********************************************************************
**# 1 - import data and rename variables
***********************************************************************

* import wave 4 season A
	use 			"$root/2010_AGSEC4A.dta", clear
	
* rename variables	
	rename 			HHID hhid
	rename 			cropID cropid
	rename 			a4aq8 area_plnt

	rename 			a4aq13 improved_sds
	
	sort 			hhid prcid pltid cropid  
	
	mdesc 			hhid prcid pltid cropid 

	duplicates drop hhid prcid pltid cropid, force
	isid 			hhid prcid pltid cropid	



	
***********************************************************************
**# 2 - create indicator variables for seed type, seed purchase, intercropped
***********************************************************************

* see how many hh used traditional vs improved seed 
	tab 			improved_sds
	* 2,295 used traditional
	* 449 used improved
	*  missing 77%
	replace 		improved_sds = 0 if improved_sds == 2

* make a variable that shows if intercropped or not
	gen				intrcrp_any =1 if a4aq7 == 2
	replace			intrcrp_any = 0 if intrcrp_any ==.

* convert area to hectares 
	replace 		area_plnt = area_plnt * 0.404686

	
***********************************************************************
**# 3 - end matter, clean up to save
***********************************************************************

	keep 			hhid prcid cropid pltid intrcrp_any /// 
					 area_plnt improved_sds
	
	lab var			improved_sds "were improved seeds used?"
	lab var			intrcrp "=1 if intercropped"
	lab var			area_plnt "Total area of plot planted"
	

	compress
	describe
	summarize

* save file
	save 			"$export/2010_agsec4a.dta", replace

* close the log
	log	close

/* END */	
