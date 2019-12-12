use strict;
use warnings;
 
# detect which OS you are on and use either dir or df

# Test which OS we are on
my $my_OS = $^O;
if ($my_OS eq 'MSWin32')
{
    print "script is running on Windows, $my_OS\n";
}
else
{
    die "script is not running on Windows, value=$my_OS\n";
}
print "\n\n";

my $output = `dir`;

print $output;

print "\n-------------------------------------\n\n";
