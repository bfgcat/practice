#!/usr/bin/perl
# Turbine 2014
#
# $Id: $
# Last modified:
# $Author: $
# $DateTime: $
#
# p4unloadedWSmonitor.pl : script to look for unloaded workspaces on all depots that haven't logged in
#                         within the specified time and delete them.
#
# Usage: p4workspacemonitor.pl [-p <port>] [-d <days>] ([-e <email>])
#
# Optional:
#       [-d <days>]     = (default 270), the number of days old we are looking for. 
#       [-p <port>]     = perforce port. If not provided, all depots checked.
#       [-e <email>]    = email report will be sent to (default is "bgillespie@turbine.com")
#       [-v <verbose>]  = output to the screen more details
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
my $useAllPorts = 0;

&Main();

sub Main()
{
        ProcessCommandLine();

        my $days = $options{days};
        my $rdate = time - ($days * (60 * 24 * 60));

	if ( ! $useAllPorts )
	{
		@ports = ($options{port});
	}
	
	foreach my $port (@ports)
	{
		my @clientlist = ();
		foreach my $client (P4Mod::Clients($port, "-U"))
		{
			if ( $rdate > $client->{Access} && $client->{client} !~ /template/i)
			{
				push(@clientlist,$client);
			}
		}
		
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
        GetOptions(\%options,'port=s', 'days=i', 'email=s', 'notify=i', 'verbose');

        unless ($options{days}) {
                $options{days} = 270;
        }

        unless ($options{port}) {
                $options{port} = "";
		$useAllPorts = 1;
        }

        unless ($options{email}) {
                $options{email} = $email;
        }
}

#-----------------------------------------------------------------------------------------------
# DisplayUsage
#-----------------------------------------------------------------------------------------------
sub DisplayUsage()
{
        print "Usage: p4unloadedWSmonitor.pl [-p <port>] [-d <days>] ([-e <email>])\n\n";
        print "Optional:\n";
        print "\t[-d <days>]    = (default 270) the number of days old we are looking for.\n\n";
        print "\t[-p <port>]    = perforce port. If not provided, all depots checked.\n";
        print "\t[-n <notify>]  = the time in hours that you gave notification for";
        print "\t[-e <email>]   = email report will be sent to (default is \"bgillespie\@turbine.com\")\n";
}
