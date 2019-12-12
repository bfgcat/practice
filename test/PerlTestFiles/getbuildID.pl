#!/usr/bin/perl -w
use strict;
use warnings;

use File::Spec;
use XML::Simple;

# Usage getbuildID.pl ChangeListNumber
#
# Script takes in a changelist number and returns a build ID tag that
# includes the 
#
my $changelist = $ARGV[0];

# is the passed in value a number?
if (not $changelist =~ /^\d+$/ ) {
    die "Argument not a number\n";
} 

# Convert changelist number into 2 parts xxxx.yyyy, lead fill with zeroes
my $CL2 = "0000";
my $CLlen = length $changelist;
if ( $CLlen > 4 ) { $CLlen = 4 };
substr ( $CL2, -$CLlen ) = substr $changelist, -$CLlen;

my $CL1 = "0000";
my $CLx = substr $changelist, 0, -4;
my $len = length $CLx;
if ($len <= 4 && $len >= 1) { substr ($CL1, -$len) = $CLx; }
if ($len > 4) { die ("Changelist over 99999999, failure.\n")};

my $majorVersion = '12';
my $minorVersion = '34';
my $pointVersion = '56';
my $branchPrefix = '8';

print qq{$minorVersion$pointVersion.$CL1.$CL2.$branchPrefix};
