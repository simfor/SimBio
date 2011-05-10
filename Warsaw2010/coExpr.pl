use strict;
use LWP::Simple;

my $infile = $ARGV[0]; 
my $outfile = $ARGV[1]; #utfil

open(my $IN, $infile);
my @rader = <$IN>;
open(UT, ">$outfile");

my $arrExpIdA;
my $arrExpIdB;
my $i=0;
my @klippt;
my $procent;

foreach (@rader){
	@klippt = split(/\t/, $_);
#	@Aklippt = split(/\|/ , $klippt[0]); #splitar första kolumnen vid |
#	@Bklippt = split(/\|/ , $klippt[1]); #splitar andra kolumnen vid |
#	@uniprotA = split(/:/ , $Aklippt[0]); 
#	@uniprotB = split(/:/ , $Bklippt[0]); 
		
	$arrExpIdA = &ArrExID($klippt[0]);  #`/usr/bin/perl conv_uniprotID_to_arrayexpressID.pl $klippt[0]`;
	$arrExpIdB = &ArrExID($klippt[1]);  #`/usr/bin/perl conv_uniprotID_to_arrayexpressID.pl $klippt[1]`;
	
	print UT "$klippt[0]\t$klippt[1]\t$arrExpIdA\t$arrExpIdB\t$klippt[2]\t$klippt[3]";
	
	$i++;
	$procent = 100*$i/$#rader;
	print "$procent % \n";
}

sub ArrExID{
	my $organism ="scerevisiae";
	my $target_database = "AFFY_YG_S98";
	my $uniprot = $_[0];
	my $ID = "";
	
	#Kollar om ArrExID-queryt redan gjorts och läser isf in det från lokal fil
	if(-e "/home/simon/workspace/GoldStandard/coExpr/ArrExID/$uniprot"){
		open(uniprot, "/home/simon/workspace/GoldStandard/coExpr/ArrExID/$uniprot");
		$ID = <uniprot>;
		close uniprot;
	}
	else{
		my $url = "http://biit.cs.ut.ee/gprofiler/gconvert.cgi?organism=$organism&output=txt&target=$target_database&query=$uniprot";
		my $query = get $url;
		my $big_line = "";
		my @query = split(/\n/, $query);
		for my $line(@query) {
			chomp($line);
			$big_line = "$big_line $line";
		}
		if ($big_line =~ m/<pre>(.*)<\/pre>/) {
			my @array = split(/\t/, $1);
			$ID = $array[3];
			open(ID_UT, ">/home/simon/workspace/GoldStandard/coExpr/ArrExID/$uniprot");
			print ID_UT $ID;
			close ID_UT;
		}
		return $ID;
	}
		
#	my $url = "http://biit.cs.ut.ee/gprofiler/gconvert.cgi?organism=$organism&output=txt&target=$target_database&query=$uniprot";
	
#	my $big_line = "";
#	my $query = get $url;
	
#	my @query = split(/\n/, $query);
#	for my $line(@query) {
#		chomp($line);
#		$big_line = "$big_line $line";
#	}
#	if ($big_line =~ m/<pre>(.*)<\/pre>/) {
#		my @array = split(/\t/, $1);
#		return $array[3];
#	}
	
}

sub mem_yeast_ppi{
	my $affyIDA = $_[0];
	my $affyIDB = $_[1];
	my $Expr;
	
	#Kollar om ArrExID-queryt redan gjorts och läser isf in det från lokal fil
	if(-e "/home/simon/workspace/GoldStandard/coExpr/coExpr_querys/$affyIDA"){
		open(Expr, "/home/simon/workspace/GoldStandard/coExpr/coExpr_querys/$affyIDA");
		$Expr = <Expr>;
		close Expr;
	}
	
	else{
		my $url = "http://biit.cs.ut.ee/mem/index.cgi?dc=A-AFFY-27&dist=spearman&output=scores&limit=100&query=$affyIDA" ; #define url
			#query=203325_s_at --- if the query is in the form of valid affymetrix id the query can be done without additional probset selection
			#      to convert gene ids to affy_ids one can use http://biit.cs.ut.ee/gprofiler/gconvert.cgi for bulk conversion
			#limit=100000 --- limits the number of genes in the output -- insanely large number will output all probesets on the platform, ordered by coexpression similarty to query gene
			#output=scores --- output only the score and names of similarly co-expressed genes (allows longer output and is much less computationally intensive)
			#dist=spearman --- indicate distance measure to be used --- refer website for selection of distance measures
			#dc=A-AFFY-XX --- indicate platform to be used --- refer website for selection of different platforms
			#other filters and options can be refered from website (i.e stdev, thresh, rmnas, etc...)
		
		my $query = get $url ; #perform query
		
		my @query = split(/\n/, $query) ; #split query in array, so that every line in output would be one variable in array
		
		for my $line (@query) {
			chomp($line) ;
			if ($line =~ m[class='p']) { #relevant text output has class='p' in the beginning of the line, we can ignore everything else
				$line =~ s[</td></tr>][] ; #chop off the end of the line
				$line =~ s[<tr><td class='p'>][] ; #chop off the beginning of the line
				my ($score, $gene, $affy_id, $gene_desc) = split(m[</td><td>], $line) ; #split line into variables indicated by name
				#atm I only print the variables out into STDOUT.. one can do filtering or other kind of manipulation at this point
			#	print join("\t", $score, $gene, $affy_id, $gene_desc), "\n" ;
				if ($affyIDB =~ m/$affy_id/i) {
					$Expr = "$score";
					open(ID_UT, ">/home/simon/workspace/GoldStandard/coExpr/ArrExID/$uniprot");
					print ID_UT $ID;
					close ID_UT;	
				}
			} 
			else {
				next ;
			}
		}
	}
	
}