#!/usr/bin/perl
use LWP::Simple;

$xml = get "http://w1.weather.gov/xml/current_obs/KCGS.xml";
@lines  = split(/\n/, $xml);

foreach $line (@lines) {
	if ($line =~ /<([^>]+)>([^<]*)<\/([^>]+)>/) {
		$name = $1;
		$value = $2;
		
		$name =~ s/_/ /g;
		
		print "$name: $value\n";
	}
}