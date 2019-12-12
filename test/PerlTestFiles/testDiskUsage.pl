#!/usr/bin/perl -w
#
# Using ActivePerl from ActiveState
# > perl -v
# This is perl 5, version 20, subversion 1 (v5.20.1) built for MSWin32-x64-multi-thread
# (with 1 registered patch, see perl -V for more detail)
# 

use strict;

# testDiskUsage.pl
#
# Script to test some disk usage tools.
#
# Brian F. Gillespie - MetraTech/Ericsson - 3 April 2015
#
# Updates
#
# Outline
#
# Test if on correct server
# test if shared directory is available and writable
# For each <version>/<branch> directory combination, count the number of non-marked build numbered directories.
#   If there are more than 5 numbered directories delete all but the 5 latest by date.
#   If a numbered directory contains a file named "DO_NOT_DELETE" it should not be deleted nor should it count toward the limit of the 5 latest directories.
#

# external references
#use File::Copy::Recursive qw/dircopy/;
#use File::Path qw/rmtree/;
use Log::Log4perl qw(:easy);
use File::stat;
use Time::localtime;
use Filesys::DfPortable;

# global values/variables

# for testing
my $testdir = "C:\\PerlTestFiles\\testdir";
#my $testdir = "X:\\";

# This is the machine that hosts the build directories, initial plan is to run script from this machine
my $have_error = 0;
my $targetHost = "ENGDC1BLD01";


my $localBuildRootDir = "D:\\Builds\\MetraNet";
my $remoteBuildRootDir = "\\engdc1bld01\\Builds\\MetraNet";

# for testing
#my $localWorkingDir = $testdir;

my $localWorkingDir = "";

# determine $localWorkingDir based on if we are on host server or on a remote machine
my $testhost = uc $targetHost;
my $computerName = uc $ENV{'COMPUTERNAME'};
if ($testhost eq $computerName)
{
    $localWorkingDir = $localBuildRootDir;
}
else
{
    $localWorkingDir = $remoteBuildRootDir;
}

$localWorkingDir = $testdir;
my $logfile = "$localWorkingDir\\cleanSharedBuildFolders.log";


# ---------------------------------------------------------------------------------------------------- #
#
# TO DO: Add More logging with Log4Perl
#            Add debugging level of DEBUG with full details
#            Make default level less verbose
#        Report on disk space useage before and after
#        Format output a bit better
#

Log::Log4perl->easy_init
(
    {
        level   => $DEBUG,
        file    => ">>$logfile"
    }
);

&printanddebug("\n---------------------------------------------------------------\n");
&printanddebug("Start 'testDiskUsage.pl' run on: $ENV{'COMPUTERNAME'}\n\n");


# Run everything
main ();

sub main
{
    ## test if target directory is available and writable
    #unless (chdir ($localWorkingDir))
    #{
    #    &error_exit("Unable to change directory to $localWorkingDir.\t$!\n");
    #}

    my $ref = dfportable("x:\\", (1024 *1024 * 1024)); # Display output in 1K blocks
    if(defined($ref))
    {
        print"Total 1G blocks: "; printf("%.0f\n", $ref->{blocks});
        print"Total 1G blocks free: "; printf("%.0f\n", $ref->{bfree});
        print"Total 1G blocks avail to me: "; printf("%.0f\n", $ref->{bavail});
        print"Total 1G blocks used: "; printf("%.0f\n", $ref->{bused});
        print"Percent full: "; printf("%.0f\n\n", $ref->{per});
    }    

    $ref = dfportable("\\\\engdc1bld01\\builds", (1024 *1024 * 1024)); # Display output in 1K blocks
    if(defined($ref))
    {
        print"Total 1G blocks: "; printf("%.0f\n", $ref->{blocks});
        print"Total 1G blocks free: "; printf("%.0f\n", $ref->{bfree});
        print"Total 1G blocks avail to me: "; printf("%.0f\n", $ref->{bavail});
        print"Total 1G blocks used: "; printf("%.0f\n", $ref->{bused});
        print"Percent full: "; printf("%.0f\n", $ref->{per});
    }    
} 

sub error_exit()
{
    my ($error_msg) = @_;
    printanddebug ($error_msg);
    printanddebug("ERROR EXIT\nFinish testDiskUsage run on: $ENV{'COMPUTERNAME'}");
    exit 1;
}

sub printanddebug ()
{
    my ($line) = @_;
    print $line;
    DEBUG ($line);
}
