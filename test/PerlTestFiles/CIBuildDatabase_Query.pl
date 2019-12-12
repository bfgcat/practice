#!C:\Perl\bin\perl.exe

use strict;
use warnings;

use DBI();
use IO::File;
use File::Basename;
use File::DosGlob 'glob'; # this module is needed to resolve UNC network path(s) correctly
use File::Spec;
use Sys::Hostname;


sub main
{

    print("Unable to create database connection: invalid connection object returned.");

}

main();
