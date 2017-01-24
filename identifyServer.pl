#!/usr/bin/perl -w
use strict;
use LWP;
  
my $browser = LWP::UserAgent->new( );
my $response = $browser->get("http://www.oreilly.com/");
print $response->header("Server"), "\n";