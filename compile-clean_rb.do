* Project: LSMS Clean Base Code
* Created on: January 2025
* Created by: alj
* Edited on: 30 January 2025
* Edited by: alj
* Stata v.18.0

* does 
	* compiles the clean version of datasets
	* puts country rounds into a single country file
	* puts all countries into a single file

* assumes
	* code to clean household data sets

* TO DO:
	* remember this is quick and dirty so we can run regressions
	* something happening and not finding do files?
	
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root1 	"$data/lsms_base/countries/malawi"
	global root2 	"$data/lsms_base/countries/"
	global logout 	"$data/logs"
	
* open log
	cap log 			close
	log using 			"$logout/compilefull", append

	
************************************************************************
**# 1 - compile ethiopia 
************************************************************************

* run all the do files
*	do 			"$code/ua_code/ethiopia/merge_eth1.do"
*	do 			"$code/ua_code/ethiopia/merge_eth2.do"
*	do 			"$code/ua_code/ethiopia/merge_eth3.do"
*	do 			"$code/ua_code/ethiopia/merge_eth4.do"
*	do 			"$code/ua_code/ethiopia/merge_eth5.do"
	
* compile the output files together 
*	use			"$export1/ethiopia/wave1_clean.dta", clear 
*	append 		using "$export1/ethiopia/wave2_clean.dta"
*	append 		using "$export1/ethiopia/wave3_clean.dta"
*	append 		using "$export1/ethiopia/wave4_clean.dta"	 		
*	append 		using "$export1/ethiopia/wave5_clean.dta"	 		
	
* save ethiopia final file 	
*	save 		"$export1/ethiopia/eth_allrounds_final", replace
	
************************************************************************
**# 2 - compile malawi 
************************************************************************

* run all the do files
*	do 			"$code/ua_code/malawi/merge_mwi1.do"
*	do 			"$code/ua_code/malawi/merge_mwi2.do"
*	do 			"$code/ua_code/malawi/merge_mwi3.do"
*	do 			"$code/ua_code/malawi/merge_mwi4.do"
	
* compile the output files together 
	use			"$root1/wave1_clean.dta", clear 
	append 		using "$root1/wave2_clean.dta"
	append 		using "$root1/wave3_clean.dta"
	append 		using "$root1/wave4_clean.dta"	 		
	
* save malawi final file 	
	save 		"$root2/mwi_allrounds_final", replace	
	
************************************************************************
**# 3 - compile mali 
************************************************************************

* run all the do files
*	do 			"$code/ua_code/mali/merge_mli1.do"
*	do 			"$code/ua_code/mali/merge_mli2.do"
	
* compile the output files together 
	use			"$export1/mali/wave1_clean.dta", clear 
	append 		using "$export1/mali/wave2_clean.dta"
	
* save mali final file 	
	save 		"$export1/mali/mli_allrounds_final", replace		
	
************************************************************************
**# 4 - compile niger 
************************************************************************

* run all the do files
*	do 			"$code/ua_code/niger/merge_niger1.do"
*	do 			"$code/ua_code/niger/merge_niger2.do"
	
* compile the output files together 
	use			"$export1/niger/wave1_clean.dta", clear 
	append 		using "$export1/niger/wave2_clean.dta"
	
* save niger final file 	
	save 		"$export1/niger/ngr_allrounds_final", replace		

************************************************************************
**# 5 - compile nigeria 
************************************************************************

* run all the do files
*	do 			"$code/ua_code/nigeria/merge_nga1.do"
*	do 			"$code/ua_code/nigeria/merge_nga2.do"
*	do 			"$code/ua_code/nigeria/merge_nga3.do"
*	do 			"$code/ua_code/nigeria/merge_nga4.do"
	
* compile the output files together 
	use			"$export1/nigeria/wave1_clean.dta", clear 
	append 		using "$export1/nigeria/wave2_clean.dta"
	append 		using "$export1/nigeria/wave3_clean.dta"
	append 		using "$export1/nigeria/wave4_clean.dta"	 		
	
* save malawi final file 	
	save 		"$export1/nigeria/nga_allrounds_final", replace		
	
************************************************************************
**# 6 - compile tanzania  
************************************************************************

* run all the do files
*	do 			"$code/ua_code/tanzania/merge_tza1.do"
*	do 			"$code/ua_code/tanzania/merge_tza2.do"
*	do 			"$code/ua_code/tanzania/merge_tza3.do"
*	do 			"$code/ua_code/tanzania/merge_tza4.do"
*	do 			"$code/ua_code/tanzania/merge_tza5.do"
	
* compile the output files together 
	use			"$export1/tanzania/wave1_clean.dta", clear 
	append 		using "$export1/tanzania/wave2_clean.dta"
	append 		using "$export1/tanzania/wave3_clean.dta"
	append 		using "$export1/tanzania/wave4_clean.dta"	 		
	append 		using "$export1/tanzania/wave5_clean.dta"	 		
	
* save tanzania final file 	
	save 		"$export1/tanzania/tza_allrounds_final", replace		

************************************************************************
**# 7 - compile uganda   
************************************************************************	
	
* uganda to come 	

************************************************************************
**# 8 - compile all files   
************************************************************************
	
