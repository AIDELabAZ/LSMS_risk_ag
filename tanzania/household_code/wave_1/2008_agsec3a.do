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
	* distinct.ado

* TO DO:
	* working on ownership/management

	
* **********************************************************************
* 0 - setup
* **********************************************************************

* define paths
	global root 	"$data/raw_lsms_data/tanzania/wave_1/raw"
	global export 	"$data/lsms_risk_ag_data/refined_data/tanzania/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/tanzania/logs"


* open log 
	cap log close 
	log using "$logout/2008_AGSEC3A", append


* **********************************************************************
* 1 - prepare TZA 2008 (Wave 1) - Agriculture Section 3A 
* **********************************************************************

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
	
* record if field was cultivated during long rains
	gen 			status = s3aq3 == 1 if s3aq3 != .
	lab var			status "=1 if field cultivated during long rains"
	***4,408 observations were cultivated (86%)

* drop uncultivated plots
	drop			if status == 0	
	* dropped 718
	
* ***********************************************************************
* 2 -fertilizer
* ***********************************************************************
	
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
	
	
* ***********************************************************************
* 3 - irrigation, pesticide, herbicide, and ownership
* ***********************************************************************
	
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
	replaced		tenure = 0 if tenure == .
	lab var			tenure "=1 if owned"
	
* ***********************************************************************
* 4 - generate labor variables
* ***********************************************************************

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

	
* **********************************************************************
* 5 - end matter, clean up to save
* **********************************************************************



* **********************************************************************
* 5 - end matter, clean up to save
* **********************************************************************
dfsdd
* keep what we want, get rid of the rest
	keep			hhid plotnum plot_id irrigated fert_any kilo_fert ///
						pesticide_any herbicide_any labor_days plotnum ///
						region district ward ea y1_rural clusterid strataid ///
						hhweight
	order			hhid plotnum plot_id
	
* renaming and relabelling variables
	lab var			hhid "Unique Household Identification NPS Y1"
	lab var			y1_rural "Cluster Type"
	lab var			hhweight "Household Weights (Trimmed & Post-Stratified)"
	lab var			plotnum "Plot ID Within household"
	lab var			plot_id "Unique Plot Identifier"
	lab var			clusterid "Unique Cluster Identification"
	lab var			strataid "Design Strata"
	lab var			region "Region Code"
	lab var			district "District Code"
	lab var			ward "Ward Code"
	lab var			ea "Village / Enumeration Area Code"
	lab var			labor_days "Total Labor (days), Imputed"
	lab var			irrigated "Is plot irrigated?"
	lab var			pesticide_any "Was Pesticide Used?"
	lab var			herbicide_any "Was Herbicide Used?"	
	lab var			kilo_fert "Fertilizer Use (kg), Imputed"
	
		
* prepare for export
	isid			hhid plotnum
	compress
	describe
	summarize 
	sort 			plot_id
	save 			"$export/AG_SEC3A.dta", replace

* close the log
	log	close

/* END */
