clear
set more off
ssc install egenmore

* global raw "/nfs/home/E/edodge/Desktop/shared_space/epoddata/Attendance/raw"
* global processed "/nfs/home/E/edodge/Desktop/shared_space/epoddata/Attendance/processed"
* global analysis "/nfs/home/E/edodge/Desktop/shared_space/epoddata/Attendance/analysis"

global raw "/Users/Eric/Desktop/Data/Attendance/raw"
global processed "/Users/Eric/Desktop/Data/Attendance/processed"
global analysis "/Users/Eric/Desktop/Data/Attendance/analysis"

////// get stats on positions

use "$processed/items_23Oct2014.dta", clear
drop if name==""
sort personid date
keep if active

keep personid name position unit location organization
duplicates drop
duplicates report personid

replace position = proper(position)
replace position = "Assistant Computer Programmer" if position=="Asst. Programmer"
replace position = "Chain Man" if position=="Chainman"
replace position = "Cleaner" if position=="Cleanar"
replace position = "Design Coordinator" if position=="Design Co-Ordinator"
replace position = "Finance & Accounts Officer" if position=="Financial & Account Officer"

keep position organization unit
sort unit organization position
contract unit organization position, freq(count)
sort unit organization position
outsheet using "$analysis/positions.csv", comma replace