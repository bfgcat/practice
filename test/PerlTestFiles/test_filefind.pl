#!/usr/bin/perl -w
use strict;

use IO::Dir;
use RMT::Mail;

my $p4server = 'perforce-hendrix:1666';
my $p4branch = 'hendrix_dev';
my $p4path = "//deployment/hendrix/$p4branch/patch/";

sub main {
    my $testdir = 'c:\\test\\Perlfiles\\testdir';
    my @deletelist = ();
    my $recipients = 'brian@bfgcat.com';
    
    my $branch = 'hendrix_dev';
    $branch =~ m/(\w+)_\w+/;
    my $game = $1;
    print ("branch: $branch\n");
    print ("game  : $game\n");
    
    $branch = 'hendrix_qa';
    $branch =~ m/(\w+)_\w+/;
    $game = $1;
    print ("branch: $branch\n");
    print ("game  : $game\n");
        
    $branch = 'hendrix_RE_test';
    $branch =~ m/(\w+^_)\w+/;
    $game = $1;
    print ("branch: $branch\n");
    print ("game  : $game\n");

    
    my $testlabel1 = 'hendrix_qa-0400.0006.0546.4098';
    my $testlabel2 = 'hendrix_qa-0400.0006.0695.4100';
    my $testlabel3 = 'hendrix_qa-0400.0005.0546.4050';
    
    push @deletelist, get_label_files($testlabel1, $testdir);
    push @deletelist, get_label_files($testlabel2, $testdir);
    push @deletelist, get_label_files($testlabel3, $testdir);
    
    printlist(@deletelist);
    
    if ( scalar(@deletelist) > 0 )
    {
        sendlist($recipients, @deletelist, $branch );
    }
}

sub sendlist {
    my ($msg_to, @dlist) = @_;
    # my $logger = get_logger();
    
    my $msg_from = "ReleaseEngineering\@turbine.com";
    my $msg_subject = "Test Tool oblit commands";
    my $msg_body = "\n";

    for (my $i = 0; $i < scalar(@dlist) ; $i++)
    {
        $msg_body = $msg_body . "p4 -p $p4server obliterate -y $p4path/$dlist[$i]\n";
    }
    
    print "Debug:\n$msg_body\n:DEBUG\n";
       
    my $status = RMT::Mail -> send(
        msg     => $msg_body,
        subject => $msg_subject,
        to      => $msg_to,
    );
    if ( ! $status ) {
        # $logger -> logconfess(sprintf("Unable to send failure email to %s:\n%s", @{$emails}, $message));
        sprintf("Unable to send test email to %s:\n%s", @{$msg_to}, $msg_body);
    }
}

sub get_label_files {
    my ($label, $testdir) = @_;
    
    # get the build number protion of the label
    $label =~ m/\w+-(\d{4}\.\d{4}\.\d{4}\.\d{4})/;
    my $mytag = $1;
    print ("tag:" . $mytag . "\n");
    
    # find all files in the test dir whose name starts with the build number. put in the delete_list
    my $d = IO::Dir->new("$testdir");
    my @filelist = $d->read();
    
    # printlist(@filelist);
    
    # find all matching files
    my @matchlist = ();
    for (my $i = 0; $i < scalar(@filelist) ; $i++)
    {
        if ( $filelist[$i] =~ /$mytag/ )
        {
            push @matchlist, $filelist[$i];
        }
    }
    
    # printlist(@matchlist);
    return(@matchlist);  
}


sub printlist  {
    my @inlist = @_;
    
    print ("# elements:" . scalar(@inlist) . "\n");
    for (my $i = 0; $i < scalar(@inlist); $i++) {
        print ($i . "\t" . $inlist[$i] . "\n");
    }
    
    print ("\n");
}

main ();