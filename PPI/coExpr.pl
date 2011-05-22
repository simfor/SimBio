#Adds column with co-Expression score to tab-file. The score corresponds to the Uniprot-IDs in column 1 and 2
#Author: Simon Forsberg
use strict;
use warnings;
use LWP::Simple;

my $infile = $ARGV[0]; 
my $outfile = $ARGV[1]; #outfile

open( IN, $infile) || die "Could not open $infile: $!, $?";
open(UT, ">$outfile") || die "Could not open $outfile: $!, $?";

my $arrExpID_path = "/home/simon/workspace/GoldStandard/coExpr/ArrExID"; #Change to fit your directory structure 
my $coExp_path = "/home/simon/workspace/GoldStandard/coExpr/coExpr_querys"; #   -||-
my $arrExpIdA;
my $arrExpIdB;
my @klippt;
my $coExpScore;

while (<IN>){
	chomp($_);
	@klippt = split(/\t/, $_);
	
	#Maps UniprotID to arrayExpressionID
	$arrExpIdA = &ArrExID($klippt[0]);  #`/usr/bin/perl conv_uniprotID_to_arrayexpressID.pl $klippt[0]`;
	$arrExpIdB = &ArrExID($klippt[1]);  #`/usr/bin/perl conv_uniprotID_to_arrayexpressID.pl $klippt[1]`;
	
	#Gets coExpression score if it exists
	if( ($arrExpIdA!~/"N\/A"/) && ($arrExpIdA ne $arrExpIdB) ){
		$coExpScore = &mem_yeast_ppi($arrExpIdA, $arrExpIdB);
	}
	
#	print "$coExpScore\n";
	print UT "$_\t$coExpScore\n";
#	print UT "$_\n";
}

sub ArrExID{
	my $organism ="scerevisiae";
	my $target_database = "AFFY_YG_S98";
	my $uniprot = $_[0];
	my $ID;
	
	#Checks if ArrExID-queryt has already been done and if so reads it from local file
	if(-e "$arrExpID_path/$uniprot.arrExpID"){
		open(uniprot, "$arrExpID_path/$uniprot.arrExpID");
		return <uniprot>;
		close uniprot;
	}
	else{
		my $url = "http://biit.cs.ut.ee/gprofiler/gconvert.cgi?organism=$organism&output=txt&target=$target_database&query=$uniprot";
		print "Hämtar ArrayExpressID för $uniprot\n";
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
			open(ID_UT, ">$arrExpID_path/$uniprot.arrExpID");
			print ID_UT $ID;
			close ID_UT;
		}
		return $ID;
	}
}

sub mem_yeast_ppi{
	my $affyIDA = $_[0];
	my $affyIDB = $_[1];
#	my $Expr;
	
	#Checks if ArrExID-queryt has already been done and if so reads it from local file
	if(-e "$coExp_path/$affyIDA.coExp"){
		open(Expr, "$coExp_path/$affyIDA.coExp");
		
		my @query = <Expr>;
		
		for my $line (@query) {
			chomp($line) ;
			if ($line =~ m[class='p']) { #relevant text output has class='p' in the beginning of the line, we can ignore everything else
				$line =~ s[</td></tr>][] ; #chop off the end of the line
				$line =~ s[<tr><td class='p'>][] ; #chop off the beginning of the line
				my ($score, $gene, $affy_id, $gene_desc) = split(m[</td><td>], $line) ; #split line into variables indicated by name
				#atm I only print the variables out into STDOUT.. one can do filtering or other kind of manipulation at this point
				#print join("\t", $score, $gene, $affy_id, $gene_desc), "\n" ;
				if ($affyIDB =~ m/$affy_id/i) {
					print "tjo $score\n";
					return "$score";
				}
			} 
			else {
				next ;
			}
		}
		
#		return <Expr>;
#		close Expr;
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
		
		print "Hämtar CoExpression-data för $affyIDA\n";
		my $query = get $url ; #perform query
		#print "$query\n";
		open(ID_UT, ">$coExp_path/$affyIDA.coExp");
		print ID_UT $query;
		close ID_UT;
		
		my @query = split(/\n/, $query) ; #split query in array, so that every line in output would be one variable in array
		
		for my $line (@query) {
			chomp($line) ;
			if ($line =~ m[class='p']) { #relevant text output has class='p' in the beginning of the line, we can ignore everything else
				$line =~ s[</td></tr>][] ; #chop off the end of the line
				$line =~ s[<tr><td class='p'>][] ; #chop off the beginning of the line
				my ($score, $gene, $affy_id, $gene_desc) = split(m[</td><td>], $line) ; #split line into variables indicated by name
				#atm I only print the variables out into STDOUT.. one can do filtering or other kind of manipulation at this point
				#print join("\t", $score, $gene, $affy_id, $gene_desc), "\n" ;
				if ($affyIDB =~ m/$affy_id/i) {
#					chomp($score);
#					open(ID_UT, ">$coExp_path/$affyIDA\_$affyIDB.coExp");
#					print ID_UT $score;
#					close ID_UT;
					print "tjo $score\n";
					return "$score";
				}
			} 
			else {
				next ;
			}
		}
	}
	
}
