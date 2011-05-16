#Exports a SQLtable => tab-textfile
#!/usr/local/bin/perl

use DBI;

my $table = $ARGV[0];   #table to be exported
my $outfile = $ARGV[1]; #outfile
open(UT, ">$outfile");

#Connects to the database. Change to fit your database
$username = 'root';$password = 'root';$database = 'silver';$hostname = 'localhost';
$dbh = DBI->connect("dbi:mysql:database=$database;" .
 "host=$hostname;port=3306", $username, $password);
 
$SQL= "SELECT * FROM $table;"; 
$Select = $dbh->prepare($SQL);
$Select->execute();

while(@Row=$Select->fetchrow_array){
	print UT &Skriv(@Row);
}

sub Skriv{
	my $TabText;
	foreach $tabar (@_){
		$TabText = $TabText . "$tabar\t";
	}
	return "$TabText\n";
}