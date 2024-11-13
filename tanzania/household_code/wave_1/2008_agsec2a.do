* Project: LSMS Risk Ag
* Created on: Nov 2024
* Created by: jdm
* Edited on: 13 Nov 2024
* Edited by: jdm
* Stata v.18.5

* does
	* reads Tanzania wave 1 plot info
	* merges in household locations and plot characteristics
	* cleans
		* plot sizes
	* merge in owner characteristics from gsec2 gsec4
	* output is ready to be appended to 2013_AGSEC2B to make 2013_AGSEC2

* assumes
	* access to the raw data
	* access to cleaned HHSECA, AGSEC3A

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
	log 	using 	"$logout/2008_AGSEC2A", append

	
************************************************************************
**# 1 - prepare TZA 2008 (Wave 1) - Agriculture Section 2A 
************************************************************************

* load data
	use				"$root/SEC_2A", clear
	
* dropping duplicates
	duplicates 		drop
	*** 0 obs dropped

* renaming variables of interest
	rename 			s2aq4 pltsizeSR
	rename 			area pltsizeGPS
	
* check for uniquie identifiers
	drop			if plotnum == ""
	isid			hhid plotnum
	*** 0 obs dropped - none lack plot ids

* generating unique ob id
	gen				pltid = hhid + " " + plotnum
	lab var			pltid "Unique plot identifier"
	isid			pltid
	
* convert from acres to hectares
	replace			pltsizeSR = pltsizeSR * 0.404686
	lab var			pltsizeSR "Self-reported Area (Hectares)"
	replace			pltsizeGPS = pltsizeGPS * 0.404686
	lab var			pltsizeGPS "GPS Measured Area (Hectares)"

	
************************************************************************
**# 2 - merge in regional ID and cultivation status
************************************************************************

* must merge in regional identifiers from 2012_HHSECA to impute
	merge			m:1 hhid using "$export/HH_SECA"
	*** 981 not matched, using only
	
	drop if			_merge == 2
	drop			_merge
	
* must merge in regional identifiers from 2012_AG_SEC_3A to impute
	merge			1:1 hhid plotnum using "$export/AG_SEC3A.dta"
	*** 945 not matched from master, 0 not matched from using
	*** must be plots without cultivation that we dropped in SEC3A cleaning
	
	keep if			_merge == 3
	drop			_merge
	

************************************************************************
**# 3 - clean and impute plot size
************************************************************************
	
* how many missing values are there?
	mdesc 			pltsizeGPS
	*** 3,446 missing, 82% of observations

* convert acres to hectares
	gen				pltsize = pltsizeGPS
	label var		pltsize "Parcel size (ha)"

* examine gps outlier values
	sum 			pltsize, detail
	*** mean 0.91, max 16, min 0, std. dev. 1.4

	list 			pltsize pltsizeSR if pltsize > 10 & !missing(pltsize)
	*** these all look reasonable
			
* check correlation between the two
	corr 			pltsize pltsizeSR
	*** 0.81 correlation, high correlation between GPS and self reported
	
* replace 0 values with missing
	replace			pltsize = . if pltsize == 0
	*** 1 change made
	
/* since GPS looks good, we don't need to replace GPS outliers using following code
* compare GPS and self-report, and look for outliers in GPS 
	sum				pltsize, detail
	*** save command as above to easily access r-class stored results 

* look at GPS and self-reported observations that are > ±3 Std. Dev's from the median 
	list			pltsize pltsizeSR if !inrange(pltsize,`r(p50)'-(3*`r(sd)'),`r(p50)'+(3*`r(sd)')) ///
						& !missing(pltsize)
	*** these all look good, largest size is 16 ha
	
* summarize before imputation
	sum				pltsize
	*** mean 0.58, max 16.67, min 0.004
*/
* impute missing GPS plot sizes using predictive mean matching
	mi set 			wide // declare the data to be wide.
	mi xtset		, clear // this is a precautinary step to clear any existing xtset
	mi register 	imputed pltsize // identify plotsize_GPS as the variable being imputed
	sort			admin_1 admin_2 admin_3 ea hhid pltid, stable // sort to ensure reproducability of results
	mi impute 		pmm pltsize i.admin_2 pltsizeSR cropid, add(1) rseed(245780) noisily dots ///
						force knn(5) bootstrap
	mi unset
		
* how did imputing go?
	sum 			pltsize_1_
	*** mean 0.93, max 16, min 0.0034

	replace 		pltsize = pltsize_1_ if pltsize == .
	
	drop			mi_miss pltsize_1_
	
	mdesc 			pltsize
	*** none missing

************************************************************************
**# 4 - end matter, clean up to save
************************************************************************

* keep what we want, get rid of the rest
	keep		hhid plotnum pltid admin_1 admin_2 admin_3 ea sector ///
					clusterid strataid wgt cropid pltsize
	
* renaming and relabelling variables
	lab var		hhid "Unique Household Identification NPS Y1"
	lab var		plotnum "Plot ID Within household"

* prepare for export
	isid			hhid plotnum

	compress

* save file	
	save 			"$export/AG_SEC2A.dta", replace
	
* close the log
	log	close

/* END */
