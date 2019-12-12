use strict;
use warnings;

use XML::Parser;

use RMT::Utilities qw(
    getOS
);

my $myOS = getOS();

print "getOS:$myOS\n";

