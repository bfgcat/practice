#!/usr/local/bin/perl

use strict;
use warnings;
use IO::File;
use P4;

my $argc = @ARGV;
$argc == 4 || die "wrong number args, expected 4\n";

my $changelist = $ARGV[0];
my $client = $ARGV[1];
my $server = $ARGV[2];
my $user = $ARGV[3];

# Files
my $outfile = '/perforce/testing/P4ModuleTest.log';

# open temporary output file
my $fhout = IO::File->new(">$outfile");
defined $fhout || die "Unable to open file for writing: $outfile\nError: $!\n";

my $P4USER = $user;
my $P4PORT = $server;

$fhout->print("Trying to connect to p4port $P4PORT as user $P4USER\n");

my $p4 = new P4;
$p4->SetPort ( $P4PORT );
$p4->Connect() or die( "Failed to connect to Perforce Server" );

my $info = $p4->Run( "info" );
#$fhout->print("Server Info:\n$info\n\n");

$p4->Disconnect();


$fhout->close() || die "Error closing file $outfile\nError: $!\n";

exit 0;
