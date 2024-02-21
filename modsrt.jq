# srtmod - modifies the timestamp ranges in an SRT file, and also ensures
# that the timestamp records are numbered correctly.

# Must be invoked with these options:
# --raw-input      read the data in raw format, i.e. don't expect JSON
# --raw-output     emit the output in raw format, i.e. don't try to emit JSON
# --slurp          (with --raw-input) consumes the entire input as a single string

# The value with which to modify the timestamp ranges must be a positive or negative
# numeric value (e.g. 10, or -5) supplied via the --arg option, like this:
# --arg secs 10
# For values that are more than a minute, just supply the total number of seconds.
# For example, to add 5 minutes and 10 seconds, use:
# --arg secs 310
# or to subtract 3 minutes and 2 seconds, use:
# --arg secs -182


# Modifies an HH:MM:SS timestamp by a number of seconds ($s) which
# can be positive or negative. It does this by computing the absolute
# number of Unix epoch seconds before introducing the $s modifier,
# then reformatting the new seconds value into an HH:MM:SS construct.
def modseconds($s):
    "1970-01-01T\(.)Z"
    | fromdate + $s
    | strftime("%H:%M:%S")
;

# "Fixes" a time which comes in like this:
# HH:MM:SS,SSS 
# We ignore the subsecond SSS value and send the HH:MM:SS part of the
# value to be modified.
def fixtime($s):
    split(",")
    | first |= modseconds($s)
    | join(",")
;

# "Fixes" a timestamp range, which comes in like this:
# HH:MM:SS,SSS --> HH:MM:SS,SSS
# Each of the two HH:MM:SS values is sent for fixing.
def fixrange($s):
    split(" --> ")
    | map(fixtime($s))
    | join(" --> ")
;

# Make sure the given number of seconds (via the `secs` argument given
# with the --arg option) is a numeric value (positive or negative)
($secs | tonumber) as $s

# Split into individual 3-line SRT records
| split("\n\n")

# Remove any non-records that come from blank lines at the of file
| map(select(test("^\\s*$";"")|not))

# Split each SRT record into the 3 individual lines (values)
| map(split("\n"))

# Adjust the timestamp range by $s seconds
| map(.[1]|=fixrange($s))

# Adjust the record numbers so that they start from 1
| to_entries | map([.key + 1] + .value[1:])

# Glue everything back together
| map(join("\n"))
| join("\n\n")
