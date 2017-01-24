#!/usr/bin/perl

package Syvum::Board::Board;

use strict;
use Syvum::Members::Info;
use Syvum::Strings::Board_texts;

# IS_NOT_AN_ENTRY_POINT
# DB NEEDS: memdb (do not import, as this is not an entry point)

my $createBoardAction = 1;
my $editAction = 2;
my $viewAction = 3;
my $postAction = 4;
my $createThreadAction = 5;
my $superAction = 6;
my $deleteAction = 7;

my $boardTypePublic = 1;
my $boardTypePrivate = 2;

sub createBoard
{
  my $thisuid = $_[0];
  my $boardName = $_[1];
  my $boardURL = $_[2];
  my $boardType = $_[3];
  my $desc = $_[4];
  my $readAccess = $_[5];
  my $postAccess = $_[6];
  my $createAccess = $_[7];
  my $superAccess = $_[8];

  my $perm = checkPermission($thisuid, $createBoardAction, $boardType);
  if ($perm != 1)
    {
      print "Content-type: text/html\n\n";
      print "Not allowed";
      die;
    }

  my $dbh = Syvum::Common::DBInit::getHandler();

  $thisuid = $dbh->quote($thisuid);
  $boardName = $dbh->quote($boardName);
  $boardURL = $dbh->quote($boardURL);
  $desc = $dbh->quote($desc);
  $readAccess = $dbh->quote($readAccess);
  $postAccess = $dbh->quote($postAccess);
  $createAccess = $dbh->quote($createAccess);
  $superAccess = $dbh->quote($superAccess);

  my $tableName = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."boards";

  my $query = qq{"INSERT INTO $tableName (OwnerID, BoardName, BoardURL, BoardType, Description, ReadAccess, PostAccess, CreateAccess, SuperAccess) VALUES (".$thisuid.", ".$boardName.", ".$boardURL.", ".$boardType.", ".$desc.", ".$readAccess.", ".$postAccess.", ".$createAccess.", ".$superAccess.")"};

  open (TMPF, ">>/tmp/query_file");
  print TMPF $query;
  close (TMPF);
  my $sth = $dbh->prepare("INSERT INTO $tableName (OwnerID, BoardName, BoardURL, BoardType, Description, ReadAccess, PostAccess, CreateAccess, SuperAccess) VALUES (".$thisuid.", ".$boardName.", ".$boardURL.", ".$boardType.", ".$desc.", ".$readAccess.", ".$postAccess.", ".$createAccess.", ".$superAccess.")");
  $sth->execute();

  $sth = $dbh->prepare("SELECT BoardID FROM $tableName WHERE BoardName=".$boardName);
  $sth->execute();
  my @ids = $sth->fetchrow_array; 

  $sth->finish();

  return ($ids[0]);
}

