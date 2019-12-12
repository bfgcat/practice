#updatePackage steps:
#
# Arguments:
#        MTPACKAGEDIR:   MetraTech 
#        baseDir:        Base directory that contains MetraNetDev repo. Example C:\dev\MetraNetDev
#        buildNum:       Build number from the build manager (Jenkins) zero padded to 4 digits
#        productVersion: Version in 3 part form, i.e. 8.3.0
#
# Script replicates steps formerly under "updatePackage" section of postbuild.build file,
#        reads the values from the Branding keywords file and updates the corresponding tokens
#        in MetraNet and MetraConnect's InstallShield *.ism files.
#
# get guid script - C:\dev\MetraNetDev\Source\Build\Tools\newGuid.ps1

# Get arguments
PARAM
(
    [Parameter(Mandatory=$true)]
    [string]$MTPACKAGEDIR,
    [Parameter(Mandatory=$true)]
    [string]$BASEDIR,
    [Parameter(Mandatory=$true)]
    [string]$buildNum,
    [Parameter(Mandatory=$true)]
    [string]$productVersion
)

"***********************************************************************"
"                UPDATING INSTALLATION PARAMETERS"
"***********************************************************************"
# is equivalent: $MTPACKAGEDIR = $PackageRootDir
$MTSTAGINGDIR = "$MTPACKAGEDIR\Staging"
$MTINSTALLDIR = "$MTPACKAGEDIR\Install"
$MTISMDIR = "$MTSTAGINGDIR\ISM"

# branding keyword file
$BrandingKeywords = "$MTSTAGINGDIR\Branding\keywords.xml"

# install files and temporary projects
$MetraNetISMFile = "$MTISMDIR\MetraNet.ism"
$MetraConnectISMFile = "$MTISMDIR\MetraConnect.ism"
$MetraNetISMTempFile = "$MTISMDIR\MetraNet_temp.ism"
$MetraConnectISMTempFile = "$MTISMDIR\MetraConnect_temp.ism"
$setISMProperties = "$BASEDIR\QABox\TestsDatabase\Tools\Utilities\setISMProperties.vbs"

# temporary folders
$MetraNetTempDir = "$MTISMDIR\MetraNet_temp"
$MetraConnectTempDir = "$MTISMDIR\MetraConnect_temp"

# cleanup temp files and folders if they exist, recreate temporary folders
"Deleting and recreating temporary files and directories"
if (test-path $MetraConnectISMTempFile)
	{ remove-item $MetraConnectISMTempFile -force }
	
if (test-path $MetraConnectTempDir)
	{ remove-item $MetraConnectTempDir -recurse -force }
New-Item $MetraConnectTempDir -type container -force | out-null
	
if (test-path $MetraNetISMTempFile)
	{ remove-item $MetraNetISMTempFile -force }
	
if (test-path $MetraNetTempDir)
	{ remove-item $MetraNetTempDir -force }
New-Item $MetraNetTempDir -type container -force | out-null

"***********************************************************************"
"                UPDATING METRANET ISM PROJECT"
"***********************************************************************"
""
# read branding values from keywords.xml
# verify file exists
if (-NOT(test-path $BrandingKeywords))
{
    return "Error: file not found - BrandingKeywords: $BrandingKeywords"
}

"Reading values from branding keyword file $BrandingKeywords"
# parse contents of $BrandingKeywords
[xml]$key = Get-Content "$BrandingKeywords"

# create empty hashtables
$keyhashvalue = @{}
$keyhashdefault = @{}

FOREACH ($keyword in $key.keywords.keyword)
{
    $mykeyname = $keyword | select -expand name 
    $mykeyvalue = $keyword | select -expand value
    $mykeydefault = $keyword | select -expand default_value
    # "key-value pair: $mykeyname-$mykeyvalue"
    $keyhashvalue.add("$mykeyname","$mykeyvalue") 
    $keyhashdefault.add("$mykeyname","$mykeydefault")   
}
# debug info
# $keyhashvalue

