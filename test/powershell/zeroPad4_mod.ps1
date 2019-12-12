# zeroPad4.ps1 build_number
#
# Script takes a parameter: build number and returns a 4 digit string prefixed with zeros to a max of 4 chars.
#

# get buildNum parameter and convert to a zero prefixed 4 digit string
PARAM
(
    [string]$innum = "xx"
)

# Functions
function isNum
{
    param ($tnum)
    if( -NOT ($tnum -match "^[0-9]+$"))
    {
		"not a number"
        return $false
    }
    else
    {
        return $true
    }
}

if ( $innum -eq "xx" )
{
    return "zeroPad4.ps1 requires a number argument, error"
}

[int]$num = $nul
$num = $innum
    
# test if a number
if (-not(isnum $num))
{
    return "$num is NOT a number, error"
}
   
if ( $num -lt 10 )
{
    $numstring = "000" + $num
}
elseif ($num -lt 100)
{
    $numstring = "00" + $num
}
elseif ($num -lt 1000)
{
    $numstring = "0" + $num
}
else
{
    $numstring = $num
}

return $numstring