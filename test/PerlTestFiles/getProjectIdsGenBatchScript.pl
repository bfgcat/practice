# Read in project_list.txt and spit out project_id_list.txt which is just
# a list of id numbers from the beginning of each line in project_list.txt.

use strict;
use Class::Struct;


sub Main
{
  my $inFile = "project_list.txt";
  my $outFile = "exportBFprojects.bat";
   
  open IN_FILE, "$inFile" or die "couldn't open [$inFile]\n";
  open OUT_FILE, ">$outFile" or die "couldn't open [$outFile]\n";
  
  while( <IN_FILE> )
  {    
    my $line = $_;
    
    # get the number at the beginning of the line
    if ( $line =~ /(\d*):/ )
    {      
      my $id = $1;
      print "$id\n";
      print OUT_FILE "bfexport -f export_$id.xml $id\n";
    }
    else
    {
      print "ERROR: project ID number not found on line: $line\n";
    }
  }
  
  close IN_FILE;
  close OUT_FILE;
  
  print "\nDone\n";
}

Main( @ARGV );