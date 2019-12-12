#!/usr/bin/perl -w
use Getopt::Long;                   ## Obtain the user options
use File::Copy;
use Win32;
use Win32::OLE 'in';

# Forward declare
sub ParseDirectory( $ );
sub FileFilter( $$ );

# Depth
$currentDepth = 1;
$maxDepth = 6;

## Options
my $help;
my $initdir;
my $rollback;
my $verbose;
my $force;

# Directory Exclusion
my @excludedDirectories = ( "ProgramData",
                            "Recycle.Bin", 
                            "Recovery",
                            "System Volume Information",
                            "Users",
                            "Windows" );

## GetOptions
## Assign the command line parameters to the appropriate variables
GetOptions( "h|help"  => \$help,
            "d|dir=s"  => \$initdir,
            "force" => \$force,
            "rollback" => \$rollback,
            "verbose"  => \$verbose );


###############################################################################
#                          MAIN
###############################################################################

if( $help )
{
  print"
   Usage:
     P4ConfigUpdate.pl - Finds p4.cfg files and if P4PORT is perforce-lotro:1666
                          or perforce01:1666 changes it to perforce-lotro:2666
     
     -h|help   Displays this message.
     -d|dir    Sets the initial directory to be scanned for p4.cfg
               files. If this is not provided all drives will be
               searched.
     -force    Updates configurations even if a backup is present.
     -rollback Will rollback any p4.cfg file encountered if it has
               been backed up by a previous run of the script.
     -verbose  Provides additional output while searching.
    ---------------------------------------------------------------\n\n";
    exit;
}

# Populate listing of valid fixed drives
my @driveTypeEnum = ( "Unknown", "Removable", "Fixed", "Network", "CDRom", "Ram Disk" );
my $fileSystem = Win32::OLE->new( "Scripting.fileSystemObject" );
my $drives = $fileSystem->Drives;

my @validDrives;
foreach my $drive ( in($drives) )
{
  if( $driveTypeEnum[ $drive->{DriveType} ] eq "Fixed" )
  {
    push( @validDrives, $drive->{DriveLetter} );
  }
}

# If the a single directory is provided only walk that directory
if( $initdir )
{
  if( -d $initdir )
  {
    # Verify that the directory provided is on a fixed drive on this system
    my $onValidDrive;
    foreach( @validDrives )
    {
      if( $initdir =~ /$_:/i )
      {
        $onValidDrive = 1;
      }
    }

    unless( $onValidDrive )
    {
      print "Directory is not on a local fixed drive!\n";
      exit;
    }
    
    # There is a bug/odd behavior when using readdir on a subset of directories:
    #  When drive letters are present they must be entered in the format 'E:\\'. If
    #  the letter comes in as 'E:' readdir will open the current working directory.
    $initdir =~ s/(^\w:$)/$1\\/;
    ParseDirectory( $initdir );
  }
  else
  {
    print "Invalid directory provided: $initdir\n";
  }
  exit;
}

foreach( @validDrives )
{
  # Parse the initial directory
  ParseDirectory( $_ . ":\\" );
}

###############################################################################


## Opening the directory, and all sub directories, depth first
sub ParseDirectory( $ )
{
  my $dir = shift;
  
  if( $currentDepth > $maxDepth )
  {
    return;
  }

  # Ignore the . and .. directories
  if( $dir =~ /\.|\.\./ )
  {
    return;
  }
  
  # Ignore any directories in our exclusion list
  foreach ( @excludedDirectories )
  {
    if( $dir =~ /$_$/i )
    {
      if( $verbose )
      {
        print "$dir\\... \n\tmatched exclusion filter: ( $_ )\n";
      }
      return;
    }
  }

  if( $verbose || $currentDepth == 2 )
  {
    print "$dir\\...\n";
  }

  # Verify that this is a directory that exists
  if( -d $dir )
  { 
    # Open the directory
    unless( opendir( DIRECTORY, "$dir" ) )
    {
      print "\tCould not open: \"$dir\"\n";
      return;
    }
    
    # Pull out the contents of the directory
    my @dirContent = readdir( DIRECTORY );
    
    foreach my $dirContent ( @dirContent )
    {
      if( -d "$dir\\$dirContent" )
      {
        $currentDepth++;
        ParseDirectory( "$dir\\$dirContent" );
        $currentDepth--;
      }
      elsif( -e "$dir\\$dirContent" )
      {
        FileFilter( $dir, $dirContent );
      }
    }
      
    close( DIRECTORY );
  }
}

sub FileFilter( $$ )
{
  my ( $dir,$dirContent )= @_;
  my $fullPath = "$dir\\$dirContent";

  if( $dirContent =~ /^p4\.cfg$/i )
  {
    if( $rollback )
    {
      RollbackP4Config( $fullPath );
    }
    else
    {
      BackupP4Config( $fullPath );
      UpdateP4Config( $fullPath );
    }
  }
}

sub BackupP4Config( $ )
{
  my $fullPath = shift;

  # Ignore this check if the force flag is present
  unless( $force )
  {
    # Backup the existing p4.cfg unless a backup already exists
    if( -f $fullPath . ".backup" )
    {
      print "A backup for $fullPath already exists.\n";
      return;
    }
  }

  print "Backing up:\t$fullPath\n";
  copy( $fullPath, $fullPath . ".backup");
}

sub RollbackP4Config( $ )
{
  my $fullPath = shift;

  unless( -f $fullPath . ".backup" )
  {
    print "Cannot rollback for $fullPath, backup does not exist.\n";
    return;
  }

  print "Rolling back:\t$fullPath\n";

  # Replace the existing p4.cfg file with the backup
  copy( $fullPath . ".backup", $fullPath );
}

sub UpdateP4Config( $ )
{
  my $fullPath = shift;

  print "Updating:\t$fullPath\n";

  # Open the file and cache the contents
  unless( open( FILE, "<$fullPath" ) )
  {
    print "ERROR: $! $fullPath \n";
  }
  my @p4ConfigContents;
  while( <FILE> )
  {
    push( @p4ConfigContents, $_ );
  }
  close( FILE );


  # Open the file for write
  unless( open( FILE, ">$fullPath" ) )
  {
    print "ERROR: $! $fullPath \n";
  }
   
  foreach( @p4ConfigContents )
  {
    # Write the new user
    if( $_ =~ /P4PORT\s*=\s*perforce01:1666|P4PORT\s*=\s*perforce-lotro:1666/ )
    {
      # Create the new port entry
      print FILE "P4PORT=perforce-lotro:2666\n";
      next;
    }
    
    # Remove the password by ignoring it
    if( $_ =~ /P4PASSWD/ )
    {
      next;
    }
    

    print FILE $_;
  }
  
   close( FILE );
}

