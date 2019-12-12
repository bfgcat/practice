use strict;
use warnings;

use IO::File;

# Get cwd

# try to open p4.cfg in current directory

# Files
my $infile = 'd:\dev\lotro\lotro_dev\p4.cfg';
my $outfile = 'd:\dev\lotro\lotro_dev\p4.cfg.new';

# open file for read
my $fh = IO::File->new("$infile");
defined $fh || die "Unable to open file $infile for reading in current directory\nError: $!\n";

# open temporary output file
my $fhout = IO::File->new(">$outfile");
defined $fhout || die "Unable to open file for writing: $outfile\nError: $!\n";

# Parse through the file, find and replace P4PORT line
while( <$fh> ) 
{
	my $line = $_;
	if ( $line =~ /P4PORT=/)
        {
		print "Found P4PORT:\nChange from: $line\n";
		$line = "P4PORT=perforce-turbine:2666\n";
		print "Change to  : $line\n";
	}

	$fhout->print($line);
}

$fh->close() || die "Error closing file $infile\nError: $!\n";
$fhout->close() || die "Error closing file $outfile\nError: $!\n";

unlink 'd:\dev\lotro\lotro_dev\p4.cfg';
rename 'd:\dev\lotro\lotro_dev\p4.cfg.new', 'd:\dev\lotro\lotro_dev\p4.cfg';
