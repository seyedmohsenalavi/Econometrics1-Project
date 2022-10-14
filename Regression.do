
    /*-------------------------------Regression---------------------------------*/
	/*
			Master.do
				|
				|___ Regression.do
			
			Steps for Regression:				
				step  1  |  Add time fixed effects
			    step  2  |  label variables
				step  3  |  Collapse for regression
				step  4  |  Add Ln variables to compute Elasticity
				step  5  |  Breush-Pagan test of heteroskedasticity for Simple Regression
				step  6  |  Simple Regression
				step  7  |  Regression with regions fixed effects
				step  8  |  Regression with weeks fixed effects(time trend)
			    step  9  |  Regression with weeks & regions fixed effects
			    step  10 |  Regression with weeks & regions fixed effects and air-pollution control
				step  11 |  Regression with regions & days & weeks fixed effects and air-pollution control
				step  12 |  Redo step5-10 for export regression results in excel 
	--------------------------------------------------------------------------*/

	
//Step1:Add time fixed effects
gen dofw=dow(numdate)
gen week=week(numdate)

//Step2:label variables
label var dofw	"trip's day of the week" // (sunday=0 monday=1 ... saturday=6)
label var week	"trip's week number"     // week number=1-52 

//Step3:Collapse for regression
collapse (sum) weight (mean) fare district dofw week unhlthy taxitype, by(numdate routeid)

//Step4:Add ln of variables to compute Elasticity
gen lndem=ln(weight)
gen lnfare=ln(fare)

label var lndem      "ln(demand)"
label var lnfare     "ln(fare)"


//Step5:Breush-Pagan test of heteroskedasticity for Simple Regression
reg lndem lnfare
estat hettest

//Step6:Simple Regression
reg lndem lnfare, robust
outreg2 using "Result/reg.doc" , replace ctitle("OLS") nocons addstat("Adjusted R-squared", e(r2_a)) /*
 */ addtext (Regions fixed effects, No , Time fixed effects, No , Days fixed effects, No )

 
//Step7:Regression with regions fixed effects
reg lndem lnfare i.district, robust
outreg2 using "Result/reg.doc" , ctitle("FE") keep(lndem lnfare)  nocons addstat("Adjusted R-squared", e(r2_a)) /*
 */addtext (Regions fixed effects, Yes , Time fixed effects, No , Days fixed effects, No )

 
//Step8:Regression with weeks fixed effects(time trend)
reg lndem lnfare i.week, robust
outreg2 using "Result/reg.doc", ctitle("FE") keep(lndem lnfare) nocons addstat("Adjusted R-squared", e(r2_a)) /*
 */addtext (Regions fixed effects, No , Time fixed effects, Yes , Days fixed effects, No )


//Step9:Regression with weeks & regions fixed effects
reg lndem lnfare i.week i.district, robust
outreg2 using "Result/reg.doc" , ctitle("FE") keep(lndem lnfare) nocons addstat("Adjusted R-squared", e(r2_a)) /*
 */addtext (Regions fixed effects, Yes , Time fixed effects, Yes , Days fixed effects, No )

 
//Step10:Regression with weeks & regions fixed effects and air-pollution control
reg lndem lnfare unhlthy i.week i.district, robust
outreg2 using "Result/reg.doc", ctitle("FE" ) keep(lndem lnfare unhlthy) nocons addstat("Adjusted R-squared", e(r2_a)) /*
 */addtext (Regions fixed effects, Yes , Time fixed effects, Yes , Days fixed effects, No )

 
//Step11:Regression with regions & days & weeks fixed effects and air-pollution control
reg lndem lnfare unhlthy i.week i.district  i.dofw, robust
outreg2 using "Result/reg.doc", ctitle("FE") keep(lndem lnfare unhlthy) nocons addstat("Adjusted R-squared", e(r2_a)) /*
 */addtext (Regions fixed effects, Yes , Time fixed effects, Yes , Days fixed effects, Yes )

 
//step12:Redo step5-10 for export results in excel 

//Simple Regression
reg lndem lnfare , robust
outreg2 using reg, dta replace ctitle("OLS") nocons depvar addstat("Adjusted R-squared", e(r2_a)) /*
 */ addtext (Regions fixed effects, No , Time fixed effects, No , Days fixed effects, No )

//Regression with regions fixed effects
reg lndem lnfare i.district, robust
outreg2 using reg , dta ctitle("FE") keep(lndem lnfare) nocons depvar addstat("Adjusted R-squared", e(r2_a)) /*
 */addtext (Regions fixed effects, Yes , Time fixed effects, No , Days fixed effects, No ) 

 
//Regression with weeks fixed effects(time trend)
reg lndem lnfare i.week, robust
outreg2 using reg , dta ctitle("FE") keep(lndem lnfare) nocons addstat("Adjusted R-squared", e(r2_a)) /*
 */addtext (Regions fixed effects, No , Time fixed effects, Yes , Days fixed effects, No )

 
//Regression with weeks & regions fixed effects
reg lndem lnfare i.week i.district, robust
outreg2 using reg , dta ctitle("FE") keep(lndem lnfare) nocons addstat("Adjusted R-squared", e(r2_a)) /*
 */addtext (Regions fixed effects, Yes , Time fixed effects, Yes , Days fixed effects, No )
 
//Regression with weeks & regions fixed effects and air-pollution control
 reg lndem lnfare unhlthy i.week i.district, robust
outreg2 using reg , dta ctitle("FE" ) keep(lndem lnfare unhlthy) nocons addstat("Adjusted R-squared", e(r2_a)) /*
 */addtext (Regions fixed effects, Yes , Time fixed effects, Yes , Days fixed effects, No )

 
//Regression with regions & days & weeks fixed effects and air-pollution control
  reg lndem lnfare unhlthy i.week i.district  i.dofw, robust
outreg2 using reg , dta ctitle("FE") keep(lndem lnfare unhlthy) nocons addstat("Adjusted R-squared", e(r2_a)) /*
 */addtext (Regions fixed effects, Yes , Time fixed effects, Yes , Days fixed effects, Yes )

 
//export to excel
use reg_dta , clear
export excel using "Result/project.xls" , sheet("Reg",replace)
