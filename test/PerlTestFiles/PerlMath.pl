#!/usr/bin/perl -w
use strict;
use warnings;
#use Scalar::Util::Numeric qw(isint);


my $i;

for ( my $i=20; $i <= 4000; $i = $i+4 )
{
    my $x = $i;
    my $x1 = 5 * $x / 4 + 1;
    my $x2 = 5 * $x1 / 4 + 1;
    my $x3 = 5 * $x2 / 4 + 1;
    my $x4 = 5 * $x3 / 4 + 1;
    my $x5 = 5 * $x4 / 4 + 1;
    print ($x, "\t");
    print ($x1, "\t");
    print ($x2, "\t");
    print ($x3, "\t");
    print ($x4, "\t");
    print ($x5, "\n");
}

