#!/usr/bin/perl

# use strict;
use Cwd;
use IO::File;
use XML::Simple;

print "\n";

# Test if filename provided on command line
#     if not error out, show syntax

print "\@ARGV: @ARGV +\n";

my $argc = @ARGV;
print "arg count: $argc\n\n";

for ( my $i = 0; $i < $argc; $i++ )
{
        my $argx = @ARGV[$i];
        print "arg $i\t$argx\n";
}

print "\n";

if ( $argc < 1 )
{
        print "Filename argument required as first argument.\n";
        print "\nAborting\n";
        exit (1);
}

if ( $argc > 1 )
{
        print "more than 1 argument. Additional arguments ignored.\n\n";
}

#
# Parse the XML file
#

my $filename = @ARGV[0];

my $Component = XMLin("$filename");

print "before loop\n";
foreach my $directory (keys %{$Component->{directory}})
{
	print "in loop\n";
	print "$directory -> $Component->{directory}{$directory}{file}\n";
}
print "after loop\n";


exit (0);
