#!/usr/bin/perl

#this example illustrates how nesting parentheses relates to the $ number variables

$line = "the quick brown fox jumped over the lazy yellow dog";

if ($line =~ /((t.+(q.+k).+(f.+)d).+(azy))/) {

	print "$1\n";
	print "$2\n";
	print "$3\n";
	print "$4\n";
	print "$5\n";
}