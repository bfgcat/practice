#!/usr/bin/perl
#
#

use strict;
use warnings;

use Time::Local;
use Getopt::Long qw(:config require_order pass_through);

my %opts = ();
my %iusers = ();
my @servers = ( 'perforce01:1666','perforce02:1666','perforce02:2666','perforce02:3666','perforce02:4666','perforce03:1666','perforce05:1666' );

sub main {
	foreach my $server (@servers) {
		open(CMD, "p4 -p $server users|") or die "Cannot open file: $!";
		my @users=<CMD>;
		close(CMD);
	
		foreach my $user (@users) {
			my ($username,$email,$fullname,$access) = $user =~ m/(.*) <(.*)> (.*) accessed (.*)$/;
			my ($year,$month,$day) = $access =~ m/(.*)\/(.*)\/(.*)$/;
			my $date = timelocal(0,0,0,$day,$month-1,$year);
	
			$iusers{$username} = $iusers{$username} ? ($iusers{$username} > $date ? $iusers{$username} : $date) : $date;
		}
	}
	
	unless ($opts{all}) {
		foreach my $user(sort keys %iusers) {
			my $today = time - ($opts{days} * (60 *24 *60));
			my ($day,$month,$year) = (localtime($iusers{$user}))[3,4,5];
			$month+=1;
			$year+=1900;
	
			if ($opts{inactive} and $today <= $iusers{$user}) {
				#print "Removing: $user [$month/$day/$year]\n";
				delete $iusers{$user};
			}
	
			if ($opts{active} and $iusers{$user} < $today) {
				#print "Removing: $user [$month/$day/$year]\n";
				delete $iusers{$user};
			}
		}
	}	
	
	foreach my $user(sort keys %iusers) {
	
		my ($day,$month,$year) = (localtime($iusers{$user}))[3,4,5];
		$month+=1;
		$year+=1900;
		print "User: $user access [$month/$day/$year]\n";
	}	
	
	print "\nNumber of users found: ".scalar(keys %iusers)."\n";
}

GetOptions(\%opts, 'days=i', 'active!', 'inactive!', 'all!');
return main();