///////////
///////////
// Nathan Thompson
// April 2015


///*------------------------------------------------------------------------*///
///*--------------- Getting State & PUMA Inequality Indices ----------------*///
///*------------------------------------------------------------------------*///


/* This script loops over years of Census microdata and creates a new data file
with state and PUMA inequality measures. Currently grabs Atkinson, Gini and 
Generalized Entropy indices, but can be altered to get any of the indices that 
ineqdeco calculates. It takes two types of ACS microdata files, the individual 
record and the household record. */

///////////
///////////




///*------------------------ Individual Measures ---------------------------*///
	

// Individual State

postfile myfile year state istategini istatea2 istatea1 istateahalf istategem1 istatege0 istatege1 istatege2 using istateresults

foreach yea of numlist 2005/2013 {
	use "/Data/`yea'/ss`yea'pus4.dta", clear
	qui levelsof st, local(state)
	qui ineqdeco pincp [fw=pwgtp], by(st)
	foreach stat in `state' {
		post myfile (`yea') (`stat') (`r(gini_`stat')') (`r(a2_`stat')')  (`r(a1_`stat')')  (`r(ahalf_`stat')') (`r(gem1_`stat')')  (`r(ge0_`stat')')  (`r(ge1_`stat')') (`r(ge2_`stat')')   
	}
	
}
	

postclose myfile 


// Individual PUMA


postfile myfiles year double pumaid ipumagini ipumaa2 ipumaa1 ipumaahalf ipumagem1 ipumage0 ipumage1 ipumage2 using ipumaresults

foreach yea of numlist 2005/2013 {
	use "/Data/`yea'/ss`yea'pus4.dta", clear
	qui levelsof pumaid, local(pumas)
	qui ineqdeco pincp [fw=pwgtp], by(pumaid)
	foreach stat in `pumas' {
	post myfiles (`yea') (`stat') (`r(gini_`stat')') (`r(a2_`stat')')  (`r(a1_`stat')')  (`r(ahalf_`stat')') (`r(gem1_`stat')')  (`r(ge0_`stat')')  (`r(ge1_`stat')') (`r(ge2_`stat')')   
	}
}

postclose myfiles



// Individual Merge


use "/Labdesk/ipumaresults"
merge m:1 pumaid using "/Data/combinedkey.dta", nogen

merge m:1 state year using "/Labdesk/istateresults", nogen

save "/Labdesk/icombinedresults"



///*------------------------- Household Measures ---------------------------*///


// Household State

postfile myfile double pumaid pumaposttaxg pumaposttaxt using aftertaxresults

	qui levelsof pumaid, local(pumas)
	qui ineqdeco aftertaxinc [fw=wgtp], by(pumaid)
	foreach stat in `pumas' {
		post myfile (`stat') (`r(gini_`stat')')   (`r(ge1_`stat')')   
	}

postclose myfile


postfile myfile double pumaid pumapretaxg pumapretaxt using pretaxresults

	qui levelsof pumaid, local(pumas)
	qui ineqdeco totinc [fw=wgtp], by(pumaid)
	foreach stat in `pumas' {
		post myfile (`stat') (`r(gini_`stat')')   (`r(ge1_`stat')')   
	}

postclose myfile


// Household PUMA


postfile myfiles year double pumaid hpumagini hpumaa2 hpumaa1 hpumaahalf hpumagem1 hpumage0 hpumage1 hpumage2 using hpumaresults

foreach yea of numlist 2005/2013 {
	use "/Data/`yea'/ss`yea'hus4.dta", clear
	qui levelsof pumaid, local(pumas)
	qui ineqdeco hincp [fw=wgtp], by(pumaid)
	foreach stat in `pumas' {
		post myfiles (`yea') (`stat') (`r(gini_`stat')') (`r(a2_`stat')')  (`r(a1_`stat')')  (`r(ahalf_`stat')') (`r(gem1_`stat')')  (`r(ge0_`stat')')  (`r(ge1_`stat')') (`r(ge2_`stat')')   
	}
}

postclose myfiles


