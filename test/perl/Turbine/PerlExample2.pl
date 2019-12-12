#!/c/Perl64/bin/perl

# Using ActivePerl from ActiveState
# > perl -v
# This is perl 5, version 12, subversion 2 (v5.12.2) built for
# MSWin32-x64-multi-thread # (with 8 registered patches, see perl -V
# for more detail)

# Brian Gillespie
# Release Engineering Candidate
# 30 Sep 2010

# Turbine Tech Test From PerlQuestion2.txt
# Using Perl 
# 
# 1) Using a Perl script, parse the file machinelist.txt, identify each
# section that has the IP address *.*.25.*, and change that 25 to a 30.


use IO::File;

# Files
my $infile = 'machinelist.txt';
my $outfile = 'newmachinelist.txt';

# open file for read
my $fh = IO::File->new("$infile");
defined $fh || die "Unable to open file for reading: $infile\nError: $!\n";

# open temporary output file
my $fhout = IO::File->new(">$outfile");
defined $fhout || die "Unable to open file for writing: $outfile\nError: $!\n";

# input file is expected to be in the form
# Machine name,IP,Location,Purpose
# example:
# test-01,250.124.25.1,Westwood,Build

# Parse through the file, find and replace all occurances of 25 in the 3rd
# position of the IP address
while( <$fh> ) 
{
	my $line = $_;
	my @elements = split /\s*,\s*/, $line;
	my $ip = $elements[1];
	if ( $ip =~ /(\d+\.\d+\.)25(\.\d+)/)
        {
		my $prefix = $1;
		my $suffix = $2;
		my $newip = $prefix."30".$suffix;
		print "old ip: $ip\tnew ip: $newip\n";
		$elements[1] = $newip;
	}

	my $new_line = join ',',@elements;
	$fhout->print($new_line);
}

$fh->close() || die "Error closing file $infile\nError: $!\n";
$fhout->close() || die "Error closing file $outfile\nError: $!\n";

unlink 'machinelist.txt';
rename 'newmachinelist.txt', 'machinelist.txt';