* compile the output files together 
	use			"$export1/ethiopia/eth_allrounds_final.dta", clear 
	append 		using "$export1/malawi/mwi_allrounds_final.dta"
	append 		using "$export1/mali/mli_allrounds_final.dta"
	append 		using "$export1/niger/ngr_allrounds_final.dta"	 		
	append 		using "$export1/nigeria/nga_allrounds_final.dta"	 		
	append 		using "$export1/tanzania/tza_allrounds_final.dta"	 		
*	append 		using "$export1/uganda/wave5_clean.dta"	 		
	
* save  final file 	
	save 		"$export1/aggregate/allrounds_final", replace		

************************************************************************
**# 9 - create year variable 
************************************************************************

* we look at the paper "A longitudinal cross-country dataset 
* on agricultural productivity and welfare in Sub-Saharan Africa" by Thomas
* Bentze and Philip Wollburg, page 4 figure 1. Timeline of LSMS-ISA data collection
* and pick the first year if wave covers multiple years 

* generate new year variable 
	gen			year = .
	
* replace with first year.

* for Ethiopia
	replace 	year = 2011 if country == "Ethiopia" & wave == 1
	replace 	year = 2013 if country == "Ethiopia" & wave == 2
	replace 	year = 2015 if country == "Ethiopia" & wave == 3
	replace 	year = 2017 if country == "Ethiopia" & wave == 4
	replace 	year = 2020 if country == "Ethiopia" & wave == 5
	
* for Malawi 
	replace 	year = 2010 if country == "Malawi" & wave == 1
	replace 	year = 2013 if country == "Malawi" & wave == 2
	replace 	year = 2016 if country == "Malawi" & wave == 3
	replace 	year = 2019 if country == "Malawi" & wave == 4
	
* for Mali 
	replace 	year = 2014 if country == "Mali" & wave == 1
	replace 	year = 2017 if country == "Mali" & wave == 2
	
* for Niger 
	replace 	year = 2011 if country == "Niger" & wave == 1
	replace 	year = 2014 if country == "Niger" & wave == 2
	
* for Nigeria 
	replace 	year = 2010 if country == "Nigeria" & wave == 1
	replace 	year = 2012 if country == "Nigeria" & wave == 2
	replace 	year = 2015 if country == "Nigeria" & wave == 3
	replace 	year = 2018 if country == "Nigeria" & wave == 4
	
* for Tanzania
	replace 	year = 2008 if country == "Tanzania" & wave == 1
	replace 	year = 2010 if country == "Tanzania" & wave == 2
	replace 	year = 2012 if country == "Tanzania" & wave == 3
	replace 	year = 2014 if country == "Tanzania" & wave == 4
	replace 	year = 2019 if country == "Tanzania" & wave == 5
	
	
* generate survey variable 
	gen			survey = ""
	
* replace with first year.

* for Ethiopia
	replace 	survey =  "ESS 2011 - 2012" if country == "Ethiopia" & wave == 1
	replace 	survey = "ESS 2013 - 2014" if country == "Ethiopia" & wave == 2
	replace 	survey = "ESS 2015 - 2016" if country == "Ethiopia" & wave == 3
	replace 	survey = "ESS 2018 - 2019" if country == "Ethiopia" & wave == 4
	replace 	survey = "ESS 2020 - 2021" if country == "Ethiopia" & wave == 5
	
* for Malawi 
	replace 	survey = "IHPS 2010" if country == "Malawi" & wave == 1
	replace 	survey = "IHPS 2013" if country == "Malawi" & wave == 2
	replace 	survey = "IHPS 2016" if country == "Malawi" & wave == 3
	replace 	survey = "IHPS 2019" if country == "Malawi" & wave == 4
	
* for Mali 
	replace 	survey = "EACI 2014 - 2015" if country == "Mali" & wave == 1
	replace 	survey = "EACI 2017 - 2018" if country == "Mali" & wave == 2
	
* for Niger 
	replace 	survey = "ECVMA 2011" if country == "Niger" & wave == 1
	replace 	survey = "ECVMA 2014" if country == "Niger" & wave == 2
	
* for Nigeria 
	replace 	survey = "GHS 2010 - 2011" if country == "Nigeria" & wave == 1
	replace 	survey = "GHS 2012 - 2013" if country == "Nigeria" & wave == 2
	replace 	survey = "GHS 2015 - 2016" if country == "Nigeria" & wave == 3
	replace 	survey = "GHS 2018 - 2019" if country == "Nigeria" & wave == 4
	
* for Tanzania
	replace 	survey = "NPS 2008 - 2009" if country == "Tanzania" & wave == 1
	replace 	survey = "NPS 2010 - 2011" if country == "Tanzania" & wave == 2
	replace 	survey = "NPS 2012 - 2013" if country == "Tanzania" & wave == 3
	replace 	survey = "NPS 2014 - 2015" if country == "Tanzania" & wave == 4
	replace 	survey = "NPS 2019 - 2020" if country == "Tanzania" & wave == 5
	
* save  final file 	
	save 		"$export1/aggregate/allrounds_final_year", replace	
	
	
************************************************************************
**# 10 - end
************************************************************************

* close the log
	log	close

/* END */
