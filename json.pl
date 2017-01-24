#!/usr/bin/perl
use JSON;
use LWP::Simple;
use Data::Dumper;

$json = JSON->new->allow_nonref;
print "Enter a zip: ";
$zip = <>;
chomp $zip;
$ll = get "http://www.melissadata.com/lookups/GeoCoder.asp?InData=$zip&submit=Search";

#split it
@lines = split(/\n/,$ll);
foreach $line (@lines) {
	if ($line =~ /Latitude <\/td><td class='padd'>([\d\.-]+)<\/td>/){
		$lat = $1;
	}
	if ($line =~ /Longitude <\/td><td class='padd'>([\d\.-]+)<\/td>/){
		$lon = $1;
	}
}

print "Lat Lon $lat $lon\n";


#JSON FILES
$file = get "http://www.opencaching.us/okapi/services/caches/search/nearest?consumer_key=LPsmqWDfLJbngdfqvUCu&center=$lat|$lon";
print $file;


#$file = get "http://real-chart.finance.yahoo.com/table.csv?s=AAPL&a=00&b=1&c=1981&d=09&e=3&f=1990&g=d&ignore=.csv";
#Date	Open	High	Low	Close	Volume	Adj Close

#@lines = split(/\n/,$file);
#foreach $line (@lines) {
#	($date,$open,$high,$low,$close,$volume,$adj) = split(/,/,$line);		#
#	$hash{$date}{"open"} = $open;
#	$hash{$date}{"high"} = $high;
#	$hash{$date}{"low"} = $low;
#	$hash{$date}{"close"} = $close;
#	$hash{$date}{"volume"} = $volume;
#	$hash{$date}{"adj"} = $adj;
#}	
#print Dumper %hash;

#$jsonString = $json->pretty->encode(\%hash);
#print $jsonString;
#$file = get "http://api.wunderground.com/api/5de098926fab46c5/history_20060405/q/CA/San_Francisco.json";
#"http://www.opencaching.us/okapi/services/caches/geocache?
#consumer_key=LPsmqWDfLJbngdfqvUCu&cache_code=OU0720";
#"http://api.openweathermap.org/data/2.5/weather?zip=94040,us&appid=bd82977b86bf27fb59a04b61b657fb6f";
#" http://www.opencaching.us/okapi/services/apisrv/stats ";
#print $file;
#print "\n";

#$jsonHash = $json->decode($file);
#print Dumper $jsonHash;
#print "\n";
#$pretty_string = $json->pretty->encode( $jsonHash );
#print $pretty_string; 

#Hash References
#%myHash = ();
#$myHash{"birthday"} = "12/16";
#keys %myHash
#$myRef = \%myHash;
#$myRef->{"birthday"};
#keys %{$myRef}