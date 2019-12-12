# if 1 arg, ie variable provided as arg, is set and is a number return 0, else return 1
#
use strict;
use warnings;

use File::Copy;

# get the number of arguments. Expecting 2.
my $argc = @ARGV;
if ( $argc != 2 ) { die "Expected 2 arguments, got $argc, exiting.\n"; };

my $source = $ARGV[0];
my $dest = $ARGV[1];

# test if source file exists
if (! -e $source) { die "Source file: $source not found. Exiting\n";}

# move it. die with error reason if fails
unless (move ($source, $dest)) { die "Error: $!\n"};

print "SUCCESS: move $source TO $dest\n\n";

