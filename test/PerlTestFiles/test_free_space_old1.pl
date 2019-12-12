use strict;
use warnings;

use Win32::DriveInfo;


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

my $drive = 'c:';
my ($SectorsPerCluster,
$BytesPerSector,
$NumberOfFreeClusters,
$TotalNumberOfClusters,
$FreeBytesAvailableToCaller,
$TotalNumberOfBytes,
$TotalNumberOfFreeBytes) = Win32::DriveInfo::DriveSpace($drive);

print "Drive being checked: $drive\n
    SectorsPerCluster: $SectorsPerCluster\n
    BytesPerSector: $BytesPerSector\n
    NumberOfFreeClusters: $NumberOfFreeClusters\n
    TotalNumberOfClusters: $TotalNumberOfClusters\n
    FreeBytesAvailableToCaller: $FreeBytesAvailableToCaller\n
    TotalNumberOfBytes: $TotalNumberOfBytes\n
    TotalNumberOfFreeBytes:$TotalNumberOfFreeBytes\n";

my $dtype = Win32::DriveInfo::DriveType($drive);
print "drive type: m$dtype\n\n";

$drive= '\\\\bgillespie\downloads';
($SectorsPerCluster,
$BytesPerSector,
$NumberOfFreeClusters,
$TotalNumberOfClusters,
$FreeBytesAvailableToCaller,
$TotalNumberOfBytes,
$TotalNumberOfFreeBytes) = Win32::DriveInfo::DriveSpace($drive);

print "Drive being checked: $drive\n
    SectorsPerCluster: $SectorsPerCluster\n
    BytesPerSector: $BytesPerSector\n
    NumberOfFreeClusters: $NumberOfFreeClusters\n
    TotalNumberOfClusters: $TotalNumberOfClusters\n
    FreeBytesAvailableToCaller: $FreeBytesAvailableToCaller\n
    TotalNumberOfBytes: $TotalNumberOfBytes\n
    TotalNumberOfFreeBytes:$TotalNumberOfFreeBytes\n";

my $dtype = Win32::DriveInfo::DriveType($drive);
print "drive type: m$dtype\n\n";

$drive= '\\\\re-mirror2\mirrors';
($SectorsPerCluster,
$BytesPerSector,
$NumberOfFreeClusters,
$TotalNumberOfClusters,
$FreeBytesAvailableToCaller,
$TotalNumberOfBytes,
$TotalNumberOfFreeBytes) = Win32::DriveInfo::DriveSpace($drive);
print "Drive being checked: $drive\n
    SectorsPerCluster: $SectorsPerCluster\n
    BytesPerSector: $BytesPerSector\n
    NumberOfFreeClusters: $NumberOfFreeClusters\n
    TotalNumberOfClusters: $TotalNumberOfClusters\n
    FreeBytesAvailableToCaller: $FreeBytesAvailableToCaller\n
    TotalNumberOfBytes: $TotalNumberOfBytes\n
    TotalNumberOfFreeBytes:$TotalNumberOfFreeBytes\n";

my $dtype = Win32::DriveInfo::DriveType($drive);
print "drive type: m$dtype\n\n";

print "\n-------------------------------------\n\n";
