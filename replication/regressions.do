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
	gen			std_f = std(nitrogen_kg2/plot_area_GPS)
	gen			std_s = std(isp)
	gen			lnf2=lnf^2
	gen			lns2=lns^2
	gen			lnfs=lnf*lns
	
* ******************************************************************************
**#3 - calculating ap and ds parameters
* ******************************************************************************

* create loop for mean and total rainfall
	xtset hh_id_obs
	
	local			rain	v01_rf1 v05_rf1
	foreach v in `rain' {
		
		local			lag	v01_rf1_t1 v05_rf1_t1
		foreach t in `lag' {
			if substr("`v'", 2, 2) == substr("`t'", 2, 2) {
				gen 		lnr = asinh(`v')
				gen			lnr_t1 = asinh(`t')
				xtivreg 		lny hh_size lnr improved i.year ///
								(lnf lnf2 lns lns2 lnfs = hh_electricity_access ///
								dist_popcenter extension dist_weekly lnr_t1), ///
								fe vce(cluster hh_id_obs) 
								
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
		gen mu1_seed = u1_seed+2*u1_seed2*lns+u1_seedfert*lnf
		* computing marginal effect of seed use
	
		gen mu1_fert = u1_fert+2*u1_fert2*lnf+u1_seedfert*lns
		* computing marginal effect for fert use
	
	
	
****Second Moment **************************************************************	
		capture drop resid1
		predict resid1, e 
		* generate residuals from the last regression
	
		capture drop resid1_sq
		gen resid1_sq=asinh(resid1^2)
		* generate squared residuals
	
		reg resid1_sq hh_size lnr improved i.year lnf lnf2 lns lns2 lnfs ///
							, vce(cluster hh_id_obs)
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
		gen mu2_seed = u2_seed+2*u2_seed2*lns+u2_seedfert*lnf
		* compute the variance effect of seed use 
 
		gen mu2_fert = u2_fert+2*u2_fert2*lnf+u2_seedfert*lns
		* compute the variance effect of fertilizer use

	
****Third Moment **************************************************************	
		capture drop resid3_sq
		gen resid3_sq=asinh(resid1^3)
	
		reg resid3_sq hh_size lnr improved i.year lnf lnf2 lns lns2 lnfs ///
							, vce(cluster hh_id_obs)

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
		gen mu3_seed = u3_seed+2*u3_seed2*lns+u3_seedfert*lnf
		gen mu3_fert = u3_fert+2*u3_fert2*lnf+u3_seedfert*lns

	
				local shock v07_rf6_t1 v09_rf6_t1 v11_rf6_t1 v13_rf6_t1 v14_rf1_t1
					foreach s in `shock' {
						gen 		lndev_t1=asinh(`s')
						
						

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
		bootstrap, reps(100) seed(2045): reg3 ///
				(mu1_seed mu2_seed mu3_seed ) ///
				(mu1_fert mu2_fert mu3_fert), constraint(1 2 3)	nolog

*outreg2 using AP_DS_yield_lag, aster excel dec(5) ctitle(Model 1) replace

		bootstrap, reps(100) seed(2045): reg3 ///
				(mu1_seed mu2_seed mu3_seed lndev_t1 mod_mu2_seed mod_mu3_seed ) ///
				(mu1_fert mu2_fert mu3_fert lndev_t1 mod_mu2_fert mod_mu3_fert), ///
				constraint(1 2 3 4 5)	nolog

*outreg2 using AP_DS_yield_lag, aster excel dec(5) ctitle(Model 2)
					drop 	lndev_t1 mod_mu2_seed mod_mu3_seed mod_mu2_fert mod_mu3_fert
				}	
					drop	lnr lnr_t1 mu1_seed mu1_fert mu2_seed mu2_fert resid1_sq ///
						mu3_seed mu3_fert resid3_sq
				
			}
		}
	}
	

