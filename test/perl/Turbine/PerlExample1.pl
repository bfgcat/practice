#!/c/Perl64/bin/perl
#
# Using ActivePerl from ActiveState
# > perl -v
# This is perl 5, version 12, subversion 2 (v5.12.2) built for
# MSWin32-x64-multi-thread # (with 8 registered patches, see perl -V
# for more detail)
# 


# Brian Gillespie
# Release Engineering Candidate
# 30 Sep 2010

# Turbine Tech Test From PerlQuestion1.txt
# Using a Perl script parse the file SettingsTEST.xml and identify each
# section that has the variable nozip="1". Then output the directory structure
# as shown in the example below.
# 
# Example XML
#     <Component name="game_client" nozip="1">
#       <directory name="config\">
#         <file>ProjectVersion</file>
#       </directory>
#       <directory name="data\">
#         <file>client_foo_*.dat</file>
#         <file>client_foo1_*.dat</file>
#         <file>client_foo2.dat</file>
#         <file installerFlags="recursesubdirs createallsubdirs">browser\*</file>
#       </directory>
#     </Component>
# 
# 
# Example Output
# 
# {root of output directory}
#    ----- game_client
#         ---- config
#         ---- data
#    ----- {next Component}
#         ---- {next Component dir}
# 

#===============================================================================
#
#  *** NOTE ***
#
# The original settingsTEST.xml file looks like it has an error. While it is
# syntactically correct, the initial Component element, "game client", appears
# to have had it's terminator, </Component>, moved to near the end of the file.
#
# Based in this assumption, I have moved the line in question to before the next
# Component in the file, "game_client_language" and saved the fixed file as
# "settingsTESTfixed.xml".
#
#===============================================================================


# Use modules
use Cwd;
use XML::Simple;
# use Data::Dumper;

# my $filename = 'settingsTEST.xml';
my $filename = 'settingsTESTfixed.xml';

# Get a reference to a data structure of the parsed XML file.
my $myxml = XMLin( $filename );

# Review data structure format (used during developemnt)
# print Dumper($myxml);

# Get root of run directory
print getcwd()."\n";

# Get top level Component reference
my $components = $myxml->{Component};
foreach my $component (keys %{$components})
{
    # for each 'Component' check if it has a nozip element and if it is set to 1
    if ( exists $components->{$component}->{nozip} &&  $components->{$component}->{nozip} eq '1' )
    {
        print "----- $component\n";
        # get each directory element and print it out
        foreach my $directory (keys %{$components->{$component}->{directory}} )
        {
            print "     ---- $directory\n";
        }
    }
}

