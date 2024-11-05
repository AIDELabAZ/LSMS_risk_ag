* Project: WB Weather
* Created on: Feb 2024
* Created by: rg
* Edited on: 12 April 24
* Edited by: rg
* Stata v.18, mac

* does
	* cleans geovars

* assumes
	* customsave.ado

* TO DO:
	* done

	
* **********************************************************************
* 0 - setup
* **********************************************************************

* define paths	
	global root 	"$data/raw_lsms_data/uganda/wave_3/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/uganda/wave_5"
	global logout 	"$data/lsms_risk_ag_data/refined_data/uganda/logs"
	
* open log	
	cap log 			close
	log using 			"$logout/2015_geovars", append

	
* **********************************************************************
* 1 - UNPS 2011 (wave 1) - geovars 
* **********************************************************************

* import wave 1 geovars
	use 			"$root/UNPS_Geovars_1112.dta", clear
	** we use the past wave geovariables because variables were not provided in 2015 data
	
* rename variables
	isid 			HHID
	rename 			HHID hhid

	rename 			ssa_aez09 aez
	
	
* **********************************************************************
* 2 - end matter, clean up to save
* **********************************************************************

	keep 			hhid aez

	compress
	describe
	summarize

* save file
	save			"$export/2015_geovars.dta", replace

* close the log
	log	close

/* END */	