# load the MetraNet ISM file into the InstallShieldm property
# replace all @<string>@ with <value> for that string
"and replacing tokens, output to: $MetraNetISMTempFile"
(get-content $MetraNetISMFile) |
        foreach-object {$_ -replace '\@MT_BUILD_NUMBER\@',$buildNum } |
        foreach-object {$_ -replace '\@MT_PRODUCT_VERSION\@',$productVersion } |
        foreach-object {$_ -replace '\@MT_PRODUCT_NAME\@',$keyhashvalue.get_item("MT_PRODUCT_NAME") } |
        foreach-object {$_ -replace '\@MT_MPM_APP_NAME\@',$keyhashvalue.get_item("MT_MPM_APP_NAME") } |
        foreach-object {$_ -replace '\@MT_MOM_APP_NAME\@',$keyhashvalue.get_item("MT_MOM_APP_NAME") } |
        foreach-object {$_ -replace '\@MT_MCM_APP_NAME\@',$keyhashvalue.get_item("MT_MCM_APP_NAME") } |
        foreach-object {$_ -replace '\@MT_MAM_APP_NAME\@',$keyhashvalue.get_item("MT_MAM_APP_NAME") } |
        foreach-object {$_ -replace '\@MT_MPS_APP_NAME\@',$keyhashvalue.get_item("MT_MPS_APP_NAME") } |
        foreach-object {$_ -replace '\@MT_PS_APP_NAME\@',$keyhashvalue.get_item("MT_PS_APP_NAME") } |
        out-file $MetraNetISMTempFile

# update ProductVersion installer property
"update ProductVersion field in $MetraNetISMTempFile"
$command = "cscript.exe $setISMProperties $MetraNetISMTempFile ProductVersion $productVersion"
(cmd /c "$command")
""
$ProductCode = [guid]::NewGuid()

# update ProductVersion installer property
"update ProductCode field in $MetraNetISMTempFile"
$command = "cscript.exe $setISMProperties $MetraNetISMTempFile ProductCode $ProductCode"
(cmd /c "$command")
""

"***********************************************************************"
"                UPDATING METRACONNECT ISM PROJECT"
"***********************************************************************"
""
# load the MetraConnect ISM file into the InstallShieldm property
# replace all @<string>@ with <value> for that string
"and replacing tokens, output to: $MetraNetISMTempFile"
(get-content $MetraConnectISMFile) |
        foreach-object {$_ -replace '\@MT_BUILD_NUMBER\@',$buildNum } |
        foreach-object {$_ -replace '\@MT_PRODUCT_VERSION\@',$productVersion } |
        foreach-object {$_ -replace '\@MT_PRODUCT_NAME\@',$keyhashvalue.get_item("MT_PRODUCT_NAME") } |
        foreach-object {$_ -replace '\@MT_MPM_APP_NAME\@',$keyhashvalue.get_item("MT_MPM_APP_NAME") } |
        foreach-object {$_ -replace '\@MT_MOM_APP_NAME\@',$keyhashvalue.get_item("MT_MOM_APP_NAME") } |
        foreach-object {$_ -replace '\@MT_MCM_APP_NAME\@',$keyhashvalue.get_item("MT_MCM_APP_NAME") } |
        foreach-object {$_ -replace '\@MT_MAM_APP_NAME\@',$keyhashvalue.get_item("MT_MAM_APP_NAME") } |
        foreach-object {$_ -replace '\@MT_MPS_APP_NAME\@',$keyhashvalue.get_item("MT_MPS_APP_NAME") } |
        foreach-object {$_ -replace '\@MT_PS_APP_NAME\@',$keyhashvalue.get_item("MT_PS_APP_NAME") } |
        out-file $MetraConnectISMTempFile

# update ProductVersion installer property
"update ProductVersion field in $MetraConnectISMTempFile"
$command = "cscript.exe $setISMProperties $MetraConnectISMTempFile ProductVersion $productVersion"
(cmd /c "$command")
""
$ProductCode = [guid]::NewGuid()

# update ProductVersion installer property
"update ProductCode field in $MetraConnectISMTempFile"
$command = "cscript.exe $setISMProperties $MetraConnectISMTempFile ProductCode $ProductCode"
(cmd /c "$command")
""


