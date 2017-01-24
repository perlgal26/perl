#!/usr/bin/perl

#########updateObjects.pl ---- 12-09-2012 ---- Sheetal #########

use strict;
use warnings;
use Getopt::Std;
use Data::Dumper;
use updateObjects;

my $time = time;
#print "Here I M in updateObjects.pl\n";

#open STDOUT, ">/apps/tools/sheetal/tmp/updateObjects_$time.log";
open STDERR, ">/apps/tools/sheetal/tmp/updateObjectsErr_$time.log ";

my %opts;
getopts("e:f:r:a:i:o:v:", \%opts);
my $envName = $opts{'e'};
my $fin = $opts{'f'};
my $rep = $opts{'r'};
my $mlc = $opts{'m'};
my $allDbs = $opts{'a'};
my $inputString = $opts{'i'};
my $outputString = $opts{'o'};
my $verify = $opts{'v'};

print "envName = $envName\n";
#print "verify = $verify\n";

my @databaseArray = ();

#print "$fin----$rep----$allDbs\n";
#print "Here I M in envName = $envName\n";

if (!defined $opts{'e'}){
    # Help Function
    print "Usage: ./updateObjects.pl -e 35 -f fin -r rep -a all -i inputstring -o outputstring\n"; 
	print "Usage for Financial database: ./updateObjects.pl -e 35 -f fin \n";  
	print "Usage for Reporting database: ./updateObjects.pl -e 35 -r rep \n"; 
	print "Usage for MLC database: ./updateObjects.pl -e 35 -m mlc \n";
	print "Usage for all databases: ./updateObjects.pl -e 35 -a all \n";  	
    exit;
}

if (!defined $opts{'i'}  || !defined $opts{'o'} ){
    # Help Function
	print "ERROR : Sorry - you have to specify BOTH inputstring and outputstring... \n";
	print "Usage: ./updateObjects.pl -e 35 -f fin -r rep -a all -i inputstring -o outputstring\n";	 	
    exit;
}

if (!defined $opts{'f'}  && !defined $opts{'r'} && !defined $opts{'m'} && !defined $opts{'a'}) {
   #push (@databaseArray, "FINANCIAL" ,"REPORTING");
	print "ERROR : Sorry - you have to specify at least one database\n";
	print "Usage for Financial database: ./updateObjects.pl -e 35 -f fin \n";  
	print "Usage for Reporting database: ./updateObjects.pl -e 35 -r rep \n"; 
	print "Usage for MLC database: ./updateObjects.pl -e 35 -m mlc \n";
	print "Usage for all databases: ./updateObjects.pl -e 35 -a all \n";
	print "Usage for Verbose mode: ./updateObjects.pl -e 35 -a all -v 1 \n";	
    exit;
}

if (defined($fin) && $fin ne ""){
	push (@databaseArray, "FINANCIAL");
#	if (!defined $opts{'i'}  || !defined $opts{'o'} ){
#			$inputString = "MUREXPROD";
#			$outputString = "MXGUAT$envName";
#	}
}
if (defined($rep) && $rep ne ""){
	push (@databaseArray, "REPORTING");
#	if (!defined $opts{'i'}  || !defined $opts{'o'} ){
#			$inputString = "ACTUATEPROD";
#			$outputString = "ACTUAT$envName";
#	}
}
if (defined($mlc) && $mlc ne ""){
	push (@databaseArray, "MLC");
#	if (!defined $opts{'i'}  || !defined $opts{'o'} ){
#			$inputString = "MLCPROD";
#			$outputString = "MLCUAT$envName";
#	}
}
if (defined($allDbs) && $allDbs ne ""){
	push (@databaseArray, "FINANCIAL" ,"REPORTING", "MLC");
}

my %tempHash   = map { $_ => 1 } @databaseArray;
@databaseArray = keys %tempHash;
my $databaseArrayRef = \@databaseArray;
#print "databaseArray == @databaseArray\n";


## connect to database
print "Process Started for env ... $envName\n";
my $connectionStatus = updateObjects::getDatabseInfo($envName, $databaseArrayRef, $inputString, $outputString, $verify);

if ($connectionStatus eq "false"){
    die("ERROR: DB Connect to ENV Database Failed\n. Exiting....\n");
}

#close STDOUT;
close STDERR;

exit(0);

