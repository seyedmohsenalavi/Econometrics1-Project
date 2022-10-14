    /*-------------------------------Cleaning---------------------------------*/
	/*
			Master.do
				|
				|___ Cleaning.do
			
			Steps for Data Cleaning:				
				step  1  |  Change time to date
			    step  2  |  Merge with data on region of routes & air pollution data
				step  3  |  Give an ID to each route
				step  4  |  Delete fake transactions
				step  5  |  Recode taxitype to numbers for easier comparison- Van=0 and Taxi=1
				step  6  |  Clean data-fix abnormal payments
				step  7  |  Delete routes that are lopsided towards before or after price change
				step  8  |  Delete routes that are out of regions 1-8
				step  9  |  Label variables
			
	--------------------------------------------------------------------------*/

//some calculations
unique firstloc secondloc
	
//Step1:Change time to date
tostring transtime, gen (stime) format (%tc) force
gen sdate=substr(stime,1,9)
gen double numdate= date(sdate,"DMY")
	
	
//Step2:Merge with data on region of routes & air pollution data
merge m:1 firstloc secondloc using "Data/RegionRoutes.dta" ,nogen
merge m:1 sdate using "Data/AirReport.dta" ,nogen
replace unhlthy=0 if unhlthy==.


//Step3:Give an ID to each route
egen routeid=group(firstloc secondloc taxitype)


//Step4:Delete fake transactions
drop if fare<1000 //under 1000 tomans


//Step5:Recode taxitype to numbers for easier comparison- Van=0 and Taxi=1
egen taxtype=group(taxitype)
drop if taxtype==1  //Delete private vehicles
recode taxtype (3=0) (2=1)
destring taxitype, replace force
replace taxitype=taxtype
drop taxtype


//Step6:Clean data-fix abnormal payments
gen apchng=(numdate>td(28apr2019))
egen modefare=mode(fare) ,by(routeid apchng)
drop if modefare==. //Has multiple modes-bad data
keep if (fare==modefare | fare==modefare*2 | fare==modefare*3 | fare==modefare*4) | ((fare==modefare | fare==modefare*2 | ///
fare==modefare*3 | fare==modefare*4 | fare==modefare*5 | fare==modefare*6 | fare==modefare*7 | fare==modefare*8| fare==modefare*9| fare==modefare*10| fare==modefare*11) & taxitype==1)
gen weight=.
replace weight=fare/modefare
replace fare=modefare
drop modefare


//Step7:Delete routes that are lopsided towards before or after price change
egen skew=mean(apchng) , by(routeid)
drop if skew<0.2
drop if skew>0.8
gen i=1
egen rtotal=sum(i) , by (routeid)
drop if rtotal<10
egen total=sum(i)
gen perc=rtotal/total
drop i total rtotal

//Step8:Delete routes that are out of regions 1-8
drop if district==.

//Step9:Label variables
label var firstloc	"beginning location of trip"
label var secondloc	"destination location of trip"
label var sdate	    "date of trip"
label var weight	"number of people travel together in one trip"
label var fare	    "trip's price"
label var unhlthy	"the day of trip is air-polluted"
label var district  "regions of beginning and destination locations of trip"

save "Result/cleaned.dta", replace
