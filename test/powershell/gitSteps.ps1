# find mtdevops repo and pull latest or clone new repo
pushd .
$MTDEVOPSBASEDIR="C:\dev\mtdevopsX"

"MTDEVOPSBASEDIR $MTDEVOPSBASEDIR"


if (Test-Path $MTDEVOPSBASEDIR -PathType Container)
{
    "Repo mtdevops found, checkout, pull, run git clean and reset ..."
    cd $MTDEVOPSBASEDIR

	"git clean -df -xf"
	git clean -df -xf
	
	"git reset --hard"
	git reset --hard
	
	"git checkout develop"
	git checkout develop
	
	"git pull origin develop"
	git pull origin develop

}
else
{

	"git clone -b developX https://github.com/MetraTech/mtdevops.git $MTDEVOPSBASEDIR"
	git clone -b developX https://github.com/MetraTech/mtdevops.git $MTDEVOPSBASEDIR
	
	"Error: $LASTEXITCODE"

}

popd
