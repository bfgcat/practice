#!/usr/local/bin/perl

use strict;
use warnings;
use IO::File;
use P4;

# Files
my $outfile = '/perforce/testing/TestP4perlmodule2.log';

# open temporary output file
my $fhout = IO::File->new(">$outfile");
defined $fhout || die "Unable to open file for writing: $outfile\nError: $!\n";

my $P4USER = 'WBIE\bgillespie';
my $P4PORT = 'perforce-turbine:9666';

$fhout->print("Trying to connect to p4port $P4PORT as user $P4USER\n");

my $p4 = new P4;
$p4->SetPort ( $P4PORT );
$p4->Connect() or die( "Failed to connect to Perforce Server" );

for my $user ($p4->Run("users"))
{
    print "$user->{ 'User' }\n";
}

$p4->Disconnect();


$fhout->close() || die "Error closing file $outfile\nError: $!\n";

exit 0;