sub post
{
  my $board = $_[0];
  my $threadID = $_[1];
  my $threadURL = $_[2];
  my $subject = $_[3];
  my $uid = $_[4];
  my $name = $_[5];
  my $mesgData = $_[6];
  my $replyto = $_[7];
  my $messageId = "";
  my $messageIdUnquoted = "";
  my $perm = checkPermission($uid, $postAction, $board);
  if ($perm != 1)
    {
      print "Content-type: text/html\n\n";
      print "Not allowed";
      die;
    }

#  $mesgData =~ s/</\&lt;/gs;
#  $subject =~ s/</\&lt;/gs;
#  $name =~ s/</\&lt;/gs;

  my $dbh = Syvum::Common::DBInit::getHandler();

  my $threadIDq = $dbh->quote($threadID);
  my $threadURLq = $dbh->quote($threadURL);
  my $boardIDq = $dbh->quote($board);
  my $uidq = $dbh->quote($uid);
  $name = $dbh->quote($name);
  $mesgData = $dbh->quote($mesgData);
  $subject = $dbh->quote($subject);
  $replyto = $dbh->quote($replyto);

  my $tim = time;
  $tim = $dbh->quote($tim);

  my $sth;
  my @data;

  my $boardsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."boards";
  my $threadsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."threads";
  my $dbmesgTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."dbmesg";

  if ($threadID ne "new" && $threadID =~ /^\d+$/)
    {
      $sth = $dbh->prepare("SELECT Messages FROM $threadsTable WHERE ThreadID = ".$threadID);
      $sth->execute();

      @data = $sth->fetchrow_array();
    }

  if (@data)
    {
      my $mesgnum = $data[0];

      $messageId = $board."_".$threadID."_".$mesgnum;
      $messageIdUnquoted = $messageId;
      $messageId = $dbh->quote($messageId);

      $mesgnum++;
      $sth = $dbh->prepare("UPDATE $threadsTable set Messages = ".$mesgnum.", Time = ".$tim." WHERE ThreadID = ".$threadID);
      $sth->execute();

      $sth = $dbh->prepare("INSERT INTO $dbmesgTable (MessageID, UserId, Name, Subject, Data, Time, InReplyTo) VALUES (".$messageId.", ".$uidq.", ".$name.", ".$subject.", ".$mesgData.", ".$tim.", ".$replyto.")");
      $sth->execute();
    }
  else
    {
      my $perm = checkPermission($uid, $createThreadAction, $board);
      if ($perm != 1)
        {
          print "Content-type: text/html\n\n";
          print "Not allowed";
          die;
        }

      if ($ENV{seed_message} && $ENV{seed_message} eq "syvum")
        {
          $uid = "syvum";
          $name = "Syvum editorial staff";
          $uidq = $dbh->quote($uid);
          $name = $dbh->quote($name);
        }

      my $count = 0;

      my $mesgnum = 1;
      $sth = $dbh->prepare("INSERT INTO $threadsTable (BoardID, ThreadURL, Messages, Subject, Time) VALUES (".$boardIDq.", ".$threadURLq.", ".$mesgnum.", ".$subject.", ".$tim.")");
      $sth->execute();

      $threadID = $sth->{mysql_insertid};

      $sth = $dbh->prepare("SELECT Threads FROM $boardsTable WHERE BoardID=".$board);
      $sth->execute();
      my @ths = $sth->fetchrow_array;
      if ($ths[0] && length $ths[0] > 0)
        {
          $ths[0] .= $threadID.",";
        }
      else
        {
          $ths[0] = ",".$threadID.",";
        }
      $ths[0] = $dbh->quote($ths[0]);
      $sth = $dbh->prepare("UPDATE $boardsTable SET Threads=".$ths[0].", Time=".$tim." WHERE BoardID=".$board);
      $sth->execute();

      $messageId = $board."_".$threadID."_".$count;
      $messageIdUnquoted = $messageId;
      $messageId = $dbh->quote($messageId);
      $sth = $dbh->prepare("INSERT INTO $dbmesgTable (MessageID, UserId, Name, Subject, Data, Time, InReplyTo) VALUES (".$messageId.", ".$uidq.", ".$name.", ".$subject.", ".$mesgData.", ".$tim.", ".$replyto.")");
      $sth->execute();
    }

  $sth->finish();

  return ($threadID, $messageIdUnquoted);
}

sub isSuper
{
  my $thisuid = $_[0];

  my $ret = 0;
  if ($thisuid eq "yogesh"
      || $thisuid eq "ushenoy"
      || $thisuid eq "sheetal26"
      || ($thisuid eq "bia" && $ENV{HTTP_HOST} =~ /syvum.com.br/i))
#      || $thisuid eq "vikram9")
    {
      $ret = 1;
    }

  return ($ret);
}

