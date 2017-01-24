#!/usr/bin/perl
use LWP::Simple;

$file = get "http://www.cs.umd.edu/~golbeck/INFM743/enron.csv";
@lines = split(/\n/,$file);


foreach(@lines) {

  ($first,$second) = split(/,/,$_);
  push (@emails,$first);
  push (@emails, $second);
}

print "total is ";
print scalar @emails;
print "\n";
















open (FILE, "weight.txt");
@lines;

while (<FILE>) {
  chomp $_;
  push (@lines, $_);

}

$total = 0;
foreach (@lines) {
  $total = $total + $_;
}

$avg = $total / scalar @lines;

print "The average is $avg\n";

















@myList = ();

#@myList[0] = "Jen";
#@myList[1] = "Bob";

push (@myList, "Jen");
push (@myList, "Bob");

foreach (@myList) {
     print "$_\n";

}

$i =0;
print scalar @myList;
print "\n";
while ($i < scalar @myList) {
  print "Item $i is ";
  print @myList[$i];
  print "\n";
   $i++;
}


#print @myList[0];
#print pop @myList;
#print "\n";
#print pop @myList;
#print "\n";
#print pop @myList;
#print "\n";
