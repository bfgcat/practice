#!/c/Perl64/bin/perl

use IO::File;

# Files
my $infile = 'BFD_MA_excel_1.txt';
my $outfile = 'MA_datalist.csv';

# open file for read
my $fh = IO::File->new("$infile");
defined $fh || die "Unable to open file for reading: $infile\nError: $!\n";

# open output file
my $fhout = IO::File->new(">$outfile");
defined $fhout || die "Unable to open file for writing: $outfile\nError: $!\n";

# print comma seperated header line
$fhout->print("First Name,MI,Last Name,Certificates,address1,address2,City,State,Zip,Company,Designee Since,Phone,Email\n");

# Format of input file, examples:
# --------------------------------
# Jayne Abbott, CLTC
# 75 Second Ave
# Ste 710
# Needham, MA. 02494
# Company: Mass Mutual
# Designee since: February 2010
# Phone number: (781)292-3303
# Email: jayneabbott@massmutual.com
# David J Abercrombie, CLTC
# 477 Route 6A
# East Sandwich, MA. 02537
# Company: Aspen Cross Financial Group
# Designee since: July 2013
# Phone number: (508)888-3715
# Email: dabercrombie@aspencross.com
# Francis Addonizio, CLTC, CFP, CRPC;
# 175 Andover Street
# Suite 201
# Danvers, MA. 01923
# Company: Ameriprise Financial
# Designee since: September 2011
# Phone number: (877)524-5522
# Email: frank.x.addonizio@ampf.com


# continue until end of file
while( <$fh> ) 
{
	my $got_address = 0; # false
	
	while ( ! $got_address )
	{
		# read the first 4 lines
		my $line1 = $_;
		my $line2 = <$fh>;
		my $line3 = <$fh>;
		my $line4 = <$fh>;
		
		# chop off the last character, the EOL character, else split() returns
		# an extra element
		chomp $line1;
		chomp $line2;
		chomp $line3;
		chomp $line4;
		
		my $name = $line1;
		my $addr1 = $line2;
		my $addr2 = "";
		my $city_state_zip = "";
		my $company = "";
		
		# Either line 4 or line 5 starts with Company.
		# if line 4 then we have company and then get since, phone and email on subsequent lines
		# else line 4 is address2 and line 5 starts company, since, phone and email
		
		if ( $line4 =~ /^Company:/)
		{
			# print "FOUND Company in line 4: $line4\n";
			$city_state_zip = $line3;
			$company = $line4;
		}
		else
		{
			my $line5 = <$fh>;
			# line 5 should start with Company
			if ( $line5 =~ /^Company:/)
			{
				# print "FOUND Company in line 5: $line5\n";
				$addr2 = $line3;
				$city_state_zip = $line4;
				chomp $line5;
				$company = $line5;
			}
		}
		
		my $since= <$fh>;
		chomp $since;
		my $phone= <$fh>;
		chomp $phone;
		my $email= <$fh>;
		chomp $ email;
		
		# Format the lines
		$name =~ /(\w+)\s(\w+)\.?\s*(\w*),\s*(.*)\;?$/;
		my $firstName = $1;
		my $MI = $2;
		my $lastName = $3;
		my $certs = $4;
		# if there was no middle initial $3 will be blank, so swap things a little
		if ($lastName eq "" )
		{
			$lastName = $MI;
			$MI = "";
		}
		
		$city_state_zip =~ /(\D+),\s(\w\w).\s(\S+)/;
		my $city = $1;
		my $state = $2;
		my $zip = $3;
		
		# remove commas from certifications
		$certs =~ s/\,/\./g;
		$company =~ s/Company: //;
		$company =~ s/\,/\./g;
		$since =~ s/Designee since: //;
		$phone =~ s/Phone number: //;
		$email =~ s/Email: //;
		
		# Display output
		print "name: $name\n";
		print "addr1: $addr1\n";
		print "addr2: $addr2\n";
		print "C-s-z: $city_state_zip\n";
		print "Company: $company\n";
		print "Designee since: $since\n";
		print "Phone: $phone\n";
		print "email: $email\n\n";
		
		# $fhout->print("First Name,MI,Last Name,Certificates,address1,address1,City,State,Zip,Company,Designee since,Phone,email\n");
		$fhout->print($firstName,",",$MI,",",$lastName,",",$certs,",",$addr1,",",$addr2,",",$city,",",$state,",",$zip,",",$company,",",$since,",",$phone,",",$email,"\n");
		
		$got_address = 1;
	}
}

$fh->close() || die "Error closing file $infile\nError: $!\n";

print "\nEND\n";