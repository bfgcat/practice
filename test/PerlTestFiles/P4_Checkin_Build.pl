#
# P4_Checkin_Build.pl : script to checkin a build environment to the miami delivery folder in P4. 
#
# Usage: P4_Checkin_Build.pl [-p=<port>] [-u=<user>] [-c=<client>] [-configPath=<configPath>]
#                            [-logPath=<logPath>] [-buildPath=<buildPath>] [-P4buildPath=<P4buildPath>]
#                            [-version=<version>] [-clientList=<file>] [-woc=<true|false>]
#
# Required:
#   [-c=<client>]                    = perforce client.
#   [-logPath=<logPath>]             = path to the log file directory.  
#   [-buildPath=<buildPath>]         = physical path to the build deployment location.  
#   [-P4buildPath=<P4buildPath>]     = perforce path to the build deployment location.  
#   [-version=<version>]             = version of the build x.x.x.  
#
# Optional:
#   [-p=<port>]                      = perforce port (default is "source.netdevil.com:1666").
#   [-u=<user>]                      = perforce user (default is "g12DenPu").  
#   [-configPath=<configPath>]       = path of the config file to save the changelist number to.   
#                                      if this is omitted, then the changelist number will not be saved. 
#   [-createClientList=<true|false>] = whether or not to automatically create the client list.
#                                      if set to false, then the client list file must exist at:
#                                      $logPath\\P4log_ClientList.txt
#                                      default is true.   
#   [-woc=<true|false>]              = writeable on client.  default is false                
#
# Last modified:
# $Id:$
# $Author:$
# $DateTime:$
#

use File::Spec;
use Getopt::Long;

my $p4port = "source-colorado.corp.lego.com:1666";
my $p4user = "g12DenPu";
my $p4client;
my $configPath;
my $logPath;
my $buildPath;
my $P4buildPath;
my $woc = "false";
my $version;
my $CLnumber;
my $createClientList = "true";
my @p4confirmation;


&Main();

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
sub Main
{
    &ProcessCommandLine();
    &CheckinBuild();
    &SaveChangelistNumber();
    &SaveP4Submission();
}

