#!/usr/bin/perl



use strict;
use warnings;
use Pithub;
use Data::Dumper;
use Pithub::Orgs::Members;
use Pithub::Repos;


print "\n\n Start of Script ...\n\n";


$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

my $time = time;
my $fileName = "catalyst".$time.".txt";
open OFILEHTML,">>/tmp/".$fileName;


#  GET THE USERS OF ORG
my $m = Pithub::Orgs::Members->new;
my $result = $m->list( org => 'catalyst' );
unless ( $result->success )
{
    printf "Cannot fetch users of organization: \n", $result->response->status_line;
    exit 1;
}

my @catUsers;


while ( my $row = $result->next ) {
    
    push (@catUsers,$row->{login});
    #print "login \n",$row->{login};
    
    
}
#print OFILEHTML "ARRAY Catusers:\n\n\n";
#print OFILEHTML Dumper(@catUsers);


#  GET THE REPOS FOR EACH USERS

my $repos  = Pithub::Repos->new;
my %catUserRepo;
foreach my $catUser(@catUsers)
 {
     my $result = $repos->list( user => $catUser );
     unless ( $result->success )
     {
         printf "Cannot fetch repos for users: \n", $result->response->status_line;
         exit 1;
     }
     

     while ( my $row = $result->next )
     {
         my $repoName = $row->{name};
         if ($repoName =~ /moodle/)
         {
             # print " matched\n";
            push(@{$catUserRepo{$catUser}},$row->{name});
         }
         
     }
    
 }

# SORTING BY THE NUMBER OF MOODLE REPOS OWNED BY USER AND PRINTING  
 
for my $k (sort {@{$catUserRepo{$a}} <=> @{$catUserRepo{$b}} } keys %catUserRepo )
{
    print OFILEHTML "$k\n";
    for my $i ( 0 .. $#{ $catUserRepo{$k} } )
    {
        print OFILEHTML " $k/$catUserRepo{$k}[$i]\n";
    }
    print OFILEHTML "\n";
}

close (OFILEHTML);

print "End of Script ...\n\n";
