#Adds two columns with AA-sequences to tab-file. The sequnces corresponds to the Uniprot-IDs in column 1 and 2
use LWP::Simple;

my $infile = $ARGV[0]; 
my $outfile = $ARGV[1]; #utfil
open(my $IN, $infile);
open(UT, ">$outfile");

while(<$IN>){
	chomp($_);
	@guld = split(/\t/, $_);
	
#	$seqA = `/usr/bin/perl conv_uniprotID_to_seq.pl $protA[1]`;
#	$seqB = `/usr/bin/perl conv_uniprotID_to_seq.pl $protB[1]`;
	$seqA = &seq($guld[0]);
	$seqB = &seq($guld[1]);	
	print UT "$_\t$seqA\t$seqB\n";
	
	$i++;
	print "$i \n";
}

sub seq{
my $uniprotID = $_[0];

my $url = "http://www.uniprot.org/uniprot/$uniprotID.fasta"; 


my $seq_line = "";	
my $query = get $url;

my @query = split(/\n/, $query);
	for my $line(@query) {
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
