* Project: WB Weather
* Created on: Oct 1 2024
* Created by: reece
* Edited on: Oct 1 2024
* Edited by: reece 
* Stata v.18

* does
	* generates crop prices
	
* assumes
	* access to all raw data
	* mdesc.ado
	* cleaned hh_seca.dta

* TO DO:
	* everything
	
* **********************************************************************
* 0 - setup
* **********************************************************************

* define paths
	global root 	"$data/household_data/tanzania/wave_6/raw"
	global export 	"$data/household_data/tanzania/wave_6/refined"
	global logout 	"$data/household_data/tanzania/logs"

* open log 
	cap log close 
	log using "$logout/wv6_AGSEC5A", append
	
* ***********************************************************************
**#1 - prepare TZA 2019 (Wave 6) - Agriculture Section 5A 
* ***********************************************************************

* load data
	use 		"$root/AG_SEC_5A"

* dropping duplicates
	duplicates 		drop
	*** 0 obs dropped
