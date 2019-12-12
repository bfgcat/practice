use strict;
use warnings;

my @time = localtime();
foreach (@time)
         {
            print $_ . "\n";
         }

# my @week = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");

# my @mYear = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");

my $timestamp;

my $year = 1900 + $time[5];
# $serverStr = $week[$time[6]] . ", " . $time[3] . " " . $mYear[$time[4]] . " " . $year . " " . $time[2] . ":" . $time[1] . ":" . $time[0];

# print $serverStr."\n\n";

$timestamp = $year . "-" . $time[4] . "-" . $time[3] . " " . $time[2] . ":" . $time[1] . ":" . $time[0];

print $timestamp."\n\n";
