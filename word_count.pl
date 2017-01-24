#!/usr/bin/perl
use strict;
use warnings;

open (File ,"output.txt");
my @array = <File>;
my $wordtobe = "peterbulmer";
my $count = 0;

foreach my $line (@array){
    my @wordsArr = split (/\W+/,$line);
    foreach my $word (@wordsArr){
        if ($word =~ /$wordtobe/)
        {
            $count = $count + 1 ;
        }
    }
}

print "The words occurs $count times";