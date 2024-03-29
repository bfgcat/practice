# functest
#
#

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


$v1 = "a"
$v1.getType()
$v2 = 7
$v2.getType()
[int]$v3 = $nul
$v3.getType()

""
isnum -num $v1
isnum -num $v2
""
isnum $v1
isnum $v2

