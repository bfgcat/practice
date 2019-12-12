#!/usr/bin/perl -w

use strict;
use warnings;

use lib::P4::P4Mod;
use Getopt::Long qw(:config require_order pass_through);

sub main($$) {
    my ($port,$domain) = @_;

    my $p4 = new P4Mod("port"=>$port,"username"=>"bhamilton");    
    my %change = $p4->Describe("-s 26");
    
    return 0;
    
    my %user = P4::User($port,"bhamilton");
    my $spec = P4::UserSpec(%user);
    
    foreach my $user (P4::Users($port)) {
        fixChangelists($port,$domain,$user->{User}) if ($user->{User}=~/$domain\\/);
    }
    
    foreach my $group (P4::Groups($port)) {
        fixGroups($port,$domain,$group);
    }
    
    return 0;
}

sub fixChangelists($$) {
    my ($port,$domain,$username) = @_;
    
    $username=~s/\\/\\\\/;
    my @changes = P4::Changes($port, "-u $username");
    foreach my $change (@changes) {
        my $temp = P4::GetSpec($port,'change',$change);
    
        $temp=~s/User:\s*$domain\\/User:\t\t/;
        P4::WriteSpec($port,'change -f',$temp);
    }
    
    fixClients($port,$domain,$username);
    fixUser($port,$domain,$username);
    
    return 0;
}

sub fixUser($$) {
    my ($port,$domain,$username) = @_;
    
    my $temp = P4::GetSpec($port,'user',$username);
    
    $temp=~s/User:\s*$domain\\/User:\t\t/;
    P4::DeleteSpec($port,'user -fd',$username);
    P4::WriteSpec($port,'user -f',$temp);
    
    return 0;
}

sub fixClients($$) {
    my ($port,$domain,$username) = @_;
    
    my @clients = P4::Clients($port, "-u", $username);
    
    foreach my $client (@clients) {
        $client=~s/\\/\\\\/;
        my $temp = P4::GetSpec($port,'client',$client);
        
        $temp =~ s/Owner:\s*$domain\\/Owner:\t\t/;
        P4::WriteSpec($port,'client -f',$temp);
    }
    
}

sub fixGroups($$) {
    my ($port,$domain,$group) = @_;
    
    my $temp = P4::GetSpec($port,'group',$group);
    $temp=~s/$domain\\//gm;
    P4::WriteSpec($port,'group',$temp);
    
    return 0;
}

exit main($ARGV[0],$ARGV[1]);
