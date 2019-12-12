#!/c/Perl64/bin/perl
#
# File to read in list of pom.xml files and extract a consolidated list of all projects
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

my $source_root = "C:\\dev\\MetadataFramework";
my $now = &formatted_datestring;
my $outFile = "$source_root\\project_packages_MDF_list_$now.txt";
open OUT_FILE, ">$outFile" or die "couldn't open [$outFile]\n";

sub main
{
    print ("Starting...\n\n");

    my $source_root = "C:\\dev\\MetadataFramework";
    
    print OUT_FILE "List of packages from pom.xml files under directory: $source_root\n";
    print OUT_FILE "date: $now\n";
    
    # find all "pom.xml" files under C:\dev\MetraNetDev and put in array.
    findconfig($source_root);
    
    # print all the filenames in our array
    #printlist (@foundfiles);
    
    my @package_array = ();
    my @packages_array = ();
  
    foreach my $file (@foundfiles)
    {        
        #print "checking file: $file\n";
        # Get a reference to a data structure of the parsed XML file.
        my $myxml = XMLin( $file );
    
        # Review data structure format (used during development)
        #print "-------------------------------\n";
        #print Dumper($myxml);
       
        # project, step, command 
        #my $packages = $myxml->{package};   
        my $dependencies = $myxml->{dependencies}->{dependency};
        if ("$dependencies" ne "" )
        {
            # if there is only one dependency in the file we get a hash error since no array element. How do we test for that condition?
            if ("$file" eq "C:\\dev\\MetadataFramework\\metanga\\performance\\pom.xml")
            {
                my $artifactID = $myxml->{dependencies}->{dependency}->{artifactId};
                my $version = $myxml->{dependencies}->{dependency}->{version};
                my $groupID = $myxml->{dependencies}->{dependency}->{groupId};
                #print "\tFound: $artifactID - $version\n";
                my @package_set = ($artifactID, $version, $groupID);
                test_and_set_package_list(@package_set);
                next; # $file
            }
            
            my $i = 0;
            my $artifactID = $myxml->{dependencies}->{dependency}->[$i]->{artifactId};
            my $version = $myxml->{dependencies}->{dependency}->[$i]->{version};
            my $groupID = $myxml->{dependencies}->{dependency}->[$i]->{groupId};
            
            while ( "$artifactID" ne "" )        
            {            
                if ("$groupID" ne "" && "$version" ne "" && "$artifactID" ne "")
                {
                    #print "\tFound: $artifactID - $version\n";
                    my @package_set = ($artifactID, $version, $groupID);
                    test_and_set_package_list(@package_set);
                }
                else
                {
                    print "Incomplete set of identifiers found in file: $file\n";
                }
                
                $i++;
                $groupID = $myxml->{dependencies}->{dependency}->[$i]->{groupId};
                $version = $myxml->{dependencies}->{dependency}->[$i]->{version};
                $artifactID = $myxml->{dependencies}->{dependency}->[$i]->{artifactId};
                
            } # while
        }
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
        my $pstring = sprintf ("%40s\t%10s\t%15s\n", $packages_list[$i][0], $packages_list[$i][1], $packages_list[$i][2]);
        print $pstring;
        print OUT_FILE $pstring;
    }
    print "\nTotal unique packages: $num_packages\n"
}

sub test_and_set_package_list
{
    my @package_set = @_;
    if (!package_set_in_list(@package_set))
    {
        add_package_set_to_list(@package_set);
        #print "\t\tAdded\n";
    }
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
    
    print "\n";
    
    return;
}

sub findconfig
{
    # uses global @files array
    # input should be a directory
    # purpose: find all pom.xml in directory
    # if filename is pom.xml, prepend the source_dir name and add to @files array
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
        if ( $file eq "pom.xml" )
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