#!/c/Perl64/bin/perl
#
# File to read in list of packages.conf files and extract a consolidated list of all projects
#

# Use modules
use XML::Simple;
use Data::Dumper;

# GLOBAL Vars
my $proj_num = 0;
my $cmd_num = 0;
my @projectArray = ();
my @stepArray = ();

my $flagFile = 0;
my $flagProject = 0;
my $flagStep = 0;
my $flagLine = 0;

my $package_sets = ();
my @foundfiles = ();

my @packages_list;
my $num_packages = 0;
    
#my $source_root = "C:\\dev\\MetraNetDev\\CoreQA";
my $source_root = "C:\\dev\\MetraNetDev";

my $now = &formatted_datestring;
my $outFile = "$source_root\\project_packages_MN_list_$now.txt";
open OUT_FILE, ">$outFile" or die "couldn't open [$outFile]\n";

sub main
{
    print ("Starting...\n\n");
    
    print OUT_FILE "List of packages from package.config files under directory: $source_root\n";
    print OUT_FILE "date: $now\n";
    
    # find all "packages.config" files under C:\dev\MetraNetDev and put in array.
    findconfig($source_root);
    
    # print all the filenames in our array
    # printlist (@foundfiles);
    
    my @package_array = ();
    my @packages_array = ();
  
    foreach my $file (@foundfiles)
    {        
        #print "checking file: $file\n";
        # Get a reference to a data structure of the parsed XML file.
        my $myxml = XMLin( $file );
    
        # Review data structure format (used during development)
        print Dumper($myxml);
       
        # project, step, command 
        my $packages = $myxml->{package};    
        
        if ( $packages != 0 )
        {
            my $id = "";
            my $targetFramework = "";
            my $version = "";
            my $got_package_id = 1;
            my $got_package_version = 1;
            my $got_package_target = 1;
            my $got_package_complete = 1;
            my $got_package_part = 1;
            
            foreach my $package (keys %{$packages})
            {               
                if ( "$package" eq "version")
                {
                    $version = $myxml->{package}->{$package};
                    $got_package_version = 0;
                    $got_package_part = 0;
                }
                elsif ( "$package" eq "id")
                {
                    $id = $myxml->{package}->{$package};
                    $got_package_id = 0;
                    $got_package_part = 0;
                }
                elsif ( "$package" eq "targetFramework")
                {
                    $targetFramework = $myxml->{package}->{$package};
                    $got_package_target = 0;
                    $got_package_part = 0;
                }
                else
                {
                    #print "package: $package\n";
                    $id = $package;
                    $version = $myxml->{package}->{$package}->{version};
                    $targetFramework = $myxml->{package}->{$package}->{targetFramework};
                    $got_package_complete = 0;
                }
                
                if ( ($got_package_complete == 0) || ($got_package_version == 0 && $got_package_id == 0 && $got_package_target == 0) )
                {
                    #print "package_id: $id\n";
                    #print "framework:  $targetFramework\n";
                    #print "version:    $version\n";
                    #print "\n";
                    
                    # Add package information to a list if it is not already on the list.
                    
                    $got_package_part = 1;
                    
                    my @package_set = ($id, $targetFramework, $version);
                    if (!package_set_in_list(@package_set))
                    {
                        add_package_set_to_list(@package_set);
                    }
                }
            } # foreach $package
            
            if ($got_package_part == 0)
            {
               print "Got a partial package!\n";
               print "* package_id: $id\n";
               print "* framework:  $targetFramework\n";
               print "* version:    $version\n";
            }
        } # if non-zero packages
    } # foreach found file
    
    #print"\nUnique list of packages:\n";
    print_packages();
    
    print ("\nFinished\n");
}

sub print_packages
{
    ## Sort packages by package name before printing
    for (my $i = 0; $i < $num_packages; $i++)
    {
        my $pstring = sprintf ("%40s %10s %15s\n", $packages_list[$i][0], $packages_list[$i][1], $packages_list[$i][2]);
        print($pstring);
        print OUT_FILE $pstring;
    }
    print "\nTotal unique packages: $num_packages\n"
}

sub package_set_in_list
{
    my @pkg = @_;
    my $pkg_found = 0;
    
    for (my $i = 0; $i < $num_packages; $i++)
    {
        if ( $pkg[0] eq $packages_list[$i][0] && $pkg[1] eq $packages_list[$i][1] && $pkg[2] eq $packages_list[$i][2] )
        {
            $pkg_found = 1;
        }
    }
    
    return $pkg_found;
}

sub add_package_set_to_list
{
    my @pkg = @_;
    $packages_list[$num_packages][0] = $pkg[0];
    $packages_list[$num_packages][1] = $pkg[1];
    $packages_list[$num_packages][2] = $pkg[2];
    
    $num_packages++;
    
    return;
}

sub printlist
{
    my @inlist = @_;
    
    print ("# elements:" . scalar(@inlist) . "\n");
    for (my $i = 0; $i < scalar(@inlist); $i++)
    {
        print (($i + 1) . "\t" . $inlist[$i] . "\n");
    }
    
    return;
}

sub findconfig
{
    # uses global @files array
    # input should be a directory
    # purpose: find all package.config in directory
    # if filename is packages.config, prepend the source_dir name and add to @files array
    # if file is another directory, prepend source_dir name and call findconfig recursively

    my ( $source_dir ) = @_;
        
    opendir (MYDIR, $source_dir) or die $!;
    
    my @files = ();
    while (my $file = readdir(MYDIR))
    {
        # skip filename . and ..
        if ( $file eq "\." || $file eq "\.\." )
        {
            next;
        }
        else
        {
            push @files, $file;
        }
    }
    
    foreach my $file (@files)
    {
        # print "Testing: $source_dir\\$file\n";
        if ( $file eq "packages.config" )
        {
            my $filename = $source_dir . "\\" . $file;
            push @foundfiles, ($filename);
        }
        else
        {
            my $fullfilename = $source_dir . "\\" . $file;
            if ( -d $fullfilename )
            {
                findconfig ( $fullfilename );
            }
        }
    }
    
    return;
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

main ();