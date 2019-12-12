#!/usr/bin/perl -w
use strict;

my @subdirs = qw/patch patch_internal launcher_patch launcher_patch_internal/;
foreach (@subdirs)
{
    print $_ . "\n";
}