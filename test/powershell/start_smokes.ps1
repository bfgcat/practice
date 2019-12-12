# Start smoketest block for MVP_1_0_0_SMOKETEST (Powershell)

"====================================================================="

# variable SMOKEVM passed in
# if we were passed in a smoketest VM name instead of "ALL" then just put that smoketest VM on list
# else get list of SMOKE VMs from database who's day of week field matches today's day of week.
# put VM names in file SMOKE_VM_LIST.txt

if ($env:SMOKEVM -ne "ALL")
{
    $SmokeServers = $env:SMOKEVM
    # test if given SmokeVM is valid for this branch
    # get list of all smoke VMs for branch
    $CMD = "$env:RUBYEXE $env:WORKSPACE\mtdevops\jenkins\dashboardDB\GetSmokeList.rb -f $env:WORKSPACE\mtdevops\Jenkins\DashboardDB\dashboardDB_config.xml -b $env:BRANCH"
    "CMD: $CMD"
    $arr = Invoke-Expression $CMD
    if ($arr -eq "")
    {
        "$env:BRANCH does not have any smoke machines."
        exit 1
    }
    $TestServers = $arr.split(",")
    if (!( $TestServers -Match $env:SMOKEVM))
    {
        "$env:SMOKEVM does not match any smoke machines for Branch $env:BRANCH"
        exit 1
    }
}
else
{
    $dow=(Get-Date).DayOfWeek
    $dow2=[Int] (Get-Date).DayOfWeek

    $CMD = "$env:RUBYEXE $env:WORKSPACE\mtdevops\jenkins\dashboardDB\GetSmokeList.rb -f $env:WORKSPACE\mtdevops\Jenkins\DashboardDB\dashboardDB_config.xml -b $env:BRANCH -d $dow2"
    "CMD: $CMD"
    $arr = Invoke-Expression $CMD
    if ($arr -eq "")
    {
        "$env:BRANCH does not have any smoke machines for the specified day of the week,exiting."
        exit 1
    }
    $SmokeServers = $arr.split(",")
    ""
}
foreach ($name in $SmokeServers)
{
    "$name"
}




# For each smokeVM in list
#    Get it's last test record
#    If STATUS is STARTED
#        if OVERWRITE is FALSE
#            Report and skip
#        else
#            Update the old record to a STATUS of ABORTED
#            Start Smoketest for that smokeVM
#            If no errors
#                Write new smoketest record with STATUS of STARTED
#            else
#                Write new smoketest record with status ERROR
#            end
#        end
# End for loop
"====================================================================="

$ServerList= Get-Content SmokeServerList.txt
$SmokeServers = $ServerList.split(" ")

$BRANCHPATH = Get-Content $env:WORKSPACE\BRANCHPATH.env
$BUILDSTRING = Get-Content BUILDSTRING.env
$BUILDSBASE = "$env:DEPLOYBUILDHOME\$env:PRODUCTNAME\$env:PRODUCTVERSION"
"BRANCHPATH: $BRANCHPATH "
"BUILDSTRING: $BUILDSTRING "
"BUILDSBASE: $BUILDSBASE "

foreach ($name in $SmokeServers)
{
    # Get status of last build record for this branch and Smoke VM
    $CMD="$env:RUBYEXE $env:WORKSPACE\mtdevops\jenkins\dashboardDB\GetTestRecordStatus.rb -f $env:WORKSPACE\mtdevops\Jenkins\DashboardDB\dashboardDB_config.xml -b $BRANCHPATH -m $name"
    $status = Invoke-Expression $CMD
    if ($status -eq "STARTED")
    {
        if ($env:OVERWRITE -eq "FALSE")
        {
            "SmokeTest running on $name and OVERWRITE option set to FALSE"
            "Not starting new SmokeTest."
            continue
        }
        else
        {
            # Change status of last test record to ABORTED
            $CMD="$env:RUBYEXE $env:WORKSPACE\mtdevops\jenkins\dashboardDB\UpdateSmokeRecordStatus.rb -f $env:WORKSPACE\mtdevops\Jenkins\DashboardDB\dashboardDB_config.xml -b $BRANCHPATH -m $name -r $status -t $env:DBTESTABORTSTATUS "
            "CMD: $CMD"
            Invoke-Expression $CMD
        }
    }
        
    $TESTSTARTTIME = Get-Date -format "yyyy-MM-dd HH:mm:ss"
    "powershell.exe $env:WORKSPACE\mtdevops\scripts\VM_Control\VM-Control.ps1 -vmName $name* -Branch $env:BRANCH -BuildNumber $BUILDSTRING -Action RevertAndTest -BuildsBase $BUILDSBASE"
    powershell.exe $env:WORKSPACE\mtdevops\scripts\VM_Control\VM-Control.ps1 -vmName $name* -Branch $env:BRANCH -BuildNumber $BUILDSTRING -Action RevertAndTest -BuildsBase $BUILDSBASE
    
    if ($? -and  ($lastExitCode -eq 0))
    {
        "Writing STARTED status record for smoketest"

        $CMD="$env:RUBYEXE $env:WORKSPACE\mtdevops\jenkins\dashboardDB\WriteTestRecord.rb -f $env:WORKSPACE\mtdevops\Jenkins\DashboardDB\dashboardDB_config.xml -b $BRANCHPATH -u $BUILDSTRING -s $env:DBTESTINITSTATUS -t " + '"' + $TESTSTARTTIME + '"' + " -m $name -p 0 -a 0"
        "CMD: $CMD"
        Invoke-Expression $CMD
    }
    else
    {
        $TESTSTOPTIME = Get-Date -format "yyyy-MM-dd HH:mm:ss"
        $CMD="$env:RUBYEXE $env:WORKSPACE\mtdevops\jenkins\dashboardDB\WriteTestRecord.rb -f $env:WORKSPACE\mtdevops\Jenkins\DashboardDB\dashboardDB_config.xml -b $BRANCHPATH -u $BUILDSTRING -s ERROR -t " + '"' + $TESTSTARTTIME + '"' + " -e " + '"' + $TESTSTOPTIME + '"' + " -m $name -p 0 -a 0"
        "CMD: $CMD"
        Invoke-Expression $CMD
    }
}















