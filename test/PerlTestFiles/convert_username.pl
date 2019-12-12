#!/usr/bin/perl -w
#
# convert_username.pl
#
# Overview: This script converts a Perforce username.  It converts metadata tied to a source
# username (user, clientspec, branchspec, group membership, etc.) to a target
# username.  For example, this script will convert metadata records associated with 'jdoe'
# to be associated with 'MAXIS\jdoe' instead.  You might also
# use this script to convert a user when their name changes (e.g. through marriage, name change, etc.).
#
# Author: Mike Sundy (msundy@maxis.com)
#
# This script was tested on Perforce 2006.1 on Linux Redhat (2.6 kernel) and may not
# work with earlier versions of Perforce.
#

use strict;
use warnings;

use FindBin qw($Bin $Script);
use Getopt::Std;
use Tie::CPHash;

use lib "$Bin";
use Ad2p4;

# Set Variables
my $gUsage = <<END;

You must specify an option to run this script.

	-c {configfile}  =  Location of config file listing source and target
          users to convert.  Incompatible with '-s' or '-t' option.
	-s {source_user} =  Use for conversion of single user account.  Source
          username.  This flag is incompatible with the '-c' option.  Requires
          '-t' option.  Requires quotes to prevent Linux shell munge of
          backslash character.
	-t {target_user} =  Use for conversion of single user account.
          Target username.  This flag is incompatible with the '-c' option.
          Requires '-s' option.  Requires quotes to prevent Linux shell munge
          of backslash character.\n"
        -d (deubg) Turn on debug output.

END

my $temp_file = "convert_temp";
my $source_user;
my $target_user;
my %opts;
my %userhash;

# Make hash lookups case-insensitive but case-preserving
tie %userhash, 'Tie::CPHash';

getopts("dc:s:t:", \%opts);

unless (defined $opts{c} || (defined $opts{s} && defined $opts{t})) {
    die $gUsage;
}

if (defined ($opts{c})) {
    my $config_file = $opts{c};

    unless (-e $config_file) {
	die "Error: could not find config file \"$config_file\"";
    }

    print "Using config_file \"$config_file\" to read in delimited list of user accounts to convert...\n";
    open (CONFIG, "$config_file");

    while (<CONFIG>) {
	# Allow # for comment character
	# Allow blank lines
	if($_ =~ /^#/ || $_ =~ /^\s+$/) {
	    next;
	}
	if ($_ =~ /(.*?)\s+(.*)/) {
	    $userhash{$1}=$2;
	    chomp($userhash{$1});
	    # remove trailing spaces from target name
	    $userhash{$1} =~ s/\s+$//;
	}
    }

    close CONFIG;
}

if (defined ($opts{s}) &&  ($opts{t})) {
    $source_user = ($opts{s});
    $target_user = ($opts{t});
    $userhash{"$source_user"}=$target_user;
}

unless (%userhash) {
    die "No users found to convert.  Exiting.\n";
}

while (($source_user,$target_user) = each(%userhash)) {
    print "Source=[$source_user]  Target=[$target_user]\n";
}

ConvertClientSpecs();
ConvertBranchSpecs();
ConvertJobSpecs();

my @source_users = keys(%userhash);
foreach $source_user (@source_users) {
    $target_user = $userhash{"$source_user"};

    ConvertGroups($source_user, $target_user);

    #Convert user record
    #print "source_user is: $source_user\n";
    if ( $source_user =~ /(.*)\\(.*)/ ) {
	#print "source_user contains backslash.\n";
	$source_user = "$1\\\\$2";
	#print "source_user has been converted to: $source_user\n";		
    }

    my $convertSuccess = ConvertUserRecord($source_user, $target_user);
    ConvertProtectTable($source_user, $target_user);
    if($convertSuccess) {
	DeleteOldUser($source_user);
    }
}

# fin

sub DeleteOldUser {
    my ($source_user) = @_;

    ShowTrace(@_) if $opts{d};

    #Remove old user account
    if(system ("p4 user -d -f \"$source_user\"") != 0) {
	warn "**ERROR** Could not delete user \"$source_user\" properly";
    }
}

sub ConvertUserRecord {
    my ($source_user, $target_user) = @_;

    ShowTrace(@_) if $opts{d};

    my $retVal = 0;
    my @form_in = `p4 user -o \"$source_user\"`;
    my $user_form_converted_flag = 0;

    #Convert user record
    print "Source user=$source_user\n";
    #if ( $source_user =~ /(.*)\\(.*)/ ) {
    #	print "source_user contains backslash.\n";
    #	$source_user = "$1\\\\$2";
    #	print "source_user has been converted to: $source_user\n";		
    #}
    if (open(SPEC, ">$temp_file")) {
	foreach my $line (@form_in) {
	    #print "User record line is: $line\n";
	    if ($line =~ /^User:\t$source_user\n/i) {
		#print "source_user inside user form processing is: $source_user\n";
		if ( $source_user =~ /(.*)\\\\(.*)/ ) {
		    $source_user = "$1\\$2";
		}
		#$target_user = $userhash{"$source_user"};
		#print "target_user inside user form is: $target_user\n";
		$line = "User:\t$target_user\n";
		$user_form_converted_flag = 1;
	    }
	    print SPEC $line;
	}
	
    }

    close SPEC;

    if ( $source_user =~ /(.*)\\\\(.*)/ ) {
	$source_user = "$1\\$2";
    }

    # Update perforce
    unless (system("cat $temp_file | p4 user -i -f")) {
	#Remove old user account
	if($user_form_converted_flag != 1) {
	    warn "**ERROR** Could not convert user form properly, so not attempting to " .
	      "delete \"$source_user\" user form\n";
	}
	else {
	    $retVal = 1;
	}
    } else {
	print "\n\n**ERROR** Target user $target_user could not be created: $!  Bad form is:\n";
	system("cat $temp_file");
	print "\n";	
    }
    unlink $temp_file;

    return $retVal;
}

