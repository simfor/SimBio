#Exports a SQLtable => tab-textfile
#!/usr/local/bin/perl

use strict;
use warnings;
use DBI;

my $table = $ARGV[0];   #table to be exported
my $outfile = $ARGV[1]; #outfile
open(UT, ">$outfile");

#Connects to the database. Change to fit your database
my $username = 'root';my $password = 'root';my $database = 'PPI';my $hostname = 'localhost';
my $dbh = DBI->connect("dbi:mysql:database=$database;" .
 "host=$hostname;port=3306", $username, $password);

my $SQL= "SELECT * FROM $table;"; 
my $Select = $dbh->prepare($SQL);
$Select->execute();

while(my @Row=$Select->fetchrow_array){
	print UT &Skriv(@Row);
}

sub Skriv{
	my $TabText;
	foreach my $tabar (@_){
		$TabText = $TabText . "$tabar\t";
	}
	return "$TabText\n";
}
