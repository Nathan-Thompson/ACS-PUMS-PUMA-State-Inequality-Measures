# ACS-PUMS-PUMA-State-Inequality-Measures

Produces a portfolio of inequality indices--Gini, Theil, Atkinson--at the state and Public Use Microdata Area levels from [American Community survey data](http://www2.census.gov/programs-surveys/acs/data/pums/).

### Using The Files

Working directory should be organized / Data / Years / .csv files.  

DataTools.do will prepare the raw .csv files for use with the ASTaxsim and InequalityMeasures scripts. 

InequalityMeasures.do will generate a portfolio of income inequality indices--Atkinson, GE, Gini. It does this with individual, household, family and wage income, but can be adjusted for use with any of the ACS income measures. Requires the `ineqdeco` Stata package. 

ASTaxsim.do prepares the income data for use with [NBER's TAXSIM tool](http://users.nber.org/~taxsim/) which calculates state and federal tax liabilities. With this you can calculate pre- and post-tax inequality measures at all geographies. . This uses a method by [Andrew Samwick](https://www.dartmouth.edu/~samwick/) in his paper [Donating the Voucher: An Alternative Tax Treatment of Private School Enrollment](https://ideas.repec.org/a/ucp/tpolec/doi10.1086-671246.html). 

This choropleth shows the difference between pre/post tax inequality levels. Darker areas show a greater decrease in inequality due to federal & state tax liabilites. (Shapefiles availble [here](https://data2.nhgis.org/main)).

![](/img/prepost.jpg)

### Citation

I did all of this for my Master's dissertation, a draft of which is included as a pdf. Please cite as " Thompson, N. B. (2015). Effects of Geographic Aggregation on Inequality Indices (Unpublished masters dissertation). London School of Economics and Poltitical Science, London.""
 
 



