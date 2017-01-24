#!/usr/bin/perl
use strict;
use warnings;


my $c;
my $first = 0;
my $sec = 1;
my $temp;

for ($c =0 ; $c<=10; $c++)
{
    if ($c < 1){
        $temp = $c;
    }
    else{
        $temp = $first + $sec;
        $first = $sec;
        $sec = $temp;
    }
    print "$temp \n";
}