* ******************************************************************************
**#4 - determine how long these shocks make people risk-averse
* ******************************************************************************

	gen mod_mu2_seed2=mod_dr_anomaly_t_2*mu2_seed
	gen mod_mu3_seed2=mod_dr_anomaly_t_2*mu3_seed
	gen mod_mu2_fert2=mod_dr_anomaly_t_2*mu2_fert
	gen mod_mu3_fert2=mod_dr_anomaly_t_2*mu3_fert

	gen mod_mu2_seed3=mod_dr_anomaly_t_3*mu2_seed
	gen mod_mu3_seed3=mod_dr_anomaly_t_3*mu3_seed
	gen mod_mu2_fert3=mod_dr_anomaly_t_3*mu2_fert
	gen mod_mu3_fert3=mod_dr_anomaly_t_3*mu3_fert

	gen mod_mu2_seed4=mod_dr_anomaly_t_4*mu2_seed
	gen mod_mu3_seed4=mod_dr_anomaly_t_4*mu3_seed
	gen mod_mu2_fert4=mod_dr_anomaly_t_4*mu2_fert
	gen mod_mu3_fert4=mod_dr_anomaly_t_4*mu3_fert

	gen mod_mu2_seed5=mod_dr_anomaly_t_5*mu2_seed
	gen mod_mu3_seed5=mod_dr_anomaly_t_5*mu3_seed
	gen mod_mu2_fert5=mod_dr_anomaly_t_5*mu2_fert
	gen mod_mu3_fert5=mod_dr_anomaly_t_5*mu3_fert

	constraint drop 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17
	constraint 1 [mu1_seed]mu2_seed=[mu1_fert]mu2_fert
	constraint 2 [mu1_seed]mu3_seed=[mu1_fert]mu3_fert
	constraint 3 [mu1_seed]mod_mu2_seed=[mu1_fert]mod_mu2_fert
	constraint 4 [mu1_seed]mod_mu2_seed2=[mu1_fert]mod_mu2_fert2
	constraint 5 [mu1_seed]mod_mu2_seed3=[mu1_fert]mod_mu2_fert3
	constraint 6 [mu1_seed]mod_mu2_seed4=[mu1_fert]mod_mu2_fert4
	constraint 7 [mu1_seed]mod_mu2_seed5=[mu1_fert]mod_mu2_fert5
	constraint 8 [mu1_seed]mod_mu3_seed=[mu1_fert]mod_mu3_fert
	constraint 9 [mu1_seed]mod_mu3_seed2=[mu1_fert]mod_mu3_fert2
	constraint 10 [mu1_seed]mod_mu3_seed3=[mu1_fert]mod_mu3_fert3
	constraint 11 [mu1_seed]mod_mu3_seed4=[mu1_fert]mod_mu3_fert4
	constraint 12 [mu1_seed]mod_mu3_seed5=[mu1_fert]mod_mu3_fert5
	constraint 13 [mu1_seed]mod_dr_anomaly_t_1=[mu1_fert]mod_dr_anomaly_t_1
	constraint 14 [mu1_seed]mod_dr_anomaly_t_2=[mu1_fert]mod_dr_anomaly_t_2
	constraint 15 [mu1_seed]mod_dr_anomaly_t_3=[mu1_fert]mod_dr_anomaly_t_3
	constraint 16 [mu1_seed]mod_dr_anomaly_t_4=[mu1_fert]mod_dr_anomaly_t_4
	constraint 17 [mu1_seed]mod_dr_anomaly_t_5=[mu1_fert]mod_dr_anomaly_t_5


	**Table 4: Do lagged weather shocks affect risk attitudes?
	
	reg3 (mu1_seed mu2_seed mu3_seed  mod_dr_anomaly_t_1-mod_dr_anomaly_t_5 mod_mu2_see* 		mod_mu3_see* ) ///
		(mu1_fert mu2_fert mu3_fert mod_dr_anomaly_t_1-mod_dr_anomaly_t_5 mod_mu2_fer* 			mod_mu3_fer*), constraint(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17) nolog

	*outreg2 using AP_DS_yield_lag, aster excel dec(5) ctitle(Model 3) replace

