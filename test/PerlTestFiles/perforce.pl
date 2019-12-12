#!/usr/bin/perl -w -I /Users/bhamilton/Perforce/home/perforce/Lib

use strict;
use warnings;

use P4::P4Mod;
use Getopt::Long qw(:config require_order pass_through);

my %options = ();

sub main
{
    return usage() if (@ARGV < 1 or ! GetOptions(\%options, 'create!','start!','stop!','restart!','verify!','checkpoint!','truncate!','journal!','recover!','optimize','upgrade!','status!'));
    print @ARGV,"\n";
    
    return 0;
}

sub usage
{
    print "Unknown option: @_\n" if ( @_);
    return 1;
}

exit main();