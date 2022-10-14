	/*--------------------------------------------------------------------------
			Master file for Calculating Price Elasticity of Taxi Fare's Demand Project
			
			Author: Mehdi SH.Zeinodin & S.Mohsen Alavi
			Date :  1398.10.14
	--------------------------------------------------------------------------*/
clear all
cd "/Users/htm/Desktop/اقتصاد/سنجی/project"


//Cleaning
use "Data/TomanRawData.dta", clear
do "Code/Cleaning.do"


//Descriptive
use "Result/cleaned.dta", clear
do "Code/Descriptive.do"


//Regression
use "Result/cleaned.dta", clear
do "Code/Regression.do"
