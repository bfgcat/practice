@ECHO OFF

echo var CD: %CD%

SET script=%~n0
echo script: %script%

set number=0002
echo number: %number%

set f=-1
set fe=5
set fi=45
set fo=345
set fum=2345

echo f: %f%
echo fe: %fe%
echo fi: %fi%
echo fo: %fo%
echo fum: %fum%

IF /I %f% LEQ 0 (
    echo fe less than or equal 0
) ELSE (
    echo  fe greater than 0
)

echo continue

if %fe% LEQ 9 (
	set zeroes=000
	echo zeroes: %zeroes%
	set fe=%zeroes%%fe%
	echo fe: %fe%
)

