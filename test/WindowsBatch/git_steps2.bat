echo off
pushd .

set MTDEVOPSBASEDIR=C:\dev\mtdevopsX

c:

IF EXIST %MTDEVOPSBASEDIR% (
	echo "found repo: %MTDEVOPSBASEDIR% "
	exit /B 0
)

echo "Repo %MTDEVOPSBASEDIR% not found, cloning mtdevops"
cd \dev
echo "git clone -b develop https://github.com/MetraTech/mtdevops.git %MTDEVOPSBASEDIR%"
git clone -b develop https://github.com/MetraTech/mtdevops.git %MTDEVOPSBASEDIR%
echo ERRORLEVEL: %ERRORLEVEL%
IF %ERRORLEVEL% NEQ 0 (
	echo "ERROR git clone call failed."
	popd
	exit /B 1
)
echo "cloned new mtdevops repo"
popd

exit /B 0