#!/usr/bin/perl



#use strict;
#use warnings;

$a = 20; 
{
   local ($a); 
   my (@b); 
   $a = 10; 
   @b = ("ram", "shyam");
   print $a; 
   print "@b"; 
}
print $a; 
print @b;
print "\n";

my @array =(3,4,5,6,7);
my @bigarray = grep{$_>4}@array;
print @bigarray;
print "\n"; 

my @dwarfs = qw(Doc Grumpy Happy Sleepy Sneezy Dopey Bashful);
splice @dwarfs, 3, 2;
print "@dwarfs";    # Doc Grumpy Happy Dopey Bashful

package Person;
sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

