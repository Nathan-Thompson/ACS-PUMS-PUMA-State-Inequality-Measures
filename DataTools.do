///////////
///////////
// Nathan Thompson
// April 2015


///*------------------------------------------------------------------------*///
///*----------------------------- Data Tools -------------------------------*///
///*------------------------------------------------------------------------*///


/* Prepares the data for use with the DissGini and Taxsim files. Files need to 
be in the directory structure specified in the ReadMe. */

///////////
///////////




///*---------------------------- Merge A/B Files ---------------------------*///
// The csv files from the census FTP site are split into a/b files. I use the 
// 1-year estimates that will be called 'csv_husa.zip' 'csv_husa.zip'.  These 
// url: http://www2.census.gov/programs-surveys/acs/data/pums/


// .csv to .dta 

foreach yea of numlist 2006/2013 {
	import delimited "/Data/`yea'/ss13pusa.csv"
	qui save "/Data/`yea'/ss`yea'husa.dta"
	import delimited "/Data/`yea'/ss13pusb.csv"
	qui save "/Data/`yea'/ss`yea'husb.dta"
}

foreach yea of numlist 2006/2013 {
	import delimited "/Data/`yea'/ss13pusa.csv"
	qui save "/Data/`yea'/ss`yea'husa.dta"
	import delimited "/Data/`yea'/ss13pusb.csv"
	qui save "/Data/`yea'/ss`yea'husb.dta"
}


// Merges the a/b files 

foreach yea of numlist 2006/2013 {
	use	"/Data/`yea'/ss`yea'husa.dta", clear
	append using "/Data/`yea'/ss`yea'husb.dta"
	save "/Data/`yea'/ss`yea'hus.dta"
}

foreach yea of numlist 2006/2013 {
	use	"/Data/`yea'/ss`yea'pusa.dta", clear
	append using "/Data/`yea'/ss`yea'pusb.dta"
	save "/Data/`yea'/ss`yea'pus.dta"
}


///*---------- Hurricane Katrina Adjustment/Generate ID variable -----------*///
// Due to the population displacement from hurricane Katrina, three PUMA areas
// were merged into one. This change will only happen in the 2005 file.  


// Individual 

foreach yea of numlist 2005/2011 {
	use "/Data/`yea'/ss`yea'pus.dta", clear
	capture drop pumaid
	gen vintage=2000
	egen pumaid=concat(st puma vintage)
	destring pumaid, replace
	qui replace pumaid=22777772000 if pumaid==2218012000
	qui replace pumaid=22777772000 if pumaid==2218022000
	qui replace pumaid=22777772000 if pumaid==2219052000
	replace 
	save "/Data/`yea'/ss`yea'pus2.dta",replace
}

foreach yea of numlist 2012 2013 {
	use "/Data/`yea'/ss`yea'pus.dta", clear
	capture drop pumaid
	gen vintage=2010
	egen pumaid=concat(st puma vintage)
	destring pumaid, replace
	save "/Data/`yea'/ss`yea'pus2.dta",replace
}


// Household

foreach yea of numlist 2005/2011 {
	use "/Data/`yea'/ss`yea'hus.dta", clear
	capture drop pumaid
	gen vintage=2000
	egen pumaid=concat(st puma vintage)
	destring pumaid, replace
	replace adjinc=adjinc/1000000
	qui replace pumaid=22777772000 if pumaid==2218012000
	qui replace pumaid=22777772000 if pumaid==2218022000
	qui replace pumaid=22777772000 if pumaid==2219052000
	save "/Data/`yea'/ss`yea'hus2.dta",replace
}

foreach yea of numlist 2012 2013 {
	use "/Data/`yea'/ss`yea'hus.dta", clear
	capture drop pumaid
	gen vintage=2010
	egen pumaid=concat(st puma vintage)
	destring pumaid, replace
	save "/Data/`yea'/ss`yea'hus2.dta",replace
}


///*----------------------- Generating Merge Keys --------------------------*///
// Creates Merge keys for the 2000's and 2010 PUMA vintages.

use "/Data/2010/ss2010pus2.dta", clear
keep st pumaid
duplicates drop pumaid, force
save "/Data/2000pumakey.dta", replace

use "/Data/2012/ss2012pus2.dta", clear
keep st pumaid 
duplicates drop pumaid, force
save "/Data/2010pumakey.dta",replace

append using "/Data/2000pumakey.dta"
rename st state
save "/Data/combinedkey.dta", replace


// PUMAID accuracy check 

split pumaid, gen(stat) destring
count if st==stat


//
