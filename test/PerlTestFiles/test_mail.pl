# if 1 arg, ie variable provided as arg is set return 0, else return 1
#

use strict;
use warnings;

# Must have at least one argument passed in
my $argc = @ARGV;

if ( $argc != 1 )
{
    print "arg count not equal 1\n";
    exit 1;
}

print "arg count = 1\n";
