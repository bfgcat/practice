#!/c/Perl64/bin/perl

use IO::File;

# Files
my $outfile = '/var/log/PerforceTrigger.log';
my $outfile = 'PerforceTrigger.log';

# open temporary output file
my $fhout = IO::File->new(">$outfile");
defined $fhout || die "Unable to open file for writing: $outfile\nError: $!\n";

$fhout->print("Pre-submit: $changelist");

$fhout->close() || die "Error closing file $outfile\nError: $!\n";

exit 0;
