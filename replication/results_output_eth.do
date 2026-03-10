* Project: lsms risk ag
* Created on: feb 2025
* Created by: reece
* Edited on: 10 Mar 2026
* Edited by: alj
* Stata v.18+

* does
    * creates output tables for Ethiopia results in .txt file

 * assumes
	* cleaned, merged (weather), and appended (waves) data

* TO DO:
	* add time: started run at 3.17
	* deal with output 
	

********************************************************************************
**#0 - setup
********************************************************************************

global root   "$data/lsms_risk_ag_data/regression_data/ethiopia"
global export "$data/lsms_risk_ag_data/results"
global logout "$data/lsms_risk_ag_data/regression_data/logs"

cap log close
log using "$logout/regressions", append

cap which esttab
if _rc {
    ssc install estout
}

********************************************************************************
**#1 - load data
********************************************************************************

use "$root/eth_complete", clear

********************************************************************************
**#2 - create variables we need for regression
********************************************************************************

egen    std_y = std(harvest_value_USD/plot_area_GPS)
sum     std_y
drop if std_y > 20
drop    std_y
egen    std_y = std(harvest_value_USD/plot_area_GPS)

gen     std_y2 = std_y^2
gen     std_y3 = std_y^3
egen    std_f  = std(fert_kg/plot_area_GPS)
egen    std_s  = std(isp)
gen     std_f2 = std_f^2
gen     std_s2 = std_s^2
gen     std_fs = std_f * std_s

********************************************************************************
**#2.5 - safe bootstrap wrappers for reg3
********************************************************************************

capture program drop reg3_safe_mod1
program define reg3_safe_mod1, rclass
    version 18
    quietly constraint drop _all
    quietly constraint 1 [mu1_s]mu2_s = [mu1_f]mu2_f
    quietly constraint 2 [mu1_s]mu3_s = [mu1_f]mu3_f

    capture noisily reg3 (mu1_s mu2_s mu3_s) (mu1_f mu2_f mu3_f), constraint(1 2) nolog
    if _rc {
        return scalar ok = 0
        return scalar theta2 = .
        return scalar theta3 = .
        exit
    }

    return scalar ok = 1
    return scalar theta2 = _b[mu1_s:mu2_s]
    return scalar theta3 = _b[mu1_s:mu3_s]
end

