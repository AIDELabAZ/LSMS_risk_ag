* Project: lsms risk ag
* Created on: feb 2025
* Created by: reece
* Edited on: 27 Feb 2025
* Edited by: jdm
* Stata v.18

* does
	* loads multi country data set
	* outputs results file for analysis

* assumes
	* cleaned, merged (weather), and appended (waves) data

* TO DO:
	*

	
********************************************************************************
**#0 - setup
********************************************************************************

* define paths

	global root 	"$data/lsms_risk_ag_data/regression_data/ethiopia"
	global export 	"$data/lsms_risk_ag_data/results"
	global logout 	"$data/lsms_risk_ag_data/regression_data/logs"

* open log 
	cap 	log 	close 
	log 	using 	"$logout/regressions", append

 	
********************************************************************************
**# 1 - load data
********************************************************************************
 
 	use 		"$root/eth_complete", clear
	
* ******************************************************************************
**# 2 - create variables we need for regression
* ******************************************************************************	

* drop missing plot area
	drop if 	plot_area_GPS == 0

* create log of yield, fert rate, seed rate, fert * seed
	gen 		lny=asinh(harvest_kg2/plot_area_GPS)
	gen			lnf=asinh(nitrogen_kg2/plot_area_GPS)
	gen			lns=asinh(seed_kg2/plot_area_GPS)
	gen			lnf2=lnf^2
	gen			lns2=lns^2
	gen			lnfs=lnf*lns
	
	
********************************************************************************
**# 3 - calculating ap and ds parameters
********************************************************************************

* set panel indicator
	xtset hh_id_obs
	
	
********************************************************************************
**## 3.1 - create loop for production regressions
********************************************************************************

