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
if ( $argc < 1 ) { return "ERROR"; };

my $myEnv = $ARGV[0];


my $myValue = $ENV{$myEnv};

unless ( defined $myValue && $myValue )
{
    print("Unable to resolve ENV setting for:" . $myEnv . "\n");
}
else
{
    print "Value of environment variable: " . $myEnv . " = (" . $myValue . ")\n";
}

    



#if (! $ENV{$myEnv} )
#{
#    return "ERROR";
#}
#else
#{
#    return "$ENV{$myEnv}";
#}