sub checkPermission
{
  my $thisuid = $_[0];
  my $actionCode = $_[1];
  my $actionParam = $_[2];

  my $ret = 0;
  my $isSuperUser = isSuper($thisuid);

  my $lenuid = length $thisuid;

  if ($isSuperUser == 1)
    {
      $ret = 1;
      return ($ret);
    }

  if ($actionCode == $createBoardAction)
    {
      if ($actionParam == $boardTypePublic)
        {
          if ($isSuperUser == 1)
            {
              $ret = 1;
            }
          else
            {
              $ret = 0;
            }
        }
      elsif ($lenuid > 0)
        {
          my ($isPremier, $isTrial) = Syvum::Members::Info::isPremierMember($thisuid);
          if ($isPremier == 1 && $isTrial == 0)
            {
              $ret = 1;
            }
          else
            {
              $ret = 0;
            }
        }
    }
  else
    {
      my $dbh = Syvum::Common::DBInit::getHandler();

      my $boardsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."boards";

      my $sth = $dbh->prepare("SELECT OwnerID, Editors, CreateAccess, ReadAccess, PostAccess, SuperAccess FROM $boardsTable WHERE BoardID = ".$actionParam);
      $sth->execute();

      my @data = $sth->fetchrow_array;

      if ($actionCode == $createThreadAction)
        {
          if ($lenuid > 0 &&
              ($data[2] =~ /syvum:members/
              || $data[0] eq $thisuid 
              || $data[1] =~ /,$thisuid,/))
            {
              $ret = 1;
            }
          else
            {
              $ret = 0;
            }
        }
      elsif ($actionCode == $postAction)
        {
          if ($lenuid > 0 &&
              ($data[4] eq "syvum:members"
              || $data[0] eq $thisuid 
              || $data[1] =~ /,$thisuid,/))
            {
              $ret = 1;
            }
          else
            {
              $ret = 0;
            }
        }
      elsif ($actionCode == $viewAction)
        {
          if ($data[3] eq "syvum:all" 
              || ($lenuid > 0 && 
                  ($data[3] eq "syvum:members"
                   || $data[0] eq $thisuid 
                   || $data[1] =~ /,$thisuid,/)))
            {
              $ret = 1;
            }
          else
            {
              $ret = 0;
            }
        }
      elsif ($actionCode == $deleteAction)
        {
          if ($lenuid > 0 &&
              ($data[0] eq $thisuid 
              || $data[1] =~ /,$thisuid,/))
            {
              $ret = 1;
            }
          else
            {
              $ret = 0;
            }
        }
      else
        {
          $ret = 0;
        }
    }

  return ($ret);
}

sub getBoardsFromURL
{
  my $boardURL = $_[0];

  my $dbh = Syvum::Common::DBInit::getHandler();

  $boardURL = $dbh->quote($boardURL);

  my $boardsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."boards";
  my $sth = $dbh->prepare("SELECT BoardID, BoardName FROM $boardsTable WHERE BoardURL = ".$boardURL);
  $sth->execute();

  my @data = $sth->fetchrow_array;

  my %nameHash;

  while (@data)
    {
      $nameHash{$data[0]} = $data[1];
      @data = $sth->fetchrow_array;
    }

  $sth->finish();

  return (\%nameHash);
}

sub getThreadsFromURL
{
  my $threadURL = $_[0];

  my $dbh = Syvum::Common::DBInit::getHandler();

  $threadURL = $dbh->quote($threadURL);

  my $threadsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."threads";
  my $sth = $dbh->prepare("SELECT ThreadID, BoardID, Subject FROM $threadsTable WHERE ThreadURL = ".$threadURL);
  $sth->execute();

  my @data = $sth->fetchrow_array;

  my %idHash;
  my %nameHash;

  while (@data)
    {
      $idHash{$data[0]} = $data[1];
      $nameHash{$data[0]} = $data[2];
      @data = $sth->fetchrow_array;
    }

  $sth->finish();

  return (\%idHash, \%nameHash);
}

sub getBoardThreads
{
  my $board = $_[0];
  my $thisuid = $_[1];

  my $perm = checkPermission($thisuid, $viewAction, $board);
  if ($perm != 1)
    {
      print "Content-type: text/html\n\n";
      print "Not allowed (gbt).  If you think this message is in error, please <a href=/contact.html>contact us</a>";
      die;
    }

  $board = lc $board;

  my %retSubjHash;
  my %retMesgHash;
  my %retDelMsgHash;
  my %retTimeHash;
  my %retURLHash;

  my $dbh = Syvum::Common::DBInit::getHandler();

  $board = $dbh->quote($board);

  my $threadsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."threads";

  my $sth = $dbh->prepare("SELECT ThreadID, Subject, Messages, DeletedMessages, Time, ThreadURL FROM $threadsTable WHERE BoardID = ".$board." ORDER BY Time DESC");
  $sth->execute();

  my @data = $sth->fetchrow_array;
  my $count = 0;
  my @keys;
  while (@data)
    {
      $keys[$count++] = $data[0];
      $retSubjHash{$data[0]} = $data[1];
      $data[2] =~ s/^$data[0]_//;
      $retMesgHash{$data[0]} = $data[2];
      $retDelMsgHash{$data[0]} = $data[3];
      $retTimeHash{$data[0]} = $data[4];
      $retURLHash{$data[0]} = $data[5];

      @data = $sth->fetchrow_array;
    }

  $sth->finish();

  return (\@keys, \%retSubjHash, \%retMesgHash, \%retDelMsgHash, \%retTimeHash, \%retURLHash);
}

