#!/usr/bin/perl -w
use strict;

open(FILE, '<', $ARGV[0]);
my @lines=<FILE>;
close(FILE);

for(my $i=0; $i<=$#lines; $i++) {
    $/ = "\r\n";
    chomp $lines[$i];
    $lines[$i]=~s/\n//;
    my $tmp = reverse($lines[$i]);
    chop($tmp);
    $tmp = reverse($tmp);
    if ($lines[$i] =~ /\w*$/) {
        $lines[$i] = "\"".$lines[$i]."\" \"//oblit-client".$tmp."\"\n";
    } else {
        $lines[$i] .= " //oblit-client".$tmp."\r\n";
    }
}

open(FILE, '>', $ARGV[0]);
print FILE @lines;
close(FILE);