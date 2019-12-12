# if 1 arg, ie variable provided as arg is set return 0, else return 1
#

use strict;
use warnings;

my $argc = @ARGV;

if ( $argc < 1 )
{
    print "no args\n";
    exit 1;
}

my $arg = $ARGV[0];

# is the arg a number?
if ($arg =~ /^\d+$/ )
{
    print "Is a number\n";
} else {
    print "Is not a number\n";
    exit 1;
}

print "ARG1: $ARGV[0]\n";

