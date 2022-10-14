  /*-------------------------------Descriptive Statistics---------------------------------*/
/*
			Master.do
				|
				|___ Descriptive.do
			
			Steps for Descriptive:				
				step  1  |  Generate some variables and label them
				steo  2  |  Some calculations
				step  2  |  Draw histogram of all transactions by date
				step  3  |  Calculate percent of all transactions before & after the campaign
				step  4  |  Calculate average number of daily transactions before & after the campaign
				step  5  |  Calculate percent of all transactions by van or taxi
				step  6  |  Calculate percent of all transactions by week's days
				step  7  |  Calculate percent of all transactions by districts
			    step  8  |  Draw bar-chart of all transaction by regions of beginning location & destination of trips
				step  9  |  Draw bar-chart of all transactions by taxitype(van or taxi)
				step  10 |  Draw bar-chart of all transactions by week's days
				step  11 |  Draw histogram of all transactions by date
	--------------------------------------------------------------------------*/

//step1: Generate some variables and label them
gen dofw=dow(numdate)
label var dofw	"trip's day of the week"
label define dofw 0 "sunday" 1 "monday" 2 "tuesday" 3 "wednesday" 4 "thursday" 5 "friday" 6 "saturday"
label values dofw dofw

label define taxitype 0 "van" 1 "taxi"
label values taxitype taxitype

gen campaign=(numdate>td(5may2019))
label define campaign 0 "before" 1 "after"
label values campaign campaign

tempfile temp
save `temp'

//step2:Some calculations
unique routeid 
unique district


//step3: Calculate percent of all transactions before & after the campaign
collapse (percent) weight, by(campaign)
save "Result/campaign.dta", replace
decode campaign , gen(Campaign)
mkmat weight , matrix(percentcamp) rownames(Campaign)
putexcel set "Result/project.xls", sheet("Desc", replace) modify
putexcel A1 = "percent of all transactions before & after the campaign" ,  font( bold , 14, blue)
putexcel A2 = matrix(percentcamp) , rownames border(all)
asdoc wmat, matrix(percentcamp) save(Result/Descriptive.doc) rnames(before after) title(All transactions before & after the campaign) cnames(Percent) label replace
use `temp', clear


//step4: Calculate average number of daily transactions before & after the campaign
collapse (sum) weight , by(campaign numdate)
collapse (mean) weight , by(campaign)
save "Result/campaign2.dta", replace
decode campaign , gen(Campaign)
mkmat weight , matrix(meancamp) rownames(Campaign)
putexcel set "Result/project.xls", sheet("Desc") modify
putexcel H1 = "average number of daily transactions before & after the campaign" ,  font( bold , 14, blue)
putexcel H2 = matrix(meancamp) , rownames border(all) 
asdoc wmat, matrix(meancamp) save(Result/Descriptive.doc) rnames(before after) title(Number of daily transactions before & after the campaign) cnames(Average) label append
use `temp', clear


//step5: Calculate percent of all transactions by van or taxi
collapse (percent) weight , by(taxitype)
save "Result/bytaxitype.dta", replace
decode taxitype , gen(Taxitype)
mkmat weight , matrix(taxi) rownames(Taxitype)
putexcel set "Result/project.xls", sheet("Desc") modify
putexcel N1 = "percent of all transactions by van or taxi" ,  font( bold , 14, blue)
putexcel N2 = matrix(taxi) , rownames border(all) 
asdoc wmat, matrix(taxi) save(Result/Descriptive.doc) rnames(Van Taxi) title(All transactions by van or taxi) cnames(Percent) label append
use `temp', clear


//step6: Calculate percent of all transactions by week's days
collapse (percent) weight , by(dofw)
save "Result/bydays.dta" , replace
decode dofw , gen(Dofw)
mkmat weight , matrix(days) rownames(Dofw)
putexcel set "Result/project.xls", sheet("Desc") modify
putexcel T1 = "percent of all transactions by week's days" ,  font( bold , 14, blue)
putexcel T2 = matrix(days) , rownames border(all) 
asdoc wmat, matrix(days) save(Result/Descriptive.doc) rnames(Sunday Monday Tuesday Wednesday Thursday Friday Saturday) title(all transactions by week's days) cnames(Percent) label append
use `temp', clear


//step7: Calculate percent of all transactions by districts
collapse (percent) weight , by(district)
save "Result/bydistrict.dta", replace
mkmat district weight , matrix(dist)
putexcel set "Result/project.xls", sheet("Desc") modify
putexcel Z1 = "percent of all transactions by districts" ,  font( bold , 14, blue)
putexcel Z2 = matrix(dist) ,  border(all)
mkmat weight , matrix(dis)
asdoc wmat, matrix(dis) save(Result/Descriptive.doc) title(All transactions by districts) append cnames(Percent) rnames(11 12 13 14 15 16 17 22 23 25 26 33 34 35 36 37 44 55 56 66 77 78)
use `temp', clear

//step8: Draw bar-chart of all transaction by regions of beginning location & destination of trips  
graph bar, over(district) nofill title(all transaction by regions of first & second locations of trips)
graph export "Result/barchart-byregions.png", replace
putexcel set "Result/project.xls", sheet("Desc") modify
putexcel A89 = "bar-chart of all transaction by regions of beginning location & destination of trips" ,  font( bold , 15, blue)
putexcel A91 = picture("Result/barchart-byregions.png")

//step9: Draw bar-chart of all transactions by taxitype(van or taxi)
graph bar, over(taxitype) title(Bar chart of all transactions by taxitype)
graph export "Result/barchart-bytaxitype.png" , replace
putexcel set "Result/project.xls", sheet("Desc") modify
putexcel A10 = "bar-chart of all transactions by taxitype(van or taxi)" ,  font( bold , 15, blue)
putexcel A12 = picture("Result/barchart-bytaxitype.png")


//step10: Draw bar-chart of all transactions by week's days
graph bar, over(dofw) title(Bar chart of all transactions by week's days)
graph export "Result/barchart-bydays.png", replace
putexcel set "Result/project.xls", sheet("Desc") modify
putexcel A50 = "bar-chart of all transactions by week's days" ,  font( bold , 15, blue)
putexcel A52 = picture("Result/barchart-bydays.png")


//step11: Draw histogram of all transactions by date
histogram numdate [fweight = weight], bin(137) kdensity xlabel(#20, angle(forty_five) format(%td)) title(Histogram of all transactions by date)  xtitle("") // saving("Result/barchart-bydate.png", replace asis)
putexcel set "Result/project.xls", sheet("Desc") modify
putexcel A136 = "histogram of all transactions by date" ,  font( bold , 18, blue)
putexcel A138 = picture("Result/histogram-bydate.png")


