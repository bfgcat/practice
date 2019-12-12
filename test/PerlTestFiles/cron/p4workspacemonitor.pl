#!/usr/bin/perl
# Turbine 2012
#
# $Id: $
# Last modified:
# $Author: $
# $DateTime: $
#
# p4workspacemonitor.pl : script to look for old workspaces and users that haven't logged in
# 			  within the specified time
#
# Usage: p4workspacemonitor.pl [-p <port>] [-u <user>] [-d <days>] ([-e <email>])
#
# Required:
# 	[-p <port>]	= perforce port.
# 	[-d <days>]	= the number of days old we are looking for.
#
# Optional:
# 	[-e <email>]	= email report will be sent to (default is "bhamilton@turbine.com")
# 	[-n <notify>]	= the time in hours that you gave notification for
# 	[-v <verbose>]	= output to the screen who was sent an email
#	
use strict;
use warnings;

use lib::P4::P4Mod;

use POSIX qw(strftime);
use Getopt::Long qw(:config require_order pass_through);

my %options =();
my $email = 'bhamilton@turbine.com';

&Main();

sub Main()
{
	ProcessCommandLine();
	
	my @oldUsers = GetOldUsers();
	my @oldClients = GetOldClients();
	
	unless ($options{notify}) {
		foreach my $user (@oldUsers) {
			NotifyUser($user);
		}

		foreach my $client (@oldClients) {
			NotifyClientUser($client);
		}
	}
	
	if ($options{notify}) {
		SendReport(\@oldUsers,\@oldClients);
	}
}

