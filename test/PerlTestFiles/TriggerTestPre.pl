#!/c/Perl64/bin/perl

use strict;
use IO::File;

# first arg should be a number/changelist
unless ($ARGV[0] =~ /^\d+$/ )
{
    die "First arg not a number/changelist.\nError: $!\n";
    exit 1;
}

my $changelist = $ARGV[0];

# Files
my $outfile = '/var/log/PerforceTrigger.log';
# my $outfile = 'PerforceTrigger.log';

# open temporary output file
my $fhout = IO::File->new(">>$outfile");
defined $fhout || die "Unable to open file for writing: $outfile\nError: $!\n";

$fhout->print("Pre-submit: $changelist\n");

$fhout->close() || die "Error closing file $outfile\nError: $!\n";

exit 0;
