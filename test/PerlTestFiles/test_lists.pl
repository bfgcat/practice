#!/usr/bin/perl -w
use strict;

sub main {
    my @filelist = ();
    
    my $filenameX = "foofile.txt";
    my @filenamesX = ( $filenameX );
    
    printlist (@filenamesX);
    
    my @testlist = ('one', 'two', 'three');
    
    printlist (@testlist);
    
    my @newlist = ('four');
    push @testlist, @newlist;
    
    printlist (@testlist);
    
    pop @testlist;
    
    printlist (@testlist);
    
    my @blist =();
    printlist (@blist);
    
    push @blist, @newlist;
    printlist(@blist);
    
    my $filename = "foofile";
    push @blist, $filename;
    printlist (@blist);

    my $five = 'five';
    unshift @blist, $five;
    printlist (@blist);
    
    push @blist, @blist;
    printlist(@blist);
}

sub printlist  {
    my @inlist = @_;
    
    print ("# elements:" . scalar(@inlist) . "\n");
    for (my $i = 0; $i < scalar(@inlist); $i++)
    {
        print ($i . "\t" . $inlist[$i] . "\n");
    }
    
    print ("\n");
}

main ();