* ******************************************************************************
**#5 - determine the accumulated shock effects- do they compound the effect?
* ******************************************************************************

	capture drop tot_shockd2	
	gen tot_shockd2=0
	replace tot_shockd2=1 if mod_dr_anomaly_t_1

	capture drop tot_shockd3
	gen tot_shockd3=0
	replace tot_shockd3=1 if mod_dr_anomaly_t_1==1 & mod_dr_anomaly_t_2==1

	capture drop tot_shockd4
	gen tot_shockd4=0
	replace tot_shockd4=1 if mod_dr_anomaly_t_1==1 & mod_dr_anomaly_t_2==1 & 				mod_dr_anomaly_t_3==1

	*drop shock*_mu2*
	*drop shock*_mu3*
	*** code stops here, need to mute these drops- reece

	gen shock1_mu2_seed=tot_shockd2*mu2_seed
	gen shock2_mu2_seed=tot_shockd3*mu2_seed
	gen shock3_mu2_seed=tot_shockd4*mu2_seed

	gen shock1_mu3_seed=tot_shockd2*mu3_seed
	gen shock2_mu3_seed=tot_shockd3*mu3_seed
	gen shock3_mu3_seed=tot_shockd4*mu3_seed

	gen shock1_mu2_fert=tot_shockd2*mu2_fert
	gen shock2_mu2_fert=tot_shockd3*mu2_fert
	gen shock3_mu2_fert=tot_shockd4*mu2_fert

	gen shock1_mu3_fert=tot_shockd2*mu3_fert
	gen shock2_mu3_fert=tot_shockd3*mu3_fert
	gen shock3_mu3_fert=tot_shockd4*mu3_fert


	constraint drop 1 2 3 4 5 6 7 8 9 10 11 12 
	constraint 1 [mu1_seed]mu2_seed=[mu1_fert]mu2_fert
	constraint 2 [mu1_seed]mu3_seed=[mu1_fert]mu3_fert
	constraint 3 [mu1_seed]shock1_mu2_seed=[mu1_fert]shock1_mu2_fert
	constraint 4 [mu1_seed]shock2_mu2_seed=[mu1_fert]shock2_mu2_fert
	constraint 5 [mu1_seed]shock3_mu2_seed=[mu1_fert]shock3_mu2_fert

	constraint 6 [mu1_seed]shock1_mu3_seed=[mu1_fert]shock1_mu3_fert
	constraint 7 [mu1_seed]shock2_mu3_seed=[mu1_fert]shock2_mu3_fert
	constraint 8 [mu1_seed]shock3_mu3_seed=[mu1_fert]shock3_mu3_fert

	constraint 9 [mu1_seed]tot_shockd2=[mu1_fert]tot_shockd2
	constraint 10 [mu1_seed]tot_shockd3=[mu1_fert]tot_shockd3
	constraint 11 [mu1_seed]tot_shockd4=[mu1_fert]tot_shockd4


	*Table 4 in the document
	reg3 (mu1_seed mu2_seed mu3_seed tot_shockd2 tot_shockd3 tot_shockd4 shock1_mu2_seed 		shock2_mu2_seed shock3_mu2_seed shock1_mu3_seed shock2_mu3_seed shock3_mu3_seed) ///
		(mu1_fert mu2_fert mu3_fert tot_shockd2 tot_shockd3 tot_shockd4 shock1_mu2_fert 		shock2_mu2_fert shock3_mu2_fert shock1_mu3_fert shock2_mu3_fert shock3_mu3_fert), 		constraint(1 2 3 4 5 6 7 8 9 10 11) nolog

	*outreg2 using AP_DS_yield_compound, aster excel dec(5) ctitle(shock) replace



















