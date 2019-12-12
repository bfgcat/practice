#!/usr/bin/perl
#
# Written using perl v5.10.0 built for cygwin-thread-multi-64int
#
# filename: myparseXMLfile.pl
# date: 29 Sep 2010
# Author: Brian F. Gillespie
#
# Syntax: myparseFile.pl filename
#
# Purpose: Parse XML file based on description below
#
# from PerlQuestion1.txt:
# 1) Using a Perl script parse the file SettingsTEST.xml and identify each
# section that has the variable nozip="1".   Then output the directory
# structure as shown in the example below.

# Example XML
#   <Component name="game_client" nozip="1">
#     <directory name="config\">
#       <file>ProjectVersion</file>
#     </directory>
#     <directory name="data\">
#       <file>client_foo_*.dat</file>
#       <file>client_foo1_*.dat</file>
#       <file>client_foo2.dat</file>
#       <file installerFlags="recursesubdirs createallsubdirs">browser\*</file>
#     </directory>
#   </Component>
# 
# # Example Output
# 
# {root of output directory}
#    ----- game_client
# 	---- config
#         ---- data
#    ----- {next Component}
#         ---- {next Component dir}

use strict; 

use Cwd;
use IO::File;


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

# my $filename = "SettingsTEST.xml";
my $fh = new IO::File;

my $filename = @ARGV[0];

if ( !$fh->open("< $filename"))
{
        print "Error: $!\n";
        my $mycwd = getcwd;
        print "Error opening file: $filename\nIn directory: $mycwd\n\n";
        exit (1);
}


print <$fh>;
$fh->close;
exit (0);
