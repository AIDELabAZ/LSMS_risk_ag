* Project: LSMS Risk Ag
* Created on: Nov 2024
* Created by: jdm
* Edited on: 12 Nov 2024
* Edited by: jdm
* Stata v.18.5

* does
	* reads Tanzania wave 1 plot info
	* merges in household locations and plot characteristics
	* cleans
		* crop name
		* irrigation
		* pesticide and herbicide
		* fertilizer
		* labor
		* tenure
		* ownership and management characteristics
	* merge in owner characteristics from gsec2 gsec4
	* output cleaned measured input file

* assumes
	* access to the raw data
	* access to cleaned SEC_A
	* access to cleaned SEC_B

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
	log 	using 	"$logout/2008_AGSEC3A", append


************************************************************************
**# 1 - prepare TZA 2008 (Wave 1) - Agriculture Section 3A 
************************************************************************

* load data
	use 		"$root/SEC_3A", clear
	
* dropping duplicates
	duplicates 		drop
	*** 0 obs dropped
	
* check for uniquie identifiers
	drop			if plotnum == ""
	isid			hhid plotnum
	*** 0 obs dropped
	
* generate unique observation id
	gen				pltid = hhid + " " + plotnum
	lab var			pltid "Unique plot identifier"
	isid			pltid

* must merge in regional identifiers from 2008_HHSECA to impute
	merge			m:1 hhid using "$export/HH_SECA"
	*** 982 not matched, from using
	
	drop if			_merge == 2
	drop			_merge
	
* rename crop
	rename			s3aq5code cropid
	
* record if field was cultivated during long rains
	gen 			status = s3aq3 == 1 if s3aq3 != .
	lab var			status "=1 if plot cultivated during long rains"
	***4,408 observations were cultivated (86%)

* verify no crop on uncultivated plot
	tab				cropid if status == 0		
	*** 4 plots with crops - all rented out so drop
	
* drop uncultivated plots
	drop			if status == 0	
	* dropped 718

	
************************************************************************
**# 2 - merge in manager and owner characteristics
************************************************************************


************************************************************************
**## 2.1 - merge in manager characteristics
************************************************************************

* rename manager variables to person id
	rename			s3aq6_1 pid
	rename			s3aq6_2 pid2
	rename			s3aq6_3 pid3
	
* merge in characteristics for manager 1
	merge m:1 		hhid pid using "$export/2008_hhsecb.dta"	
	*** 267 in master not merged
	
	tab pid if _merge == 1
	*** all but 4 are missing pid

	drop 			if _merge == 2
	drop 			_merge	

* rename variables
	rename 			pid manage_rght_a
	rename			gender gender_mgmt_a
	rename			age age_mgmt_a
	rename			edu edu_mgmt_a
	
* rename pid for b to just pid so we can merge	
	rename			pid2 pid	

* merge in characteristics for manager 2
	merge m:1 		hhid pid using "$export/2008_hhsecb.dta"	
	*** 2,661 in master not merged

	drop 			if _merge == 2
	drop 			_merge	

* rename variables
	rename 			pid manage_rght_b
	rename			gender gender_mgmt_b
	rename			age age_mgmt_b
	rename			edu edu_mgmt_b
	
	gen 			two_mgmt = 1 if manage_rght_a != . & manage_rght_b != .
	replace 		two_mgmt = 0 if two_mgmt ==.	
	
* rename pid for b to just pid so we can merge	
	rename			pid3 pid	

* merge in characteristics for manager 3
	merge m:1 		hhid pid using "$export/2008_hhsecb.dta"	
	*** 4.326 in master not merged

	drop 			if _merge == 2
	drop 			_merge	

* rename variables
	rename 			pid manage_rght_c
	rename			gender gender_mgmt_c
	rename			age age_mgmt_c
	rename			edu edu_mgmt_c

	gen 			three_mgmt = 1 if manage_rght_a != . & manage_rght_b != . & ///
						manage_rght_c != . 
	replace 		three_mgmt = 0 if three_mgmt ==.	

	
