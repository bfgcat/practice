#!/usr/bin/perl -w
use strict;

# cleanSharedBuildsFolder.pl
#
# Script to set up testdir for testing cleanSharedBuildFolders.pl
#
# Brian F. Gillespie - MetraTech/Ericsson - 3 March 2015
#
# Outline
#
# Removes C:\PerlTestFiles\testdir
# Copies C:\PerlTestFiles\source_testdir C:\PerlTestFiles\testdir
#

# external references
use File::Copy::Recursive qw/dircopy/;
use File::Path qw/rmtree/;

# global values/variables

# for testing
my $testdir = "C:\\PerlTestFiles\\testdir";
my $sourcedir = "C:\\PerlTestFiles\\source_testdir";

# -------------------- #
main ();

sub main
{
    my $success = 0;
    my $count = 0;
    # seems rmtree needs to be run multiple time do do everything right so I am going to have it repeat 5 times to make sure
    while ( !$success &&  $count < 5 )
    {
        unless(rmtree ($testdir,1,1))
        {
            my $error = $!;
            if ( $error eq "No such file or directory" )
            {
                # acceptable reason for failure
                $success = 1;
            }
            else
            {            
                # If dir already deleted that's OK. If failed due to permissions issue, die
                print "Failed to delete directory: $error\n";
                $count++;
            }
        }
        else
        {
            print "rmtree run successful\n";
            $success = 1;
        }
    }
    
    unless (dircopy ($sourcedir, $testdir))
    {
        print "Failed to copy directory $sourcedir to $testdir: $!\n";
    }
    
    print "\nEnd\n";
    
}
