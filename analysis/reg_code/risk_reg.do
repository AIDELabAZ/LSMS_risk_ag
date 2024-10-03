* Project: lsms risk ag
* Created on: oct 3, 2024
* Created by: reece
* Edited on: oct 3, 2024
* Edited by: reece
* Stata v.18

* does
	
	
* assumes
	* access to all raw data
	* mdesc.ado
	* cleaned hh_seca.dta

* TO DO:
	* everything
* **********************************************************************
**#0 - setup
* **********************************************************************
xtset hhid
xtreg cp_hrv c.cp_frt##c.cp_frt v07_rf1 i.year, fe vce(cluster hhid)
predict resid, xb
egen resid2 = sd(resid)
egen resid3 = skew(resid)

* use resid2 and resid3 for the reg