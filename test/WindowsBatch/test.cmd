@echo off
set count=5
setlocal EnableDelayedExpansion
for /L %%i in (1, 1, %count%) do (
     set "formattedValue=000000%%i"
     echo !formattedValue:~-4!
)

echo.

set f=-1
set fe=5
set fi=45
set fo=345
set fum=2345

rem test value and pad accordingly to 4 digits

if %fe% LEQ 9 (
	set fe=000%fe%%
	set fe: !fe:~-4!
)
if %fi% LEQ 99 (
	set fi=00%fi%%
	set fi: !fi:~-4!
)
if %fo% LEQ 999 (
	set fo=0%fo%%
	set fo: !fo:~-4!
)
if %fum% LEQ 999 (
	set fum=000%fum%%
	set fum: !fum:~-4!
)

echo.
echo final values:
set fe
set fi
set fo
set fum

echo.
echo.
echo New block, nested if.
echo.

set myvar=7
REM set myvar=77
REM set myvar=777
REM set myvar=7777

echo myvar before: %myvar%
echo.

rem test value and pad accordingly to 4 digits
if %myvar% LEQ 9 (
	set myvar=000%myvar%%
	set myvar: !myvar:~-4!
) else (
	if %myvar% LEQ 99 (
		set myvar=00%myvar%%
		set myvar: !myvar:~-4!
	) else (
		if %myvar% LEQ 999 (
			set myvar=0%myvar%%
			set myvar: !myvar:~-4!
		)
	)
)



echo.
echo myvar: %myvar%




