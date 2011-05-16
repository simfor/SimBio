#The algorithm creates redundancy that needs to be removed afterwards. In our protocoll this is done with mysql

use DBI;
my $i = 0;

my $infile = $ARGV[0];  #Must be tab-textfile identical to the SQLtable. Use export.pl for: SQL-table => tab-textfile
my $outfile = $ARGV[1]; #outfile
open(my $IN, $infile);
my @rader = <$IN>;
open(UT , ">$outfile");

#Connects to the database. Change to fit your database
$username = 'root';$password = 'root';$database = 'artuppdelat';$hostname = 'localhost';
$dbh = DBI->connect("dbi:mysql:database=$database;" .
 "host=$hostname;port=3306", $username, $password);

my $count=$#rader+1;
foreach (@rader){
	@klippt = split(/\t/, $_);
	$SQL="";
	$hit=0;
	
	if($klippt[6]=~/two hybrid/){
		$SQL="SELECT * FROM human_MultSource100728_2145 WHERE protA='$klippt[0]' and protB='$klippt[1]'; "; 
		$hit=1;
	}

	if($hit==1){
		$Select = $dbh->prepare($SQL);
		$Select->execute();
		while(my @Row=$Select->fetchrow_array){
			print UT &Skriv(@Row);
		}
	}
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