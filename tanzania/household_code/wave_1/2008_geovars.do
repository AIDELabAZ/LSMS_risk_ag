* Project: LSMS Risk Ag
* Created on: Nov 2024
* Created by: jdm
* Edited on: 12 Nov 2024
* Edited by: jdm
* Stata v.18.5

* does
	* reads in Tanzania wave 1 geovars
	* cleans and outputs geovars
		* aez
		* urban/rural
		* elevation
		* soil variables for use in index
		* distances to road and pop center
	* output cleaned geovar file for merging

* assumes
	* access to all raw data

* TO DO:
	* done

	
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root 	"$data/raw_lsms_data/tanzania/wave_1/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"

* open log 
	cap 	log 	close 
	log 	using 	"$logout/2008_geovars", append

	
************************************************************************
**# 1 - NPSY1 (Wave 1) - geovars
************************************************************************

* import wave 1 geovars
	use 			"$root/HH.Geovariables_Y1.dta", clear

* rename variables
	isid 			hhid

	rename 			land03 aez
	rename			dist01 dist_road
	rename			dist02 dist_pop
	rename			soil01 elevat
	rename			soil05 sq1
	rename			soil06 sq2
	rename			soil07 sq3
	rename			soil08 sq4
	rename			soil09 sq5
	rename			soil10 sq6
	rename			soil11 sq7
	
	
************************************************************************
**# 2 - end matter, clean up to save
************************************************************************

	keep 			hhid dist_road dist_pop aez elevat sq1- sq7

	compress

* save file
		save 		"$export/2008_geovars.dta", replace

* close the log
	log	close

/* END */	
