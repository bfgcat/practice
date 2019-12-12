#!/usr/bin/perl -w

use strict;
use warnings;

use lib::P4::P4Mod;

#my $workspace = "RE_weekly_cleanup";
my $workspace = "RE_weekly_cleanup_test";

my $hendrix_port = "perforce-hendrix:1666";
# my $hendrix_port = "perforce-turbine:1666";

sub main {
    my ($game, $branch) = @_;
    
    my $count = 0;
    my $oblit_count = 0;
    my $deleted_count = 0;
        
    ###my $oblit_label = "OBLIT_NEXT";
    
    # games in hendrix_depot
    my @hendrix_depot_games = ("hendrix", "ronin", "nexus", "ares");
    # if ( grep $_ eq "$testtag", @tags)
    
    # derive path and port from game and branch
    my $parentpath = "//deployment/$game";
    my $path = "//deployment/$game/$branch";
    my $port = "";
    
    if ( grep $_ eq "$game", @hendrix_depot_games)
    {
        $port = $hendrix_port; 
    }
    else
    {
        die "ABORTING! Attempting to run on non-supported game: $game!";
    }
    
    print "Game: $game\nBranch: $branch\nPort: $port\n\n";
    
    if ("$branch" eq "hendrix_pre" || "$branch" eq "hendrix_live") { die "ABORTING! Attempting to run on protected branch!"; }
    
    {
        print "Part 1 - Oblit files in with build tag/label OBLIT_*\n";
        # PART 1 - Obliterate files in //deployment/<game>/<branch>/*
        #    directories with no build tag matching label
        
        # get list of labels that start with OBLIT_
        my $label_args = "-e OBLIT_*";
        my @label_structs = P4Mod::Labels($port, $label_args);
        # get just the label elements
        my @oblit_labels = ();
        for (my $i = 0; $i < scalar(@label_structs); $i++)
        {
            push @oblit_labels, $label_structs[$i]->{label};
        }    
        # printlist(@labels);
        if ( scalar @oblit_labels > 0 )
        {
            foreach my $oblit_label (@oblit_labels)
            {
                # get all files with tag OBLIT_NEXT
                my $label_path = "$path/...\@$oblit_label";
                my @files = P4Mod::Files($port, "$label_path");
            
                # for each file get it's build tag
                foreach my $file (@files)
                {
                        $oblit_count++;
                        print "p4 -p $port obliterate -y $file->{depotFile}#$file->{rev}\n";
                        print `p4 -p $port obliterate -y $file->{depotFile}#$file->{rev}`;
                }
                
                # now delete the label so we don't have hundreds in the DB
                # since a label could be assigned to files from other branches only delete if it's count is 0
                $label_path = "$parentpath/...\@$oblit_label";
                @files = P4Mod::Files($port, "$label_path");
            
                unless ( scalar @files > 0 )
                {
                    my $del_label_args = "-d $oblit_label";
                    P4Mod::Label($port, $del_label_args);
                }
            }
        }
        print "Part 1 - END\n\n";
    }
    
    {
        print "Part 2 - Mark for oblit and delete, files in patch directories if corresponding build tag label does not exist\n";
        # PART 2 - Mark for oblit files in //deployment/<game>/<branch>/<named directories>
        #    with no build tag matching label
        # get all labels that start with $branch
        # put all build tags for each label in @build_tags
        my $label_args = "-e $branch*";
        my @label_structs = P4Mod::Labels($port, $label_args);
        # get just the label elements
        my @labels = ();
        for (my $i = 0; $i < scalar(@label_structs); $i++)
        {
            push @labels, $label_structs[$i]->{label};
        }    
        # printlist(@labels);
        
        # get the build tag portion of the label
        my @build_tags = ();
        for ( my $i = 0; $i < scalar(@labels); $i++)
        {
            push @build_tags, $labels[$i] =~ m/\w+-(\d{4}\.\d{4}\.\d{4}\.\d{4})/; 
        }
        # printlist(@build_tags);
        
        # Run on all supported patch directories, not on client, launcher, etc. dirs
        my @subdirs = qw/patch patch_internal/;
        
        my $delcount = 0;
        foreach (@subdirs)
        {
            my $patchpath = "$path/$_";
            # get all files in //deployment/<game>/<branch>/$_ directory
            my @files = P4Mod::Files($port, "$patchpath/*");
            my $fcount = scalar(@files);
            
            print "Files being checked: $fcount\n";
            
            # for each file get it's build tag
            foreach my $file (@files)
            {
                $count++;
                my $btag = get_tag_from_filepath($file->{depotFile});
                # if btag is blank, skip to next
                if ( $btag eq "" ) { next; }
                
                # if file's build tag is not in @build_tags oblit all revs of the file
                if ( ! grep $_ eq "$btag", @build_tags)
                {
                    # mark for purge all revs of the file
                    my @revs = P4Mod::Files($port, "-a $file->{depotFile}");
                    foreach my $filerev (@revs)
                    {
                        if ( defined $filerev && $filerev && "$filerev->{depotFile}" ne "" )
                        {
                            
                            $delcount++;
                            my $oblit_label = get_oblit_label($port, $filerev->{rev});
                            print "p4 -p $port -u build tag -l $oblit_label $filerev->{depotFile}#$filerev->{rev}\n";
                            print `p4 -p $port -u build tag -l $oblit_label $filerev->{depotFile}#$filerev->{rev}`;
                        }
                    }
                    
                    # mark files for delete in workspace
                    print "p4 -p $port -c $workspace -u build delete -v $file->{depotFile}\n";
                    print `p4 -p $port -c $workspace -u build delete -v $file->{depotFile}\n`;
                }
            }
        }
        
        if ($delcount > 0 )
        {
            # submit default changelist with deleted files
            print "\nSUBMIT:\np4 -p $port -c $workspace -u build submit -d \"[RE] Branch cleanup tool, part 1\"\n";
            print `p4 -p $port -c $workspace -u build submit -d \"[RE] Branch cleanup tool, part 1\"\n`;
        }
        
        $deleted_count += $delcount;
        
        print "Part 2 - END\n\n";
    }
    
    
    my @deleted_files = ();
    
    {
        print "Part 3 - Obliterate any rev of a file in //deployment/<game>/<branch>/... that does not have a label\n";
        # PART 3 - Mark for oblit and delete any rev of a file in //deployment/<game>/<branch>/... that does not have a label
        # get all files in //deployment/<game>/<branch>/...
        my @files = P4Mod::Files($port, "$path/...");
        my $fcount = scalar(@files);
        
        my $delcount = 0;
        
        print "Files being checked: $fcount\n";
        
        # for each file get all revs of the file
        
        foreach my $file (@files)
        {
            # if this is a manifest file, skip and go to the next file.
            if ( $file =~ m/^manifest\w*.xml/ ) { next; }
            
            # if any rev of the file is action type delete, save the file to @deletelist and go on to next file
            my @revs = P4Mod::Files($port, "-a $file->{depotFile}");

            my $del_file = 0;
            foreach my $filerev (@revs)
            {
                $count++;
                if ( defined $filerev && $filerev && "$filerev->{action}" eq "delete")
                {
                    # print "file with deleted rev: $filerev->{depotFile}#$filerev->{rev}\n";
                    push @deleted_files, $file;
                    $del_file = 1;
                    last;
                }
            }
            
            # if file was NOT moved to deleted_files list test number of labels
            if ( ! $del_file)
            {
                # foreach filerev if file#rev has no labels, label with OBLIT_NEXT
                my $revcount = scalar @revs;
                my $last_rev = $revs[0];
                foreach my $filerev (@revs)
                {
                    $count++;
                    if ( defined $filerev && $filerev && "$filerev->{depotFile}" ne "" )
                    {
                        my @file_labels = P4Mod::Labels($port, "$filerev->{depotFile}#$filerev->{rev},$filerev->{rev}");
                        my $num_labels = scalar(@file_labels);
                        # print "num labels: $num_labels\tfile: $filerev->{depotFile}#$filerev->{rev},$filerev->{rev}\n";
                        if (! $num_labels > 0 )
                        {
                            $delcount++;
                            my $oblit_label = get_oblit_label($port, $filerev->{rev});
                            print "p4 -p $port -u build tag -l $oblit_label $filerev->{depotFile}#$filerev->{rev}\n";
                            print `p4 -p $port -u build tag -l $oblit_label $filerev->{depotFile}#$filerev->{rev}`;
                            # if the filerev to be deleted is the last rev of the file, mark it for delete.
                            if ( $filerev->{rev} eq $last_rev->{rev} )
                            {
                                # mark files for delete in workspace
                                print "p4 -p $port -c $workspace -u build delete -v $filerev->{depotFile}\n";
                                print `p4 -p $port -c $workspace -u build delete -v $filerev->{depotFile}\n`;
                            }
                        }
                    }
                }
            }
        }
        
        if ($delcount > 0 )
        {
            # submit default changelist with deleted files
            print "\nSUBMIT:\np4 -p $port -c $workspace -u build submit -d \"[RE] Branch cleanup tool, part 2\"\n";
            print `p4 -p $port -c $workspace -u build submit -d \"[RE] Branch cleanup tool, part 2\"\n`;
        }
        
        $deleted_count += $delcount;
        
        print "Part 3 - END\n\n";
    }
    
    # printlist(@deleted_files);
    my $num_del_files = scalar(@deleted_files);
    print "\nNumber files with deleted rev(s): $num_del_files\n";
    ## for (my $i = 0; $i < scalar(@deleted_files); $i++)
    #for (my $i = 0; $i < 50; $i++)
    #{
    #    print "$deleted_files[$i]->{depotFile}\n";
    #}
    
    print "\nTotal individual files and revs of files examined: $count\n";
    print "\nTotal files purged: $oblit_count\n";
    print "\nTotal files marked for next purge: $deleted_count\n";
    
##### Skip trying to deal with files that have a deleted rev ####
#    {
#        print "Part 4 - Obliterate any rev of a file in //deployment/<game>/<branch>/... that does not have a label\n";
#        # PART 4 - files with a deleted rev.
#        # for now, do not obliterate the rev that is of action type delete
#        # if the deleted rev is NOT the latest rev, skip this file and go on to the next file
#        # if the deleted rev is the latest rev, skip this rev and start with next rev
#        # for each rev if file#rev has no labels obliterate it
#        print "Part 3 - END\n\n";
#    }

}

