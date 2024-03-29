# paramtest1.ps1 build_number
#
# Script takes a parameter: build number and pads it to 4 digits
#


# get buildNum parameter, should be a 4 digit string with leading zeroes as needed
PARAM
(
    [Parameter(Mandatory=$true)]
    [string]$buildNum
)

$numString = $buildNum

echo "buildNum: $numString"