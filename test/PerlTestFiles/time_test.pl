use strict;
use warnings;

sub timestamp
{
    my @time = localtime();
    my $timestamp;

    my $year = 1900 + $time[5];
    $timestamp = $year . "-" . $time[4] . "-" . $time[3] . " " . $time[2] . ":" . $time[1] . ":" . $time[0];
}

print &timestamp . "\n\n";
