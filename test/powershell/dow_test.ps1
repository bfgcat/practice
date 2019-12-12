"====================================================================="
"Test if it's the right night of the week to run Set1 Servers"
"====================================================================="
$BUILDSTRING=Get-Content BUILDSTRING.env

$dow=(Get-Date).DayOfWeek
$BUILDSBASE="$env:DEPLOYBUILDHOME\$env:PRODUCTNAME\$env:PRODUCTVERSION"

$file = get-content $env:CCNETBASEDIR\TeamSettings.xml | where-object {$_ -like '*Set1Servers=*'}
$arr=$file.split('"')
$Set1Servers=$arr[1].split(",")

$file = get-content $env:CCNETBASEDIR\TeamSettings.xml | where-object {$_ -like '*Set1DaysOfWeek=*'}
$arr=$file.split('"')
$Set1DaysOfWeek=$arr[1].split(",")

"DEBUG: Set1DaysOfWeek: $Set1DaysOfWeek"
"DEBUG: dow: $dow"

$allow=($Set1DaysOfWeek -contains $dow)

if ($allow -eq $True)
 {
    foreach ($i in $Set1Servers)
     {
      	$a=$i |where-object {$_ -like '*SMOKE*'}
        if ($a.length) 
        {
			"smokeVM: $a"
			"Executing command line: powershell.exe  $env:MTDEVOPSBASEDIR\scripts\VM_Control\VM-Control.ps1 -vmName $a* -Branch $env:BRANCH -BuildNumber $BUILDSTRING -Action RevertAndTest -BuildsBase $BUILDSBASE"
			powershell.exe  $env:MTDEVOPSBASEDIR\scripts\VM_Control\VM-Control.ps1 -vmName $a* -Branch $env:BRANCH -BuildNumber $BUILDSTRING -Action RevertAndTest -BuildsBase $BUILDSBASE
        }
     }
 }