use strict;
use warnings;

use XML::Simple;
use File::Spec;
use Getopt::Long;

my $projectSettingsFile = File::Spec->catfile('config', 'ProjectSettings.xml');
my $projectSettingsFilePath;
my $projectSettingsXml;

my $userSettingsFile = File::Spec->catfile('config', 'UserSettings.xml');
my $userSettingsFilePath;
my $userSettingsXml;

my @projectBaseDirs;
my $volume;
my $directories;
my $g_sdkPath;
my $g_useSDKPath = 1;

my ($path, $perl, $env);

GetOptions
(
    "path" => \$path,
    "perl" => \$perl,
    "env"  => \$env,
);


foreach my $path ((File::Spec->rel2abs('.'), $0))
{
    # the 1 passed to splitpath here is for 'no file', otherwise on windows,
    # it treats the last part of the path as a file, even if it's a directory
    ($volume, $directories) = File::Spec->splitpath($path, 1);
    @projectBaseDirs = File::Spec->splitdir($directories);
    while (@projectBaseDirs and !-e File::Spec->catfile($volume, @projectBaseDirs, $projectSettingsFile))
    {
        pop(@projectBaseDirs);
    }
    last if(@projectBaseDirs);
}

if(@projectBaseDirs)
{
    $projectSettingsFilePath = File::Spec->catfile($volume, @projectBaseDirs, $projectSettingsFile);
    $userSettingsFilePath = File::Spec->catfile($volume, @projectBaseDirs, $userSettingsFile);

    $projectSettingsXml = eval
    {
        XMLin( $projectSettingsFilePath,
               ForceArray => ['BinDir', 'LibDir', 'variable', 'setting'] ) 
    } if(-e $projectSettingsFilePath);

    if ($@)
    {
        print "\n\nThere was an error parsing ProjectSettings.xml:\n$@\n\n";
        print "Please correct the file and then relaunch the build shell.\n\n";
        print "Press any key to close this window...";
        `pause`;
        exit(1);
    }
    if ( !defined( $projectSettingsXml ) )
    {
        print "\n\nNo project settings were found.\n\n";
        print "Please insure that your dev tree is synced up and relaunch the build shell.\n\n";
        print "Press any key to close this window...";
        `pause`;
        exit(1);
    }

    $userSettingsXml = eval
    { 
        XMLin( $userSettingsFilePath, 
               ForceArray => ['BinDir', 'LibDir', 'variable', 'setting'] )
    } if(-e $userSettingsFilePath);

    if ($@)
    {
        print "\n\nThere was an error parsing UserSettings.xml:\n$@\n\n";
        print "Please correct the file and then relaunch the build shell.\n\n";
        print "Press any key to close this window...";
        `pause`;
        exit(1);
    }

    $g_sdkPath = File::Spec->catfile($volume, @projectBaseDirs, "sdk" );

    if( defined( $userSettingsXml ) )
    {
        if( defined( $userSettingsXml->{EnvironmentVariables}->{variable} ) )
        {
            foreach my $envVar (@{$userSettingsXml->{EnvironmentVariables}->{variable}})
            {
                if( $envVar->{variableName} eq "PROJECT_SDK_PATH" )
                {
                    $g_sdkPath = $envVar->{value};
                }
            }
        }
    }
    $ENV{"PROJECT_SDK_PATH"} = $g_sdkPath;

    my @buildPathVariable = ( { 'variableName' => "BUILD_PATH", 'value' => '%PROJECT_SDK_PATH%\build\%BUILD_VERSION_EXTERNAL_SDK%' } );
    ProcessEnvironmentVariables( \@buildPathVariable );

    #############################################
    ## set up the environment variables...

    my @envVars;

    if ( $env )
    {
        foreach my $envVar ( @buildPathVariable )
        {
            print "set $envVar->{variableName}=$ENV{$envVar->{variableName}}\n";
        }

        if(defined($userSettingsXml))
        {
            if(defined($userSettingsXml->{EnvironmentVariables}->{variable}))
            {
                ProcessEnvironmentVariables( \@{$userSettingsXml->{EnvironmentVariables}->{variable}} );
                foreach my $envVar (@{$userSettingsXml->{EnvironmentVariables}->{variable}})
                {
                    print "set $envVar->{variableName}=$ENV{$envVar->{variableName}}\n";
                }
            }
        }

        if (defined($projectSettingsXml->{EnvironmentVariables}->{variable}))
        {
            ProcessEnvironmentVariables( \@{$projectSettingsXml->{EnvironmentVariables}->{variable}} );
            foreach my $envVar (@{$projectSettingsXml->{EnvironmentVariables}->{variable}})
            {
                print "set $envVar->{variableName}=$ENV{$envVar->{variableName}}\n";
            }
        }

    }
    ## end setup of env vars...
    ###############################################

    ###############################################
    ## set up the user's path...
    my @binDirs;

    foreach my $binDir (@{$projectSettingsXml->{SDKDepotBinarySettings}->{BinDir}})
    {
        CanonizeAndAddPath( $binDir, \@binDirs );
    }
    foreach my $binDir (@{$projectSettingsXml->{BinarySettings}->{BinDir}})
    {
        CanonizeAndAddPath( $binDir, \@binDirs );
    }

    if(defined($userSettingsXml))
    {
        if(defined($userSettingsXml->{BinarySettings}->{BinDir}))
        {
            foreach my $userBinDir (@{$userSettingsXml->{BinarySettings}->{BinDir}})
            {
                CanonizeAndAddPath( $userBinDir, \@binDirs );
            }
        }
    }

    $ENV{"PATH"} = $ENV{"PATH"} . ";" . join(';', @binDirs);

    if ( $path )
    {
        print ( $ENV{"PATH"} );
    }

    ## end path setup...
    #############################################

    #############################################
    ## set up the perl site lib...

    my @perlLibDirs;

    foreach my $perlLibDir (@{$projectSettingsXml->{PerlSettings}->{LibDir}})
    {
        CanonizeAndAddPath( $perlLibDir, \@perlLibDirs );
    }

    if(defined($userSettingsXml))
    {
        if(defined($userSettingsXml->{PerlSettings}->{LibDir}))
        {
            foreach my $userPerlLibDir (@{$userSettingsXml->{PerlSettings}->{LibDir}})
            {
                CanonizeAndAddPath( $userPerlLibDir, \@perlLibDirs );
            }
        }
    }

    if(@perlLibDirs)
    {
        $ENV{'PERL5LIB'} = join(';', @perlLibDirs);
        push(@INC, @perlLibDirs);

        if ( $perl )
        {
            print ( $ENV{"PERL5LIB"} );
        }
    }

    ## end setup of user's site lib...
    ###############################################

    print ("\n");
}

sub CanonizeAndAddPath
{
  my $pathToAdd = EvaluateEnvironmentVariables(shift);
  my $validPaths = shift;
    
  # starts with a drive letter, let it through
  if($pathToAdd =~ /^.:/)
  {
    push(@$validPaths, File::Spec->canonpath($pathToAdd));
  }
  # starts with a backslash, let it through, but add volume
  elsif($pathToAdd =~ /^\\/)
  {
    push(@$validPaths, File::Spec->catfile($volume, $pathToAdd));
  }
  # relative path
  else
  {
    push(@$validPaths, File::Spec->catfile($volume, @projectBaseDirs, $pathToAdd));
  }
}

sub GetEnvironmentVariableValue
{
    my $variable = shift;

    if (exists $ENV{$variable})
    {
        return $ENV{$variable};
    }

    return '%'.$variable.'%';
}

sub EvaluateEnvironmentVariables
{
    my $value = shift;

    $value =~ s/%([^%]+)%/GetEnvironmentVariableValue($1)/ge;

    return $value;
}

sub ProcessEnvironmentVariables
{
    my $variables = shift;

    foreach my $envVar (@{$variables})
    {
        $ENV{$envVar->{variableName}} = EvaluateEnvironmentVariables($envVar->{value});
    }
}
