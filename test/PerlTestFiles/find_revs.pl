#!/usr/bin/perl -w

# find_revs.pl - Examines all files in the supplied path and if the number of revs to be stored
#                is less than the current rev number it purges and extra revs starting at rev 1
#                up to the limit needed to be compliant.
#
#                While Perforce normally takes care of this by the type setting of the file,
#                if the limit is changed in the database, as was done for the qa and dev branches
#                of hendrix, Perforce does not go back and clean up revs in excess of the limit.
#
# Usage: find_revs.pl port perforce_path/...
#
# Example: find_revs.pl perforce-hendrix:1666 //hendrix/hendrix_qa/...
#

use strict;
use warnings;

BEGIN {
    use FindBin qw( $Bin );
    use lib "$Bin";
}

use lib::P4::P4Mod;

sub main {
    my ($port,$path) = @_;
    
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
