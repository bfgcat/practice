#!/c/Perl64/bin/perl

# This perl: perl -v
# This is perl 5, version 12, subversion 2 (v5.12.2) built for MSWin32-x64-multi-thread (with 8 registered patches, see perl -V for more detail)
#
#Copyright 1987-2010, Larry Wall
#
#Binary build 1202 [293621] provided by ActiveState http://www.ActiveState.com
#Built Sep  6 2010 22:53:42

# Sample file to take lines from a file, count the number of time the word
# 'the' is found in the sentence and the reverse the order of the words
# and print them out.
#
# words may be separated by spaces and/or commas and/or periods.
# periods and commas are removed from the lines
#

use IO::File;

# Files
my $infile = 'sentences.txt';

# open file for read
my $fh = IO::File->new("$infile");
defined $fh || die "Unable to open file for reading: $infile\nError: $!\n";


# continue until end of file
while( <$fh> ) 
{
	my $line = $_;
	# chop off the last character, the EOL character, else split() returns
	# an extra element
	chomp $line;
	print "LINE: $line\n";
	
	# remove line ending periods.
	$line =~ s/\.$//g;
	
	# replace commas and other periods with a space
	$line =~ s/,/ /g;
	$line =~ s/\./ /g;
	
	# replace any instances of multiple spaces with a single space
	$line =~ s/ +/ /g;
	# the above is redundant since 'split' counts multiple spaces as a
	# single separator
	
	# find how many 'the' strings are in the line, ignore case
	# if there is at least one, count them up.
	if ( $line =~ / the /i )
	{
		my $newline = $line;
		my $num_of_the = ( $newline =~ s/ the /foo/gi );
		$num_of_the += ( $newline =~ s/^the /foo/gi ); # count 'the' at
		$num_of_the += ( $newline =~ s/^the$/foo/gi ); # begin and end
		$num_of_the += ( $newline =~ s/ the$/foo/gi ); # of lines too
		print "found string 'the' $num_of_the times\n";
	}
	else
	{
		print "no instances of 'the' found in string.\n";
	}
	
	# split line on spaces and print the words in reverse order
	my @elements = split / /, $line;
	my $numelements = scalar @elements;
	print "numelements: $numelements\n";
	my $revline = "";
	for ( my $i=($numelements-1); $i >= 0; $i--)
	{
		print "i: $i,  $elements[$i]\n";
		$revline = $revline . " $elements[$i]";
	}
	print "REV: $revline\n\n";
}

$fh->close() || die "Error closing file $infile\nError: $!\n";

print "\nEND\n";