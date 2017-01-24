#!/usr/bin/perl

package Syvum::Board::delete;

use strict;
use Syvum::Board::Board;
use Syvum::Common::DBInit;
use Syvum::Topbot;
use Syvum::Members::Session;
use Syvum::Strings::Board_texts;

# IS_AN_ENTRY_POINT
# DB NEEDS: memdb 

# BEGIN INIT BLOCK ******************
#
  Syvum::Common::DBInit::initHandler();
  Syvum::Members::Session::init();
#
# END INIT BLOCK ********************

my $userID = Syvum::Members::Session::getCurrentUserID();

#if ($userID ne "yogesh" && $userID ne "ushenoy")
#  {
#    print "Content-type: text/html\n\n";
#    print "Not allowed.";
#    die;
#  }

my $query = $ENV{'QUERY_STRING'};

my $len = defined $query ? length $query : 0;

if ($len > 0)
  {
  }
elsif ($ENV{CONTENT_LENGTH})
  {
    read(STDIN, $query, $ENV{'CONTENT_LENGTH'});
    $len = length $query;
  }

my %table;
if ($len > 0)
  {
    my @pairs = split(/&/, $query);

    foreach my $pair (@pairs) 
      {  
        my ($name, $value) = split(/=/, $pair);
        $value =~ tr/+/ /;
        $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
        $value =~ s/~!/ ~!/g; 

         $table{$name} = $value;
#        print "$name = $table{$name}<br>";
      }
  }

my $lenUID = length $userID;
my $noCookie = 1;
if ($lenUID > 0)
  {
    $noCookie = 0;
  }

my $loggedOut = 0;

my %userInfo;
my $name = "";
if ($noCookie == 0)
  {
    if (length ($userID) > 0 && Syvum::Members::Info::isMember($userID))
      {
        %userInfo = Syvum::Members::Info::getMemberInfo($userID);
        $name = $userInfo{xxxName};
      }
    else
      {
        $loggedOut = 1;
      }
  }

if ($name)
  {
  }
else
  {
    $name = $userID;
  }

if (defined $table{delmesg})
  {
    if ($table{confirmDelMesg} && $table{confirmDelMesg} == 1)
      {
        my ($status, $mesg) = Syvum::Board::Board::removeMessage($table{board}, $table{thread}, $table{mesg}, $userID);
        
        my $str215 = $STRINGS{$ENV{DOCUMENT_ROOT}}->[215];
        $str215 =~ s/_var1_/$status/;
        my $str216 = $STRINGS{$ENV{DOCUMENT_ROOT}}->[216];
        $str216 =~ s/_var1_/$mesg/;
        my $insString =<<EOF;
<h2>$STRINGS{$ENV{DOCUMENT_ROOT}}->[214]</h2>
<p>$str215
<p>$str216
<p>
Status of 1 means success, rest is failure.
EOF
        printOutput($insString, 1, \%table);
        cleanUpAndExit();
      }
     else
      {
        printConfirmDelMesg(\%table);
        cleanUpAndExit();
      }
  }
elsif (defined $table{delthread})
  {
    if ($table{confirmDelThread} && $table{confirmDelThread} == 1)
      {
        my ($status, $mesg) = Syvum::Board::Board::removeThread($table{board}, $table{thread}, $userID);
        
        my $str215 = $STRINGS{$ENV{DOCUMENT_ROOT}}->[215];
        $str215 =~ s/_var1_/$status/;
        my $str216 = $STRINGS{$ENV{DOCUMENT_ROOT}}->[216];
        $str216 =~ s/_var1_/$mesg/;
        my $insString =<<EOF;
<h2>$STRINGS{$ENV{DOCUMENT_ROOT}}->[214]</h2>
<p>$str215
<p>$str216
<p>
Status of 1 means success, rest is failure.
EOF
        printOutput($insString, 1, \%table);
        cleanUpAndExit();
      }
     else
      {
        printConfirmDelThread(\%table);
        cleanUpAndExit();
      }
  }
