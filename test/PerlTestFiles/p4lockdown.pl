#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long qw(:config require_order pass_through);

my %options = ();

&Main();

sub Main()
{
	&ProcessCommandLine();
	my @users = &GetUsers($options{input});
	foreach my $user (@users)
	{
		my $passwd = `uuidgen | tr -d '\n'`;
		my $line = `p4 -Ztag -p $options{port} -u $options{username} passwd -P $passwd $user`;
	}
}

sub ProcessCommandLine()
{
	GetOptions(\%options,
		'port=s',
		'username=s',
		'input=s'
	);

	if ( !($options{port} && $options{username} && $options{input}) )
	{
		#DisplayUsage();
		die "Arguments are not correct\n";
	}
}

#sub Login()
#{
#	print "Enter password:";
#	system('stty -echo');
#	chomp(my $passwd=<>);
#	print "\n";
#	system('stty echo');
#
#	return $passwd;
#}

sub GetUsers()
{
	my ($filename) = @_;
	my @users = ();

	open(FILE, "<$filename") or die "Cannot open $filename: $!";
	while (<FILE>) { push(@users,$_); }
	close(FILE);

	return (@users);
}
