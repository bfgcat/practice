#!/usr/bin/perl -w
#
# Overview:  This script will take the output from 'p4 users' and lookup the names in AD outputting with DOMAIN\username.
#
# Authors:  Toby Roberts (troberts@ea.com) and Mike Sundy (msundy@ea.com)
#

use strict;
use warnings;

use Getopt::Std;
use Net::LDAP;

use Ad2p4;

# User Hashes
my %singlehit = ();
my %multihit = ();
my %nohits = ();
my %cmdline;

my $gUsage = <<END;
Options:
    -u=s  --  Perforce super user account.  Account to be performing the migration.  (required)
    -t=s  --  number of days during which account must have been accessed. (optional)
    -d    --  Debug flag. Turns on debugging output.
END

#
# Main
#
# Loops through all users in perforce and tries to obtain an adlookup for that user
#
sub Main() {
    my $current_time;
    my $access_date_filter = 0;
    my @p4users;
    my $sam_account_name = "";

    getopts('dt:u:', \%cmdline);

    if(!$cmdline{u}) {
	print $gUsage;
	return;
    }

    ReadConfigFile($cmdline{d});

    @p4users = `p4 -ztag users`;

    # Even though we only support linux servers... just sanity check against running on windows
    if ($^O eq 'MSWin32') {
	$current_time = `date /T`;
    }
    else {
	$current_time = `date +%s`;
    }

    # Convert day argument to seconds
    if($cmdline{t}) {
	$access_date_filter = ($cmdline{t} * 86400);
    }

    foreach my $p4user (@p4users) {
	my $access_time = ();

	chomp $p4user;

	if ($p4user =~ /^\.{3}\sUser\s(.*)/) {
	    $sam_account_name = lc $1;
	    Debug("SAM name = $sam_account_name") if $cmdline{d};
	}
	if ($p4user =~ /\.{3}\sAccess\s(.*)/) {
	    $access_time = $1;
	    #print "Access time = $access_time\n";
	}
	if ($access_time) {
	    if ($access_date_filter > 0) {
		if (($current_time - $access_time) < $access_date_filter) {
		    my $delta = ($current_time - $access_time);
		    #print "Delta = $delta\n";
		    Debug("AD Lookup with delta: $delta") if $cmdline{d};
		    ADLOOKUP($sam_account_name);
		}
	    }
	    else {
		ADLOOKUP($sam_account_name);
	    }	
	}
    }

    PrintResults();
}


#
# PrintResults
#
# Prints found results for mapping perforce username to an AD username to output file
# Output file is used by conversion script (convert_username.pl) as input and '#' begun
# lines are treated as comments
#
sub PrintResults {
    ShowTrace(@_) if $cmdline{d};

    print "\n\n# *** Single Hit Names, no editing needed ***\n";
    PrintNames(\%singlehit);
    print "# *** End Single Hit Names ***\n\n\n";

    print "# *** Multi Hit Names, select one correct AD account ***\n";
    PrintNames(\%multihit);
    print "# *** End Multi Hit Names ***\n\n\n";

    print "# *** Users Not Found in AD, replace with correct AD account ***\n";
    PrintNames(\%nohits);
    print "# *** End Users Not Found ***\n";
}

sub PrintNames {
    my ($nameRef) = @_;

    ShowTrace(@_) if $cmdline{d};

    foreach my $key (sort keys %{$nameRef}) {
	if($key eq $cmdline{u}) {
	    print "# Commented super user account.  Can not be ported with other users, needed for migration.\n";
	    print "#";
	}
	print sprintf("%-25s\t%-30s\n", $key, $nameRef->{$key});
    }
}

