#! /usr/bin/perl

use Digest::MD5 qw(md5_hex);
print "Digest is ", md5_hex($ARGV[0]), "\n";
