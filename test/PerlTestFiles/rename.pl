#!/usr/bin/perl -w
use strict;


use File::Find;#
use Cwd qw(getcwd abs_path);

sub main {
    
    my @dir = (getcwd());
    finddepth(\&process_file, $_) for @dir;
    
    return 0;
}

sub process_file {
    
    my $dir = getcwd();    
    my $clean_name=lc($_);
    if (-e $clean_name) {
        print "Found: $dir/$clean_name\n";
        if ( (stat($clean_name))[9] < (stat($_))[9] ) {
            #unlink $clean_name;
            print "Deleting: $clean_name\n";
        }
    }
    
    #rename($_,$clean_name) unless($_ eq $clean_name);
    print "Renaming: $dir/$clean_name\n" unless($_ eq $clean_name);
}

exit main();