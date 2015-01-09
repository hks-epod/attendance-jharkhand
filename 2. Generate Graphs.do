clear
set more off
ssc install egenmore

* global raw "/nfs/home/E/edodge/Desktop/shared_space/epoddata/Attendance/raw"
* global processed "/nfs/home/E/edodge/Desktop/shared_space/epoddata/Attendance/processed"
* global analysis "/nfs/home/E/edodge/Desktop/shared_space/epoddata/Attendance/analysis"

global raw "/Users/Eric/Desktop/Data/Attendance/raw"
global processed "/Users/Eric/Desktop/Data/Attendance/processed"
global analysis "/Users/Eric/Desktop/Data/Attendance/analysis"

////////////// generate attendance rate graph by unit
use "$processed/items_23Oct2014.dta", clear

drop if name==""
keep if active

// exclude holidays
keep if !holiday

egen absences_on_date = total(status=="A"), by(date unit) missing
egen presences_on_date = total(status=="P"), by(date unit) missing
gen attendance_rate = (presences_on_date/(presences_on_date+absences_on_date))

keep date attendance_rate unit
duplicates drop
duplicates report date unit
sort date
twoway (line attendance_rate date if unit=="Secretariat") ///
(line attendance_rate date if unit=="District") ///
(line attendance_rate date if unit=="Division") ///
(line attendance_rate date if unit=="SubDivision"), legend(label(1 "Secretariat") label(2 "District") label(3 "Division") label(4 "SubDivision"))

///////////// attendance rate graph police vs. everyone else
use "$processed/items_23Oct2014.dta", clear

drop if name==""

sort personid date
keep if active

// exclude holidays
keep if !holiday

gen police = (organization=="Jharkhand Police (SPEB)" | organization=="Jharkhand Police")
replace police = . if missing(organization)

egen absences_on_date = total(status=="A"), by(date police) missing
egen presences_on_date = total(status=="P"), by(date police) missing
gen attendance_rate = (presences_on_date/(presences_on_date+absences_on_date))

keep date attendance_rate police
duplicates drop
duplicates report date police
sort date

line attendance_rate date if police==0 & date>=td(01feb2014), lcolor(gs10) lpattern(dash) || ///
line attendance_rate date if police==1 & date>=td(01feb2014), lcolor("255 107 107") lpattern(solid) legend(label(1 "All others") label(2 "Police")) legend(order(2 1)) scheme(tufte) ytitle("Attendance Rate") xtitle("")

////////////// attendance rate graph police vs. other secretariat
use "$processed/items_23Oct2014.dta", clear

drop if name==""

sort personid date
keep if active

// exclude holidays
keep if !holiday

gen police = (organization=="Jharkhand Police (SPEB)" | organization=="Jharkhand Police")
replace police = . if missing(organization)

keep if unit=="Secretariat"

egen absences_on_date = total(status=="A"), by(date police) missing
egen presences_on_date = total(status=="P"), by(date police) missing
gen attendance_rate = (presences_on_date/(presences_on_date+absences_on_date))

keep date attendance_rate police
duplicates drop
duplicates report date police
sort date

summ attendance_rate if police
gen cutoff_police = `r(mean)' - (2*`r(sd)') if police
summ attendance_rate if !police
gen cutoff_sec = `r(mean)' - (2*`r(sd)') if !police

gen dip = 0
replace dip = 1 if attendance_rate<cutoff_police & police
replace dip = 1 if attendance_rate<cutoff_sec & !police

sort date
egen dip_total = total(dip), by(date) missing
replace attendance_rate = . if dip_total==2

line attendance_rate date if police==0 & date>=td(01feb2014), lcolor(gs10) lpattern(dash) legend(label(1 "Other secretariat") on) scheme(tufte) ytitle("Attendance Rate") xtitle("") ylabel(0(.2)1)
graph export "$analysis/attendance_sec.ps", replace logo(off) fontface(Helvetica) 

