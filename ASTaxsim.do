///////////
///////////
// Nathan Thompson
// Prof. Andrew Samwick
// April 2015


///*------------------------------------------------------------------------*///
///*------------------------ Taxsim Preparation ----------------------------*///
///*------------------------------------------------------------------------*///


/* Takes scripts prepared by DataTools.do and prepares them for use with the 
NBER TAXSIM calculator.  */

/* Original code provided by Andrew Samwick 25-4-15. Nathan Thompson added file 
loop, code now outputs taxsim9-ready files, does not call taxsim */
 
/* “Users of this code are requested to cite the following paper as the original 
source: Samwick, Andrew A. 2013. “Donating the Voucher: An Alternative Tax 
Treatment of Private School Enrollment”. Tax Policy and the Economy 27 (1). 
University of Chicago Press: 125–60. doi:10.1086/671246.” */

///////////
///////////


clear
capture log close
log using rev1_nathan.log, replace


set more 1


// Uses merged PUMS data files

foreach ff of numlist 2005/2013 {
macro def gg "1 2 4 5 6 8 9 10 11 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56"
 
  
use "/Users/Jake94x/Desktop/Dissertation/Data/`ff'/ss`ff'hus3", clear
d,d
drop adjinc type-hfl mhp rms rntm tel-vacs veh-ybl fparc-hhl hugcl-ocpip plm smocp facrp-wgtp80
//capture drop adjust
sort serialno
save ptemp, replace

use "/Users/Jake94x/Desktop/Dissertation/Data/`ff'/ss`ff'pus3", clear
d,d
drop eng-gcr lan* jw* wkl-drivesp mlp* nw* mig* nativity nop paoc pobp-racwht vps-pwgtp80
sort serialno
merge m:m serialno using ptemp

tab _merge
drop if _merge != 3
drop _merge

gen ast = st
gen year = `ff'
gen rschg  = schg
gen rrelp = relp
drop schg relp



** Household identifier, recognizing subfamily units

gen rsfn = sfn
replace rsfn = 0 if rsfn == .
gen rsfr = sfr
replace rsfr = 0 if rsfr == .
gen rmsp = msp
drop sfn sfr msp

sort serialno rsfn rsfr rrelp

* Construct demographic variables and new tax filing units as needed

gen rhht = hht
gen rsch = sch

drop hht sch

gen qualchild = agep <= 19 | (agep <= 24 & rschg != .)
gen qualrel = qualchild == 0 & pincp <= 3700 & rrelp != 0

** Recode foster children as children (i.e. always with the nuclear family)
replace rrelp = 2 if rrelp == 11

** Identify nuclear families filing as one unit
gen nucfam = rsfn != 0 | rrelp == 0 | rrelp == 1 | (rrelp == 2 & qualchild == 1) | (rrelp == 2 & qualrel == 1)
gen nonnuc = 1 - nucfam
egen hasnonnuc = max(nonnuc), by(serialno rsfn)
egen numnonnuc = sum(nonnuc), by(serialno rsfn)

** Verify that nonnuc == 1 implies rmsp != 1
**   i.e. if the spouse were present, this would be a subfamily
**   All observations with newsingle == 1 will be a single taxfiling unit
   
tab rmsp nonnuc if rsfn == 0

gen newsingle = rrelp < 13 & nonnuc == 1 & rmsp != 1 & qualchild == 0

replace newsingle = 1 if rrelp == 8 & nonnuc == 1 & rmsp != 1
replace newsingle = 1 if rrelp == 9 & nonnuc == 1 & rmsp != 1

** Make new identifiers for non-nuclear family members not in subfamilies

gen nnn = 0
gen maxnnn = 0
gen rnum = 1
egen nf = count(sporder), by(serialno rsfn)
sum nf
local nn = r(max)

forvalues i = 2(1)`nn' {
  di `i'
  replace rnum = `i' if serialno == serialno[_n-`i'+1] & rsfn == rsfn[_n-`i'+1] 
  replace nnn = maxnnn[_n-1] + 1 if newsingle == 1 & rnum == `i'
  replace maxnnn = nnn if newsingle == 1 & rnum == `i'
  replace maxnnn = maxnnn[_n-1] if newsingle == 0 & rnum == `i' 
  }
 
