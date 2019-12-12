echo off
pushd .

set MTDEVOPSBASEDIR=C:\dev\mtdevopsX

c:

IF NOT EXIST %MTDEVOPSBASEDIR% (
    echo "Repo %MTDEVOPSBASEDIR% not found, cloning mtdevops"
    cd \dev
    echo "git clone -b develop https://github.com/MetraTech/mtdevops.git %MTDEVOPSBASEDIR%"
    git clone -b develop https://github.com/MetraTech/mtdevops.git %MTDEVOPSBASEDIR%
    IF !ERRORLEVEL! NEQ 0 (
        echo "ERROR git clone call failed."
		popd
        exit /B 1
    )
	echo "cloned new mtdevops repo"
	exit /B 0
)

echo "Repo mtdevops found, checkout, pull, run git clean and reset ..."
cd %MTDEVOPSBASEDIR%
echo "git clean -df -xf"
git clean -df -xf
IF !ERRORLEVEL! NEQ 0 (
	echo "ERROR git clean call failed. Bad return code %ERRORLEVEL%"
	popd
	exit /B 1
)
echo "git reset --hard"
git reset --hard
IF !ERRORLEVEL! NEQ 0 (
	echo "ERROR git reset call failed. Bad return code %ERRORLEVEL%"
	popd
	exit /B 1
)
echo "git checkout develop"
git checkout develop 
IF !ERRORLEVEL! NEQ 0 (
	echo "ERROR git checkout call failed. Bad return code %ERRORLEVEL%"
	popd
	exit /B 1
)
echo "git pull origin develop"
git pull origin develop
IF !ERRORLEVEL! NEQ 0 (
	echo "ERROR git pull call failed. Bad return code %ERRORLEVEL%"
	popd
	exit /B 1
)


popd

exit /B 0