timer off 3

// Household Merge

use "/Labdesk/hpumaresults"
merge m:1 pumaid using "/Data/combinedkey.dta", nogen

merge m:1 state year using "/Labdesk/hstateresults", nogen

save "/Labdesk/hcombinedresults"

///*------------------------ Family Measures -------------------------------*///


// Family State

postfile myfile year state fstategini fstatea2 fstatea1 fstateahalf fstategem1 fstatege0 fstatege1 fstatege2 using fstateresults

foreach yea of numlist 2005/2013 {
	use "/Data/`yea'/ss`yea'hus4.dta", clear
	qui levelsof st, local(state)
	qui ineqdeco fincp [fw=wgtp], by(st)
	foreach stat in `state' {
		post myfile (`yea') (`stat') (`r(gini_`stat')') (`r(a2_`stat')')  (`r(a1_`stat')')  (`r(ahalf_`stat')') (`r(gem1_`stat')')  (`r(ge0_`stat')')  (`r(ge1_`stat')') (`r(ge2_`stat')')   
	}
}


postclose myfile


// Family PUMA


postfile myfiles year double pumaid fpumagini fpumaa2 fpumaa1 fpumaahalf fpumagem1 fpumage0 fpumage1 fpumage2 using fpumaresults

foreach yea of numlist 2005/2013 {
	use "/Data/`yea'/ss`yea'hus4.dta", clear
	qui levelsof pumaid, local(pumas)
	qui ineqdeco fincp [fw=wgtp], by(pumaid)
	foreach stat in `pumas' {
		post myfiles (`yea') (`stat') (`r(gini_`stat')') (`r(a2_`stat')')  (`r(a1_`stat')')  (`r(ahalf_`stat')') (`r(gem1_`stat')')  (`r(ge0_`stat')')  (`r(ge1_`stat')') (`r(ge2_`stat')')   
	}
}

postclose myfiles

// Family Merge

use "/Labdesk/fpumaresults"
merge m:1 pumaid using "/Data/combinedkey.dta", nogen

merge m:1 state year using "/Labdesk/fstateresults", nogen

save "/Labdesk/fcombinedresults"


	
///*------------------------------ Wages -----------------------------------*///


// Wage State

postfile myfile year state wstategini wstatea2 wstatea1 wstateahalf wstategem1 wstatege0 wstatege1 wstatege2 using wstateresults

foreach yea of numlist 2005/2013 {
	use "/Data/`yea'/ss`yea'pus4.dta", clear
	qui levelsof st, local(state)
	qui ineqdeco wagp [fw=pwgtp], by(st)
	foreach stat in `state' {
		post myfile (`yea') (`stat') (`r(gini_`stat')') (`r(a2_`stat')')  (`r(a1_`stat')')  (`r(ahalf_`stat')') (`r(gem1_`stat')')  (`r(ge0_`stat')')  (`r(ge1_`stat')') (`r(ge2_`stat')')   
	}
}


postclose myfile


// Wage PUMA


postfile myfiles year double pumaid wpumagini wpumaa2 wpumaa1 wpumaahalf wpumagem1 wpumage0 wpumage1 wpumage2 using wpumaresults

foreach yea of numlist 2005/2013 {
	use "/Data/`yea'/ss`yea'pus4.dta", clear
	qui levelsof pumaid, local(pumas)
	qui ineqdeco wagp [fw=pwgtp], by(pumaid)
	foreach stat in `pumas' {
		post myfiles (`yea') (`stat') (`r(gini_`stat')') (`r(a2_`stat')')  (`r(a1_`stat')')  (`r(ahalf_`stat')') (`r(gem1_`stat')')  (`r(ge0_`stat')')  (`r(ge1_`stat')') (`r(ge2_`stat')')   
	}
}

postclose myfiles


// Wage Merge

use "/Labdesk/wpumaresults"
merge m:1 pumaid using "/Data/combinedkey.dta", nogen

merge m:1 state year using "/Labdesk/wstateresults", nogen

save "/Labdesk/wcombinedresults"


//