drop maxnnn nf

** Identifier taxpayer and spouse across all family types

gen taxpayer = 0
gen spouse = 0

replace taxpayer = 1 if rsfn == 0 & (rrelp == 0 | rrelp == 13 | rrelp == 14 | nnn != 0)
replace taxpayer = 1 if (rsfr == 1 | rsfr == 2) & rnum == 1
replace taxpayer = 1 if rsfr == 3

replace spouse = 1 if rsfn == 0 & rrelp == 1
replace spouse = 1 if (rsfr == 1 | rsfr == 2) & rnum == 2

egen hastaxpayer = max(taxpayer), by(serialno rsfn nnn)
egen hasspouse = max(spouse), by(serialno rsfn nnn)

** Adjust weights to take a 1/K sample of non-k12 households
** Recode state to match Taxsim

gen byte state = 0
replace state =  1 if ast ==  1
replace state =  2 if ast ==  2
replace state =  3 if ast ==  4
replace state =  4 if ast ==  5
replace state =  5 if ast ==  6
replace state =  6 if ast ==  8
replace state =  7 if ast ==  9
replace state =  8 if ast == 10
replace state =  9 if ast == 11
replace state = 10 if ast == 12
replace state = 11 if ast == 13
replace state = 12 if ast == 15
replace state = 13 if ast == 16
replace state = 14 if ast == 17
replace state = 15 if ast == 18
replace state = 16 if ast == 19
replace state = 17 if ast == 20
replace state = 18 if ast == 21
replace state = 19 if ast == 22
replace state = 20 if ast == 23
replace state = 21 if ast == 24
replace state = 22 if ast == 25
replace state = 23 if ast == 26
replace state = 24 if ast == 27
replace state = 25 if ast == 28
replace state = 26 if ast == 29
replace state = 27 if ast == 30
replace state = 28 if ast == 31
replace state = 29 if ast == 32
replace state = 30 if ast == 33
replace state = 31 if ast == 34
replace state = 32 if ast == 35
replace state = 33 if ast == 36
replace state = 34 if ast == 37
replace state = 35 if ast == 38
replace state = 36 if ast == 39
replace state = 37 if ast == 40
replace state = 38 if ast == 41
replace state = 39 if ast == 42
replace state = 40 if ast == 44
replace state = 41 if ast == 45
replace state = 42 if ast == 46
replace state = 43 if ast == 47
replace state = 44 if ast == 48
replace state = 45 if ast == 49
replace state = 46 if ast == 50
replace state = 47 if ast == 51
replace state = 48 if ast == 53
replace state = 49 if ast == 54
replace state = 50 if ast == 55
replace state = 51 if ast == 56

** Recode property tax to interval midpoint

gen rtaxp = taxp
gen rtaxpval = 0
replace rtaxpval = 50*(rtaxp - 1) - 25 if rtaxp >= 2 & rtaxp <= 21
replace rtaxpval = 100*(rtaxp - 11) - 50 if rtaxp >= 22 & rtaxp <= 61
replace rtaxpval = 500*(rtaxp - 51) - 250 if rtaxp >= 62 & rtaxp <= 63
replace rtaxpval = 1000*(rtaxp - 57) - 500 if rtaxp >= 64 & rtaxp <= 67
replace rtaxpval = 14000 if rtaxp == 68
drop taxp

** Recode property value to interval midpoint

gen rval = val
gen rhval = 0
replace rhval = 5000 if rval == 1
replace rhval = 5000*(rval + 1) - 2500 if rval >= 2 & rval <= 7
replace rhval = 10000*(rval - 3) - 5000 if rval >= 8 & rval <= 13
replace rhval = 25000*(rval - 9) - 12500 if rval >= 14 & rval <= 17
replace rhval = 50000*(rval - 13) - 25000 if rval >= 18 & rval <= 19
replace rhval = 100000*(rval - 16) - 50000 if rval >= 20 & rval <= 21
replace rhval = 250000*(rval - 19) - 125000 if rval >= 22 & rval <= 23
replace rhval = 1400000 if rval == 24
drop val