sub ConvertProtectTable {
    my ($source_user, $target_user) = @_;

    ShowTrace(@_) if $opts{d};

    #Convert protect table references
    my @form_in = `p4 protect -o`;
    my $protect_flag=0;
    if (open(SPEC, ">$temp_file")) {
	foreach my $line (@form_in) {
	    if ($line =~ s/user $source_user /user $target_user /i) {
		print SPEC $line;
		$protect_flag = 1;
	    } else {
		print SPEC $line;
	    }
	}

    }

    close SPEC;

    if ($protect_flag == 1) {
	if (system("cat $temp_file | p4 protect -i")) {
	    print "\n\n**ERROR** Client update error with protect table conversion of $target_user.  Bad form is:\n";
	    system("cat $temp_file");
	    print "\n";
	}
    }
    unlink $temp_file;
}


sub ConvertGroups {
    my ($source_user, $target_user) = @_;

    ShowTrace(@_) if $opts{d};

    #Convert group membership
    my @groups = `p4 groups $source_user`;
    my $user_flag = 0;

    foreach my $group (@groups) {
	$user_flag = 0;
	my @form_in = `p4 group -o $group`;
	if (open(SPEC, ">$temp_file")) {
	    foreach my $line (@form_in) {
		if ($user_flag == 1) {
		    if ($line =~ /\t$source_user\n/i) {
			#Debug("source_user is: $source_user") if $opts{d};
			#$target_user = $userhash{"$source_user"};
			#Debug("target_user is: $target_user") if $opts{d};
			$line = "\t$target_user\n";
		    }
		}
		if ($line =~ /^Users:/) {
		    $user_flag = 1;
		}
		print SPEC $line;
	    }
	}

	close SPEC;

	if (system("cat $temp_file | p4 group -i")) {
	    print "\n\n**ERROR** Group update error with $group.  Bad form is:\n";
	    system("cat $temp_file");
	    print "\n";
	}
	unlink $temp_file;
    }
}

sub ConvertClientSpecs {
    ShowTrace(@_) if $opts{d};

    #Convert clientspec ownership
    my @specdump = `p4 -Ztag clients`;
    my $specname;
    my $owner;

    foreach my $line (@specdump) {
	if ($line=~/\.{3}\sclient\s(.*)/) {
	    $specname = $1;
	}
	if ($line=~/\.{3}\sOwner\s(.*)/) {
	    #print "client owner line is: $line\n";
	    $owner = $1;
	    if ($userhash{"$owner"}) { #check if spec owner is in user hash
		my @form_in = `p4 client -o \"$specname\"`;
		if (open(SPEC, ">$temp_file")) {
		    foreach $line (@form_in) {
			if ($line =~ /^Owner:/) {
			    $target_user = $userhash{"$owner"};
			    $line = "Owner:\t$target_user\n";
			}
			print SPEC $line;
		    }

		    close SPEC;

		    # Update perforce
		    if (system("cat $temp_file | p4 client -i -f")) {
			print "\n\n**ERROR** Client update error with $specname.  Bad form is:\n";
			system("cat $temp_file");
			print "\n";
		    }
		    unlink $temp_file;
		}
	    }
	}
    }
}

sub ConvertBranchSpecs {
    ShowTrace(@_) if $opts{d};

    #Convert branchspec ownership
    my @specdump = `p4 -Ztag branches`;
    my $specname;
    my $owner;

    foreach my $line (@specdump) {

	if ($line=~/\.{3}\sbranch\s(.*)/) {
	    $specname = $1;
	}
	if ($line=~/\.{3}\sOwner\s(.*)/) {
	    $owner = $1;
	    if ($userhash{"$owner"}) { #check if spec owner is in user hash
		my @form_in = `p4 branch -o \"$specname\"`;
		if (open(SPEC, ">$temp_file")) {
		    foreach $line (@form_in) {
			if ($line =~ /^Owner:/) {
			    $target_user = $userhash{"$owner"};
			    $line = "Owner:\t$target_user\n";
			}
			print SPEC $line;
		    }

		    close SPEC;

		    # Update perforce
		    if (system("cat $temp_file | p4 branch -i -f")) {
			print "\n\n**ERROR** Branch update error with $specname.  Bad form is:\n";
			system("cat $temp_file");
			print "\n";
		    }
		    unlink $temp_file;
		}
	    }
	}
    }

}

sub ConvertJobSpecs {
    ShowTrace(@_) if $opts{d};

    #Convert jobspec ownership
    my @specdump = `p4 -Ztag jobs`;
    my $specname;
    my $owner;

    foreach my $line (@specdump) {
	if ($line=~/\.{3}\sJob\s(.*)/) {
	    $specname = $1;
	}
	if ($line=~/\.{3}\sUser\s(.*)/) {
	    $owner = $1;
	    #print "Job owner is: $owner\n";
	    if ($userhash{"$owner"}) { #check if spec owner is in user hash
		my @form_in = `p4 job -o \"$specname\"`;
		if (open(SPEC, ">$temp_file")) {
		    foreach $line (@form_in) {
			if ($line =~ /^User:/) {
			    $target_user = $userhash{"$owner"};
			    $line = "User:\t$target_user\n";
			}
			print SPEC $line;
		    }

		    close SPEC;

		    # Update perforce
		    if (system("cat $temp_file | p4 job -i -f")) {
			print "\n\n**ERROR** Job update error with $specname.  Bad form is:\n";
			system("cat $temp_file");
			print "\n";
		    }
		    unlink $temp_file;
		}
	    }
	}
    }
}