#-----------------------------------------------------------------------------------------------
# ProcessCommandLine
#-----------------------------------------------------------------------------------------------
sub ProcessCommandLine()
{
	GetOptions(\%options,'port=s', 'days=i', 'email=s', 'notify=i', 'verbose');

	if ( !($options{port} && $options{days}) ) {
		die &DisplayUsage();
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
	print "Usage: p4workspacemonitor.pl [-p <port>] [-d <days>] ([-e <email>])\n\n";
	print "Required:\n";
	print "\t[-p <port>]	= perforce port.\n";
	print "\t[-d <days>]	= the number of days old we are looking for.\n\n";
	print "Optional:\n";
	print "\t[-e <email>]	= email report will be sent to (default is \"bhamilton\@turbine.com\")\n";
}

#-----------------------------------------------------------------------------------------------
# GetOldUsers
#
# return: Array
#-----------------------------------------------------------------------------------------------
sub GetOldUsers()
{
	my @userlist = ();
	my $days = $options{notify} ? $options{days} + ($options{notify} / 24) :  $options{days};
	my $rdate = time - ($days * (60 * 24 * 60));
	
	foreach my $user (P4Mod::Users($options{port})){
		my %groups = map { $_->{group} => 1 } P4Mod::Groups($options{port}, $user->{User});
		if ( $rdate > $user->{Access} && !(exists($groups{admin}) || exists($groups{donotexpire})))
		{
		 	push(@userlist,$user);
		}
	}
	
	return @userlist;
}

#-----------------------------------------------------------------------------------------------
# GetOldClients
#
# input:  Hash	clientlist
# return: Hash	clientlist
#-----------------------------------------------------------------------------------------------
sub GetOldClients()
{
	my @clientlist = ();
	my $days = $options{notify} ? $options{days} + ($options{notify} / 24) :  $options{days};
	my $rdate = time - ($days * (60 * 24 * 60));
	
	foreach my $client (P4Mod::Clients($options{port})){
		if ( $rdate > $client->{Access} && $client->{client} !~ /template/i)
		{
		 	push(@clientlist,$client);
		}
	}
	
	return @clientlist;
}

#-----------------------------------------------------------------------------------------------
# NotifyUser
#
# input:  Array
#-----------------------------------------------------------------------------------------------
sub NotifyUser
{
    my ($user) = @_;

	my $sendmail = "/usr/sbin/sendmail -t";
	my $from     = "From: perforce\@turbine.com\n";
	my $send_to  = "To: $user->{Email}\n";
	my $reply_to = "Reply-to: perforce\@turbine.com\n";
	my $subject  = "Subject: Action Required: Perforce User Removal\n";

	if ($options{verbose}) { print "USERNOTIFY: Message sent to $user->{User} ($user->{Email})\n"; }
		
	open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
	print SENDMAIL $reply_to;
	print SENDMAIL $from;
	print SENDMAIL $subject;
	print SENDMAIL $send_to;
	print SENDMAIL "Content-Type: text/plain\n\n";
	print SENDMAIL "\nDear $user->{FullName},\n\tYour Perforce account \'$user->{User}\' on $options{port} has been inactive for at least $options{days} days and will be removed within 48  hours. If you still need this account active, please log into $options{port} at least once within the next 48 hours and your account will NOT be deleted.  Please contact open a ticket in \'ServiceNow (https://turbine.service-now.com)\' if you need assistance.\n\nThis is an automated message from your neighborhood RE group.";
	close(SENDMAIL);
}

#-----------------------------------------------------------------------------------------------
# NotifyClientUser
#
# input:  Hash    client_user
#-----------------------------------------------------------------------------------------------
sub NotifyClientUser
{
    my ($client) = @_;

	my %user = P4Mod::User($options{port},$client->{Owner});
	unless ($user{FullName}) { $user{FullName} = "Workspace Owner"; }
	if ($client->{Owner} && $user{Email} && $user{FullName} !~ /build/i) {
		my $sendmail = "/usr/sbin/sendmail -t";
		my $from     = "From: perforce\@turbine.com\n";
		my $send_to  = "To: $user{Email}\n";
		my $reply_to = "Reply-to: perforce\@turbine.com\n";
		my $subject  = "Subject: Action Required: Perforce Workspace Removal\n";
	
		if ($options{verbose}) { print "CLIENTNOTIFY: Message sent to $client->{client} ($client->{Owner})\n"; }
	
		open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
		print SENDMAIL $reply_to;
		print SENDMAIL $from;
		print SENDMAIL $subject;
		print SENDMAIL $send_to;
		print SENDMAIL "Content-Type: text/plain\n\n";
		print SENDMAIL "Dear $user{FullName},\n\tYour Perforce workspace \'$client->{client}\' on $options{port} has been inactive for at least $options{days} days and will be removed within 48 hours. If you do not want this workspace to be deleted please log into $options{port}, switch to the workspace \'$client->{client}\' and sync at least one file.  By doing this, the workspace will remain intact. Please contact open a ticket in \'ServiceNow (https://turbine.service-now.com)\' if you need assistance.\n\nThis is an automated message from your neighborhood RE group.";
		close(SENDMAIL);
	}
}

#-----------------------------------------------------------------------------------------------
# SendReport
#
# input: Hash	oldUsers
# input: Hash	oldClients
#-----------------------------------------------------------------------------------------------
sub SendReport(\@\@)
{
	my ($oldUsersRef,$oldClientsRef) = @_;
	my (@oldUsers) = @{$oldUsersRef};
	my (@oldClients) = @{$oldClientsRef};

	my $days = $options{notify} ? $options{days} + ($options{notify} / 24) :  $options{days};
	my $rdate = time - ($days * (60 * 24 * 60));
	my $date = strftime "%m/%d/%Y", localtime($rdate);
	
	my $sendmail = "/usr/sbin/sendmail -t";
	my $from     = "From: perforce\@turbine.com\n";
	my $send_to  = "To: $options{email}\n";
	my $reply_to = "Reply-to: perforce\@turbine.com\n";
	my $subject  = "Subject: Perforce Workspace/User Report: $options{port}\n";
	my $content  = "Server: $options{port}\n";
	my $mailpart = `uuidgen|tr -d '\n'`;
	my $filename = "p4cleanup.txt";
	
	if (scalar(@oldClients) or scalar(@oldUsers)) {
		open (FILE, "+>",\$filename) or die "Cannot open $filename: $!";
		print FILE "p4 -p $options{port} login\n";
		print FILE "p4 -p $options{port} info\n";
		print FILE "\n";
	
		if (scalar(@oldClients)) {
			my $count = scalar(@oldClients);
			$content .= "\n$count Inactive workspaces (since $date):\n";
			$content .= "=======================================================================================================\n";
			$content .= sprintf( "%-40s %-16s %-32s %-9s\n","WORKSPACE","OWNER","HOST","LAST ACCESS");
			$content .= "=======================================================================================================\n";
			print FILE "echo Deleting clients older than $date...\n";
	
			foreach my $client (@oldClients) {
				my ($day,$month,$year) = (localtime($client->{Access}))[3,4,5];
				$year+=1900;
				$month+=1;
				$content .= sprintf("%-40s %-16s %-32s %-9s\n", $client->{client}, $client->{Owner}, $client->{Host}, "$month/$day/$year");
				print FILE "p4 -p $options{port} unload -fLz -c $client->{client}\n";
			}
		
			$content .= "\n\n";
		}
	
		if (scalar(@oldUsers)) {
			my $count = scalar(@oldUsers);
			$content .= "\n$count Inactive users (since $date):\n";
			$content .= "=======================================================================================================\n";
			$content .= sprintf( "%-26s %-30s %-32s %-9s\n","USERNAME","FULLNAME","EMAIL","LAST ACCESS");
			$content .= "=======================================================================================================\n";
			print FILE "\necho Deleting users who have not logged in since $date...\n";
	
			foreach my $user (@oldUsers) {
				my ($day,$month,$year) = (localtime($user->{Access}))[3,4,5];
				$year+=1900;
				$month+=1;
				$content .= sprintf("%-26s %-30s %-32s %-9s\n", $user->{User}, $user->{FullName}, $user->{Email}, "$month/$day/$year");
				print FILE "p4 -p $options{port} user -f -d $user->{User}\n";
			}
		}
	
		close(FILE);
		
		open (FILE, "<",\$filename) or die "Cannot open $filename: $!";
		my @attachment=<FILE>;
		close(FILE);
	
		open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
		print SENDMAIL $reply_to;
		print SENDMAIL $from;
		print SENDMAIL $subject;
		print SENDMAIL $send_to;
		print SENDMAIL "MIME-Version: 1.0\n";
		print SENDMAIL "Content-Type: multipart/mixed; boundary=\"$mailpart\"\n\n";
		print SENDMAIL "--$mailpart\n\n";
		print SENDMAIL "$content\n\n";
		print SENDMAIL "--$mailpart\n";
		print SENDMAIL "Content-Type: text/plain; name=\"p4cleanup.txt\"\n\n";
		print SENDMAIL @attachment;
		print SENDMAIL "--$mailpart--";
		close(SENDMAIL);
	}
}