sub getThreadInfo
{
  my $board = $_[0];
  my $thread = $_[1];
  my $thisuid = $_[2];

  my $perm = checkPermission($thisuid, $viewAction, $board);
  if ($perm != 1)
    {
      print "Content-type: text/html\n\n";
      print "Not allowed (gti).  If you think this message is in error, please <a href=/contact.html>contact us</a>";
      die;
    }

  my $dbh = Syvum::Common::DBInit::getHandler();

  $thread = $dbh->quote($thread);
  my $threadsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."threads";
  my $sth = $dbh->prepare("SELECT BoardID, Subject, Messages, DeletedMessages, Time, ThreadURL FROM $threadsTable WHERE ThreadID = ".$thread);
  $sth->execute();

  my @data = $sth->fetchrow_array;

  my %retHash;
  if (@data && $data[0] && $board == $data[0])
    {
      $retHash{Subject} = $data[1];
      $retHash{Messages} = $data[2];
      $retHash{DeletedMessages} = $data[3];
      $retHash{Time} = $data[4];
      $retHash{ThreadURL} = $data[5];
    }
  else
    {
    }
  $sth->finish();

  return (\%retHash);
}

sub getBoards
{
  my %nameHash;

  my $dbh = Syvum::Common::DBInit::getHandler();

  my $boardsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."boards";
  my $sth = $dbh->prepare("SELECT BoardID, BoardName FROM $boardsTable WHERE BoardType=$boardTypePublic");
  $sth->execute();

  my @data = $sth->fetchrow_array;

  while (@data)
    {
      $nameHash{$data[0]} = $data[1];
      @data = $sth->fetchrow_array;
    }

  $sth->finish();
  return (\%nameHash);
}

sub getBoardName
{
  my $bid = $_[0];

  my $dbh = Syvum::Common::DBInit::getHandler();

  $bid = $dbh->quote($bid);

  my $boardsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."boards";
  my $sth = $dbh->prepare("SELECT BoardName FROM $boardsTable where BoardID=$bid");
  $sth->execute();

  my @data = $sth->fetchrow_array;
  $sth->finish();
  return ($data[0]);
}

sub getBoardDescription
{
  my $bid = $_[0];

  my $dbh = Syvum::Common::DBInit::getHandler();

  my $boardsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."boards";
  my $sth = $dbh->prepare("SELECT Description FROM $boardsTable where BoardID=$bid");
  $sth->execute();

  my @data = $sth->fetchrow_array;
  $sth->finish();
  return ($data[0]);
}

sub getBoardURL
{
  my $bid = $_[0];

  my $dbh = Syvum::Common::DBInit::getHandler();

  my $boardsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."boards";
  my $sth = $dbh->prepare("SELECT BoardURL FROM $boardsTable where BoardID=$bid");
  $sth->execute();
  my @data = $sth->fetchrow_array;
  $sth->finish();
  return ($data[0]);
}

sub getBoardID
{
  my $bname = $_[0];

  my $dbh = Syvum::Common::DBInit::getHandler();

  $bname = $dbh->quote($bname);

  my $boardsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."boards";
  my $sth = $dbh->prepare("SELECT BoardID FROM $boardsTable where BoardName=".$bname);
  $sth->execute();

  my @data = $sth->fetchrow_array;
  $sth->finish();
  return ($data[0]);
}

sub doesThreadExist
{
  my $board = $_[0];
  my $thread = $_[1];

  my $dbh = Syvum::Common::DBInit::getHandler();

  my $threadID = $board."_".$thread;
  my $threadIDq = $dbh->quote($threadID);
  #$boardIDq = $dbh->quote($board);

  my $ret = 0;

  my $threadsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."threads";

  #my $sth = $dbh->prepare("SELECT Messages FROM $threadsTable WHERE BoardID = ".$boardIDq." AND ThreadID = ".$threadIDq);
  my $sth = $dbh->prepare("SELECT Messages FROM $threadsTable WHERE ThreadID = ".$threadIDq);
  $sth->execute();

  my @files = $sth->fetchrow_array; 
  if (@files)
    {
      $ret = 1;
    }
  else
    {
      $ret = 0;
    }

  $sth->finish();

  return $ret;
}

