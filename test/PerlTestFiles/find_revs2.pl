#!/usr/bin/perl -w

############################
# NOT ready for prime time #
############################

use strict;
use warnings;

BEGIN {
    use FindBin qw( $Bin );
    use lib "$Bin";
}

use lib::P4::P4Mod;
use RMT::Logger qw( get_logger );


sub main {
    my ($port,$path) = @_;
    my $logger = get_logger();
    
    $logger -> info('Starting ...');
    
    my $count = 0;
    
    foreach my $file (P4Mod::Files($port, $path))
    {
        my ($limit) = $file->{type} =~ m/\w\+S(\d+)/;
        if ($file->{rev} && $limit && $limit < $file->{rev}) {
            my $trim = $file->{rev} - ($limit + 1);
            $count++;
            # before doing obliterate, we should check if rev $trim exists, else we are calling oblit on nothing.
            print "p4 -p $port obliterate -y $file->{depotFile}#1,#$trim\n";
            print `p4 -p $port obliterate -y $file->{depotFile}#1,#$trim`;
        }
    }
    print "\nRevs purged: $count\n";
}

exit main(@ARGV);
