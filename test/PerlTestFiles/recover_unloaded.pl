#!/usr/bin/perl -w

use strict;
use warnings;

use lib::P4::P4Mod;

our @active;
our @last;
our @deleted;
our @both;

sub main {
    my ($p4port) = @_;
    
    recoverClients($p4port);
    recoverLabels($p4port);
    
    return 0;
}

sub recoverClients {
    my ($p4port) = @_;
    
    my @clients = P4Mod::Clients($p4port,"-U");
    
    foreach my $client (@clients) {
        P4Mod::ReloadClient($p4port, $client -> {client});
    }
}

sub recoverLabels {
    my ($p4port) = @_;
    
    my @labels = P4Mod::Labels($p4port,"-U");
    
    foreach my $label (@labels) {
        P4Mod::ReloadLabel($p4port, $label -> {label});
    }
}

exit main(@ARGV);
