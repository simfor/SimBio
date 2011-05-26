#Adds two columns with AA-sequences to tab-file. The sequnces corresponds to the Uniprot-IDs in column 1 and 2
use strict;
use warnings;
use LWP::Simple;

my $infile = $ARGV[0]; 
my $outfile = $ARGV[1]; #outfile
open(my $IN, $infile);
open(UT, ">$outfile");

my $seqPath = "/home/simon/workspace/Data/sequences/AA/"; #Change to your fasta-folder
my $i = 0;

while(<$IN>){
	chomp($_);
	my @guld = split(/\t/, $_);
	
	my $seqA = &seq($guld[0]);
	my $seqB = &seq($guld[1]);	
	print UT "$_\t$seqA\t$seqB\n";
	
	$i++;
	print "$i \n";
}

sub seq{
	my $uniprotID = $_[0];
	my $seq_line = "";
	my $fasta;

	#Checks if the sequence exists localy
	if(-e "$seqPath$uniprotID.fasta"){
		open(seq_in, "$seqPath$uniprotID.fasta");
		$fasta = <seq_in>;
		close seq_in;
	}
	#If not, downloads it from www.uniprot.org
	else{
		my $url = "http://www.uniprot.org/uniprot/$uniprotID.fasta"; 
		$fasta = get $url;
		open(seq_out, ">$seqPath$uniprotID.fasta");
		print seq_out $fasta; #Saves fasta file locally
		close seq_out;
	}
	
	my @fasta = split(/\n/, $fasta);
		for my $line(@fasta) {
			if ($line =~ m/^>/){

			next;	

			}
			else{	
				chomp($line);
				$seq_line = "$seq_line$line";
			}
		}

		return $seq_line;	
}