# -----------------------------------------------------------------------------
# SUBROUTINES
# -----------------------------------------------------------------------------
sub DisplayUsage()
{
    # display the comments at the top of this script.
    if (open(ME, "$0")) {
        my $headerFound = 0;
        while (<ME>) 
        {
            my $line = $_;
            if ($line =~ m/^\#/) 
            {
                $headerFound = 1;
                print $line;
            } 
            elsif ($headerFound) 
            {
                last;
            }
        }
        close ME;
    }
}

# -----------------------------------------------------------------------------
sub ProcessCommandLine()
{
    GetOptions(
    "-p=s"                 => \$p4port,
    "-u=s"                 => \$p4user,
    "-c=s"                 => \$p4client, 
    "-configPath=s"        => \$configPath,
    "-logPath=s"           => \$logPath, 
    "-buildPath=s"         => \$buildPath, 
    "-P4buildPath=s"       => \$P4buildPath,
    "-version=s"           => \$version,
    "-createClientList=s"  => \$createClientList,
    "-woc=s"               => \$woc); 
    
    if ( !($p4client && $logPath && $buildPath && $P4buildPath && $version) )
    {
        DisplayUsage();
        exit(1);
    }
    
    if ($woc eq "false")
    {
        $woc = "";
    }
    else
    {
        $woc = "-t +w";
    }
}

# -----------------------------------------------------------------------------
sub CheckinBuild()
{
        print("\n");
        
        # force the perforce server to think that this client is up to date
        print ("\np4.exe -u $p4user -p $p4port -c $p4client sync -k > $logPath\\P4log_SyncList.txt\n");
        system  ("p4.exe -u $p4user -p $p4port -c $p4client sync -k > $logPath\\P4log_SyncList.txt");
        
        if ($createClientList eq "true")
        {
            # find the complete list of files on the client that need to be checked in
            print ("\nDIR $buildPath /s /b /a:-d > $logPath\\P4log_ClientList.txt\n");
            system  ("DIR $buildPath /s /b /a:-d > $logPath\\P4log_ClientList.txt");
        }
 
        # find the files on the server that are no longer on the client.  these will be deleted from the server.
        print ("\np4.exe -u $p4user -p $p4port -c $p4client diff -sd $P4buildPath > $logPath\\P4log_DeleteList.txt\n");
        system  ("p4.exe -u $p4user -p $p4port -c $p4client diff -sd $P4buildPath > $logPath\\P4log_DeleteList.txt");

        # open for add all the new files from the client
        print ("\np4.exe -u $p4user -p $p4port -c $p4client -x $logPath\\P4log_ClientList.txt add $woc > $logPath\\P4log_AddFiles.txt\n");
        system  ("p4.exe -u $p4user -p $p4port -c $p4client -x $logPath\\P4log_ClientList.txt add $woc > $logPath\\P4log_AddFiles.txt");
        
        # open for delete all the files that are no longer on the client
        print ("\np4.exe -u $p4user -p $p4port -c $p4client -x $logPath\\P4log_DeleteList.txt delete > $logPath\\P4log_DeleteFiles.txt\n");
        system  ("p4.exe -u $p4user -p $p4port -c $p4client -x $logPath\\P4log_DeleteList.txt delete > $logPath\\P4log_DeleteFiles.txt");
        
        # open for edit all the existing files from the client
        print ("\np4.exe -u $p4user -p $p4port -c $p4client -x $logPath\\P4log_ClientList.txt edit $woc > $logPath\\P4log_EditFiles.txt\n");
        system  ("p4.exe -u $p4user -p $p4port -c $p4client -x $logPath\\P4log_ClientList.txt edit $woc > $logPath\\P4log_EditFiles.txt");

        # revert any unchanged files
        print ("\np4.exe -u $p4user -p $p4port -c $p4client revert -a -c default > $logPath\\P4log_RevertFiles.txt\n");
        system  ("p4.exe -u $p4user -p $p4port -c $p4client revert -a -c default > $logPath\\P4log_RevertFiles.txt");
        
        # submit all the files in the default changelist
        print ("\np4.exe -u $p4user -p $p4port -c $p4client submit -d \"\[Internal Notes/Technical Impact\]Build $version submission\n\[External Release Notes\] na\n\[Test Criteria\] na\n\[Rally ID\] na\n\[TestTrack ID\] \n\[Reviewer\] na\"\n");
        @p4confirmation = `p4.exe -u $p4user -p $p4port -c $p4client submit -d "\[Internal Notes/Technical Impact\]Build $version submission\n\[External Release Notes\] na\n\[Test Criteria\] na\n\[Rally ID\] na\n\[TestTrack ID\] \n\[Reviewer\] na"`;
        
        # get the submitted changelist number
        if ($p4confirmation[-1] =~ m|Change (\d+) submitted|)
        {
            $CLnumber = $1;
        }
        elsif ($p4confirmation[-1] =~ m|Change \d+ renamed change (\d+) and submitted|)
        {
            $CLnumber = $1;
        }
}

# -----------------------------------------------------------------------------
sub SaveChangelistNumber()
{
        if ($configPath)
        {
            my $perlScriptPath = &rel2abs("$configPath\\..\\..\\..\\perl_scripts");
          
            print ("\nperl $perlScriptPath\\UpdateProjectEnvVars.pl -f=$configPath -env=MiamiDeployChangeList -val=$CLnumber\n");
            system  ("perl $perlScriptPath\\UpdateProjectEnvVars.pl -f=$configPath -env=MiamiDeployChangeList -val=$CLnumber");
        }
}

# -----------------------------------------------------------------------------
sub SaveP4Submission()
{
        unshift (@p4confirmation, "$CLnumber\n\n");
        open OUTPUT, ">$logPath\\P4log_Submission.txt" or die $!;
        print OUTPUT @p4confirmation;
        close OUTPUT;
}

# -----------------------------------------------------------------------------
sub rel2abs() #( filename or path )
{
    my ($filename ) = @_;
    $filename = File::Spec->rel2abs( $filename );
    $filename =~ s|\\|/|g;
    
    # remove '..' in paths  
    # /sub/sub1/../ -> /sub/
    # /root/sub/sub1/../../ -> /root/
    while( $filename =~ s|/[\w ]*/\.\./|/|g )
    {
    }
    $filename =~ s|/|\\|g;
    $filename;
}
