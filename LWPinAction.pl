

#!/usr/bin/perl -w
use strict;
use LWP::Simple;
  
my $catalog = get("http://www.oreilly.com/catalog");
die "Couldn't get it?!" unless $catalog;
my $count = 0;
$count++ while $catalog =~ m{Perl}gi;
print "$count\n";