** Mortgage payments
** Assume whole payment is interest (for now)

gen rmrgi = mrgi
gen rmrgt = mrgt
gen rmrgp = mrgp
replace rmrgp = 0 if rmrgp == .
gen rinsp = insp
replace rinsp = 0 if insp == .

gen rmrgval = 0
replace rmrgval = 12*rmrgp if rmrgi != 1 & rmrgt != 1
replace rmrgval = max(0,12*rmrgp - rinsp) if rmrgi == 1 & rmrgt != 1
replace rmrgval = max(0,12*rmrgp - rtaxpval) if rmrgi != 1 & rmrgt == 1
replace rmrgval = max(0,12*rmrgp - rinsp - rtaxpval) if rmrgi == 1 & rmrgt == 1 

* Note that there seem to be errors in which reported smp is an annual amount
*   These errors should not get multiplied by 12.  Better to err on the side of
*   treating smp like a one-time payment

gen rsmp = smp
replace rsmp = 0 if rsmp == .
* replace rmrgval = rmrgval + 12*rsmp
replace rmrgval = rmrgval + rsmp
drop mrgi mrgt insp smp

egen numqualchild = sum(qualchild*(taxpayer == 0)*(spouse == 0)), by(serialno rsfn nnn)
egen numqualrel = sum(qualrel*(taxpayer == 0)*(spouse == 0)), by(serialno rsfn nnn)

gen a65 = agep >= 65
egen t65 = sum(a65), by(serialno rsfn nnn)

** Taxsim inputs

gen depx = numqualchild + numqualrel
replace depx = 15 if depx > 15

gen mstat = 1
replace mstat = 2 if hasspouse == 1
replace mstat = 3 if hasspouse == 0 & depx > 0

gen agex = min(2,t65) 

gen pwages = wagp + semp
*** A change from earlier version -> Use all non-primary wages
egen swages_spouse = sum((wagp+semp)*spouse), by(serialno rsfn nnn)
egen swages = sum((wagp+semp)*(taxpayer == 0)), by(serialno rsfn nnn)

gen dividends = 0

egen otherprop = sum(intp), by(serialno rsfn nnn)
egen pensions = sum(retp), by(serialno rsfn nnn)
egen gssi = sum(ssp), by(serialno rsfn nnn)
egen transfers = sum(pap+ssip), by(serialno rsfn nnn)

gen rentpaid = 0
replace rentpaid = 12*rntp if rntp < . & rrelp == 0 

gen proptax = 0
replace proptax = rtaxpval if rrelp == 0

gen otheritem = 0

gen childcare = 0

gen ui = 0

gen isdepchild = (agep <= 17)*(qualchild == 1)
egen depchild = sum(isdepchild), by(serialno rsfn nnn)
replace depchild = 5 if depchild > 5
replace depchild = depx if depchild > depx

gen mortgage = 0
replace mortgage = rmrgval if rrelp == 0

** No information on capital gains
** Assign all other income to ltcg

gen stcg = 0

replace oip = 0 if oip == .
egen ltcg = sum(oip), by(serialno rsfn nnn)

sort serialno

gen long taxsimid2 = _n

sum year state mstat-ltcg if taxpayer == 1

** Save data, prior to call to Taxsim9

sort taxsimid



compress
save "/Users/Jake94x/Desktop/Dissertation/labdesk/rev1_`ff'", replace

preserve
keep if taxpayer==1

gen long taxsimid = _n
save "/Users/Jake94x/Desktop/Dissertation/labdesk/rev1_`ff'combinekey", replace

keep taxsimid year state mstat depx agex pwages swages dividends otherprop pensions gssi transfers rentpaid proptax otheritem childcare ui depchild mortgage stcg ltcg

save "/Users/Jake94x/Desktop/Dissertation/labdesk/rev1_`ff'taxsimready.dta", replace

restore
}


//Now use taxsim local client, these are usually too big to send to the servers
//