#
# ADLookup
#
sub ADLOOKUP {
	my ($sam_account_name) = @_;

	ShowTrace(@_) if $cmdline{d};

	my $ldap;
	my $mesg;
	my $flatname;
	my $dn;
	my $domain;

	# Query AD using $sam_account_name and hope for a single match.  Sacrificing something may help.
	$ldap = Net::LDAP->new (
				$config{std_ldap}{host},
				port => $config{ldap_port},
				timeout => $config{timeout}
			       )
	  or die "*** ERROR: Unable to connect to $config{std_ldap}{host}: $! ***\n";

	$mesg = $ldap->bind (
			     $config{std_ldap}{read_account_dn},
			     password => $config{ldap_password},
			     version => $config{ldap_version}
			    )
	  or die "*** ERROR: Unable to bind to $config{std_ldap}{host}: $! ***\n";

	$mesg = $ldap->search (
			       base => $config{std_ldap}{domain_name},
			       filter => "(samaccountname=$sam_account_name)",
			       attrs => ['dn','name']
			      );

	my @entries = $mesg->entries;

	if (@entries) {
	    foreach my $entry (@entries) {
		$dn = $entry->dn();
		$dn =~ /\,DC=(.*)/;
		$domain = $1;
		$domain =~ s/,DC=/\./g;
		$flatname = GET_FLATNAME($domain);

		if ($flatname) {
		    if ($#entries == 0) {
			$singlehit{$sam_account_name} = "$flatname\\$sam_account_name";
		    }
		    else {
			if (exists($multihit{$sam_account_name})) {
			    $multihit{$sam_account_name} = "$multihit{$sam_account_name},$flatname\\$sam_account_name";
			}
			else {
			    $multihit{$sam_account_name} = "$flatname\\$sam_account_name";
			}
		    }
		}
		else {
		    warn "*** Couldn't resolve flatname for user " . $entry->get_value('name') . " and domain $domain. ***\n\n";
		}
	    }
	}
	else {
	    QUERY_VC($sam_account_name);
	}

	$ldap->unbind;
    }

#
# Query_VC
#
sub QUERY_VC {
	my ($sam_account_name) = @_;

	ShowTrace(@_) if $cmdline{d};

	my $ldap;
	my $mesg;
	my $result;
	my $flatname;

	$ldap = Net::LDAP->new (
				$config{vc_ldap}{host},
				port => $config{ldap_port},
				timeout => $config{timeout}
			       )
	  or die "*** ERROR: Unable to connect to $config{vc_ldap}{host}: $! ***\n";

	$mesg = $ldap->bind (
			     $config{vc_ldap}{read_account_dn},
			     password => $config{ldap_password},
			     version => $config{ldap_version}
			    );

	if($mesg->code()) {
	    if($cmdline{d}) {
		Debug("LDAP bind error [" . $mesg->code() . " : " . $mesg->error_name() ."]");
		Debug($mesg->error());
	    }
	    die "*** ERROR: Unable to bind to $config{vc_ldap}{host} ***\n";
	}

	$result = $ldap->search (	
			       base => $config{vc_ldap}{domain_name},
			       filter => "(samaccountname=$sam_account_name)",
			       attrs => ['dn','name']
			      );

	my @entries = $result->entries;	

	if (@entries) {
	    my $entry = $entries[0];
	    $flatname = "VC";
	    print "*** P4 User = $sam_account_name ***\n";
	    print "\tName = " . $entry->get_value('name') . "\n";
	    print "\tDomain\\user = $flatname\\$sam_account_name\n\n";
	}
	else {
	    $nohits{$sam_account_name} = "NOT FOUND";
	    # warn "*** User $sam_account_name not found in either the ad.ea.com or vc.ea.com forests. ***\n\n";
	}

	$ldap->unbind;
}


#
# Get_Flatname
#
sub GET_FLATNAME {
	my ($domain) = @_;

	ShowTrace(@_) if $cmdline{d};

	my $ldap;
	my $mesg;
	my $flatname;

	$ldap = Net::LDAP->new ($config{std_ldap}{host}, port => $config{ldap_port}, timeout => $config{timeout} )
	  or die "*** ERROR: Unable to connect to $config{std_ldap}{host}: $! ***\n";
	$mesg = $ldap->bind ($config{std_ldap}{read_account_dn}, password => $config{ldap_password}, version => $config{ldap_version} )
	  or die "*** ERROR: Unable to bind to $config{std_ldap}{host}: $! ***\n";
	$mesg = $ldap->search (	
			       base => $config{std_ldap}{domain_search},
			       filter => "(name=$domain)",
			       attrs =>	"flatName"
			      );
	my @output = $mesg->entries;

	if (@output) {
	    foreach my $out (@output) {
		$flatname = $out->get_value('flatname');
;		    Debug("Flatname found: $flatname") if $cmdline{d};
	    }
	}
	else {
	    warn "*** ERROR:  Could not find flatname from $domain in Active Directory. ***\n\n";
	}
	$ldap->unbind;

	return $flatname;
}

#
# Applicaiton entry point
#
Main();
exit;

# Fin
