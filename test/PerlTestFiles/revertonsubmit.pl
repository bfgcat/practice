#!/usr/bin/perl -w
use strict;
use warnings;

use lib::P4::P4Mod;

sub main(@) {
    my ($port) = @_;
    
    foreach my $client (P4Mod::Clients($port)) {
        print "Looking at: $client->{client}\n";
        my $spec = P4Mod::FetchSpec($port,'client',$client->{client});
        $spec =~ s/SubmitOptions:\tsubmitunchanged/SubmitOptions:\trevertunchanged/;
        P4Mod::StoreSpec($port,'client',$spec) if ($spec ne P4Mod::FetchSpec($port,'client',$client->{client}));
    }
    
    return 0;
}

exit main(@ARGV);