elsif (defined $table{delboard})
  {
    if ($table{confirmDelBoard} && $table{confirmDelBoard} == 1)
      {
        my ($status, $mesg) = Syvum::Board::Board::removeBoard($table{board}, $userID);
        
        my $str215 = $STRINGS{$ENV{DOCUMENT_ROOT}}->[215];
        $str215 =~ s/_var1_/$status/;
        my $str216 = $STRINGS{$ENV{DOCUMENT_ROOT}}->[216];
        $str216 =~ s/_var1_/$mesg/;
        my $insString =<<EOF;
<h2>$STRINGS{$ENV{DOCUMENT_ROOT}}->[214]</h2>
<p>$str215
<p>$str216
<p>
Status of 1 means success, rest is failure.
EOF
        printOutput($insString, 1, \%table);
        cleanUpAndExit();
      }
     else
      {
        printConfirmDelBoard(\%table);
        cleanUpAndExit();
      }
  }

sub printConfirmDelMesg
{
  my %table = %{$_[0]};
  my $messageId = $table{board}."_".$table{thread}."_".$table{mesg};
  my $dr = Syvum::Board::Board::getMessage($messageId, $userID);
  my @d = @$dr;

  print "Content-type: text/html\n\n";
  if (length $d[0] > 0)
    {
      my $messageString .= "<table width=100% border=0 cellspacing=0 cellpadding=5 bgcolor=white><tr bgcolor=#bdbddd><td><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[191]: $d[0]</b></td></tr><tr><td><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[188]: $d[2]</b></td></tr><tr><td><pre>$d[3]</pre></td></tr></table>";

      print <<EOF;
<html>
<head><title>$STRINGS{$ENV{DOCUMENT_ROOT}}->[281]</title></head>
<body bgcolor=white>
<h1>$STRINGS{$ENV{DOCUMENT_ROOT}}->[283]</h1>
$STRINGS{$ENV{DOCUMENT_ROOT}}->[217]:
<form action=delete.cgi method=post>
<input type=hidden name=board value="$table{board}">
<input type=hidden name=thread value="$table{thread}">
<input type=hidden name=mesg value="$table{mesg}">
$messageString
<p>
<input type=hidden name=confirmDelMesg value=1>
<input type=submit name=delmesg value=$STRINGS{$ENV{DOCUMENT_ROOT}}->[284]> &nbsp;&nbsp; $STRINGS{$ENV{DOCUMENT_ROOT}}->[282]
</form>
</body>
</html>
EOF
  }
else
  {
    print <<EOF;
<html>
<head><title>$STRINGS{$ENV{DOCUMENT_ROOT}}->[218]</title></head>
<body bgcolor=white>
<h1>$STRINGS{$ENV{DOCUMENT_ROOT}}->[218]</h1>
$STRINGS{$ENV{DOCUMENT_ROOT}}->[218].
</body>
</html>
EOF
  }
}

sub printConfirmDelThread
{
  my %table = %{$_[0]};
  print "Content-type: text/html\n\n";
  my $threadInfoRef = Syvum::Board::Board::getThreadInfo($table{board}, $table{thread}, $userID);
  my %threadInfo = %$threadInfoRef;

  if ($threadInfo{Subject} && length $threadInfo{Subject} > 0)
    {
      my $messageString .= "<table width=100% border=0 cellspacing=0 cellpadding=5 bgcolor=white><tr bgcolor=#bdbddd><td><b>Subject: $threadInfo{Subject}</b></td></tr></table>";

      print <<EOF;
<html>
<head><title>$STRINGS{$ENV{DOCUMENT_ROOT}}->[281]</title></head>
<body bgcolor=white>
<h1>$STRINGS{$ENV{DOCUMENT_ROOT}}->[283]</h1>
$STRINGS{$ENV{DOCUMENT_ROOT}}->[219]:
<form action=delete.cgi method=post>
<input type=hidden name=board value="$table{board}">
<input type=hidden name=thread value="$table{thread}">
$messageString
<p>
<font color=red>$STRINGS{$ENV{DOCUMENT_ROOT}}->[220]:</font> >$STRINGS{$ENV{DOCUMENT_ROOT}}->[221]
<p>
<input type=hidden name=confirmDelThread value=1>
<input type=submit name=delthread value=>$STRINGS{$ENV{DOCUMENT_ROOT}}->[284]> &nbsp;&nbsp; >$STRINGS{$ENV{DOCUMENT_ROOT}}->[282]
</form>
</body>
</html>
EOF
  }
else
  {
    print <<EOF;
<html>
<head><title>$STRINGS{$ENV{DOCUMENT_ROOT}}->[222]</title></head>
<body bgcolor=white>
<h1>$STRINGS{$ENV{DOCUMENT_ROOT}}->[222]</h1>
$STRINGS{$ENV{DOCUMENT_ROOT}}->[223]
</body>
</html>
EOF
  }
}

