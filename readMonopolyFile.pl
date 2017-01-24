#!/usr/bin/perl


@fields = ("Name", "Color", "Rent ", "1 house", "2 house", "3 house", "4 house", "hotel", "Mortgage", "House cost", "Hotel cost");
open (FILE, "monopolySpots.txt");

$line = 0;
while (<FILE>) {
	chomp $_;
	if ($line ==0) {
		$name = $_;
	}

	$m{$name}{@fields[$line]}= $_;
	$line++;
	if ($line>10) {
		$line=0;
	}

}
close FILE;

foreach $k (keys %m) {
	foreach $f (@fields) {
		print "$k - $f: " . $m{$k}{$f};
		print "\n";
	}
}