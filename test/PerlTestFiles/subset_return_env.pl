sub GetEnvironmentVariableValue
{
    # input: string containing an ENV variable name
    #
    # If ENV variable exists, return the value, else return the original string
    # Continue to evaluate until string contains no more "known" strings,
    # 
    my $variable = shift;
    my $value;

    if (exists $ENV{$variable})
    {
        $value = $ENV{$variable};
        
        # test if returned value has another %string% in it
        if ( $value =~ m/%([^%]+)%/ )
        {
            $value = EvaluateEnvironmentVariables($value);
        }
        
        return $value;
    }

    return '%'.$variable.'%';
}

sub EvaluateEnvironmentVariables
{
    # input: string which may contain %ENV_VAR% substring
    #
    # if input string contains %VAR_NAME% string, replace the variable with it's environment value
    # repeat until no more %STRING% strings or the ENV in %STRING% is not defined
    my $value = shift;

    if ( defined $value )
    {
        $value =~ s/%([^%]+)%/GetEnvironmentVariableValue($1)/ge;
    }

    return $value;
}

sub ProcessEnvironmentVariables
{
    # input to this routine as an array
    my $variables = shift;

    foreach my $envVar (@{$variables})
    {
        $ENV{$envVar->{variableName}} = EvaluateEnvironmentVariables($envVar->{value});
    }
}

