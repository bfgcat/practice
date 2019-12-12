#!/usr/bin/perl -w
use strict;

# create a list of all *.xml files in
# the current directory
opendir(DIR, ".");
my @files = grep(/\.xml$/,readdir(DIR));
closedir(DIR);

# print all the filenames in our array
foreach my $file (@files) {
   print "$file\n";
}