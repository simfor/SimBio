use LWP::Simple;

my $infile = $ARGV[0]; 
my $outfile = $ARGV[1]; #utfil
open(my $IN, $infile);
open(UT, ">$outfile");

while(<$IN>){
	chomp($_);
	@guld = split(/\t/, $_);

#	@protA = split(/:/, $guld[0]);
#	@protB = split(/:/, $guld[1]);
	
#	$seqA = `/usr/bin/perl conv_uniprotID_to_seq.pl $protA[1]`;
#	$seqB = `/usr/bin/perl conv_uniprotID_to_seq.pl $protB[1]`;
	$seqA = &seq($guld[0]);
	$seqB = &seq($guld[1]);
#	print "$guld[0]\t$guld[1]\n";
#	print @guld;
	
#	print UT "$guld[0]\t$guld[1]\t$seqA\t$seqB\n";
	print UT "$_\t$seqA\t$seqB\n";
	
	$i++;
#	$procent = 100*$i/1000;
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
