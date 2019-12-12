#! /usr/bin/perl
#--------------------------------------------------------------------------------------
# Perforce Trigger Helper Classes
#
# Blair Hamilton, bhamilton@turbine.com
#
#--------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------#
# Trigger Helper package                                                              #
#-------------------------------------------------------------------------------------#

package P4TriggerHelper;

use strict;
use Error qw(:try);

sub createParams {
    my ($keys,$values) = @_;

    if (@$keys != @$values) {throw IndexError("Mismatched number of keys and values");}

    my %hash;
    @hash{ @$keys } = @$values;

    return \%hash;
}
1;

#-------------------------------------------------------------------------------------#
# Trigger package                                                                     #
#-------------------------------------------------------------------------------------#

package P4Trigger;
use strict;

#-------------------------------------------------------------------------------------#
# Instance initialiser                                                                #
# Params:                                                                             #
#   class    - This is passed by default                                              #
#   params   - The paramater list that is expected                                    #
#   args     - The arguments being passed (as a hash ref)                             #
#-------------------------------------------------------------------------------------#
sub new {
    my ($class,$args) = @_;

    my $self = {
        mailhost => 'mx.i.turbinegames.com',
        errorMailTo => 'root@localhost',
        errorMailFrom => 'perforce@localhost',
        passed => 0,
        failed => 0,
        result => 1,
        args => $args,
    };

    bless ($self, $class);
    return %$self;
}
1;

#-------------------------------------------------------------------------------------#
# Exception packages                                                                  #
#-------------------------------------------------------------------------------------#

package IndexError;

use base qw(Error);
use overload ('""' => 'stringify');
use strict;

sub new {
    my $self = shift;
    my $text = "" . shift;
    my @args = ();
    
    local $Error::Depth = $Error::Depth + 1;
    local $Error::Debug = 1; # Enables storing of stacktrace
    
    $self->SUPER::new(-text => $text, @args);
}
1;
__END__
