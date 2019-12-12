#!/c/Perl64/bin/perl

use strict;

#
# PerlTest01.pl - Perl scripting test file. This file, as it stands, includes
# syntax and functional errors. 
#
# Associated file: PerlTest01.txt
#
# 1. Fix all perl syntax errors
# 2. Fix functional errors so the script performs as described
# 3. Suggest improvements
# 4. Code improvements
# ### Code changes should be commented
# ### Hope they comment on how blank lines are treated ( Not sure anyone will notice )
# ### 7 syntactical or functional errors in code.

# This script take lines from a file, PerlTest01.txt, counts the number of time the word
# 'the' is found in each sentence and then reverses the order of the words in each sentence
# and prints out each sentence.
#
# Words in a sentence may be separated by spaces and/or commas and/or periods.
# All periods and commas are removed from each sentence.
#

use IO::File;

# Files
my $infile = 'PerlTest01.txt';    ### <- variable not qualified with 'my'

# open file for read
my $fh = IO::File->new("$infile");
defined $fh || die "Unable to open file for reading: $infile\nError: $!\n";


# continue until end of file
while( <$fh> ) 
{
	my $line = $_;   ### <- variable not qualified with 'my'
	# chop off the last character, the EOL character, else split() returns
	# an extra element
	chomp $line;
	print "LINE: $line\n";
	
	# remove line ending periods.
	$line =~ s/\.$//g;
	
	# replace commas and other periods with a space
	$line =~ s/,/ /g;
	$line =~ s/\./ /g;    ### <- period not replaced with a space
	
	# replace any instances of multiple spaces with a single space
	$line =~ s/ +/ /g;    ### <- missing ; at EOL
	# the above is redundant since 'split' counts multiple spaces as a
	# single separator
	
	# find how many 'the' strings are in the line, ignore case
	# if there is at least one, count them up.
	if ( $line =~ /the/i )   ### <- add 'i' to ignore case
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
	for ( my $i=($numelements-1); $i >= 0; $i--)  ### <- variable should be decremented, not incremented
	{
		print "i: $i,  $elements[$i]\n";
		$revline = $revline . " $elements[$i]";
	}
	print "REV: $revline\n\n";
}

$fh->close() || die "Error closing file $infile\nError: $!\n";  ### <- missing quotes around string

print "\nEND\n";