sub printlist  {
    my @inlist = @_;
    
    print ("# elements:" . scalar(@inlist) . "\n");
    for (my $i = 0; $i < scalar(@inlist); $i++) {
        print ($i . "\t" . $inlist[$i] . "\n");
    }
    
    print ("\n");
}

sub get_tag_from_filepath {
    my ($filename) = @_;
    
    # get the build number portion of the label
    my ($mytag) =$filename =~ m"\/(\d{4}\.\d{4}\.\d{4}\.\d{4})";
    # print ("file: $filename\tbuild tag:" . $mytag . "\n");
    return($mytag);  
}

sub get_oblit_label {
    my ($port, $rev) = @_;
    
    # check if a label with OBLIT_$rev already exists. if so return it

    my $mylabel = "OBLIT_$rev";
    # my $labels_args = "-e \"OBLIT_$rev\"";
    # my @file_labels = P4Mod::Labels($port, $labels_args);
    # my $num_labels = scalar(@file_labels);
    # if ( $num_labels < 1 )
    # {
    #     print "p4 -p $port -u build label -o $mylabel | p4 -p $port -u build label -i";
        print `p4 -p $port -u build label -o $mylabel | p4 -p $port -u build label -i`;
    # }
    
    
    return $mylabel;
}

exit main(@ARGV);
