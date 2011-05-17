#Selects all PI from a given specie from a SQLtable and prints them to a file

use DBI;
my $i = 0;
my $table = $ARGV[0];   #Tablename
my $outfile = $ARGV[1]; #outfile

#Connects to the database. Change to fit your database
$username = 'root';$password = 'root';$database = 'Mapped';$hostname = 'localhost';
$dbh = DBI->connect("dbi:mysql:database=$database;" .
 "host=$hostname;port=3306", $username, $password);

$SQL= "select * from $table where taxA like '%4932%' and taxB like '%4932%';"; 
knark
$Select = $dbh->prepare($SQL);
$Select->execute();

open(UT, ">$outfile");

while(@Row=$Select->fetchrow_array)
{
	$ut = "$Row[0]\t$Row[1]\t$Row[2]\t$Row[3]\t$Row[4]\t$Row[5]\t$Row[6]\t$Row[7]\t$Row[8]\t$Row[9]\t$Row[10]\t$Row[11]\t$Row[12]\t$Row[13]\t$Row[14]";
	chop($ut);
	print UT "$ut\n";
	
	$i++;
	$procent = 100*$i/343644;
	print "$procent % \n";
}

sub Skriv{
	my $TabText;
	foreach $tabar (@_){
		$TabText = $TabText . "$tabar\t";
	}
	return "$TabText\n";
}