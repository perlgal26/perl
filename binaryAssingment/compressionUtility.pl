#!/usr/bin/perl

use strict ;
use warnings ;
use IO::Compress::Bzip2 qw(bzip2 $Bzip2Error) ;

print "\n\n Start of Script ...\n\n";


my $input = "feed_file_5.txt";
bzip2 $input => "$input.bz2"
or die "bzip2 failed: $Bzip2Error\n";

print "\n\n End of Script ...\n\n";