#!/usr/bin/perl -w
use strict;

sub main {
    my ($port) = @_;
    
    open(CMD, "p4 -p $port labels |");
    my @labels = <CMD>;
    close(CMD);
    
    my @names = map{m/Label\s(.*)\s\d+.*/} @labels;
    
    print @names,"\n";
}

exit main(@ARGV);