************************************************************************
**## 2.2 - merge in owner characteristics
************************************************************************
	
* rename owner variables to person id
	rename			s3aq27_1 pid
	rename			s3aq27_2 pid2
	replace			pid2 = . if pid2 == 99

* merge in characteristics for manager 3
	merge m:1 		hhid pid using "$export/2008_hhsecb.dta"	
	*** 744 in master not merged

	drop 			if _merge == 2
	drop 			_merge
	
* rename variables
	rename 			pid ownshp_rght_a
	rename			gender gender_own_a
	rename			age age_own_a
	rename			edu edu_own_a
	
* rename PID for b to just PID so we can merge	
	rename			pid2 pid

* merge in characteristics for manager 2
	merge m:1 		hhid pid using "$export/2008_hhsecb.dta"	
	*** 3,304 in master not merged

	drop 			if _merge == 2
	drop 			_merge	
	
* rename variables
	rename 			pid ownshp_rght_b
	rename			gender gender_own_b
	rename			age age_own_b
	rename			edu edu_own_b
	
	gen 			two_own = 1 if ownshp_rght_a != . & ownshp_rght_b != .
	replace 		two_own = 0 if two_own==.	
	
	
************************************************************************
**# 3 -fertilizer
************************************************************************
	
* constructing fertilizer variables
	rename			s3aq43 fert_any
	rename			s3aq37 fert_org
	rename			s3aq45 fert_qty

* replace the missing fert_any with 0
	tab 			fert_qty if fert_any == .
	*** no observations
	
	replace			fert_any = 2 if fert_any == . 
	*** 227 changes
			
	sum 			fert_qty if fert_any == 1, detail
	*** mean 512, min 1, max 150,000
	*** two clear outliers based on type of fert and price

* replace zero to missing, missing to zero, and outliers to missing
	replace			fert_qty = . if fert_qty > 1200
	*** 2 outliers changed to missing
	
* record fert_any
	replace			fert_any = 0 if fert_any == 2	
	
	
************************************************************************
**# 4 - irrigation, pesticide, herbicide, and ownership
************************************************************************
	
* make a variable that shows the irrigation
	gen				irr_any = 1 if s3aq15 == 1
	replace			irr_any = 0 if irr_any == .
	lab var			irr_any "=1 if irrigated"
	*** there are 105 irrigated	

* pesticide & herbicide
	tab 			s3aq50
	*** 10 percent of the sample used pesticide or herbicide
	
* constructing pesticide/herbicide variables
	gen				pest_any = 1 if s3aq50 == 1 | s3aq50 == 4
	replace			pest_any = 0 if pest_any == .
	
	gen				herb_any = 1 if s3aq50 == 2 | s3aq50 == 3
	replace			herb_any = 0 if herb_any == .
	
* make tenure variables
	gen				tenure = 1 if s3aq22 == 1 | s3aq22 == 5
	replace			tenure = 0 if tenure == .
	lab var			tenure "=1 if owned"
	
************************************************************************
**# 5 - generate labor variables
************************************************************************

* per Palacios-Lopez et al. (2017) in Food Policy, we cap labor per activity
* 7 days * 13 weeks = 91 days for land prep and planting
* 7 days * 26 weeks = 182 days for weeding and other non-harvest activities
* 7 days * 13 weeks = 91 days for harvesting
* we will also exclude child labor_days
* in this survey we can't tell gender or age of household members
* since we can't match household members we deal with each activity seperately
					
