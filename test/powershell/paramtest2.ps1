# paramtest2.ps1 build_number
#
# Script takes a parameter: build number and gets version information from MetraNetDev\Source\Build\version.xml
# * future: feed filename as parammeter, not hardcoded
#



# get buildNum parameter, should be a 4 digit string with leading zeroes as needed
PARAM
(
    [Parameter(Mandatory=$true)]
    [string]$buildNum
)

function isNum
{
    param ($num)
    if( -NOT ($num -match "^[0-9]+$"))
    {
        return $false
    }
    else
    {
        return $true
    }
}

function zeropad4
{
    param ($num)
    
    # test if a number
    if (-not(isnum -num $num))
    {
        return "$num is NOT a number"
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
}

function zeropad4b
{
    param ($num)
    
    # test if a number
    if (-not(isnum -num $num))
    {
        return "$num is NOT a number"
    }
    
    $numstring = "$num"
    if ($numstring.length -lt 4)
    {
        #DO
        #{
        #    $numstring.padleft(1,"0")
        #} while ($numstring.length -lt 4)
    }

    return $numstring
}

"input string: $buildNum"
[int]$intvar = $nul
$intvar = $buildnum

#$zerostring = (zeropad4 -num $buildnum)
$zerostring = (zeropad4 -num $intvar)
"zero padded string: $zerostring"

""
        
$v5 = 5
$v25 = 25
$v255 = 255
$v4444 = 4444

"$v5     " + (zeropad4 $v5)
"$v25    " + (zeropad4 $v25)
"$v255   " + (zeropad4 $v255)
"$v4444  " + (zeropad4 $v4444)
""
"zeropad2"
$mystring = $buildnum
"length: " + $mystring.length
$newstring = $mystring.padleft(1, "x")
"newstring: $newstring"
"mystring: $mystring"


""
$v5 = 5
$v25 = 25
$v255 = 255
$v4444 = 4444

"call zeropad4b"
"$v5     " + (zeropad4b $v5)
"$v25    " + (zeropad4b $v25)
"$v255   " + (zeropad4b $v255)
"$v4444  " + (zeropad4b $v4444)
""

return

"variable type testing block"
""
$a = 10
$b = "10"

$a.gettype()
$b.gettype()
$buildNum.gettype()
""

$a + 1
3 + $a

$b + 1
3 + $b

