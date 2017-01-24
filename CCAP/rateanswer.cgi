#! /usr/bin/perl

use strict;
use Syvum::Members::Session;
use Syvum::Online::XMLParser;
use Syvum::Board::Board;
use Syvum::editor::ContribAns;
use Syvum::Fs::Dirs;

#Syvum::Members::Session::init();

# IS_ENTRY_POINT
# DB NEEDS : memdb, fsdb

# BEGIN INIT BLOCK ******************
#

  Syvum::Common::DBInit::initHandler();
  Syvum::Members::Session::init();

#
# END INIT BLOCK ********************

#print "Content-type: text/html/\n\n";

my $userID = Syvum::Members::Session::getCurrentUserID();

my $queryString = $ENV{QUERY_STRING};
my @queryData = split(/%%%/, $queryString);

my $vote = $queryData[0];
my $messageId = $queryData[1];
my $fileName = $queryData[2];
$fileName = Syvum::Fs::Dirs::longenPath($fileName);
my $ajaxCall = $queryData[3]; 
my $spanIdUp = $queryData[1]."_tup";
my $spanIdDn = $queryData[1]."_tdn";

if (length $userID == 0)
  {
    my $loginform =<<EOF;
<form method="post" action="/cgi/members/login.cgi"><table><tr><td><b>User ID</b></td><td><input type="text" size="10" maxlength="20" name="UserID"></td></tr><tr><td><b>Password</b></td><td><input type="password" size="10" maxlength="20" name="Password"></td></tr></table><input type="hidden" name="TargetURL" value="/cgi/editor/rateanswer.cgi?$queryString"><input type="submit" name="submit" value = "Login"></form>
EOF

    print "Content-type: text/html\n\n";   
    print <<EOF;
<html>
<body>
You must be signed in as a member to use this feature.<br/><br/>
$loginform
If you are not yet a member, you can <a href="/members/register.html" target="_blank">register here</a>.<br/>
</body>
</html>
EOF
    
  }
else
  {
    my ($userTupList, $userTdnList, $retMessageId) = Syvum::Board::Board::getUserList($messageId);

    if (defined $retMessageId && length $retMessageId == 0)
      {
        print "Content-type: text/html\n\n";
        print "No vote recorded"; 
      }
    else
      {            
        my $tupCount = 0;
        my $tdnCount = 0;

        if (length $userTupList > 0 && $userTupList =~/,$userID,/ && $vote eq "tup")
          {
            if ($ajaxCall eq 'ajax')
              {  
                print <<EOF;
Content-type: text/xml
Cache-Control: no-cache
Content-Type: application/xml

<error>
User $userID has already voted!
</error>
EOF
 
                exit;
              } 
            else
              {
                print "Content-type: text/html\n\n";
                print "User $userID has already voted!";
                exit;
              }   
          }
        elsif ($userTupList =~/,$userID,/ && $vote eq "tdn")
          {
            $userTupList =~ s/,$userID,/,/;
            $userTupList =~ s/^,$//;
          }
       elsif (length $userTdnList > 0 && $userTdnList =~/,$userID,/ && $vote eq "tdn")
         {
           if ($ajaxCall eq 'ajax') 
             {
               print <<EOF;
Content-type: text/xml
Cache-Control: no-cache
Content-Type: application/xml

<error>
User $userID has already voted!
</error>
EOF

           exit;
             }
           else
             {
               print "Content-type: text/html\n\n";
               print "User $userID has already voted!";
               exit;   
             }
         }
       elsif ($userTdnList =~/,$userID,/ && $vote eq "tup")
         {
           $userTdnList =~ s/,$userID,/,/;
           $userTdnList =~ s/^,$//;
         }

       if ($vote eq "tup")
         {
            $userTupList = length $userTupList == 0 ? ",".$userID."," : $userTupList.$userID.",";
         }
       elsif ($vote eq "tdn")
         {
            $userTdnList = length $userTdnList == 0 ? ",".$userID."," : $userTdnList.$userID.",";
         }
       else
         {
            print "Content-type: text/html\n\n";
       	    print "No vote recorded.";
            exit;
         }

      Syvum::Board::Board::updateUserVote($messageId, $userTupList, $userTdnList);

      while ($userTupList =~/,/g)
        {
          $tupCount++;
        }

      $tupCount = $tupCount - 1;
      if ($tupCount == -1)
        {
          $tupCount = 0;
        }

      while ($userTdnList =~/,/g)
        {
          $tdnCount++;
        }

      $tdnCount = $tdnCount - 1;
      if ($tdnCount == -1)
        {
          $tdnCount = 0;
        }

      print "Content-type: text/html\n\n";
      Syvum::editor::ContribAns::updateRatings($userID, $fileName, $messageId, $tupCount, $tdnCount);
      print "Thank you for rating the answer.";
      

      if (defined $ajaxCall && $ajaxCall eq "ajax")
        {
          print <<EOF;
          Content-type: text/xml
          Cache-Control: no-cache
          Content-Type: application/xml

          <?xml version="1.0" encoding="utf-8"?>
          <elem>
          $tupCount
          </elem>
          <elem>
          $tdnCount
          </elem>
EOF
  
        }
      else
        {
          print <<EOF;
          <script language=javascript> 
          window.opener.document.getElementById(\'$spanIdUp\').innerHTML = $tupCount;
          window.opener.document.getElementById(\'$spanIdDn\').innerHTML = $tdnCount;   
          </script>
EOF
        }

      } 
  }
