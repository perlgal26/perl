#!/usr/bin/perl

use warnings;
use strict;


#pass by value

firstSub((1..5),("A".."G"));

sub firstSub{
    my (@fArr,@sArr)=@_;
    
    print ("\n------Pass By value---------\n");
    print("the firstarray is @fArr\n");
    print("the secarray is @sArr\n\n");
}

#pass by refrence


my @fArray =(1..5);
my @sArray =("A".."G");

firstSubRef(\@fArray,\@sArray);

sub firstSubRef{
    my ($fArrRef,$sArrRef)=@_;
    
    print ("========Pass By Ref=======\n");
    print("the firstarray is @{$fArrRef}\n");
    print("the secarray is @{$sArrRef}\n\n");
}