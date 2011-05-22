#Changes the format of the All-dataset. This is a minor modification of gold_UNFformat.pl. View readme for more info
#Author: Simon Forsberg

use strict;
use warnings;
use DBI;
my $i = 0;

my $infile = $ARGV[0];  #I use export.pl for: SQL-table => tab-textfile
my $outfile = $ARGV[1]; #Outfile
open(my $IN, $infile);
my @rader = <$IN>;

open(UT , ">$outfile");

#Connects to the database. Change to fit your database
my $username = 'root';my $password = 'root';my $database = 'PPI';my $hostname = 'localhost';
my $dbh = DBI->connect("dbi:mysql:database=$database;" .
 "host=$hostname;port=3306", $username, $password);

my $count=$#rader+1;
foreach (@rader){
	my @klippt = split(/\t/, $_);
	my $SQL="";
	my $y2h=0;
	my $komplex=0;
	
	$SQL="SELECT expMet FROM s_cerevisiae_merge_nonred WHERE protA='$klippt[0]' and protB='$klippt[1]';";
	
	my $Select = $dbh->prepare($SQL);
	$Select->execute();
	while(my @Row=$Select->fetchrow_array){
		if($Row[0]=~/two hybrid/){
			$y2h++;
		}
		elsif($Row[0]=~/pull down/ || $Row[0]=~/affinity chromatography/ || $Row[0]=~/tandem affinity purification/ || $Row[0]=~/coimmunoprecipitation/){
			$komplex++;
		}
	}
	print UT "$klippt[0]\t$klippt[1]\t$y2h\t$komplex\n";
	
	$i++;
	my $procent = 100*$i/$count;
	print "$procent % \n";
}