sub printConfirmDelBoard
{
  my %table = %{$_[0]};
  print "Content-type: text/html\n\n";
  my $boardName = Syvum::Board::Board::getBoardName($table{board});

  if ($boardName && length $boardName > 0)
    {
      my $messageString .= "<table width=100% border=0 cellspacing=0 cellpadding=5 bgcolor=white><tr bgcolor=#bdbddd><td><b>Board name: $boardName</b></td></tr></table>";

      print <<EOF;
<html>
<head><title>$STRINGS{$ENV{DOCUMENT_ROOT}}->[281]</title></head>
<body bgcolor=white>
<h1>$STRINGS{$ENV{DOCUMENT_ROOT}}->[283]</h1>
$STRINGS{$ENV{DOCUMENT_ROOT}}->[224]:
<form action=delete.cgi method=post>
<input type=hidden name=board value="$table{board}">
$messageString
<p>
<font color=red>$STRINGS{$ENV{DOCUMENT_ROOT}}->[220]:</font> $STRINGS{$ENV{DOCUMENT_ROOT}}->[225]
<p>
<input type=hidden name=confirmDelBoard value=1>
<input type=submit name=delboard value=$STRINGS{$ENV{DOCUMENT_ROOT}}->[284]> &nbsp;&nbsp; $STRINGS{$ENV{DOCUMENT_ROOT}}->[282]
</form>
</body>
</html>
EOF
  }
else
  {
    print <<EOF;
<html>
<head><title>$STRINGS{$ENV{DOCUMENT_ROOT}}->[226]</title></head>
<body bgcolor=white>
<h1>$STRINGS{$ENV{DOCUMENT_ROOT}}->[226]</h1>
$STRINGS{$ENV{DOCUMENT_ROOT}}->[227]
</body>
</html>
EOF
  }
}

sub printOutput
{ 
  my $str = $_[0];
  my $success = $_[1];
  my %table = %{$_[2]};

  my $link;
  my $topString = Syvum::Topbot::getTop();
  my $botString = Syvum::Topbot::getBottom();
  if ($table{delboard})
    {
      $link = "<a href=dboard.cgi>$STRINGS{$ENV{DOCUMENT_ROOT}}->[228]</a>";
    }
  else
    {
      $link = "<a href=list.cgi?bid=$table{board}>$STRINGS{$ENV{DOCUMENT_ROOT}}->[229]</a>";
    }

  print "Content-type: text/html\n\n";
  print <<EOF;
<html>
<head><title>$STRINGS{$ENV{DOCUMENT_ROOT}}->[285]</title></head>
<body>
$topString

$str
<center>
<p>
<a href=list.cgi?bid=$table{board}>$STRINGS{$ENV{DOCUMENT_ROOT}}->[229]</a>
</center>

$botString

</body>
</html>
EOF
} 

sub cleanUp
{
  Syvum::Common::DBInit::closeConnection();
}

sub cleanUpAndExit
{
  Syvum::Common::DBInit::closeConnection();
  exit;
}
