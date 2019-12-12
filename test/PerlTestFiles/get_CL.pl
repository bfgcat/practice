# This script is run from a client workspace directory,
# gets the current changelist and prints it to STDOUT.

use strict;
use warnings;
use Getopt::Long;

# get args

my $p4client = '';
my $p4root   = '';
my $p4server = '';

GetOptions
(
    'p4client=s' => \$p4client,
    'p4root=s'   => \$p4root,
    'p4server=s' => \$p4server
);

my $p4args = '';

if ( $p4client )
{
    $p4args .= " -c ${p4client}";
}

if ( $p4root )
{
    $p4args .= " -d ${p4root}";
}

if ( $p4server )
{
    $p4args .= " -p ${p4server}";
}

my $p4command = "p4 ${p4args} changes -m1 ...#have";

# my $p4ChangesString = `p4 ${p4args} changes -m1 ...#have`;

my $p4ChangesString = `${p4command}`;

my ($p4ChangeListNumber) = ( $p4ChangesString =~ /Change (\d+)/ );

if ( $p4ChangeListNumber eq '')
{
    $p4ChangeListNumber = 'Error';
}

print $p4ChangeListNumber;
