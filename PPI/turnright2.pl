#Turns all identical PI in a SQLtable in the same direction

use DBI;
my $i = 0;

my $table = $ARGV[0];  #The SQLtable that is to be turned
my $infile = $ARGV[1]; #A tab-textfile identical to the table
open(my $IN, $infile);
my @rader = <$IN>;

#Connects to the database. Change to fit your database
$username = 'root';$password = 'root';$database = 'artuppdelat';$hostname = 'localhost';
$dbh = DBI->connect("dbi:mysql:database=$database;" .
 "host=$hostname;port=3306", $username, $password);

my $count=$#rader+1;
foreach (@rader){
	@klippt = split(/\t/, $_);
	$SQL= "UPDATE $table SET protA='$klippt[0]', protB='$klippt[1]' where protA='$klippt[1]' and protB='$klippt[0]';"; 

	$Select = $dbh->prepare($SQL);
	$Select->execute();
	
	$i++;
	$procent = 100*$i/$count;
	print "$procent % \n";
}