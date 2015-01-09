clear
set more off
ssc install egenmore

* global raw "/nfs/home/E/edodge/Desktop/shared_space/epoddata/Attendance/raw"
* global processed "/nfs/home/E/edodge/Desktop/shared_space/epoddata/Attendance/processed"
* global analysis "/nfs/home/E/edodge/Desktop/shared_space/epoddata/Attendance/analysis"

global raw "/Users/Eric/Desktop/Data/Attendance/raw"
global processed "/Users/Eric/Desktop/Data/Attendance/processed"
global analysis "/Users/Eric/Desktop/Data/Attendance/analysis"

insheet using "$raw/items_23Oct2014.csv", comma names

// duplicates report
duplicates drop

replace duration="" if substr(duration,1,1)=="-"

label variable name "Name"
label variable position "Position"
label variable unit "Unit"
label variable location "Location"
label variable sublocation "Sublocation"
label variable organization "Organization"
label variable month "Month"
label variable year "Year"
label variable sno "S.no"
label variable date "Date"
label variable status "Status"
label variable in_time "In Time"
label variable out_time "Out Time"
label variable in_time_short_fall "In Time_Short Fall"
label variable out_time_short_fall "Out Time_Short Fall"
label variable short_fall "Short Fall"
label variable duration "Duration"
label variable over_time "Over Time"
label variable total_short_fall "Total Short Fall"
label variable url "URL"

tostring month year, replace

split date, generate(date)
rename date2 day
drop date date1 date3 date4
gen datestring = month+"/"+day+"/"+year
gen date = date(datestring,"MDY")
format date %td
label variable date "Date"
drop day datestring

gen hour = substr(in_time,1,2)
gen minute = substr(in_time,4,2)
gen second = substr(in_time,7,2)
destring hour minute second, replace
egen in_seconds =  hms(hour minute second)

drop hour minute second
gen hour = substr(duration,1,2)
gen minute = substr(duration,4,2)
gen second = substr(duration,7,2)
destring hour minute second, replace
egen duration_seconds =  hms(hour minute second)

// generate person id's
sort unit location sublocation org name position date
egen personid = group(unit location sublocation org name position) if !missing(name), missing
summ personid

// find start date for each person
sort personid date
gen active = 0
by personid: replace active = 1 if !missing(in_time) | (active[_n-1]==1 & _n!=1)

// generate holiday variable
egen h_count = total(status=="H"), by(date) missing
gen holiday = (h_count>0 & !missing(h_count))
drop h_count

order name personid position unit location sublocation organization month year sno date status in_time in_seconds out_time in_time_short_fall out_time_short_fall short_fall duration duration_seconds over_time total_short_fall url holiday active
sort personid date

save "$processed/items_23Oct2014.dta", replace
