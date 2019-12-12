#-------------------------------------------------------------------------------------
# P4 Package
#   WARNING:
#   To use this module requires p4perl 2012.2+
#-------------------------------------------------------------------------------------

package P4Mod;

use strict;
use P4;
use Data::Dumper;
use Exporter qw(import);

#our $VERSION    = 1.00;
#our @ISA        = qw(Exporter);
#our @EXPORT_OK  = qw(Info Change Changes Opened User Users Client GetP4ChangeSpec);

sub new {
    my $class = shift;
    my (%args)  = @_;
    #$args{'+required_defined_arguments'} = [qw(
    #    port
    #    username
    #    password
    #)];
   
    my $self = {
        serverport => $args{port},
        user => $args{username},
        password => $args{password},
    };

    bless ($self, $class);
    return $self;
}

sub Port() {
    
    # Create a new Perforce Object
    my $p4 = new P4;
    
    # Get the port that is defined in P4PORT
    return $p4->GetPort();
}

sub Info {
    my ($port) = @_;

    # Run a info command
    my @results = _Run(port=>$port, cmd=>"info");
    
    return %{$results[0]};
}

sub Describe {
    my ($port,$args) = @_;
    
    # Run a describe on the changelist and give back the first one
    my @results = _Run(port=>$port, cmd=>"describe ".$args);
    
    return %{$results[0]};
}

sub Changes {
    my ($port,$args) =  @_;
    
    return _Run(port=>$port, cmd=>"changes ".$args);
}

sub User {
    my ($port,$args) = @_;
    
    my @results = _Run(port=>$port, cmd=>"user -o ".$args);
    
    return %{$results[0]};
}

sub Users {
    my ($port,$args) = @_;
    
    return _Run(port=>$port, cmd=>"users ".$args);    
}

sub Group {
    my ($port,$args) = @_;
    
    my @results = _Run(port=>$port, cmd=>"group -o ".$args);
    
    return %{$results[0]};
}

sub Groups {
    my ($port,$args) = @_;
    
    return _Run(port=>$port, cmd=>"groups ".$args);
}

sub Client {
    my ($port,$args) = @_;
    
    my @results = _Run(port=>$port, cmd=>"client -o ".$args);
    
    return %{$results[0]};
}

sub Clients {
    my ($port,$args) = @_;
    
    my $cmd = $args ? "clients $args" : "clients";
    return _Run(port=>$port, cmd=>$cmd);
}

sub Label {
    my ($port,$args) = @_;
    
    my $cmd = $args ? "label $args" : "label";
    return _Run(port=>$port, cmd=>$cmd);
}

sub Labels {
    my ($port,$args) = @_;
    
    my $cmd = $args ? "labels $args" : "labels";
    return _Run(port=>$port, cmd=>$cmd);
}

sub Depots {
    my ($port,$args) = @_;
    
    my $cmd = $args ? "depots $args" : "depots";
    return _Run(port=>$port, cmd=>$cmd);
}

sub ReloadLabel {
    my ($port,$args) = @_;

    return _Run(port=>$port, cmd=>"reload -f -l ".$args);
}

sub ReloadClient {
    my ($port,$args) = @_;
    
    return _Run(port=>$port, cmd=>"reload -f -c ".$args);
}

sub Opened {
    my ($port,$args) = @_;
    
    return _Run(port=>$port, cmd=>"opened ".$args);
}

sub Fstat {
    my ($port,$args) = @_;
    
    return _Run(port=>$port, cmd=>"fstat ".$args)
}

sub Print {
    my($port,$file) = @_;
    
    my @results = _Run(port=>$port, tagged=>0, cmd=>"print -q ".$file);
    shift @results;
    return join(" ",@results);
}

sub Verify {
    my ($port,$path) = @_;
    
    return _Run(port=>$port, cmd=>"verify ".$path)
}

sub Diff2 {
    my ($port,$file1,$file2) = @_;
    my $tagged=0;
    
    my $p4 = new P4;
    $p4->SetPort($port);
    $p4->Connect();
    
    # Turnoff tags as we don't need them
    $tagged = $p4->IsTagged();
    
    $p4->Tagged(0);
    my $results = $p4->Run("diff2",$file1,$file2);    
    
    # Put the server Tag back to what it was before we changed it
    $p4->Tagged($tagged);
    
    return join("\n",@$results);
}

sub Reviews {
    my ($port,$args) = @_;
    
    return _Run(port=>$port, cmd=>"reviews -c ".$args);
}

sub Files {
    my ($port,$args) = @_;
        
    return _Run(port=>$port, cmd=>"files ".$args);   
}

sub FetchSpec {
    my ($port,$type,$args) = @_;
    
    my @spec = _Run(port=>$port, cmd=>"$type -o ".$args);
    
    my $p4 = new P4();    
    return $p4->FormatSpec($type,$spec[0]);
}

sub StoreSpec {
    my ($port,$type,$spec) = @_;
    return _Run(port=>$port, input=>$spec, cmd=>"$type -i -f");
}

sub DeleteSpec {
    my ($port,$spec,$var) = @_;
    
    `p4 -p $port $spec -d $var`;
}

sub _Run(%) {
    my (%params) = @_;
    my ($port,$input,$cmd) = @params{qw(port input cmd)};
    
    # Create a new Perforce Object
    my $p4 = new P4;
    
    # Set the server that we are going to use
    $p4->SetPort($port);
    # Connect to the server
    $p4->Connect();
    
    # Get the Tag state
    my $tags = $p4->IsTagged();
    
    # Turn tags on/off
    $p4->Tagged($params{tagged}) if $params{tagged};
    $p4->SetInput($input) if $input;
    my @results = $p4->Run(split(" ",$cmd));
    
    my @warnings = $p4 -> Warnings();
    foreach my $warning (@warnings) {
        print $warning, "\n";
    }
    
    my @messages = $p4 -> Messages();
    foreach my $message (@messages) {
        print $message -> GetText(), "\n" if defined($message);
    }
    
    # Put the server Tag back to what it was before we changed it
    $p4->Tagged($tags);
    
    $p4->Disconnect();
    
    wantarray ? return @results : return \@results;
}

1;
__END__
