* Project: lsms risk ag
* Created on: feb 2025
* Created by: reece
* Edited on: 7 Feb 2025
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
* 0 - setup
* **********************************************************************

* define paths

	global root 	"$data/lsms_risk_ag_data/regression_data/ethiopia"
	global export 	"$data/lsms_risk_ag_data/results"
	global logout 	"$data/lsms_risk_ag_data/regression_data/logs"

* open log 
	cap log close 
	log using "$logout/regressions", append

 	
* **********************************************************************
* 1 - load data
* **********************************************************************
 
 	use 		"$root/eth_complete", clear
	
* **********************************************************************
* 2 - create variables we need for regression
* **********************************************************************	
* create log of yield, rain, fert rate, seed rate, fert * seed
	gen 		lny=asinh(harvest_kg2/plot_area_GPS)
	gen 		lnr=asinh(v05_rf1)
	gen			lnf=asinh(nitrogen_kg2/plot_area_GPS)
	gen			lns=asinh(seed_kg2/plot_area_GPS)
	gen			lnf2=lnf^2
	gen			lns2=lns^2
	gen			lnfs=lnf*lns
	
* **********************************************************************
* 3 - start of shared code
* **********************************************************************
		
 *############################################################################
 * GET INPUT ATTRIBUTES
 *____________________________________________________________________________*
 
 *KEY
 * dum_binis= improved seed use, proportion of area
	***improved
 * dum_binis2=improved seed use squared
 * dum_fertrate= fertilizer application rate, kg/ha
 * dum_fertseed= interaction of improved seed and fertilizer
 * totharv, measure of total production (proxy for income)
	***harvest_kg

 /*
*capture drop std_income
egen std_income=std(totcons_USD2)

*capture drop improved
egen dum_binis=std(improved)
* original code uses proportion of area for improved seed use, our data has improved seed use binary

*capture drop dum_binis2
gen dum_binis2= dum_binis2^2
* does it make sense to use improved seed squared? leaving for now

*capture drop dum_fertrate
egen dum_fertrate=std(inorganic_fertilizer)
* original code used fertilizer application rate- ok to use fertilizer dummy?

*capture drop dum_fertrate2
gen dum_fertrate2=dum_fertrate^2

*capture drop dum_fertseed
gen dum_fertseed=dum_fertrate*improved2

* 

capture drop log_rain_t
*gen log_rain_t=ln(rain_t)

*capture drop log_rain_t
gen log_shock=ln(crop_shock)
*/



collapse (mean) seed_kg2, by(year)
 twoway (line seed_kg2 year), title()



*##############################################################################
* 				CALCULATING AP AND DS PARAMETERS
*____________________________________________________________________________* 


/////
*xtivreg std_income primeage age drought_shock i.year (improved dum_binis2 dum_fertrate dum_fertrate2 dum_fertseed= dist_agrodealer dist_fert extension rain_t_1), fe vce(cluster id)
	* original reg
	
xtset hh_id_obs
xtivreg lny hh_size v05_rf1 improved i.year (lnf lnf2 lns lns2 = hh_electricity_access dist_popcenter extension dist_weekly), fe vce(cluster hh_id_obs) first
	* our reg

capture drop u1
predict u1, xb

capture matrix drop a
matrix a=e(b)

scalar u1_seed=a[1,1] //You are refering to the specific coefficients in the matric. e.g., this one is for dum_binis.
scalar u1_fert=a[1,2]

scalar u1_seed2=a[1,3]
scalar u1_fert2=a[1,4]

scalar u1_seedfert=a[1,5]

capture drop mu1_seed mu1_fert
gen mu1_seed = u1_seed+2*u1_seed2*dum_binis+u1_seedfert*dum_fertrate
gen mu1_fert = u1_fert+2*u1_fert2*dum_fertrate+u1_seedfert*dum_binis



/// Second Moment
capture drop resid1
predict resid1, e 

capture drop resid1_sq
gen resid1_sq=resid1^2

reg resid1_sq dum_binis dum_binis2 dum_fertrate dum_fertrate2 dum_fertseed primeage age dist_agrodealer log_hh_income remitt i.year, vce(cluster id)

capture drop u2 
predict u2

capture matrix drop a2
matrix a2=e(b)

scalar u2_seed=a2[1,1]
scalar u2_fert=a2[1,2]

scalar u2_seed2=a2[1,3]
scalar u2_fert2=a2[1,4]

scalar u2_seedfert=a2[1,5]

capture drop mu2_seed mu2_fert
gen mu2_seed = u2_seed+2*u2_seed2*dum_binis+u2_seedfert*dum_fertrate
gen mu2_fert = u2_fert+2*u2_fert2*dum_fertrate+u2_seedfert*dum_binis

