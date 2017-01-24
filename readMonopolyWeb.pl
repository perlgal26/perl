#!/usr/bin/perl
use LWP::Simple;


@fields = ("Name", "Color", "Rent ", "1 house", "2 house", "3 house", "4 house", "hotel", "Mortgage", "House cost", "Hotel cost");
$file = get "http://www.cs.umd.edu/~golbeck/INFM743/monopolySpots2.txt";
@lines = split(/\n/,$file);

foreach $line (@lines) {

	chomp $line;
	($name, @fields) = split(/\t/,$line);
	($m{$name}{"Name"},$m{$name}{"Color"},$m{$name}{"Rent"},$m{$name}{"1 house"},$m{$name}{"2 house"},$m{$name}{"3 house"},$m{$name}{"4 house"},$m{$name}{"hotel"},$m{$name}{"Mortgage"},$m{$name}{"House Cost"},$m{$name}{"Hotel Cost"}) = split(/\t/,$line);
	
}

foreach $k (keys %m) {
	foreach $f (keys %{$m{$k}}) {
		print "$k - $f: " . $m{$k}{$f};
		print "\n";
	}
}