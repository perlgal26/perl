#!/usr/bin/perl

$info{"Jen"}{"age"} = 32;
$info{"Jen"}{"height"} = 68;
$info{"Jen"}{"YrsInSchool"} = 24;

$info{"Bob"}{"age"} = 60;
$info{"Bob"}{"height"} = 72;
$info{"Bob"}{"MilitaryBranch"} = "USMC";

if ( $info{"Jen"}{"MilitaryBranch"} eq "")
foreach $name (keys %info) {
   print "$\n";
   foreach $data (keys %{$info{$name}}) {
    #print "$data\n";
    #print $info{$name}{$data};
    #print "\n";
   }
}

















#@jensDogs = ("Pi","K");
#$petNames{"Jen"} = ("Pi","K");


#push (@{$petNames{"Jen"}}, "Pi");
#push (@{$petNames{"Jen"}}, "K");

#print @{$petNames{"Jen"}};


















#%heights = ();

#$heights{"Jen"}= 68;
#$heights{"Bob"} = 72;
#$heights{"Frank"} = 63;


#open (FILE, "age.txt");
#while (<FILE>) {
#  chomp $_;
#  ($name,$age) = split(/,/,$_);
#   $heights{$name} = $age;
#}
#
#foreach $k (keys %heights) {
#    $total = $total + $heights{$k};
#}
#
#print $total / scalar keys %heights ;














#print "Whose height do you want to know? ";
#print keys  %heights;



#$person = <>;
#chomp $person;
#print $heights{$person};
