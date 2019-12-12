# This step is a hack. For some unknown reason, the file:
# MetraNetDev\RMP\config\SqlCore\Queries\ProductCatalog\__SAVE_CHAR_VALS_FOR_SUB__.SqlServer.sql
# is not getting properly copied to where it should be after a successful "git pull" for various mvp/<name> branches.
#
# Therefor the reason for this step.

$BRANCHSHORT="mvp_develop"
$env:BASEDIR="c:\dev\MetraNetDev"

$wonkyFile=$env:BASEDIR + "\" + "RMP\config\SqlCore\Queries\ProductCatalog\__SAVE_CHAR_VALS_FOR_SUB__.SqlServer.sql"
"wonkyFile: $wonkyFile"

# test if we are on a branch that starts with "mvp"
if ($BRANCHSHORT -match '^mvp')
{
    "$BRANCHSHORT contains mvp"
	# test if file found in repo where it should be
	if (!(Test-Path $wonkyFile))
	{
		"file not found"	
	}
	else
	{
		"file found"
	}
}