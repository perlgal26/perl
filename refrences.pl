#!/usr/bin/perl

use warnings;
use strict;

my $scalar = 2;
my @array =("1","test","testdetest");
my %hash = ('key1' => 10, 'key2' => 20);

testfunc(\$scalar,\@array,\%hash);

sub testfunc
{
    my ($scalar,$arrayref,$hashref) = @_;
    
    
    print "Value of $scalar is : ", $$scalar, "\n";
    print "Value of $arrayref is : ",  @$arrayref, "\n";
    print "Value of %hash is : ", %$hashref, "\n";
}



# Function definition
sub PrintHash{
    my (%hash) = @_;
    
    foreach my $item (%hash){
        print "Item : $item\n";
    }
}
my %hash = ('name' => 'Tom', 'age' => 19);

# Create a reference to above function.
my $cref = \&PrintHash;

# Function call using reference.
&$cref(%hash);