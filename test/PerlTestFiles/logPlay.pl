use strict;
use warnings;

use RMT::Logger qw( get_logger initLogging );

BEGIN {
    use FindBin qw( $Bin );
    use lib "$Bin";
}

use constant DBMS_DRIVER    => 'mysql';
# use constant DBMS_HOSTNAME  => 'bgillespie-opc.i.turbinegames.com'; # development environment
# use constant DBMS_HOSTNAME  => 're-build-38.i.turbinegames.com'; # staging environment
use constant DBMS_HOSTNAME  => 're-ops-01.i.turbinegames.com'; # production environment
use constant DBMS_DATABASE  => 'depotmgt';
use constant DBMS_URL       => sprintf('DBI:%s:%s:%s', DBMS_DRIVER, DBMS_DATABASE, DBMS_HOSTNAME);
use constant DBMS_USERNAME  => 'mirrorcomp';
# use constant DBMS_USERNAME  => 'root';
use constant DBMS_PASSWORD  => 'password';

use DBI();

my $conf_file = "$Bin/mylogger.conf";
if ( -e $conf_file )
{
    initLogging ( filename => $conf_file );
}

sub main {
    my $logger = get_logger();
    # begin code
    drink("Soda");
    drink();
    drink("Wine");
    
    my $dbh = DBI->connect( DBMS_URL, DBMS_USERNAME, DBMS_PASSWORD ) or die "Error: Failed to connect to database.\n";

    # my $statement = "UPDATE buildinfo SET CanDeploy = 'F' WHERE Branch = '$projectVariant' and Buildversion = '$buildNumber'";
    my $statement = "select ParamVal from system_parameter where ParamName='SYSLOG_HOSTNAME'";
    # my $statement = "select ParamVal from system_parameter where ParamName='TEST_PARAM'";
    # my $statement = "select ParamName, ParamVal from system_parameter where ParamName='TEST_PARAM'";
    my $sth = $dbh->prepare($statement);
    $sth->execute;
    
    my $value = $sth->fetchrow; # pulls off and does not leave a copy
    
    if ( ! defined $value)
    {
        $logger->info("SYSLOG_HOSTNAME: value is not defined");
    }
    else
    {
        if ($value)
        {
            $logger->info("SYSLOG_HOSTNAME: ", $value);
        }
        else
        {
            $logger->info("SYSLOG_HOSTNAME: value is empty");
        }
    }
    
    # my @row = $sth->fetchrow_array(  );
    # my $value2 = shift @row;

    $sth->finish;
    $dbh->disconnect();
}

sub drink {
    my($what) = @_;
    my $logger = get_logger();
    
    $logger -> debug('Starting ...');
    
    if(defined $what)
    {
        $logger->info("Drinking ", $what);
    }
    else
    {
        $logger->error("No drink defined");
    }
}

main();