sub getBoardThreadCount
{
  my $board = $_[0];

  my $dbh = Syvum::Common::DBInit::getHandler();

  my $threadsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."threads";
  my $sth = $dbh->prepare("SELECT count(*) FROM $threadsTable WHERE BoardID = ".$board);
  $sth->execute();

  my @data = $sth->fetchrow_array;

  $sth->finish();
  return ($data[0]);
}

sub getMessage
{
  my $messageID = $_[0];
  my $thisuid = $_[1];
  my $board = $_[2];

  my $perm = checkPermission($thisuid, $viewAction, $board);
  if ($perm != 1)
    {
      print "Content-type: text/html\n\n";
      print "Not allowed (gm).  If you think this message is in error, please <a href=/contact.html>contact us</a>";
      die;
    }

  my $dbh = Syvum::Common::DBInit::getHandler();

  $messageID = $dbh->quote($messageID);
  my $dbmesgTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."dbmesg";

  my $sth = $dbh->prepare("SELECT UserId, Name, Subject, Data, InReplyTo, Time FROM $dbmesgTable WHERE MessageID = ".$messageID);
  $sth->execute();

  my @data = $sth->fetchrow_array;

  $sth->finish();

  $data[1] =~ s/</\&lt;/gs;
  $data[2] =~ s/</\&lt;/gs;
  $data[3] =~ s/</\&lt;/gs;

  return (\@data);
}

sub getNewMessages
{
  my $lastCheck = $_[0];
  my $thisuid = $_[1];

  my $perm = isSuper($thisuid);
  if ($perm != 1)
    {
      print "Content-type: text/html\n\n";
      print "Not allowed (gnm).  If you think this message is in error, please <a href=/contact.html>contact us</a>";
      die;
    }

  my $dbh = Syvum::Common::DBInit::getHandler();

  my $dbmesgTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."dbmesg";

  my $sth = $dbh->prepare("SELECT MessageID, UserId, Name, Subject, Data, Time FROM $dbmesgTable WHERE Time >= ".$lastCheck." ORDER BY Time");
  $sth->execute();

  my (@midref, %uidref, %nameref, %subref, %dataref, %timeref);
  my @data = $sth->fetchrow_array;

  while (@data)
    {
      $data[1] =~ s/</\&lt;/gs;
      $data[2] =~ s/</\&lt;/gs;
      $data[3] =~ s/</\&lt;/gs;
      $data[4] =~ s/</\&lt;/gs;
      push @midref, $data[0];
      $uidref{$data[0]} = $data[1];
      $nameref{$data[0]} = $data[2];
      $subref{$data[0]} = $data[3];
      $dataref{$data[0]} = $data[4];
      $timeref{$data[0]} = $data[5];
      @data = $sth->fetchrow_array;
    }

  $sth->finish();

  return (\@midref, \%uidref, \%nameref, \%subref, \%dataref, \%timeref);
}

sub getReplyCount
{
  my $messageID = $_[0];

  my $dbh = Syvum::Common::DBInit::getHandler();

  $messageID = $dbh->quote($messageID);

  my $dbmesgTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."dbmesg";
  my $sth = $dbh->prepare("SELECT count(*) FROM $dbmesgTable WHERE InReplyTo = ".$messageID);
  $sth->execute();

  my @data = $sth->fetchrow_array;

  $sth->finish();

  return ($data[0]);
}

sub isReplyTo
{
  my $thismessageID = $_[0];
  my $origmessageID = $_[1];

  my $dbh = Syvum::Common::DBInit::getHandler();

  $thismessageID = $dbh->quote($thismessageID);

  my $dbmesgTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."dbmesg";
  my $sth = $dbh->prepare("SELECT InReplyTo FROM $dbmesgTable WHERE MessageID = ".$thismessageID);
  $sth->execute();

  my @data = $sth->fetchrow_array;

  my $ret = 0;
  if ($data[0] eq $origmessageID)
    {
      $ret = 1;
    }
  else
    {
      $ret = 0;
    }
  $sth->finish();

  return ($ret);
}

