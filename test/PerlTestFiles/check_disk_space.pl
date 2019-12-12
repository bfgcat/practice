#begin perl program
# $dirname = ".";
$dirname = "c:";
# $dirname = "\\\\re-mirror2\\";

system("dir $dirname /s > junk");

open(FILE,"junk");
@_ = <FILE>;
close(FILE);

print "------\n";
print @_;
print "\n-----\n";


$lastline = @_;
$dir_size = @_[$lastline-2];
$disk_remain = @_[$lastline-1];
@fields = split(/ +/,$dir_size);
$_ = $fields[3];

s/,//g; #get rid of commas in the number

print "dir and subdirs are using $_ bytes\n";
@fields = split(/ +/,$disk_remain);
$_ = $fields[3];

s/,//g; #get rid of commas in the number
print "disk free space is $_ bytes\n";

#system("del junk");
#uncomment the line above unless this script has problems
#end perl program