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


display "PASSED!"

// END OF FILE