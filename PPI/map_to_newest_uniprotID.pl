use strict;
use warnings;
use LWP::Simple;

my $infile = $ARGV[0]; 
my $outfile = $ARGV[1]; #outfile

open(my $IN, $infile) || die "Could not open $infile: $!, $?";
open(my $UT, ">", "$outfile") || die "Could not open $outfile: $!, $?";

my $uniprot_path = "/home/simon/workspace/Data/uniprotentries"

while(<$IN>){
	@klippt = split(/\t/, $_);
	my $uniprotA = $klippt[0];
	my $uniprotB = $klippt[1];

	$newID_A = &map($uniprotA);
	$newID_B = &map($uniprotB);
	
	print $UT "$newID_A\t$newID_B\t$klippt[2]\t$klippt[3]\n";
}

sub map {
	if(-e "$uniprot_path/$_[0].txt"){
		open(ID_IN, "$uniprot_path/$_[0].txt");
		my @uniprot_entry = <ID_IN>;
		close ID_IN;
	}
	else{
		print "$_[0].txt finns inte. Allt är johans fel...\n";
	}
	
	for my $line (@uniprot_entry){
		if ($line =~ m/^AC\s+(.*);/){
			my $new_uniprotID = $1;
		}
	}
	return $new_uniprotID;
}
