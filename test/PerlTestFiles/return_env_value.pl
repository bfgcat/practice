# When given an environment variable name, get and return it's value
#
# input : environment variable name
#
# output: returns value of input name or string ERROR
#
use strict;
use warnings;

# get the number of arguments
my $argc = @ARGV;
if ( $argc < 1 ) { print "ERROR"; exit 0; };

my $myEnv = $ARGV[0];
my $myValue;
if (! $ENV{$myEnv} )
{
    print "ERROR";
    exit 0;
}
else
{
    $myValue = "$ENV{$myEnv}";
}

print "$myValue";