* summarize household individual labor for land prep to look for outliers
	sum				s3aq61_1 s3aq61_2 s3aq61_3 s3aq61_4 s3aq61_5 s3aq61_6 ///
						s3aq61_7 s3aq61_8 s3aq61_9 s3aq61_10 s3aq61_11 ///
						s3aq61_12
	replace			s3aq61_1 = . if s3aq61_1 > 91 // 97 changes
	replace			s3aq61_2 = . if s3aq61_2 > 91 // 115 changes
	replace			s3aq61_3 = . if s3aq61_3 > 91 // 50 changes
	replace			s3aq61_4 = . if s3aq61_4 > 91 // 19 changes
	replace			s3aq61_5 = . if s3aq61_5 > 91 // 16 changes
	replace			s3aq61_6 = . if s3aq61_6 > 91 // 8 changes
	replace			s3aq61_8 = . if s3aq61_8 > 91 // 1 change
	replace			s3aq61_11 = . if s3aq61_11 > 91 // 1 change
	replace			s3aq61_12 = . if s3aq61_12 > 91 // 1 change
	** 308 changes made

* summarize household individual labor for weeding to look for outliers
	sum				 s3aq61_13 s3aq61_14 s3aq61_15 s3aq61_16 s3aq61_17 ///
						s3aq61_18 s3aq61_19 s3aq61_20 s3aq61_21 s3aq61_22 ///
						s3aq61_23 s3aq61_24
	*** None above 182, no outliers
	
* summarize household individual labor for harvest to look for outliers
	sum				s3aq61_25 s3aq61_26 s3aq61_27 s3aq61_28 s3aq61_29 s3aq61_30 ///
						s3aq61_31 s3aq61_32 s3aq61_33 s3aq61_34 s3aq61_35 ///
						s3aq61_36
	replace			s3aq61_25 = . if s3aq61_25 > 91 // 126 changes
	replace			s3aq61_26 = . if s3aq61_26 > 91 // 111 changes
	replace			s3aq61_27 = . if s3aq61_27 > 91 // 62 changes
	replace			s3aq61_28 = . if s3aq61_28 > 91 // 34 changes
	replace			s3aq61_29 = . if s3aq61_29 > 91 // 22 changes
	replace			s3aq61_30 = . if s3aq61_30 > 91 // 7 changes
	*** 362 changes made

* compiling labor inputs
	egen			fam_lab = rowtotal(s3aq61_1 s3aq61_2 s3aq61_3 s3aq61_4 ///
						s3aq61_5 s3aq61_6 s3aq61_7 s3aq61_8 s3aq61_9 s3aq61_10 ///
						s3aq61_11 s3aq61_12 s3aq61_13 s3aq61_14 s3aq61_15 ///
						s3aq61_16 s3aq61_17  s3aq61_18 s3aq61_19 s3aq61_20 ///
						s3aq61_21 s3aq61_22 s3aq61_23 s3aq61_24 s3aq61_25 ///
						s3aq61_26 s3aq61_27 s3aq61_28 s3aq61_29 s3aq61_30 ///
						s3aq61_31 s3aq61_32 s3aq61_33 s3aq61_34 s3aq61_35 ///
						s3aq61_36)

* generate hired labor by gender and activity
	gen				plant_w = s3aq63_2
	gen				plant_m = s3aq63_1
	gen				other_w = s3aq63_5
	gen				other_m = s3aq63_4
	gen				hrvst_w = s3aq63_8
	gen				hrvst_m = s3aq63_7

* summarize hired individual labor to look for outliers
	sum				plant* other* hrvst* if s3aq62 == 1

* replace outliers with missing
	replace			plant_w = . if plant_w > 91
	replace			plant_m = . if plant_m > 91
	replace			other_w = . if other_w > 182
	replace			other_m = . if other_m > 182 
	replace			hrvst_w = . if hrvst_w > 91 // 1 change
	replace			hrvst_m = . if hrvst_m > 91 // 1 change
	*** only 2 values replaced

* generate total hired labor days
	egen			hrd_lab = rowtotal(plant_w plant_m other_w ///
						other_m hrvst_w hrvst_m)

* generate labor days as the total amount of labor used on plot in person days
	gen				tot_lab = fam_lab + hrd_lab
	
	sum 			tot_lab
	*** mean 82, max 1,018, min 0	

	
