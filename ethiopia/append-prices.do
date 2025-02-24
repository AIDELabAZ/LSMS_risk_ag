* Project: reece thesis
* Created on: feb 2025
* Created by: alj
* Edited on: 21 feb 2025
* Edited by: alj
* Stata v.18.5

* does
	* puts ethiopia prices together 

* assumes
	* price data in ethiopia 
	
* TO DO:
	* done
	
* **********************************************************************
* 0 - setup
* **********************************************************************

* define paths
	global root = "$data/lsms_risk_ag_data/refined_data/ethiopia/"
	global root2 = "$data/lsms_risk_ag_data/regression_data/ethiopia"
	global logout = "$data/lsms_risk_ag_data/refined_data/ethiopia/logs/"

* open log
	cap log close
	log using "$logout/compile-prices", append

	
* **********************************************************************
* 1 - stack them up 
* **********************************************************************

	use			"$root/wave_1/medianmaizeprice.dta", clear 
	append 		using "$root/wave_2/medianmaizeprice.dta"
	append 		using "$root/wave_3/medianmaizeprice.dta"
	append 		using "$root/wave_4/medianmaizeprice.dta", force	
	append 		using "$root/wave_5/medianmaizeprice.dta", force 

* **********************************************************************
* 2 - convert to 2020 usd  
* **********************************************************************

* convert to 2015 prices 
* file is called world_bank_exchange_rates 
	gen 		price_usd = .
	replace 	price_usd = price / 23.427 if wave == 1
	replace 	price_usd = price / 22.672 if wave == 2
	replace 	price_usd = price / 20.577 if wave == 3
	replace 	price_usd = price / 21.417 if wave == 4
	replace 	price_usd = price / 28.125 if wave == 5
	
* this comes from cpi usd from the us government
* gosh we're lucky to be able to trust national statistics, i wonder for how much longer 	
	replace 	price_usd = price_usd * 1.33 
	

* **********************************************************************
* 3 - save to merge
* **********************************************************************

	keep 		country wave price_usd household_id ea
	rename 		household_id hh_id_merge
	rename 		ea ea_id_merge
	
	save 		"$root/prices", replace

* **********************************************************************
* 2 - convert to 2020 usd  
* **********************************************************************	

	use 		"$root2/eth_complete", clear 
	
	merge 			m:1 country wave hh_id_merge	        		using "$root/prices.dta", force
	