#!/c/Perl64/bin/perl

# remove blank lines from file

use IO::File;

# Files
my $infile = 'infile.txt';

# open file for read
my $fh = IO::File->new("$infile");
defined $fh || die "Unable to open file for reading: $infile\nError: $!\n";


# continue until end of file
while( <$fh> ) 
{
	my $line = $_;
	# chop off the last character, the EOL character, else split() returns
	# an extra element
	# chomp $line;
	#print "LINE: $line\n";
	

	if (! $line == /^\s+$/ )
	{
		print "$line";
	}
	#else
	#{
	#	print "<BLANK>\n";
	#}
}

$fh->close() || die "Error closing file $infile\nError: $!\n";

print "\nEND\n";