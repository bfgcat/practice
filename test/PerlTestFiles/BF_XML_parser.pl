#!/c/Perl64/bin/perl
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

# my $filename = 'settingsTEST.xml';
# my $filename = 'export_262.xml'; 
# my $filename = 'export_598.xml';

opendir(DIR, ".");
my @files = grep(/\.xml$/,readdir(DIR));
closedir(DIR);

MAIN:
{
    # print all the filenames in our array
    foreach my $file (@files)
    {
        # Flag to tell if file has an issue that needs to be looked into.
        $flagFile = 0;
        
        my @outLines = ();
        
        # print "checking file: $file";
        # Get a reference to a data structure of the parsed XML file.
        my $myxml = XMLin( $file );
    
        # Review data structure format (used during development)
        # print Dumper($myxml);
       
        # project, step, command 
        my $projects = $myxml->{project};
        if ( $projects != 0 )
        {
            foreach my $project (keys %{$projects})
            {
                $flagProject = 0;
                # print "$project\n";
                my $steps = $myxml->{project}->{$project}->{step};
                if ( $steps != 0 )
                {
                    foreach my $step (keys %{$steps})
                    {
                        $flagStep = 0;
                        @outLines = ();
                        # print "\t$step\n";
                        my $command = $myxml->{project}->{$project}->{step}->{$step}->{command};
                        #print "\t\t$command\n";
                        # reset var names array
                        my @varNames = ();
                        
                        # parse command into lines
                        my @lines = split /\n/, $command;
                        foreach my $line (@lines)
                        {
                            $flagLine = 0;
                            # for each line
                            # print "\t\t$line\n";
                            
                            # if line is a comment, skip it
                            if ( $line =~ m/(^\s*?#)/ )
                            {
                                next;
                            }
                            # does it use any var names identified? If so flag as needs attention
                            foreach my $var ( @varNames )
                            {
                                my $varS = "$var"."SUMMARY";
                                if ( ($line =~ /$var/) && !($line =~ /_$var/) && !($line =~ /$varS/) && !($line =~ /^::/))
                                {
                                    $flagLine = 1;
                                    $flagStep = 1;
                                    $flagFile = 1;
                                    # push ( @outLines, "--$var--" );
                                    # print "\t$step\n";
                                    # print "\t\t$line\n";
                                    # print "**\t\t** above line needs attention!\n";
                                }
                            } # foreach var
                            
                            if ( $flagLine )
                            {
                                push ( @outLines, "**  $line" );
                            }
                            else
                            {
                                push ( @outLines, "    $line" );
                            }
                            
                            my $varName = 0;
                            #if contains .bset env (get var name ex: .bset env "VAR_NAME=xxxxx"
                            if ( !($line =~ /^::/) )
                            {
                                $line =~ m/.bset env "(.*?)=/;
                                $varName = $1;
                            }
                            
                            # if there is something there add it to the varNames array
                            if ( $varName )
                            {
                                # print "\t\t\tvar name: $varName\n"
                                # add var name to var names array
                                push ( @varNames, $varName );
                            };
                        } #foreach line
                        
                        # did we find anything?
                        if ( $flagStep )
                        {
                            # print "\n\n** Use of just defined var found **\n";
                            print "$project\n";
                            # print "  $step\n";
                            foreach my $oline (@outLines)
                            {
                                print "$oline\n";
                            }
                            
                            # if the project is not already on the list, put it there.
                            my $found = 0;
                            foreach my $p (@projectArray)
                            {
                                if ( $p eq  $project )
                                {
                                    $found = 1;
                                }
                            }
                            
                            if ( ! $found )
                            {
                                push ( @projectArray, $project );
                            }
                        }
                    } #foreach step
                }
            } # foreach project
        }
        
        # did we find anything in this file?
        if ( $flagFile )
        {
            # print "File with errors: $file\n\n";
        }
        else
        {
            # print "\tOK\n";
        }
    } # foreach file
    print "\n\nSummary of project or libraries found.\n";
    foreach my $project (@projectArray) { print "$project\n" };
    my $num_projs = @projectArray;
    print "\nTotal number: $num_projs\n";
}