************************************************************************
**# 6 - end matter, clean up to save
************************************************************************

* drop if crop id is missing
	drop if			cropid == .
	*** dropped 225 observations

* keep what we want, get rid of the rest
	keep			hhid plotnum pltid cropid manage_rght_a manage_rght_b ///
						manage_rght_c ownshp_rght_a ownshp_rght_b fert_org ///
						fert_any fert_qty admin_1 admin_2 admin_3 ea sector ///
						clusterid strataid wgt status gender_mgmt_a age_mgmt_a ///
						edu_mgmt_a gender_mgmt_b age_mgmt_b edu_mgmt_b two_mgmt  ///
						gender_mgmt_c age_mgmt_c edu_mgmt_c three_mgmt ///
						gender_own_a age_own_a edu_own_a gender_own_b age_own_b ///
						edu_own_b two_own irr_any pest_any herb_any tenure ///
						fam_lab hrd_lab tot_lab
						
	order			hhid admin_1 admin_2 admin_3 ea sector clusterid ///
						strataid wgt plotnum pltid status cropid tenure ///
						fert_org fert_any fert_qty irr_any pest_any herb_any ///
						fam_lab hrd_lab tot_lab ownshp_rght_a gender_own_a ///
						age_own_a edu_own_a ownshp_rght_b gender_own_b ///
						age_own_b edu_own_b two_own manage_rght_a gender_mgmt_a /// 
						age_mgmt_a edu_mgmt_a manage_rght_b gender_mgmt_b ///
						age_mgmt_b edu_mgmt_b two_mgmt manage_rght_c ///
						gender_mgmt_c age_mgmt_c edu_mgmt_c three_mgmt
	
* renaming and relabelling variables
	lab var			hhid "Household Identification NPS Y1"
	lab var			plotnum "Plot ID Within household"
	lab var			pltid "Unique Plot Identifier"
	lab var			fert_qty "Inorganic Fertilizer (kg)"
	lab var			fert_org "=1 if organic fertilizer used"
	lab var			fam_lab "Total family labor (days)"
	lab var			hrd_lab "Total hired labor (days)"
	lab var			tot_lab "Total labor (days)"
	lab var			tenure "=1 if owned"
	lab var			irr_any "=1 if irrigated"
	lab var			pest_any "=1 if pesticide used"
	lab var			herb_any "=1 if herbicide used"
	lab var			cropid "Crop code"
	lab var			fert_any "=1 if any inorganic fertilizer used"
	lab var			ownshp_rght_a "pid for first owner"
	lab var			gender_own_a "Gender of first owner"
	lab var			age_own_a "Age of first owner"
	lab var			edu_own_a "=1 if first owner has formal edu"
	lab var			ownshp_rght_b "pid for second owner"
	lab var			gender_own_b "Gender of second owner"
	lab var			age_own_b "Age of second owner"
	lab var			edu_own_b "=1 if second owner has formal edu"
	lab var			two_own "=1 if there is joint ownership"
	lab var			manage_rght_a "pid for first manager"
	lab var			gender_mgmt_a "Gender of first manager"
	lab var			age_mgmt_a "Age of first manager"
	lab var			edu_mgmt_a "=1 if first manager has formal edu"
	lab var			manage_rght_b "pid for second manager"
	lab var			gender_mgmt_b "Gender of second manager"
	lab var			age_mgmt_b "Age of second manager"
	lab var			edu_mgmt_b "=1 if second manager has formal edu"
	lab var			two_mgmt "=1 if there is two managers"
	lab var			manage_rght_c "pid for third manager"
	lab var			gender_mgmt_c "Gender of third manager"
	lab var			age_mgmt_c "Age of third manager"
	lab var			edu_mgmt_c "=1 if third manager has formal edu"
	lab var			three_mgmt "=1 if there is three managers"
		
* prepare for export
	isid			hhid plotnum
	
	compress

* save file
	save 			"$export/AG_SEC3A.dta", replace

* close the log
	log	close

/* END */
