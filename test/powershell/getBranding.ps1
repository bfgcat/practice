# parse contents of $BrandingKeywords

$BrandingKeywords = "c:\dev\MetraNetDev\Source\Install\Branding\keywords.xml"

# parse contents of $BrandingKeywords
[xml]$key = Get-Content "$BrandingKeywords"

# $key.keywords

# create empty hashtable
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

# $keyhashvalue
# "========================="
# $keyhashdefault



