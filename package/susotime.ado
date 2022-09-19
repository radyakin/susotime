*** Sergiy Radyakin, 2022
*** sradyakin@@worldbank.org

program define susotime
  // Passes the execution to a subcommand of susotime
  version 14.0

  gettoken subcmd 0 : 0

  _susotime_`subcmd' `0'
end

program define _susotime_offsetvalue, rclass
  // Convert offset value from a string to a numeric constant.
  // Example of input value: "-03:00:00"
  // Returns: number of milliseconds equivalent to the specified offset.
  // Example: -10800000
  version 14.0
  
  syntax , offset(string)
  
  local sec=substr(`"`offset'"', -2,2)
  assert inrange(`sec',0,59)
  local min=substr(`"`offset'"', -5,2)
  assert inrange(`min',0,59)
  local hour=substr(`"`offset'"', -8,2)
  assert inrange(`sec',0,23)
  
  local t= cond(strpos(`"`offset'"',"-") > 0,-1,1) * hms(`hour',`min',`sec')
  return scalar offset=`t'
end

program define _susotime_offsetdata
  // Data version of the offset conversion to a numeric constant.
  version 14.0
  
  syntax varname, generate(string)
  
  generate long `generate' = ///    
    cond(strpos(`varlist',"-") > 0,-1,1) * ///
	hms( ///
	  real(substr(`varlist', -8,2)), ///
	  real(substr(`varlist', -5,2)), ///
	  real(substr(`varlist', -2,2)))
  label variable `generate' "Value of offset `varlist' in msec."
end

program define _susotime_ts2dt
  // Convert timestamp as recorded in Survey Solutions paradata 
  // files into two Stata variables formatted as date and time.
  // Example of input values: "2021-11-22T23:59.59"
  version 14.0
  syntax varname, [datevar(string) timevar(string)]
  
  if (`"`datevar'"'=="") local datevar `"`varlist'__d"' 
  if (`"`timevar'"'=="") local timevar `"`varlist'__t"'
  
  confirm new variable `datevar'
  confirm new variable `timevar'
  
  generate long `datevar'=date(substr(`varlist',1,10),"YMD") ///
    if strlen(`varlist')==19
  format `datevar' %td
  label variable `datevar' "Date from: `varlist'"
  
  generate long `timevar'=clock(substr(`varlist',12,8),"hms") ///
    if strlen(`varlist')==19
  format `timevar' %tcHH:MM:SS
  label variable `timevar' "Time from: `varlist'"
end

program define _susotime_utctolocal
  // Convert UTC time and time zone offset to local time.
  version 14.0
  syntax , utctime(varname) tzoffset(varname) generate(string)
  
  tempvar offsetval
  _susotime_offsetdata `tzoffset', generate(`offsetval')
  generate long `generate'=`utctime'+`offsetval'
  format `generate' %tcHH:MM:SS  
end

program define _susotime_timestampz, rclass
  // Combines two separate string values representing date and time into a
  // single string timestamp value used in Survey Solutions, for example in
  // restricting the time frame for the export of data to certain time bounds.
  // Input formats are:
  // assume date as YYYY-MM-DD
  // assume time as hh:mm:ss or hh:mm:ss.sss
  
  version 14.0
  syntax , date(string) [time(string)]
  
  local d=date("`date'","YMD")
  if (missing(`d')) {
    display as error "Invalid date"
	error 117
  }
  local ds = string(`d', "%tdCCYY-NN-DD")

  if missing(`"`time'"') local time="00:00:00.000"
  
  if clockpart(clock(`"`time'"',"hms"),"ms")==0 {
  	// if milliseconds are zero, omit them
  	local ts=string(clock(`"`ds' `time'"',"YMDhms"), ///
	      "%tcCCYY-NN-DD!THH:MM:SS!Z")
  }
  else {
  	// include milliseconds if they are non-zero
    local ts=string(clock(`"`ds' `time'"',"YMDhms"), ///
	      "%tcCCYY-NN-DD!THH:MM:SS.sss!Z")
  }
  
  if (`"`ts'"'==".") {
    display as error "Invalid time"
	error 117
  }

  return local timestampz = `"`ts'"'

end

program define _susotime_timestampznow
  // Obtain the current timestamp in the format suitable for the 
  // Survey Solutions API.
  // No inputs required.
  // Output: current timestamp is saved to r(tsznow), for example:
  //     r(tsznow) : "2021-11-10T15:07:04.000Z"
  // Note that since Stata does not report the current milliseconds, 
  // the milliseconds part of the returned timestamp will always be zero.
  
  version 14.0
  local cdate = c(current_date)
  local ctime = c(current_time)
  local cdate2=c(current_date)
  if ("`cdate'"!="`cdate2'") {
  	// In the unlikely event when the clock has 
	// ticked across the days while capturing the 
	// date and time, we repeat:
  	local ctime=c(current_time)
	local cdate="`cdate2'"
  }
  
  assert strlen(`"`ctime'"')==8 // Avoid any unexpected formatting of time
  
  // Stata reports date with month names: "10 Nov 2021"
  // Here we convert them to the standard numeric format
  local cdate=string(date("`cdate'", "DMY"),"%tdCCYY-NN-DD")
  
  _susotime_timestampz, date(`"`cdate'"') time(`"`ctime'"')
end

program define _susotime_readable_duration
/*
    Generate human-readable duration in format DAYS HH:MM:SS.MS
	
	[short] - all durations are known to be short (no days). 
	          Hence days are not in the output.
	[vshort] - all durations are known to be short (no days or hours). 
	          Hence days and hours are not in the output.
	[ms] - data is measured with milliseconds precision (not in 
	       Survey Solutions paradata, but useful for averages and other stats).
*/

	version 12.0
	syntax varname, generate(string) [short] [vshort] [ms]
	tempvar ddys dhrs dmin dsec msec
	
	generate long `ddys' = int(`varlist'/1000/60/60/24)
	generate byte `dhrs' = int(`varlist'/1000/60/60 - `ddys'*24)
	generate byte `dmin' = int(`varlist'/1000/60 - `ddys'*24*60 - `dhrs'*60)
	generate byte `dsec' = int(`varlist'/1000 - `ddys'*24*60*60 - ///
	                           `dhrs'*60*60 - `dmin'*60)
	generate int  `msec' = mod(`varlist',1000)
	
	if (`"`vshort'"'!="") {
		// VERY SHORT
		generate `generate'= ///
		  string(`dmin', "%02.0f") + ":" + ///
		  string(`dsec', "%02.0f") + ///
		  cond(`"`ms'"'=="","", "." + ///
		  string(`msec', "%03.0f"))
	}
	else {
		if (`"`short'"'=="") {
			// NOT SHORT
			generate `generate'= ///
			  string(`ddys', "%07.0g") + " " + ///
			  string(`dhrs', "%02.0f") + ":" + ///
			  string(`dmin', "%02.0f") + ":" + ///
			  string(`dsec', "%02.0f") + ///
			  cond(`"`msec'"'=="","", "." + string(`msec', "%03.0f"))
		}
		else {
			// SHORT
			generate `generate'= ///
			  string(`dhrs', "%02.0f") + ":" + ///
			  string(`dmin', "%02.0f") + ":" + ///
			  string(`dsec', "%02.0f") + ///
			  cond(`"`msec'"'=="","", "." + string(`msec', "%03.0f"))
		}
	}
	replace `generate' = "." if missing(`varlist')
end


// END OF FILE
