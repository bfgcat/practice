#!/usr/bin/perl -w

use strict;
use Cwd;
use IO::File;


print "\n";

# Test if filename provided on command line
#     if not error out, show syntax

print "\@ARGV: @ARGV +\n";

#my $argc = @ARGV;
my $argc = scalar @ARGV;
print "arg count: $argc\n\n";

for ( my $i = 0; $i < $argc; $i++ )
{
        my $argx = $ARGV[$i];
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

my $fh = new IO::File;
my $filename = $ARGV[0];

if ( !$fh->open("< $filename"))
{
        print "Error: $!\n";
        my $mycwd = getcwd;
        print "Error opening file: $filename\nIn directory: $mycwd\n\n";
        exit (1);
}

# open (MYFILE, $filename) || die "Could not open file: $filename\n";

# print "\nPrint first 10 lines of file:\n";

# print <$fh>;
# for ( my $i = 0; $i < 10; $i++ )
while (<$fh>)
{
	readline;
	print $_;
}

$fh->close;
# close(MYFILE) || die "Could not close file: $filename\n";


exit (0);
