#!/usr/bin/perl -w

use strict;
use warnings;
use Switch;

use constant LINUX => "linux";
use constant MACOSX => "darwin";
use constant WINDOWS => "MSWin32";
 
while ((my $key, my$value) = each (%ENV))
{
    print "$key=$value\n";
}

my $OpSys = $^O;


print "\n";
print "$OpSys\n";
print "\n";

# OS values: linux, MSWin32, darwin

switch ($OpSys)
{
    case [LINUX]
    {
        print "Linux OS\n"
    }
    case [MACOSX]
    {
        print "Mac OS X\n"
    }
    case [WINDOWS]
    {
        print "Windows OS\n"
    }
    print "UNKNOWN OS - $OpSys\n";
}