
# susotime

**susotime** is a Stata package by *Sergiy Radyakin* (*sradyakin@worldbank.org*) for working with date and time variables/formats in conjunction with Survey Solutions.

## Requires
`Stata 14.0` or newer is required. This has been developed and tested with `Survey Solutions 21.09.3`. (other versions may use other formats or conventions).

## Description of subcommands

### susotime

Core command for date and time manipulation. All commands listed below should follow `susotime` in the command line.


### offsetvalue
Convert offset value from a string to a numeric constant.

**Input:**
- string value in the format: `"hh:mm:ss"`, where hours can be positive or negative, for example, `"-03:00:00"`

**Output:**
- returns the number of milliseconds equivalent to the specified offset in the saved value.

**Example:**
```
r(offset)=-10800000
```


### offsetdata
This is a version of the offset conversion to a numeric constant, which processes data in memory.

**Input:**
- string variable representing time offset, expected format: `"hh:mm:ss"`, where hours can be positive or negative, for example: `"-03:00:00"`.

**Output:**
- numeric variable representing the corresponding offset in milliseconds.



### ts2dt
Convert timestamp as recorded in Survey Solutions paradata files into two Stata variables formatted as date and time.

**Input**:
- single variable name containing timestamps as produced by Survey Solutions in the paradata files.
- two new variable names for date and time components in options *datevar()* and *timevar()*.

Expects input values in the format: `YYYY-MM-DDThh:mm:ss.sss` for example: `2021-11-22T23:59.59`

**Output**:
- creates new variables containing date and time components of a timestamp in the user-specified new variables.

### utctolocal
Convert UTC time and time zone offset to local time.

**Input**:
- utctime(varname) - variable containing the UTC time of an event in the format `YYYY-MM-DDThh:mm:ss.sss`, for example: `2021-11-22T23:59.59.123`
- tzoffset(varname) - variable containing string representation of the offset relative to UTC in the format: `"hh:mm:ss"`, where hours can be positive or negative, for example: `"-03:00:00"`.

**Output**:
- generate(string) - variable in the Stata datetime format representing the local time of event.


### timestampz
Combines two separate string values representing date and time into a single string timestamp value used in Survey Solutions, for example in restricting the time frame for the export of data to certain time bounds.

**Input**:
- date(string) - string representing a date, assumed format is `YYYY-MM-DD`
- time(string) - optional string representing time, assumed format is `hh:mm:ss` or `hh:mm:ss.sss`, and `"00:00:00.000"` is used if the value of time is not specified.

**Output**:
- returns the string representation of the timestamp in the saved result, for example:

```
r(timestampz): "2021-11-10T15:07:04.000Z"
```

### timestampznow
Obtain the current timestamp in the format suitable for the Survey Solutions API.

**Input**:
- no inputs required.

**Output**:
- current timestamp is saved to `r(tsznow)`, for example:

```
   r(tsznow) : "2021-11-10T15:07:04.000Z"
```

Note that since Stata does not report the current milliseconds, the milliseconds part of the returned timestamp will always be zero.
