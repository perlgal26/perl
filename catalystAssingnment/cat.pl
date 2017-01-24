#!/usr/bin/perl



use strict;
use warnings;

use Pithub;
use Data::Dumper;
use Pithub::Repos;


my %HoA = (
naik             =>["sandeep"],
flintstones        => [ "fred", "barney" ],
jetsons            => [ "george", "jane", "elroy","test" ],
simpsons           => [ "homer", "marge", "bart" ],
);



for my $family ( sort {@{$HoA{$a}} <=> @{$HoA{$b}}} keys %HoA ) {
    print "$family\n";
    for my $i ( 0 .. $#{ $HoA{$family} } ) {
        print " $family/$HoA{$family}[$i]\n";
    }
    print "\n";
}




=cut
 $ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;
 my $time = time;
 print "Here I M  = $time\n\n";
 
 my $m = Pithub::Orgs::Members->new;
 my $result = $m->list( org => 'catalyst' );
 unless ( $result->success ) {
 printf "reached deadend: \n", $result->response->status_line;
 exit 1;
 }
 
 my @catUsers;
 my $fileName = "catalyst".$time.".txt";
 open OFILEHTML,">>/tmp/".$fileName;
 while ( my $row = $result->next ) {
 
 push (@catUsers,$row->{login});
 #print "login \n",$row->{login};
 
 
 }
 #print OFILEHTML "ARRAY Catusers:\n\n\n";
 #print OFILEHTML Dumper(@catUsers);
 
 
 
 
 my $repos  = Pithub::Repos->new;
 
 my %catUserRepo;
 foreach my $catUser(@catUsers)
 {
 my $result = $repos->list( user => $catUser );
 while ( my $row = $result->next ) {
 # print OFILEHTML "RECORD\n\n", $catUser   , $row->{name}    , $row->{description} || 'no description';
 #push (@catUsers,$row->{login});
 #print OFILEHTML Dumper($row);
 my $repoName = $row->{name};
 if ($repoName =~ /moodle/) {
 # print "'$string' matches the pattern\n";
 #$catUserRepo{$catUser}{"repoName"}=$row->{name};
 push(@{$catUserRepo{$catUser}},$row->{name});
 }
 
 }
 
 }
 
 
 
 foreach my $k ( sort {@{$catUserRepo{$a}} <=> @{$catUserRepo{$b}} ||$b cmp $a} keys %catUserRepo )
 {
 print OFILEHTML "$k \n", join("$k/\n ", sort @{ $catUserRepo{$k} }), "\n\n\n";
 }
 
 =pod
 
 
 
 #print OFILEHTML Dumper(%catUserRepo);
 close (OFILEHTML);
 
 
 
