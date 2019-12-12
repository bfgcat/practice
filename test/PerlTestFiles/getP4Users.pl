#!/usr/bin/perl
# Turbine 2014
#
# $Id: $
# Last modified:
# $Author: $
# $DateTime: $
#
# getP4Users.pl : script to look for users in all depots
#
# Usage: getP4Users.pl userID [.userID[,...]]
#
# Optional:
#       userID : a Perforce userID, usually consisting of first letter of first name followed by last name
#                examples - Brian Gillespie       -> bgillespie
#                           John Smith            -> jsmith
#
# Some users are known not to follow this scheme
# 	Paul Frost	frost
#	Allan Maki	allan
#	Alfreda Smith	alsmith
#	Eric Deans	erdeans
#	Erika Ng	erng
#	Elliot Gilman	elliot
#	Kevin Nolan	kenolan
#	Michael Kujawa	kujawa
#	Sean Huxter	sean
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
my @users = ();

&Main();

sub Main()
{
	push (@users, @ARGV);
	
	if ( scalar @users < 1)
	{
		die "no userIDs provided";
	}
	
	foreach my $port (@ports)
	{
		my @p4userList = P4Mod::Users($port, "-a");
		
		if ( scalar @p4userList > 0 )
		{
			# print "Port: " . $port . "\t" . scalar @p4userList . " userIDs to be checked.\n";
			print "Port: " . $port . "\n";
			
			# create list of user IDs without leading 'WBIE\'
			my @p4idList = "";
			foreach my $user (@p4userList)
			{
				my $newID;
				if ( $user->{User} =~ m/^WBIE\\(.+)/)
				{
					$newID = $1;
					#print $1 . "\n";
				}
				else
				{
					$newID = $user->{User};
					#print $user->{User} . "\n";
				}
				push (@p4idList, $newID);
				
				foreach my $id (@users)
				{
					if ( $user->{FullName} =~ m/$id/i )
					{
						print "\tPartial Match\t" . $user->{User} . "\t" . $user->{FullName} . " found on " . $port. "\n";
					}
					
					if ( $newID eq $id )
					{
						print "\tFull Match\t" . $id . " found on " . $port . "\n";
					}
				}
			}
			
			#foreach my $id (@users)
			#{
			#	# test if supplied ID is an exact match in list from this port
			#	if ( $id ~~ @p4idList )
			#	{
			#		print "\t" . $id . " found on " . $port . "\n";
			#	}
			#}
		}
		else
		{
			print "Port: $port\tNo clients found matching criteria.\n";
		}
	}
}
#-----------------------------------------------------------------------------------------------
# DisplayUsage
#-----------------------------------------------------------------------------------------------
sub DisplayUsage()
{
        print "Usage: getP4Users.pl userID [.userID[,...]]\n\n";
}