line attendance_rate date if police==0 & date>=td(01feb2014), lcolor(gs10) lpattern(dash) || ///
line attendance_rate date if police==1 & date>=td(01feb2014), lcolor("255 107 107") lpattern(solid) legend(label(1 "Other secretariat") label(2 "Police")) legend(order(2 1)) scheme(tufte) ytitle("Attendance Rate") xtitle("")
graph export "$analysis/attendance_police_sec.ps", replace logo(off) fontface(Helvetica) 

////////////// generate attendance rate histogram by individual
use "$processed/items_23Oct2014.dta", clear
drop if name==""

sort personid date
keep if active

// exclude holidays
keep if !holiday

egen absences = total(status=="A"), by(personid) missing
egen presences = total(status=="P"), by(personid) missing
gen attendance_rate = (presences/(presences+absences))

keep personid attendance_rate unit
duplicates drop
duplicates report personid

/*
histogram attendance_rate if unit=="Secretariat", name(attendance_hist_sec, replace) title("Secretariat") nodraw
histogram attendance_rate if unit=="District", name(attendance_hist_dist, replace) title("District") nodraw
histogram attendance_rate if unit=="Division", name(attendance_hist_div, replace) title("Division") nodraw
histogram attendance_rate if unit=="SubDivision", name(attendance_hist_subdiv, replace) title("SubDivision") nodraw
graph combine attendance_hist_sec attendance_hist_dist attendance_hist_div attendance_hist_subdiv, ycommon
*/

summarize attendance_rate if unit=="Secretariat", d
histogram attendance_rate if unit=="Secretariat", name(attendance_hist_sec, replace) title("Secretariat") nodraw xtitle("Attendance Rate") fysize(70) percent fcolor("78 205 196") addplot(pci 0 `r(p50)' 15 `r(p50)') legend(off) scheme(tufte)
summarize attendance_rate if unit=="District", d
histogram attendance_rate if unit=="District", name(attendance_hist_dist, replace) title("District") nodraw xtitle("Attendance Rate") fysize(70) percent fcolor("255 115 115") addplot(pci 0 `r(p50)' 15 `r(p50)') legend(off) scheme(tufte)
graph combine attendance_hist_sec attendance_hist_dist, ycommon

//////////// generate absences per worker per month graph by unit
use "$processed/items_23Oct2014.dta", clear
drop if name==""

sort personid date
keep if active

destring month, replace

egen absences_per_month = total(status=="A"), by(personid month) missing
keep personid month absences_per_month unit
duplicates drop personid month, force
drop personid
collapse absences_per_month, by(unit month)
sort month

twoway (line absences_per_month month if unit=="Secretariat") ///
(line absences_per_month month if unit=="District") ///
(line absences_per_month month if unit=="Division") ///
(line absences_per_month month if unit=="SubDivision"), legend(label(1 "Secretariat") label(2 "District") label(3 "Division") label(4 "SubDivision"))

///////// generate active workers by unit graph

use "$processed/items_23Oct2014.dta", clear
drop if name==""

sort personid date
keep if active
keep if !holiday

keep personid date unit

collapse (count) personid, by(unit date)

rename personid active_workers
sort date

twoway (line active_workers date if unit=="Secretariat") ///
(line active_workers date if unit=="District") ///
(line active_workers date if unit=="Division") ///
(line active_workers date if unit=="SubDivision"), legend(label(1 "Secretariat") label(2 "District") label(3 "Division") label(4 "SubDivision"))

///////

bys date: egen avg_in = mean(in_seconds)

///////// generate average duration by unit graph

use "$processed/items_23Oct2014.dta", clear
drop if name==""

sort personid date
keep if active
keep if !holiday

bys unit date: egen avg_duration = mean(duration_seconds)

keep date avg_duration unit
duplicates drop
duplicates report date unit
sort date
replace avg_duration = avg_duration/3600
twoway (line avg_duration date if unit=="Secretariat") ///
(line avg_duration date if unit=="District") ///
(line avg_duration date if unit=="Division") ///
(line avg_duration date if unit=="SubDivision"), legend(label(1 "Secretariat") label(2 "District") label(3 "Division") label(4 "SubDivision"))
