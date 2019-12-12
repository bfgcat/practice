# Get the "Project" (aka game) from the "Project Variant" (aka branch)
# 
# example: branch = lotro_v3b35, return lotro
#          branch - dnd_update9, return dnd
#
# Verify game is one of: lotro, dnd, console, engine, hendrix
#
# If not one of above return 'unknown'
#
use strict;
use warnings;

# get the number of arguments. Is there a better way to do this?
my $argc = @ARGV;

if ( $argc < 1 )
{
	# print "no args\n";
	print "unknown\n";
	exit 1;
}

# Create a list of acceptable branches
my @branches = ("lotro", "dnd", "hendrix", "engine", "console");

#
my $mystring =  $ARGV[0];
my $game = "";
# get string up to first _
if ($mystring =~ m/^(.*?)_.*/)
{
	$game = $1;
	# print $game, "\n";
}
else
{
	print "unknown\n";
	exit 1;
}

# is the branch found in the acceptable list of branches
if ( grep {$game eq $_} @branches)
{
	print "$game\n";
}
else
{
	print "unknown\n";
	exit 1;
}

