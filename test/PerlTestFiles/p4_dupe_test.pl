# Usage:

use strict;
use warnings;
use File::Find;
use Data::Dumper;
use Getopt::Std;
use Filehandle;
use TBE::Utils;


my $files;
my $dir = CompleteProjectPath("");

#
my $READ_COMMAND = "p4 files $dir...";
die if not open ( COMMAND, "$READ_COMMAND |" );

while (my $line = <COMMAND>)
{
  if ( $line =~ /^(.*)#\d+\s-\s(.*?)\s.*$/ )
  {
    my $file = $1;
    my $change = $2;
    push @{$files->{lc $file}}, $file if $change ne "delete";
  }
}

close COMMAND;


foreach my $file ( sort keys %{$files} )
{
  my @dupes = @{$files->{$file}};

  if ( @dupes > 1 )
  {
    foreach my $dupe ( @dupes )
    {
      print "$dupe\n";
    }
  }
}

print "p4_dupe run completed\n\n";