sub removeMessage
{
  my $board = $_[0];
  my $thread = $_[1];
  my $message = $_[2];
  my $thisuid = $_[3];

  my $perm = checkPermission($thisuid, $deleteAction, $board);
  if ($perm != 1)
    {
      print "Content-type: text/html\n\n";
      print "Not allowed (rm).  If you think this message is in error, please <a href=/contact.html>contact us</a>";
      die;
    }

  my $status = 0;
  my $mesg = "";

  my $messageID = $board."_".$thread."_".$message;

  my $dbh = Syvum::Common::DBInit::getHandler();

  $messageID = $dbh->quote($messageID);

  my $threadsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."threads";
  my $dbmesgTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."dbmesg";

  my $sth = $dbh->prepare("SELECT UserId, Name, Subject, Data, InReplyTo FROM $dbmesgTable WHERE MessageID = ".$messageID);
  $sth->execute();

  my @md = $sth->fetchrow_array;

  if (@md)
    {
      $sth = $dbh->prepare("SELECT Messages, DeletedMessages FROM $threadsTable WHERE BoardID = ".$board." AND ThreadID = ".$thread);
      $sth->execute();

      my @data = $sth->fetchrow_array;
#      $mesg = $data[0];

      my $numDel = 0;
      if (defined $data[1] && length $data[1] > 0)
        {
          while ($data[1] =~ /,/g)
            {
              $numDel++;
            }
        }

      if ($numDel > 0)
        {
          $numDel--;
        }

      if ($data[0] == 1 && $message == 0 || $numDel + 1 == $data[0])
        {
          $sth = $dbh->prepare("DELETE FROM $threadsTable WHERE BoardID = ".$board." AND ThreadID = ".$thread);
          $sth->execute();
    
          $sth = $dbh->prepare("DELETE FROM $dbmesgTable WHERE MessageID = ".$messageID);
          $sth->execute();
          $status = 1;
          $mesg = "$STRINGS{$ENV{DOCUMENT_ROOT}}->[206]";
        }
      elsif ($message < $data[0] && (!$data[1] || $data[1] !~ /,$message,/ ))
        {
          if (defined $data[1] && length $data[1] > 0)
            {
              $data[1] .= $message.",";
            }
          else
            {
              $data[1] = ",".$message.",";
            }

          $data[1] = $dbh->quote($data[1]);
          $sth = $dbh->prepare("UPDATE $threadsTable set DeletedMessages = ".$data[1]." WHERE BoardID = ".$board." AND ThreadID = ".$thread);
          $sth->execute();
    
          $sth = $dbh->prepare("DELETE FROM $dbmesgTable WHERE MessageID = ".$messageID);
          $sth->execute();
          $status = 1;
          $mesg = "$STRINGS{$ENV{DOCUMENT_ROOT}}->[207]";
        }
      elsif (defined $data[1] && $data[1] =~ /,$message,/ )
        {
          $status = 1;
          $mesg = "$STRINGS{$ENV{DOCUMENT_ROOT}}->[208]";
        }
    }
  else
    {
      $status = 0;
      $mesg = "$STRINGS{$ENV{DOCUMENT_ROOT}}->[209]";
    }

  $sth->finish();
  return ($status, $mesg);
}

sub removeThread
{
  my $board = $_[0];
  my $thread = $_[1];
  my $thisuid = $_[2];

  my $perm = checkPermission($thisuid, $deleteAction, $board);
  if ($perm != 1)
    {
      print "Content-type: text/html\n\n";
      print "Not allowed (rt).  If you think this message is in error, please <a href=/contact.html>contact us</a>";
      die;
    }

  my $status;
  my $mesg;

  my $dbh = Syvum::Common::DBInit::getHandler();

  my $boardsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."boards";
  my $threadsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."threads";

  my $sth = $dbh->prepare("SELECT Threads FROM $boardsTable WHERE BoardID = ".$board);
  $sth->execute();
  my @data = $sth->fetchrow_array;

  if ($data[0] =~ s/,$thread,/,/)
    {
      removeThreadMessages($board, $thread, $thisuid);
      if ($data[0] eq ",")
        {
          $data[0] = "";
        }

      $data[0] = $dbh->quote($data[0]);
      $sth = $dbh->prepare("UPDATE $boardsTable SET Threads=".$data[0]." WHERE BoardID=".$board);
      $sth->execute();

      $sth = $dbh->prepare("DELETE FROM $threadsTable WHERE BoardID = ".$board." AND ThreadID = ".$thread);
      $sth->execute();
      $sth->finish();
      $status = 1;
      $mesg = "$STRINGS{$ENV{DOCUMENT_ROOT}}->[210]";
    }
  else
    {
      $status = 0;
      $mesg = "$STRINGS{$ENV{DOCUMENT_ROOT}}->[211]";
    }

  return ($status, $mesg);
}

