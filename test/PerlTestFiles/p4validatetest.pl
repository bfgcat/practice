#!/usr/local/bin/perl
#--------------------------------------------------------------------------------------
# Script to validate that the wcgens are not broken on submit.
#
# The script runs as a change-content trigger.
#
#--------------------------------------------------------------------------------------

use strict;
use warnings;

use IO::File;

use FindBin qw($Bin);
use lib "$Bin";
use Data::Dump qw(dump);

use lib::P4::P4Trigger;
use lib::P4::P4Mod;
use Error qw(:try);


#--------------------------------------------------------------------------------------------------
# main
#--------------------------------------------------------------------------------------------------
sub main(@) {
    my ($args) = @_;
    my $params = ['serverport', 'changelist', 'changeroot'];

    # Files
    my $outfile = '/var/log/PerforceTrigger.log';
    #my $outfile = 'PerforceTrigger.log';

    # open output file
    my $fhout = IO::File->new(">>$outfile");
    defined $fhout || die "Unable to open file for writing: $outfile\nError: $!\n";

    try {
        # Our Perforce Trigger helper class.
        # An IndexError will be raised if the incorrect number of arguments are provided
        my %trigger = new P4Trigger(P4TriggerHelper::createParams($params, $args));

        my $changelistnumber = $trigger{args}{changelist};
        my $server = $trigger{args}{serverport};
        my $changeroot = $trigger{args}{changeroot};

        # DEBUG
        $fhout->print("Pre-submit trigger p4validatewcgen:Server: $server\tCL: $changelistnumber\troot:$changeroot\n");
        #print("Pre-submit trigger p4validatewcgen:Server: $server\tCL: $changelistnumber\troot:$changeroot\n");

        # Get the change description
        my %change = P4Mod::Changes($server,$changelistnumber);

        $fhout->print("Pre-submit XXX $server\tCL: $changelistnumber\n");
        #print("Pre-submit XXX $server\tCL: $changelistnumber\n");
        $fhout->print("Pre-submit YYY $change{depotFile}[0]\n");
        #print("Pre-submit YYY $change{depotFile}[0]\n");
        $fhout->print("Pre-submit ZZZ @{$change{depotFile}}\n");
        #print("Pre-submit ZZZ @{$change{depotFile}}\n");

        # Validate all filenames
        for( my $i=0; $i<@{$change{depotFile}}; $i++)
        {
            my $teststring = P4::Print( $change{depotFile}[$i] . "@=" . $changelistnumber);
            $fhout->print("Pre-submit trigger p4validatewcgen: test string: $teststring\n");

            # If the file contains a broken *.wcgen file.
            if ( P4::Print( $change{depotFile}[$i] . "@=" . $changelistnumber ) =~ m/\# User \[[^\]]*\] on machine \[[^\]]*\] did not pay attention to the WCGen errors and checked in this bad .wcgen file!/ )
            {
                $fhout->print("Pre-submit trigger p4validatewcgen: throw error\n");
                throw Error::Simple($change{depotFile}[$i]." is a broken wcgen file!.");
            }
            else
            {
                    $fhout->print("Pre-submit trigger p4validatewcgen: no problem with file.\n");
            }

        }
        $fhout->print("Pre-submit YYY YYY YYY $server\tCL: $changelistnumber\n");


    } catch IndexError with {
        my $ex = shift;

        print "args:".dump($args)."\n\n$ex->{-stacktrace}";
        return 4321;
    } catch Error::Simple with {
        my $ex = shift;

        print "$ex->{-text}";
        return 1234;
    };

    $fhout->close() || die "Error closing file $outfile\nError: $!\n";

    return 0;
}

#--------------------------------------------------------------------------------------------------
# Main body
#--------------------------------------------------------------------------------------------------
exit main(\@ARGV);

