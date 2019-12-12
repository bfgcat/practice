# if 1 arg, ie variable provided as arg, is set and is a number return 0, else return 1
#
use strict;
use warnings;

# get the number of arguments. Is there a better way to do this?
my $argc = @ARGV;

my $argc2 = scalar  @ARGV;

if ( $argc < 1 )
{
    # print "no args\n";
    exit 1;
}

# is the arg an integer number?
unless ($ARGV[0] =~ /^\d+$/ )
{
    print "Is not a number\n";
    exit 1;
}

print "ARG1: $ARGV[0]\n";
