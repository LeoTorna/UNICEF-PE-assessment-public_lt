
* Change this address to the address of your GitHub folder
global git_local "C:\Users\Usuario\OneDrive\Documentos\GitHub\UNICEF-PE-assessment-public_lt"

cd "$git_local"



* 2-A) Read in the csv file, “Zimbabwe_children_under5_interview.csv”
import delimited "https://raw.githubusercontent.com/unicef-drp/UNICEF-P3-assessment-public/main/01_rawdata/Zimbabwe_children_under5_interview.csv", clear 



* 2-B) Recode the responses so that Yes=1 / No=0 / DK=0.
* There is an observation in which the answers to all questions are codified as "9". 
* To avoid problems in the following exercises, those answers are recoded as missings (".")
recode ec6-ec15 (1 = 1) (2 8 = 0) (9 = .)



* 2-C) Calculate a table of summary statistics showing the percent correct for each item (EC6 to EC15), by child age in years
* Estimates are directly saved in Table_2C, then exported to Excel
putexcel set "UNICEF_results.xlsx", sheet(Table_2C) replace
local variables "ec6 ec7 ec8 ec9 ec10 ec11 ec12 ec13 ec14 ec15" 
local j = 5
foreach var in `variables' {
	putexcel B`j' = "`var'"
	local t = 3
	local columns "C D" 
	foreach COL in `columns' {
		sum `var' if child_age_years==`t'
		putexcel `COL'`j' = `r(mean)', nformat("#.0%")
		local t = `t'+1	
	}
	local j = `j'+1
}
putexcel (C3:D3), merge border(bottom)
putexcel (B2:D2) (B4:D4), border("bottom", "medium", "black") bold
putexcel (B14:D14), border(bottom)
putexcel (B5:B14), bold
putexcel (B3:D14), hcenter vcenter font(Calibri,11)
putexcel (C5:D14), font(Calibri,10)
putexcel C3 = "Child age in years", bold font(Calibri,12) txtwrap
putexcel B4 = "item", txtwrap
putexcel C4 = "3 years old", txtwrap
putexcel D4 = "4 years old", txtwrap
putexcel A1 = "Table 2C. Percent of correct answers for each item, by child age in years", bold font(Calibri,12)



* 2-D) Calculate an index, by taking the arithmetic average of the 10 items.
* There seems to be 3 reversely-worded items (EC10 - EC14 - EC15)
* If those items are not recoded, the index wont be the same than the scale constructed by Stata command "alpha" to compute reliability
egen index = rmean(ec6-ec15)



* 2-E) Calculate the Cronbach's Alpha of the index and report it in a table along with the number of observations.
* Estimates are directly saved in Table_2E, then exported to Excel
* Stata command "alpha" is used to calculate Cronbach's Alpha
* It calculates Cronbach's Alpha using those observations with complete information in all items (i.e., without missings)
putexcel set "UNICEF_results.xlsx", sheet(Table_2E) modify

* Using standardized items 
alpha ec6-ec15, gen(scale1) std
putexcel C4 = `r(alpha)', nformat("0.0000")
* Using unstandardized items
alpha ec6-ec15, gen(scale2)
putexcel C5 = `r(alpha)', nformat("0.0000")

* Stata command "alpha" does not report # of observations used in calculations 
* Then, # of observations is obtained counting the # of cases without missings in the 10 items 
egen nomiss = rownonmiss(ec6-ec15)
sum nomiss
count if nomiss==r(max)
putexcel (D4:D5) = `r(N)', nformat("#,###")

putexcel A1 = "Table 2E. Cronbach's Alpha", bold font(Calibri,12)
putexcel B4 = "Standardized Items", bold txtwrap
putexcel B5 = "Unstandardized Items", bold txtwrap
putexcel C3 = "Cronbach's Alpha", bold txtwrap
putexcel D3 = "# of observations", bold txtwrap
putexcel (B3:D5), hcenter vcenter font(Calibri,11)
putexcel (C4:D5), font(Calibri,10)
putexcel (B2:D3), border("bottom", "medium", "black")
putexcel (B5:D5), border(bottom)



* 2-F) Plot the conditional mean of the index on the child's age in months at the time of the interview. 
putexcel set "UNICEF_results.xlsx", sheet(Graph_2F) modify

* Obtaining child's age in months (months rounded to the closest integer)
gen months = round((date(interview_date,"YMD")-date(child_birthday,"YMD"))/(365/12))

* Conditional mean of index on child's age in months
bysort months: egen mean_index = mean(index)

* Plotting
scatter mean_index months, title("Mean of index, conditional on child's age in months") xtitle("Child's age in months", color(blue)) ytitle("Mean Index", color(blue)) xscale(noline) yscale(noline) 
graph export age1.png, width(600) height(360) replace
putexcel B3 = picture(age1.png)
putexcel A1 = "Graph 2F. Mean of the arithmetic index conditional on child's age in months", bold font(Calibri,12)



* 2-G) Print a table of OLS regression results regressing index on the child's age in months at the time of the interview. 
*      These regression results should contain at least the estimated coefficient on age, SE, R-squared, and the number of observations.
putexcel set "UNICEF_results.xlsx", sheet(Table_2G) modify

* Regression
regress index months

* Regression results
putexcel B5 = etable
putexcel B5 = ""
putexcel B6 = "Child's age in months"
putexcel B7 = "Intercept"

* # of observations
putexcel G3 = "# of Obs.", hcenter vcenter font(Calibri,11) bold
putexcel H3 = `e(N)', nformat("#,###") hcenter vcenter font(Calibri,10)

* R squared 
putexcel H4 = `e(r2)', nformat("0.0000") hcenter vcenter font(Calibri,10)
putexcel G4 = "R squared", hcenter vcenter font(Calibri,11) bold

putexcel (G5:H5), merge
putexcel (B5:H5) (B5:B7), bold txtwrap
putexcel (B5:H7), hcenter vcenter font(Calibri,10)
putexcel (C6:H7), nformat("0.0000")
putexcel (E6:E7), nformat("0.00")
putexcel (F6:F7), nformat("0.000")
putexcel A1 = "Table 2G. OLS regression of Index on child's age in months", bold font(Calibri,12)
putexcel (B4:H5), border("bottom", "medium", "black") 