//Third Moment

capture drop resid3_sq
gen resid3_sq=resid1^3

reg resid3_sq dum_binis dum_binis2 dum_fertrate dum_fertrate2 dum_fertseed primeage age dist_agrodealer log_hh_income remitt i.year, vce(cluster id)

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
gen mu3_seed = u3_seed+2*u3_seed2*dum_binis+u3_seedfert*dum_fertrate
gen mu3_fert = u3_fert+2*u3_fert2*dum_fertrate+u3_seedfert*dum_binis

*########### GENERATING INTERACTION OF MOEMENT AND DROUGHT
 gen mod_mu2_seed=mod_dr_anomaly_t_1*mu2_seed
 gen mod_mu3_seed=mod_dr_anomaly_t_1*mu3_seed
 gen mod_mu2_fert=mod_dr_anomaly_t_1*mu2_fert
 gen mod_mu3_fert=mod_dr_anomaly_t_1*mu3_fert
 

 * GENERATING CONSTRAINTS SO THAT THE COEFFICEN ON THE SEED AND FERT MOMENT ARE THS SAME
constraint drop 1 2 3 4 5
constraint 1 [mu1_seed]mu2_seed=[mu1_fert]mu2_fert
constraint 2 [mu1_seed]mu3_seed=[mu1_fert]mu3_fert
constraint 3 [mu1_seed]mod_mu2_seed=[mu1_fert]mod_mu2_fert
constraint 4 [mu1_seed]mod_mu3_seed=[mu1_fert]mod_mu3_fert
constraint 5 [mu1_seed]mod_dr_anomaly_t_1=[mu1_fert]mod_dr_anomaly_t_1


**TABLE 3 in the paper


bootstrap, reps(300) seed(2045): ///
reg3 (mu1_seed mu2_seed mu3_seed ) ///
	(mu1_fert mu2_fert mu3_fert), constraint(1 2 3)	nolog

outreg2 using AP_DS_yield_lag, aster excel dec(5) ctitle(Model 1) replace



bootstrap, reps(300) seed(2045): ///
reg3 (mu1_seed mu2_seed mu3_seed mod_dr_anomaly_t_1 mod_mu2_seed mod_mu3_seed ) ///
	(mu1_fert mu2_fert mu3_fert mod_dr_anomaly_t_1 mod_mu2_fert mod_mu3_fert), constraint(1 2 3 4 5)	nolog

outreg2 using AP_DS_yield_lag, aster excel dec(5) ctitle(Model 2)

 
 
*#############################################################################
* DETERMINE HOW LONG THESE SHOCKS MAKE PEOPLE  RISK-AVERSE
*   we find they are temporal, get only up to t-3
*______________________________________________________________________________
 
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

**TABLE 4 in the text: Do lagged weather shocks affect risk attitudes?
	
reg3 (mu1_seed mu2_seed mu3_seed  mod_dr_anomaly_t_1-mod_dr_anomaly_t_5 mod_mu2_see* mod_mu3_see* ) ///
	(mu1_fert mu2_fert mu3_fert mod_dr_anomaly_t_1-mod_dr_anomaly_t_5 mod_mu2_fer* mod_mu3_fer*), constraint(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17) nolog

outreg2 using AP_DS_yield_lag, aster excel dec(5) ctitle(Model 3) replace
	
* =========================================================================
* Get the accumulated shocks effect--do they compound the effect***
*____________________________________________________________________________*
capture drop tot_shockd2	
gen tot_shockd2=0
replace tot_shockd2=1 if mod_dr_anomaly_t_1

capture drop tot_shockd3
gen tot_shockd3=0
replace tot_shockd3=1 if mod_dr_anomaly_t_1==1 & mod_dr_anomaly_t_2==1

capture drop tot_shockd4
gen tot_shockd4=0
replace tot_shockd4=1 if mod_dr_anomaly_t_1==1 & mod_dr_anomaly_t_2==1 & mod_dr_anomaly_t_3==1

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


**TABLE 4 in the document
reg3 (mu1_seed mu2_seed mu3_seed tot_shockd2 tot_shockd3 tot_shockd4 shock1_mu2_seed shock2_mu2_seed shock3_mu2_seed shock1_mu3_seed shock2_mu3_seed shock3_mu3_seed) ///
	(mu1_fert mu2_fert mu3_fert tot_shockd2 tot_shockd3 tot_shockd4 shock1_mu2_fert shock2_mu2_fert shock3_mu2_fert shock1_mu3_fert shock2_mu3_fert shock3_mu3_fert), constraint(1 2 3 4 5 6 7 8 9 10 11) nolog

outreg2 using AP_DS_yield_compound, aster excel dec(5) ctitle(shock) replace