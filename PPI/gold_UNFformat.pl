#Changes the format of the goldstandard-dataset. View readme for more info

use DBI;
my $i = 0;

my $infile = $ARGV[0];  #I use export.pl for: SQL-table => tab-textfile
my $outfile = $ARGV[1]; #Outfile
open(my $IN, $infile);
my @rader = <$IN>;

open(UT , ">$outfile");

#Connects to the database. Change to fit your database
$username = 'root';$password = 'root';$database = 'gold';$hostname = 'localhost';
$dbh = DBI->connect("dbi:mysql:database=$database;" .
 "host=$hostname;port=3306", $username, $password);

my $count=$#rader+1;
foreach (@rader){
	@klippt = split(/\t/, $_);
	$SQL="";
	$y2h=0;
	$komplex=0;
	
	$SQL="SELECT expMet FROM gold_yeast100728_2230unred WHERE protA='$klippt[0]' and protB='$klippt[1]';";
	
	$Select = $dbh->prepare($SQL);
	$Select->execute();
	while(my @Row=$Select->fetchrow_array){
		if($Row[0]=~/two hybrid/){
			$y2h++;
		}
		else{
			$komplex++;
		}
	}
	print UT "$klippt[0]\t$klippt[1]\t$y2h\t$komplex\n";
	
	$i++;
	$procent = 100*$i/$count;
	print "$procent % \n";
}

sub Skriv{
	my $TabText;
	foreach $tabar (@_){
		$TabText = $TabText . "$tabar\t";
	}
	return "$TabText\n";
}