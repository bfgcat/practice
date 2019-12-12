#!/usr/bin/perl -w

use strict;
use warnings;

use lib::P4::P4Mod;

our @active;
our @last;
our @deleted;
our @both;

sub main {
    my ($p4port,$p4client) = @_;    
    my %workspace = P4Mod::Client($p4port,$p4client);
    
    foreach my $view (@{$workspace{View}}) {
        my ($path) = $view =~ /(.*)\s.*$/;
        print "Procesing: $path\n";
        my @p4Files = P4Mod::Files($p4port,$path);
        my @sorted = sort sortFiles @p4Files;
    }
    
    print "Active duplicates:\n";
    print @active,"\n\n";
    print "Deleted duplicates:\n";
    print @deleted,"\n\n";
    print "First Deleted:\n";
    print @both,"\n\n";
    print "Last Touched\n";
    print @last,"\n\n";
    
    return 0;
}

sub sortFiles {
    if ( lc($a->{depotFile}) lt lc($b->{depotFile}) ) { return -1; }
    elsif ( lc($a->{depotFile}) eq lc($b->{depotFile}) ) {
        if ($a->{action} =~ /delete/ && $b->{action} =~ /delete/) {
            ($a->{time} < $b->{time}) ? push(@both,sprintf("%s\n",$a->{depotFile})) : push(@both,sprintf("%s\n",$b->{depotFile}));
        }
        elsif ($a->{action} =~ /delete/ || $b->{action} =~ /delete/) {
            ($a->{action} =~ /delete/) ? push(@deleted,sprintf("%s\n",$a->{depotFile})) : push(@deleted,sprintf("%s\n",$b->{depotFile}));
        }
        elsif ($a->{change} != $b->{change}) {
            ($a->{change} < $b->{change}) ? push(@last,sprintf("%s\n",$a->{depotFile})) : push(@last,sprintf("%s\n",$b->{depotFile}));
        }
        else {  
            push(@active,sprintf("%s#%s[%s] <-> %s#%s[%s]\n",$a->{depotFile},$a->{action},$a->{change},$b->{depotFile},$b->{action},$b->{change}));
        }
        
        return 0;
    }
    elsif ( lc($a->{depotFile}) gt lc($b->{depotFile}) ) { return 1; }
}

exit main(@ARGV);