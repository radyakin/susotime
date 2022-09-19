// TESTS

version 14.0

clear all
adopath ++ "../package"

// Just check that it runs and returns non-missing value 
// (since it is time-dependent)
susotime timestampznow
return list
assert r(timestampz)!=""

susotime offsetvalue , offset("-03:00:00")
return list
assert r(offset)==-10800000

susotime offsetvalue , offset("-04:30:00")
return list
assert r(offset)==-16200000

susotime timestampz, date("2020-12-17") time("00:09:42")
return list
assert r(timestampz)=="2020-12-17T00:09:42Z"

input strL event strL offset
"2020-12-17T15:01:59" "00:00:00"
"2020-12-17T15:01:59" "01:00:00"
"2020-12-17T15:01:59" "-01:00:00"
"2020-12-17T15:01:59" "02:00:00"
"2020-12-17T15:01:59" "-02:00:00"
"2020-12-17T15:01:59" "03:30:00"
"2020-12-17T15:01:59" "-03:30:00"
end

susotime ts2dt event, datevar(eventd) timevar(eventt) 

susotime utctolocal, utctime(eventt) tzoffset(offset) generate(loctime)
assert eventd==22266
assert loctime[1]==54119000
assert loctime[2]==57719000
assert loctime[3]==50519000
assert loctime[4]==61319000
assert loctime[5]==46919000
assert loctime[6]==66719000
assert loctime[7]==41519000


clear all
set obs 4
generate double t=.
replace t=clock("2022-07-03 18:53:19", "YMDhms") - clock("1922-06-03 10:58:10.230", "YMDhms") in 1
replace t=clock("2022-07-03 18:53:19", "YMDhms") - clock("2022-06-03 10:58:10.23", "YMDhms") in 2
replace t=clock("2022-07-03 18:53:19.590", "YMDhms") - clock("2022-07-03 10:59:59.177", "YMDhms") in 3
replace t=. in 4

format t %21.0gc
susotime readable_duration t , generate(r)
list

assert r[1]=="36555 07:55:08.770"
assert r[2]=="30 07:55:08.770"
assert r[3]=="0 07:53:20.413"
assert r[4]=="."

display "PASSED!"

// END OF FILE