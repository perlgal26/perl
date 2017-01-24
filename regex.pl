#!/usr/bin/perl


$text = "I really like broccoli.";
$text =~ s/[aeiou]//ig;
print "$text\n";
@vowels = ("a","e","i","o","u");
foreach $v (@vowels) {
	$text =~ s/$v//ig;
}

print "$text\n";


















# open (FILE, "KenLayEmail.txt");
# $state=0;
# while (<FILE>) {
# 	chomp $_;
# 
# 	if ($_ =~ /(\(?\d{3}?[) -\.]\d{3}[ -\.]\d{4})/) {
# 		print "$1\n";
# 	}
# 
# }
# close FILE;
# 












	
	# if ($_ =~ /\s+\d{5}(-\d{4})?\s*$/) {
# 		print "$previousLine\n$_\n\n";
# 	}
# 	$previousLine = $_;

# 
# if ($state==1) {
# 		if ($_ =~ /\s+\d{5}(-\d{4})?\s*$/) {
# 			print "$_\n\n";
# 		}
# 		$state=0;
# 	}	
# 	if ($_ =~ /^(\d+ [a-zA-Z]+ [a-zA-Z]+)$/ ) {
# 		print "$1\n";
# 		$state=1;
# 	}