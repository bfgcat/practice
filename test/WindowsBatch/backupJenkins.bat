:: Backup and zip the Jenkins folder under C:\Program Files(x86)
:: then copy to network share: \\qavmserv1.metratech.com\DevOps\Jenkins
::
:: Create a date-time stamp string
@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
SET DELIMITER=-

SET DATESTRING=%date:~-4,4%%DELIMITER%%date:~-7,2%%DELIMITER%%date:~-10,2%
SET TIMESTRING=%TIME%
::TRIM OFF the LAST 3 characters of TIMESTRING, which is the decimal point and hundredths of a second
set TIMESTRING=%TIMESTRING:~0,-3%

:: Replace colons from TIMESTRING with DELIMITER
SET TIMESTRING=%TIMESTRING::=!DELIMITER!%

:: if there is a preceeding space substitute with a zero
:: echo %DATESTRING%_%TIMESTRING: =0%
set DATETIME=%DATESTRING%_%TIMESTRING: =0%
:: echo %DATETIME%

set PF86="\Program Files (x86)"
set JZIPDEST=\\qavmserv1.metratech.com\qafileserver\DevOps\Jenkins

pushd c:\temp

echo 7z a -r -bd -y %PF86%\Jenkins-%DATETIME% Jenkins
7z a -r -bd -y %PF86%\Jenkins-%DATETIME% Jenkins
robocopy . %JZIPDEST% Jenkins-%DATETIME%

rm -f Jenkins-%DATETIME%

popd
