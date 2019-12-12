# test_int_arg.pl
#
# Test if there is at least one argument and if the argument is an integer
# if not return 1 (false)
#
use strict;
use warnings;

# get the number of arguments. Is there a better way to do this?
my $argc = @ARGV;

if ( $argc < 1 )
{
    # print "no args\n";
    exit 1;
}

# is the arg an integer number?
unless ($ARGV[0] =~ /^\d+$/ )
{
    # print "Is not a number\n";
    exit 1;
}

# print "ARG1: $ARGV[0]\n";
