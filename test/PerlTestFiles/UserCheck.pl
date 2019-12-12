#!/usr/bin/perl
# Turbine 2014
#
# $Id: $
# Last modified:
# $Author: $
# $DateTime: $
#
# p4UserCheck.pl : script to lookup users in all depots
#
# Usage: p4workspacemonitor.pl userID [userID, [...]]
#
# userID: a valid Perforce user ID
#

use strict;
use warnings;

use lib::P4::P4Mod;

use POSIX qw(strftime);
use Getopt::Long qw(:config require_order pass_through);

my %options =();
my $email = 'bgillespie@turbine.com';
my $p4 = "/usr/bin/p4";

my @ports = qw/perforce-ddo:3666 perforce-lotro:2666 perforce-hendrix:1666 perforce-engine:1666 perforce-engine:2666 perforce-engine:3666 perforce-engine:4666/;
my @users = "";

&Main();

sub Main()
{
        ProcessCommandLine();
	
	foreach my $user (@users)
	{
		foreach my $port (@ports)
		{
			# does the user exist on this port?
		}
		
		### CONTINUE HERE ###
		if ( scalar @clientlist > 0 )
		{
			my $filename = "p4cleanup_temp.txt";
	
			open (FILE, "+>",\$filename) or die "Cannot open $filename: $!";
			print FILE "Delete unloaded clients over " . $days . " days old:\n\n";
			print FILE "\t" . scalar @clientlist . " clients to delete.\n\n";
			foreach my $client (@clientlist)
			{
				print FILE "p4 -p $port -u WBIE\\bgillespie client -d -f " . $client->{client} . "\n";
			}
	
			print FILE "\n\n";
	
			close (FILE);
	
			open (FILE, "<",\$filename) or die "Cannot open $filename: $!";
			my @attachment=<FILE>;
			close(FILE);
	
			my $sendmailfile = "cleanUnloadClients.txt";
			open(SENDMAIL, ">$sendmailfile") or die "Cannot open $sendmailfile: $!";
			
			print SENDMAIL @attachment;
			
			print @attachment;
		}
		else
		{
			print "Port: $port\tNo clients found matching criteria.\n";
		}
	}
}

#-----------------------------------------------------------------------------------------------
# ProcessCommandLine
#-----------------------------------------------------------------------------------------------
sub ProcessCommandLine()
{
        
}