* loop through rainfall in time t
	local			rain	v01_rf1 v05_rf1
	foreach v in `rain' {
		
	* loop through rainfall in time t-1
		local			lag	v01_rf1_t1 v05_rf1_t1
		foreach t in `lag' {
			
		* compare two rainfall variables and only use one from same source	
			if substr("`v'", 2, 2) == substr("`t'", 2, 2) {
				
			* production function with IV
				xtivreg 		lny hh_size `v' improved i.year ///
									(lnf lnf2 lns lns2 lnfs = hh_electricity_access ///
									dist_popcenter extension dist_weekly `t'), ///
									fe vce(cluster hh_id_obs) 

****First Moment****************************************************************

			* generate fitted values (u1)			
				capture 		drop u1							
				predict 		u1, xb
	
			* store estimated coefficients from last reg into matrix 'a'
				capture 		matrix drop a
				matrix 			a = e(b)
	
			* extract the fertilizer coefficients from matrix 'a'
			* and store them as 'u1_f' and 'u1_f2'
				scalar 			u1_f = a[1,1]
				scalar 			u1_f2 = a[1,2]
	
			* extract the seed coefficients from matrix 'a'
			* and store them as 'u1_s' and 'u1_s2'
				scalar 			u1_s = a[1,3]
				scalar 			u1_s2 = a[1,4]
	
			* extract the interaction coefficients from matrix 'a'
			* and store it as 'u1_fs'
				scalar 			u1_fs = a[1,5]
	
			* computing marginal effect of seed and fertilizer
				capture 		drop mu1_s mu1_f
				gen 			mu1_s = u1_s + 2*u1_s2 * lns + u1_fs * lnf
				gen 			mu1_f = u1_f + 2*u1_f2 * lnf + u1_fs * lns
	
	
****Second Moment **************************************************************

			* generate residuals from the last regression
				capture 		drop resid1
				predict 		resid1, e 
	
			* generate squared residuals
				capture 		drop resid2
				gen 			resid2 = asinh(resid1^2)
	
			* regress on squared residuals
				xtreg 			resid2 lnf lnf2 lns lns2 lnfs /// 
									hh_size `v' improved i.year, fe ///
									vce(cluster hh_id_obs)
					
			* generate fitted values (u2)	
				capture 		drop u2 
				predict 		u2
	
			* store estimated coefficients from last reg into matrix 'a2'
				capture 		matrix drop a2
				matrix 			a2 = e(b)
	
			* extract the fertilizer coefficients from matrix 'a2'
			* (variance effect of fertilizer use)
				scalar 			u2_f = a2[1,1]
				scalar 			u2_f2 = a2[1,2]
	
			* extract the seed coefficients from matrix 'a2'
			* (variance effect of seed use)
				scalar 			u2_s = a2[1,3]
				scalar 			u2_s2 = a2[1,4]
	
			* extract the interaction coefficients from matrix 'a2'
			* (variance effect of the seed and fertilizer interaction)
				scalar 			u2_fs = a2[1,5]
	
			* computing variance effect of seed and fertilizer
				capture 		drop mu2_s mu2_f
				gen 			mu2_s = u2_s + 2*u2_s2 * lns + u2_fs * lnf
				gen 			mu2_f = u2_f + 2*u2_f2 * lnf + u2_fs * lns


****Third Moment ***************************************************************

			* generate cubed residuals
				capture 		drop resid3
				gen 			resid3 = asinh(resid1^3)
	
			* regress on cubed residuals
				xtreg 			resid3 lnf lnf2 lns lns2 lnfs /// 
									hh_size `v' improved i.year, fe ///
									vce(cluster hh_id_obs)

			* generate fitted values (u3)	
				capture 		drop u3
				predict 		u3
	
			* store estimated coefficients from last reg into matrix 'a3'
				capture 		matrix drop a3
				matrix 			a3 = e(b)
	
			* extract the fertilizer coefficients from matrix 'a2'
			* (skew effect of fertilizer use)
				scalar 			u3_f = a3[1,1]
				scalar 			u3_f2 = a3[1,2]
	
			* extract the seed coefficients from matrix 'a2'
			* (skew effect of seed use)
				scalar 			u3_s = a3[1,3]
				scalar 			u3_s2 = a3[1,4]
	
			* extract the interaction coefficients from matrix 'a2'
			* (skew effect of the seed and fertilizer interaction)
				scalar 			u3_fs = a3[1,5]
	
			* computing skew effect of seed and fertilizer
				capture 		drop mu3_s mu3_f
				gen 			mu3_s = u3_s + 2*u3_s2 * lns + u3_fs * lnf
				gen 			mu3_f = u3_f + 2*u3_f2 * lnf + u3_fs * lns

				
********************************************************************************
**## 3.2 - create loop for risk aversion regressions
********************************************************************************	
			
			* generate loop for shock variables
				local shock v07_rf1_t1 v09_rf1_t1 v11_rf1_t1 v13_rf1_t1 v14_rf1_t1
					foreach s in `shock' {
						
				* create interaction of moment and shock
					gen 			mod_mu2_s = `s' * mu2_s
					gen 			mod_mu3_s = `s' * mu3_s
					gen 			mod_mu2_f = `s' * mu2_f
					gen 			mod_mu3_f = `s' * mu3_f
				
 
				* constraint coefficients of the seed and fert moment to be equal
					constraint 		drop 1 2 3 4 5
					constraint 1 	[mu1_s]mu2_s = [mu1_f]mu2_f
					constraint 2 	[mu1_s]mu3_s = [mu1_f]mu3_f
					constraint 3 	[mu1_s]mod_mu2_s = [mu1_f]mod_mu2_f
					constraint 4 	[mu1_s]mod_mu3_s = [mu1_f]mod_mu3_f
					constraint 5 	[mu1_s]`s' = [mu1_f]`s'

				* Model 1: AP regression with no shock
					bootstrap, 		reps(100) seed(2045): ///
					reg3 			(mu1_s mu2_s mu3_s) ///
									(mu1_f mu2_f mu3_f), ///
									constraint(1 2) nolog

				* Model 2: AP regression with shock
					bootstrap, 		reps(100) seed(2045): ///
					reg3 			(mu1_s mu2_s mu3_s `s' mod_mu2_s mod_mu3_s) ///
									(mu1_f mu2_f mu3_f `s' mod_mu2_f mod_mu3_f), ///
									constraint(1 2 3 4 5) nolog

				* drop variables generated for AP regressions
					drop 			mod_mu2_s mod_mu3_s mod_mu2_f mod_mu3_f
			}	
			* drop variables generated in production regressions
				drop			mu1_s mu1_f mu2_s mu2_f mu3_s mu3_f ///
									u1 u2 u3 resid1 resid2 resid3	
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



















