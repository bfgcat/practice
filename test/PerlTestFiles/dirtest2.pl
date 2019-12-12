#!/usr/bin/perl -w
use strict;
#use File::DirList;
use Cwd;

# create a list of all *.xml files in
# the current directory
opendir(DIR, ".");
my @files = grep(/\.xml$/,readdir(DIR));
closedir(DIR);

# print all the filenames in our array
foreach my $file (@files) {
   print "$file\n";
}

print "\n\n---------------------------\n\n";

print"PWD: ", getcwd(), "\n";

# exec ('"dir /b /a /s"');
# exec ('"which dir"');

# my $result = `find . -type f -print`;
my $result = `dir /b /a:-d /s`;

print "$result";