capture program drop reg3_safe_mod2
program define reg3_safe_mod2, rclass
    version 18
    syntax varname(name=shockvar)

    quietly constraint drop _all
    quietly constraint 1 [mu1_s]mu2_s = [mu1_f]mu2_f
    quietly constraint 2 [mu1_s]mu3_s = [mu1_f]mu3_f
    quietly constraint 3 [mu1_s]mod_mu2_s = [mu1_f]mod_mu2_f
    quietly constraint 4 [mu1_s]mod_mu3_s = [mu1_f]mod_mu3_f
    quietly constraint 5 [mu1_s]`shockvar' = [mu1_f]`shockvar'

    capture noisily reg3 ///
        (mu1_s mu2_s mu3_s `shockvar' mod_mu2_s mod_mu3_s) ///
        (mu1_f mu2_f mu3_f `shockvar' mod_mu2_f mod_mu3_f), ///
        constraint(1 2 3 4 5) nolog

    if _rc {
        return scalar ok = 0
        return scalar theta2 = .
        return scalar theta3 = .
        return scalar theta2_shock = .
        return scalar theta3_shock = .
        exit
    }

    return scalar ok = 1
    return scalar theta2 = _b[mu1_s:mu2_s]
    return scalar theta3 = _b[mu1_s:mu3_s]
    return scalar theta2_shock = _b[mu1_s:mod_mu2_s]
    return scalar theta3_shock = _b[mu1_s:mod_mu3_s]
end

********************************************************************************
**#3 - run regressions and store formatted model results to file
********************************************************************************

xtset hh_id_obs

local rain  v01_rf2 v05_rf2 v01_rf3 v05_rf3 v01_rf4 v05_rf4
local lag   v01_rf2_t1 v05_rf2_t1 v01_rf3_t1 v05_rf3_t1 v01_rf4_t1 v05_rf4_t1
local shock v07_rf2_t1 v09_rf2_t1 v11_rf2_t1 v13_rf2_t1 v14_rf2_t1 ///
           v07_rf3_t1 v09_rf3_t1 v11_rf3_t1 v13_rf3_t1 v14_rf3_t1 ///
           v07_rf4_t1 v09_rf4_t1 v11_rf4_t1 v13_rf4_t1 v14_rf4_t1

cap erase "$export/model_comparisons_eth.txt"

foreach v in `rain' {
    foreach t in `lag' {

        if substr("`v'", 2, 2) == substr("`t'", 2, 2) & substr("`v'", 7, 1) == substr("`t'", 7, 1) {

            * ------------------------------------------------------------
            * First Moment (Mean)
            * ------------------------------------------------------------
            xtivreg std_y hh_size `v' i.year ///
                (std_f std_f2 std_s std_s2 std_fs = ///
                 hh_electricity_access dist_popcenter ///
                 extension dist_weekly maize_ea_p `t'), ///
                fe vce(cluster hh_id_obs)

            * ------------------------------------------------------------
            * Tier-1 IV relevance diagnostics (FIRST MOMENT ONLY)
            * FE first stages + joint F test of excluded instruments
            * ------------------------------------------------------------
            local Zinst hh_electricity_access dist_popcenter extension dist_weekly maize_ea_p `t'

            quietly xtreg std_f  hh_size `v' i.year `Zinst', fe vce(cluster hh_id_obs)
            quietly test `Zinst'
            scalar fsF_f = r(F)

            quietly xtreg std_s  hh_size `v' i.year `Zinst', fe vce(cluster hh_id_obs)
            quietly test `Zinst'
            scalar fsF_s = r(F)

            quietly xtreg std_f2 hh_size `v' i.year `Zinst', fe vce(cluster hh_id_obs)
            quietly test `Zinst'
            scalar fsF_f2 = r(F)

            quietly xtreg std_s2 hh_size `v' i.year `Zinst', fe vce(cluster hh_id_obs)
            quietly test `Zinst'
            scalar fsF_s2 = r(F)

            quietly xtreg std_fs hh_size `v' i.year `Zinst', fe vce(cluster hh_id_obs)
            quietly test `Zinst'
            scalar fsF_fs = r(F)

            scalar fsF_min = min(fsF_f, fsF_s, fsF_f2, fsF_s2, fsF_fs)

            matrix a = e(b)
            scalar b1_f  = a[1,1]
            scalar b1_f2 = a[1,2]
            scalar b1_s  = a[1,3]
            scalar b1_s2 = a[1,4]
            scalar b1_fs = a[1,5]

            gen mu1_s = b1_s + 2*b1_s2 * std_s + b1_fs * std_f
            gen mu1_f = b1_f + 2*b1_f2 * std_f + b1_fs * std_s

            * ------------------------------------------------------------
            * Second Moment (Variance proxy)
            * ------------------------------------------------------------
            xtivreg std_y2 hh_size `v' i.year ///
                (std_f std_f2 std_s std_s2 std_fs = ///
                 hh_electricity_access dist_popcenter ///
                 extension dist_weekly `t'), ///
                fe vce(cluster hh_id_obs)

            matrix a2 = e(b)
            scalar b2_f  = a2[1,1]
            scalar b2_f2 = a2[1,2]
            scalar b2_s  = a2[1,3]
            scalar b2_s2 = a2[1,4]
            scalar b2_fs = a2[1,5]

            gen mu2_s = b2_s + 2*b2_s2 * std_s + b2_fs * std_f
            gen mu2_f = b2_f + 2*b2_f2 * std_f + b2_fs * std_s

            * ------------------------------------------------------------
            * Third Moment (Skewness proxy)
            * ------------------------------------------------------------
            xtivreg std_y3 hh_size `v' i.year ///
                (std_f std_f2 std_s std_s2 std_fs = ///
                 hh_electricity_access dist_popcenter ///
                 extension dist_weekly `t'), ///
                fe vce(cluster hh_id_obs)

            matrix a3 = e(b)
            scalar b3_f  = a3[1,1]
            scalar b3_f2 = a3[1,2]
            scalar b3_s  = a3[1,3]
            scalar b3_s2 = a3[1,4]
            scalar b3_fs = a3[1,5]

            gen mu3_s = b3_s + 2*b3_s2 * std_s + b3_fs * std_f
            gen mu3_f = b3_f + 2*b3_f2 * std_f + b3_fs * std_s

            * Print diagnostics ONCE per (v,t) block
            file open fh using "$export/model_comparisons_eth.txt", write append
            file write fh _n "------------------------------------------------------------" _n ///
                "Ethiopia | Rain: `v' | Lag: `t'" _n ///
                "IV relevance diagnostics (first moment; FE first-stage joint F tests):" _n ///
                "   F(std_f)  = " %9.2f (fsF_f)  _n ///
                "   F(std_s)  = " %9.2f (fsF_s)  _n ///
                "   F(std_f2) = " %9.2f (fsF_f2) _n ///
                "   F(std_s2) = " %9.2f (fsF_s2) _n ///
                "   F(std_fs) = " %9.2f (fsF_fs) _n ///
                "   F(min)    = " %9.2f (fsF_min) _n ///
                "------------------------------------------------------------" _n
            file close fh

            foreach s in `shock' {
                if substr("`v'", 7, 1) == substr("`s'", 7, 1) {

                    gen mod_mu2_s = `s' * mu2_s
                    gen mod_mu3_s = `s' * mu3_s
                    gen mod_mu2_f = `s' * mu2_f
                    gen mod_mu3_f = `s' * mu3_f

                    eststo clear

                    * Model 1 (safe bootstrap)
                    bootstrap r(theta2) r(theta3), reps(100) seed(2045) reject(r(ok)==0): ///
                        reg3_safe_mod1
                    eststo model1

                    * Model 2 (safe bootstrap)
                    bootstrap r(theta2) r(theta3) r(theta2_shock) r(theta3_shock), reps(100) seed(2045) reject(r(ok)==0): ///
                        reg3_safe_mod2 `s'
                    eststo model2

                    * Save to results file
                    esttab model1 model2 using "$export/model_comparisons_eth.txt", ///
                        append se star(* 0.1 ** 0.05 *** 0.01) ///
                        label compress nomtitle nogaps ///
                        title("Shock: `s'")

                    drop mod_mu2_s mod_mu3_s mod_mu2_f mod_mu3_f
                }
            }

            drop mu1_s mu1_f mu2_s mu2_f mu3_s mu3_f
        }
    }
}

log close