sub removeThreadMessages
{
  my $board = $_[0];
  my $thread = $_[1];
  my $thisuid = $_[2];

  my $status;
  my $mesg;

  my $dbh = Syvum::Common::DBInit::getHandler();

  my $threadsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."threads";

  my $sth = $dbh->prepare("SELECT Messages FROM $threadsTable WHERE BoardID = ".$board." AND ThreadID = ".$thread);
  $sth->execute();

  my @data = $sth->fetchrow_array;
  my $i;
  if ($data[0] > 0)
    {
      for ($i = 0; $i < $data[0]; $i++)
        {
          removeMessage($board, $thread, $i, $thisuid);
        }
    }
  $sth->finish();
}

sub removeBoard
{
  my $board = $_[0];
  my $thisuid = $_[1];

  my $status;
  my $mesg;

  my $perm = checkPermission($thisuid, $deleteAction, $board);
  if ($perm != 1)
    {
      print "Content-type: text/html\n\n";
      print "Not allowed (rb).  If you think this message is in error, please <a href=/contact.html>contact us</a>";
      die;
    }

  my $dbh = Syvum::Common::DBInit::getHandler();

  my $boardsTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."boards";

  my $sth = $dbh->prepare("SELECT Threads FROM $boardsTable WHERE BoardID = ".$board);
  $sth->execute();
  my @data = $sth->fetchrow_array;

  $data[0] =~ s/^,//;
  $data[0] =~ s/,$//;

  my $i;
  if (length $data[0] > 0)
    {
      my @threads = split(/,/, $data[0]);
      my $maxTh = scalar @threads;
      for ($i = 0; $i < $maxTh; $i++)
        {
          removeThread($board, $threads[$i]);
        }

      $sth = $dbh->prepare("DELETE FROM $boardsTable WHERE BoardID = ".$board);
      $sth->execute();

      $sth->finish();
      $status = 1;
      $mesg = "$STRINGS{$ENV{DOCUMENT_ROOT}}->[212]";
    }
  else
    {
      $status = 0;
      $mesg = "$STRINGS{$ENV{DOCUMENT_ROOT}}->[213]";
    }

  return ($status, $mesg);
}

sub getDeleteAction
{
  return ($deleteAction);
}

sub getCreateThreadAction
{
  return ($createThreadAction);
}

sub getUserList
{
  my $messageId = shift;
  my $userTupList = "";
  my $userTdnList = "";

  my $dbh = Syvum::Common::DBInit::getHandler();
  my $messageIdq = $dbh->quote($messageId);
  my $dbmesgTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."dbmesg";
  my $sth;

  $sth = $dbh->prepare("SELECT MessageId, UserTUP, UserTDN FROM $dbmesgTable WHERE MessageId = ".$messageIdq);
  $sth->execute();
  my @data = $sth->fetchrow_array;
  my $retMessageId = $data[0];
  $userTupList = $data[1];
  $userTdnList = $data[2];

  return ($userTupList, $userTdnList, $retMessageId); 
}
  
sub updateUserVote
{
  my $messageId = shift; 
  my $userTupList = shift;
  my $userTdnList = shift;

  my $dbh = Syvum::Common::DBInit::getHandler();
  my $messageIdq = $dbh->quote($messageId);
  my $userTupListq = $dbh->quote($userTupList);
  my $userTdnListq = $dbh->quote($userTdnList);
  my $sth;
  my $dbmesgTable = $memdbinit::tablePrefix2{$ENV{DOCUMENT_ROOT}}."dbmesg";
  $sth = $dbh->prepare("UPDATE $dbmesgTable set UserTUP = ".$userTupListq.", UserTDN = ".$userTdnListq." WHERE MessageId = ".$messageIdq);
  $sth->execute();
  $sth->finish();
}

(1);
