* Project: lsms risk ag
* Created on: feb 2025
* Created by: reece
* Edited on: 25 Feb 2025
* Edited by: reece
* Stata v.18

* does
	* loads multi country data set
	* outputs results file for analysis

* assumes
	* cleaned, merged (weather), and appended (waves) data
	* customsave.ado

* TO DO:
	*

	
* **********************************************************************
**#0 - setup
* **********************************************************************

* define paths
	global root 	"$data/lsms_risk_ag_data/regression_data/ethiopia"
	global export 	"$data/lsms_risk_ag_data/results"
	global logout 	"$data/lsms_risk_ag_data/regression_data/logs"

* open log 
	cap log close 
	log using "$logout/regressions", append

 	
* ******************************************************************************
**#1 - load data
* ******************************************************************************
 
 	use 		"$root/eth_complete", clear
	
* ******************************************************************************
**#2 - create variables we need for regression
* ******************************************************************************	

* drop missing plot area
	drop if 	plot_area_GPS == 0

* create log of yield, fert rate, seed rate, fert * seed
	egen 		std_y = std(harvest_kg2/plot_area_GPS)
	egen		std_f = std(nitrogen_kg2/plot_area_GPS)
	egen		std_s = std(isp)
	gen			std_f2 = std_f^2
	gen			std_s2 = std_s^2
	gen			std_fs = std_f*std_s
	
	
* create loop for mean and total rainfall
	xtset hh_id_obs
	

				gen 		lnr = asinh(v01_rf1)
				gen			lnr_t1 = asinh(v01_rf1_t)
				xtreg 		std_y hh_size lnr i.year ///
								std_f std_f2 std_s std_s2 std_fs, ///
								fe vce(cluster hh_id_obs) 
				
				
				xtivreg 		std_y hh_size lnr i.year ///
								(std_f std_f2 std_s std_s2 std_fs = hh_electricity_access ///
								dist_popcenter extension dist_weekly lnr_t1), ///
								fe vce(cluster hh_id_obs) first
								
		capture drop u1							
		predict u1, xb
		* generate fitted values (u1)
	
		capture matrix drop a
		matrix a=e(b)
		* store estimated coefficients from last reg into matrix 'a'
	
		scalar u1_seed=a[1,1]
		scalar u1_fert=a[1,2]
		* extract the first coefficient from matrix 'a' and store it in scalar 'u1_seed' ///
		then extract the second coeffient from matrix 'a' and store it in scalar 'u1_fert'
	
		scalar u1_seed2=a[1,3]
		scalar u1_fert2=a[1,4]
		* extract third and fourth coeffient for squared seed and fert use
	
		scalar u1_seedfert=a[1,5]
		* fifth coefficient for seed fert interaction term
	
		capture drop mu1_seed mu1_fert
		gen mu1_seed = u1_seed+2*u1_seed2*std_s+u1_seedfert*std_f
		* computing marginal effect of seed use
	
		gen mu1_fert = u1_fert+2*u1_fert2*std_f+u1_seedfert*std_s
		* computing marginal effect for fert use
	
	
	
****Second Moment **************************************************************	
		capture drop resid1
		predict resid1, e 
		* generate residuals from the last regression
	
		capture drop resid1_sq
		gen resid1_sq=resid1^2
		* generate squared residuals
	
		xtreg resid1_sq hh_size lnr i.year std_f std_f2 std_s std_s2 std_fs ///
							, fe vce(cluster hh_id_obs)
							* regress on squared residuals
							
		capture drop u2 
		predict u2
		* predict values from the regression on squared residual and store them in 'u2'.
	
		capture matrix drop a2
		matrix a2=e(b)
		* store the estimated coefficients from the last regression into matrix 'a2'.
	
		scalar u2_seed=a2[1,1]
		* extract the first coefficient from matrix 'a2' 
		* (variance effect of seed use)
	
		scalar u2_fert=a2[1,2]
		* extract the second coefficient from matrix 'a2' 
		* (variance effect of fertilizer use)

		scalar u2_seed2=a2[1,3]
		* extract the third coefficient from matrix 'a2'
		* (variance effect of the squared seed term)
		
		scalar u2_fert2=a2[1,4]
		* extract the fourth coefficient from matrix 'a2'
		* (variance effect of the squared fertilizer term).

		scalar u2_seedfert=a2[1,5]
		* extract the fifth coefficient from matrix 'a2'
		* (variance effect of the interaction between seed and fertilizer).

		capture drop mu2_seed mu2_fert
		gen mu2_seed = u2_seed+2*u2_seed2*std_s+u2_seedfert*std_f
		* compute the variance effect of seed use 
 
		gen mu2_fert = u2_fert+2*u2_fert2*std_f+u2_seedfert*std_s
		* compute the variance effect of fertilizer use

	
****Third Moment **************************************************************	
		capture drop resid3_sq
		gen resid3_sq=resid1^3
	
		xtreg resid3_sq hh_size lnr i.year std_f std_f2 std_s std_s2 std_fs ///
							, fe  vce(cluster hh_id_obs)

		capture drop u3
		predict u3
	
		capture matrix drop a3
		matrix a3=e(b)

		scalar u3_seed=a3[1,1]
		scalar u3_fert=a3[1,2]

		scalar u3_seed2=a3[1,3]
		scalar u3_fert2=a3[1,4]

		scalar u3_seedfert=a3[1,5]

		capture drop mu3_fert mu3_seed
		gen mu3_seed = u3_seed+2*u3_seed2*std_s+u3_seedfert*std_f
		gen mu3_fert = u3_fert+2*u3_fert2*std_f+u3_seedfert*std_s

	

		gen 		lndev_t1=v07_rf6_t1
						
						

***Generating interaction of moment and drought*********************************
		gen mod_mu2_seed=lndev_t1*mu2_seed
		gen mod_mu3_seed=lndev_t1*mu3_seed
		gen mod_mu2_fert=lndev_t1*mu2_fert
		gen mod_mu3_fert=lndev_t1*mu3_fert
		* drought anomalies*moments
		* using deviation in no rain days t-1 
				
 
***Generating constraints so that the coefficients of the seed and fert moment are the same
		constraint drop 1 2 3 4 5
		constraint 1 [mu1_seed]mu2_seed=[mu1_fert]mu2_fert
		constraint 2 [mu1_seed]mu3_seed=[mu1_fert]mu3_fert
		constraint 3 [mu1_seed]mod_mu2_seed=[mu1_fert]mod_mu2_fert
		constraint 4 [mu1_seed]mod_mu3_seed=[mu1_fert]mod_mu3_fert
		constraint 5 [mu1_seed]lndev_t1=[mu1_fert]lndev_t1


	* Table 3
		bootstrap, reps(300) seed(2045): reg3 ///
				(mu1_seed mu2_seed mu3_seed ) ///
				(mu1_fert mu2_fert mu3_fert), constraint(1 2 3)	nolog


	