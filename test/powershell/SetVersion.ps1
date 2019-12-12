# SetVersion.ps1 build_number
#
# Script takes 3 parameters:
#   build number
#   path to version.xml file
#   baseDir
#
# Using this information it then updates a set of files wth the current version and build information.
#

PARAM
(
    [Parameter(Mandatory=$true)]
    [string]$buildNum,
    [Parameter(Mandatory=$true)]
    [string]$VersionFile,
    [Parameter(Mandatory=$true)]
    [string]$BaseDir
)

# Functions
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
    if (-not(isnum $num))
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


# convert buildnum to 4 digit string, pad with leading zeroes as needed.
# for some reason when we pass $buildNum to the function it fails to pad properly
[int]$intvar = $nul
$intvar = $buildnum
$buildNumString = zeropad4 $intvar
#"buildNumString value $buildNumString"

# test string, if problem in convert return false
if (-not(isnum $buildNumString))
{
    return $false
}

# Global Values
# $BaseDir = "c:\dev\MetraNetDev" --> now a parameter
# $VersionFile = "Source\Build\version.xml" __> now a parameter
$tempdir = "$BaseDir\_tmp"
$TemplateDir = "$BaseDir\Source\Build\Templates\VersionFiles"
$IncludeLocation = "$BaseDir\Source\include"
$FilesLocation = "$BaseDir\Source\Build"

# parse contents of $VersionFile
[xml]$v = Get-Content "$VersionFile"
$vname = $v.version.name
$vmajor = $v.version.major
$vminor = $v.version.minor
$vSP = $v.version.SP
$vrelease = $v.version.release
$vbuildbranch = $v.version.buildbranch
$vstartyear = $v.version.startyear

$timestamp = get-date
$version3part = "$vmajor.$vminor.$vSP"
$version4part = "$vmajor.$vminor.$vSP.$vrelease"

# Other setting derived from above
$assembly_file_version = "$vmajor.$vminor.$vSP.$buildNumString"
$file_version_commas = "$vmajor,$vminor,$vSP,$vrelease"
$base_version_commas = "$vmajor,$vminor,$vSP,$buildNumString"
$product_version = "$base_version_commas"
$company = "MetraTech Corporation, now part of Ericsson"
$product = "MetraNet"
$copyright = "Copyright(c) 2016 MetraTech, now part of Ericsson. All rights reserved."

#echo ""
#echo "Debug Block:"
#echo "timestamp: $timestamp"

#echo "version name: $vname"
#echo "version major: $vmajor"
#echo "version minor: $vminor"
#echo "version SP: $vSP"
#echo "version release: $vrelease"
#echo "version buildbranch: $vbuildbranch"
#echo "version startyear: $vstartyear"
#echo ""
#echo "assembly_version: $assembly_version"
#echo "assembly_file_version: $assembly_file_version"
#echo "file_version_commas: $file_version_commas"
#echo "base_version_commas: $base_version_commas"
#echo "product_version: $product_version"
#echo "company: $company"
#echo "product: $product"
#echo "copyright: $copyright"
#echo ""

# clean up old tempdir if it exists and create new
if (test-path $tempdir)
{
    remove-item $tempdir -recurse -force
}
new-item -itemtype directory -path $tempdir | out-null

#copy template files to be modified
copy-item $TemplateDir\* $tempdir

#Get list of all files in tempdir and Replace tokens of form "@STRING@", in template files with values from VersionFile
$filenames = get-childitem $tempdir | select name
foreach ($file in $filenames)
{
    $myfile = $file.name
    echo File: $myfile
    # get-content $tempdir\$myfile
    (get-content $tempdir\$myfile) |
        foreach-object {$_ -replace '\@VERSION\@',$version3part } |
        foreach-object {$_ -replace '\@MAJOR\@',$vmajor } |
        foreach-object {$_ -replace '\@MINOR\@',$vminor } |
        foreach-object {$_ -replace '\@RELEASE\@',$vrelease } |
        foreach-object {$_ -replace '\@BASE_VERSION\@',$version4part } |
        foreach-object {$_ -replace '\@BASE_VERSION_COMMAS\@',$base_version_commas } |
        foreach-object {$_ -replace '\@FILE_VERSION_COMMAS\@',$file_version_commas } |
        foreach-object {$_ -replace '\@BUILD\@',$buildNumString } |
        foreach-object {$_ -replace '\@COMPANY\@',$company } |
        foreach-object {$_ -replace '\@COPYRIGHT\@',$copyright } |
        foreach-object {$_ -replace '\@FILE_VERSION\@',$assembly_file_version } |
        foreach-object {$_ -replace '\@ASSEMBLY_VERSION\@',$version4part } |
        foreach-object {$_ -replace '\@ASSEMBLY_FILE_VERSION\@',$assembly_file_version } |
        foreach-object {$_ -replace '\@PRODUCT\@',$product } |
        foreach-object {$_ -replace '\@T_STAMP\@',$timestamp } |
        out-file $tempdir\$myfile
    get-content $tempdir\$myfile
    echo ""
    echo ""
}

# 


# Copy template files to where they will be needed by the build
copy-item $tempdir\MTTreeRev.h -Destination $IncludeLocation -force
copy-item $tempdir\AssemblyInfo.cs -Destination $FilesLocation -force
copy-item $tempdir\interopversion.mak -Destination $FilesLocation -force
copy-item $tempdir\VersionInfo.cs -Destination $FilesLocation -force

