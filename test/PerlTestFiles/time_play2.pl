#!/c/Perl64/bin/perl
use strict;
use warnings;

sub main
{
    #print &formatted_datestring;
    #print "\n";
    # printf("%04d%02d%02d_%02d%02d%02d", $year, $mon, $mday, $hour, $min, $sec);
    my $today = &formatted_datestring;
    print $today;
    print "\n";
}

sub formatted_datestring
{
    (my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst) = localtime();
    $year += 1900;
    $mon ++;
    if ($mon < 10)
    {
        $mon = "0" . $mon;
    }
    if ($mday < 10)
    {
        $mday = "0" . $mday;
    }
    if ($hour < 10)
    {
        $hour = "0" . $hour;
    }
    if ($min < 10)
    {
        $min = "0" . $min;
    }
    if ($sec < 10)
    {
        $sec = "0" . $sec;
    }
    
    my $datestring = $year . $mon . $mday. "_" . $hour . $min . $sec;
    
    return $datestring;
}

main;