#This script takes a tab-separated file as input and replaces the uniprotID:s in column 1 and 2 with the newest synonym
#Author: Simon Forsberg
use strict;
use warnings;
use LWP::Simple;

my $infile  = $ARGV[0];
my $outfile = $ARGV[1];    #outfile

open( my $IN, $infile ) || die "Could not open $infile: $!, $?";
open( my $UT, ">", "$outfile" ) || die "Could not open $outfile: $!, $?";

my $uniprot_path = "/home/simon/workspace/Data/uniprot_entries/bajs";

  while (<$IN>) {
	my @klippt   = split( /\t/, $_ );
	my $uniprotA = $klippt[0];
	my $uniprotB = $klippt[1];

	my $newID_A = &map($uniprotA);
	my $newID_B = &map($uniprotB);

	print $UT "$newID_A\t$newID_B\t$klippt[2]\t$klippt[3]";
}

sub map {
	my @uniprot_entry = "";
	my $new_uniprotID = $_[0];
	
	#Checks if the Uniprot entry exists locally
	if ( !(-e "$uniprot_path/$_[0].txt") ) {
		print "$_[0].txt finns inte. Allt är johans fel...\n";
		my $url = "http://www.uniprot.org/uniprot/$_[0].txt";
		print "Hämtar uniprot entry för $_[0]\n";
		my $uniprot_entry = get $url;
		
		open(my $entry_UT, ">", "$uniprot_path/$_[0].txt");
		print $entry_UT $uniprot_entry;
		close $entry_UT;
	}
	
	open( entry_IN, "$uniprot_path/$_[0].txt" );
	@uniprot_entry = <entry_IN>;
	close entry_IN;

	for my $line (@uniprot_entry) {
		if ( $line =~ m/^AC\s+(.*?);/ ) { #Matches the first UniprotID of the synonyms. 
			$new_uniprotID = $1;
		}
	}
	return $new_uniprotID;
}