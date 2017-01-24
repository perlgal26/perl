#!/usr/bin/perl

use strict;
use Syvum_data;
use Syvum::Members::Session;
use Syvum::Debug;
use Syvum::Common::DBInit;

package Syvum::editor::ContribAns;

sub insertContAnsTxt
{
  my $userId = shift;
  my $contribAns = shift;
  my $contribExp = shift;
  my $questionNum = shift;
  my $fileName = shift;
  my $title = shift;
  my $messageId = shift;
  my $oldMsgId = shift;
  my $contans_flag = shift;
  my $board_num = shift;
  my $thread_num = shift;
  my $count = 0;
  my $strlen = 0;
  my $insertPosition = 0;
  my $flag = 1;
  my $save_pub_flag = 3;
  my $DB_flag = 1;
  $fileName =~ s/\.(html|tdf)$/.xml/g;
  $fileName =~ /^\/u\/(.*?)\/.*?/g;
  my $authorId = $1;
  

  my $contribString = " (Contributed by : ".$userId.")";
  
  my $txtData = getTxtData($fileName,$authorId);
  
  pos($txtData) = 0;
 
  if (length $oldMsgId > 0 && $txtData =~ m/syvum=\"userid:$userId&[^&]*?messId:$oldMsgId/gs)
    {
       my $newAnswer = "";  
       if ($contans_flag == 0)
         {
            $newAnswer = "<img src=\"/s_i/cs.gif\" syvum=\"userid:".$userId."&messId:".$oldMsgId."&contans_flag:".$contans_flag."&tup:0&tdn:0\" title=\"Contributed Solution\" /><img src=\"/s_i/a.gif\" title=\"Answer\" />".$contribAns."<img src=\"/s_i/ac.gif\" title=\"End Answer\" /><p><img src=\"/s_i/e.gif\" title=\"Explanation\" />".$contribExp.$contribString."<img src=\"/s_i/ec.gif\" title=\"End Explanation\" /><img src=\"/s_i/csc.gif\" title=\"End Contributed Solution\" />";
         } 
       else
         {
           $newAnswer = "<img src=\"/s_i/cs.gif\" syvum=\"userid:".$userId."&messId:".$oldMsgId."&contans_flag:".$contans_flag."&tup:0&tdn:0\" title=\"Contributed Solution\" /><img src=\"/s_i/e.gif\" title=\"Explanation\" />".$contribExp.$contribString."<img src=\"/s_i/ec.gif\" title=\"End Explanation\" /><img src=\"/s_i/csc.gif\" title=\"End Contributed Solution\" />";
         } 
       $txtData =~ s/<img\s*[^>]*?syvum=\"userid:$userId&[^&]*?messId:$oldMsgId\s*[^>]*?>.*?<img\s*[^>]*?src=\"\/s_i\/csc.gif\"\s*[^>]*?>/$newAnswer/gs;
    }
  else
    {
      while ($txtData =~ m/(<img src=\"\/s_i\/qc\.gif\"[^>]*?>)/sg && $count < 300)
        {
          my $closeQues = $1;
          $strlen = length ($closeQues);
          $count++;
      
          if ($count == $questionNum)
            { 
              $insertPosition = pos($txtData);
              last;
            }
        }
      
      
      if ($contans_flag == 1)
        {
          if ($txtData =~ m/(<img src=\"\/s_i\/ac\.gif\"[^>]*?>)/sg && $count == $questionNum)
            {
              $insertPosition = pos($txtData);
              substr($txtData,$insertPosition,0) = "<br /><img src=\"/s_i/cs.gif\" syvum=\"userid:".$userId."&messId:".$messageId."&contans_flag:".$contans_flag."&tup:0&tdn:0\" title=\"Contributed Solution\" /><img src=\"/s_i/e.gif\" title=\"Explanation\" />".$contribExp.$contribString."<img src=\"/s_i/ec.gif\" title=\"End Explanation\" /><img src=\"/s_i/csc.gif\" title=\"End Contributed Solution\" /></p>";
            }
        } 
      else
        {
           substr($txtData,$insertPosition,0) = "<br /><img src=\"/s_i/cs.gif\" syvum=\"userid:".$userId."&messId:".$messageId."&contans_flag:".$contans_flag."&tup:0&tdn:0\" title=\"Contributed Solution\" /><img src=\"/s_i/a.gif\" title=\"Answer\" />".$contribAns."<img src=\"/s_i/ac.gif\" title=\"End Answer\" /><p><img src=\"/s_i/e.gif\" title=\"Explanation\" />".$contribExp.$contribString."<img src=\"/s_i/ec.gif\" title=\"End Explanation\" /><img src=\"/s_i/csc.gif\" title=\"End Contributed Solution\" /></p>";  
        }
    }


#  Code to replace the xml 7.10.2009.
 
  my $fileData = Syvum::Online::Files::getFile($fileName); # To retrieve the XML.
 
  pos($fileData) = 0;
  my $counter = 0;

  if (length $oldMsgId > 0 && $fileData =~ m/.*?<cans c=\"$userId;$oldMsgId;(.*?);(.*?)\"/is) 
    {
       my $newAnswer = "";

       if ($contans_flag == 1)
         {
           $newAnswer = "<cans c=\"$userId;$oldMsgId;0;0\"><exp>$contribExp$contribString</exp></cans>";
         }
       else
         {
           $newAnswer = "<cans c=\"$userId;$oldMsgId;0;0\"><out>$contribAns</out><exp>$contribExp$contribString</exp></cans>";
         }

       $fileData =~ s/<cans c=\"$userId;$oldMsgId;(.*?);(.*?)\">(.*?)<\/cans>/$newAnswer/is;
       
    }
  else
    {
      while ($fileData =~ m/(<\/que>)/sg && $counter < 300) # We can't use the </inp> tag here to locate the position since it occurs before the first <que> tag so we are using the </que> tag and then manipulating it to get the right position.
        {
          my $closeQues = $1;
          $strlen = length ($closeQues);
          $counter++;

          if ($counter == $questionNum)
            {
              $insertPosition = pos($fileData) - 6;
              last;
            }
        }

      if ($contans_flag == 1 && $counter == $questionNum)
        {
          substr($fileData, $insertPosition, 0) = "<cans c=\"$userId;$messageId;0;0\"><exp>$contribExp$contribString</exp></cans>";  
        }
      else
        {
          substr($fileData, $insertPosition, 0) = "<cans c=\"$userId;$messageId;0;0\"><out>$contribAns</out><exp>$contribExp$contribString</exp></cans>";
        }
    }

  
  my $diff = iodb::diffForVersioning($fileName, $txtData);
  Syvum_data::updateSyvum_data($fileName, $fileData, $txtData, $diff); 

} 

sub getTxtData
{
  my $fileName = shift;
  my $userId = shift;
  
  my $dataRef = Syvum_data::getAllDataSyvum_data($fileName,$userId);  
  my @fileData = @$dataRef;
  
  my $txtData = $fileData[2];

  return $txtData;
}

sub updateRatings
  {
    my $userId = shift;
    my $fileName = shift;
    my $message_id = shift;
    my $thumbs_up_value = shift;
    my $thumbs_down_value = shift;
    
    $fileName =~ s/\.(html|tdf)$/.xml/g;
    $fileName =~ /^\/u\/(.*?)\/.*?/g;
    my $authorId = $1;
#    my $flag = 1;
#    my $save_pub_flag = 4;
#    my $DB_flag = 1;
    my $txtData = getTxtData($fileName,$authorId);
    my $newRating = "&tup:".$thumbs_up_value."&tdn:".$thumbs_down_value;
   
    $txtData =~ s/&amp;/&/gs;
    $txtData =~ s/(syvum=\"[^&]*?&messId:$message_id.*?&contans_flag:[^&]*?)&[^\"]*?\"/$1$newRating\"/s;

    my $fileData = Syvum::Online::Files::getFile($fileName); # To retrieve the XML.
    $fileData =~ s/<cans c=\"(.*?);($message_id);(.*?);(.*?)\">/<cans c=\"$1;$2;$thumbs_up_value;$thumbs_down_value\">/s;

    my $diff = iodb::diffForVersioning($fileName, $txtData);
    Syvum_data::updateSyvum_data($fileName, $fileData, $txtData, $diff);


  }

sub bestAns
  {
    my $userId = shift;
    my $fileName = shift;
    my $messageId = shift;
    my $bestAns = shift;
    $fileName =~ s/\.(html|tdf)$/.xml/g;
    $fileName =~ /^\/u\/(.*?)\/.*?/g;
    my $authorId = $1;
    my $txtData = getTxtData($fileName,$authorId);
    my $bestansReplace = "&bestans:".$bestAns;
    $txtData =~ s/&amp;/&/gs;
    $txtData =~ s/(syvum=\"[^&]*?&messId:$messageId.*?)\"/$1$bestansReplace\"/s;
    my $fileData = Syvum::Online::Files::getFile($fileName); # To retrieve the XML.
    $fileData =~ s/<cans c=\"(.*?;$messageId;.*?;.*?)\">/<cans c=\"$1;$bestAns\">/s;
    my $diff = iodb::diffForVersioning($fileName, $txtData);
    Syvum_data::updateSyvum_data($fileName, $fileData, $txtData, $diff);
  }

sub deleteContAnswer
  {
    my $contributorUserId = shift;
    my $fileName = shift;
    my $messageId = shift;

    $fileName =~ s/\.(html|tdf)$/.xml/g;
    $fileName =~ /^\/u\/(.*?)\/.*?/g;
    my $authorId = $1;
   
    my $txtData = getTxtData($fileName,$authorId);
    $txtData =~ s/<img\s*[^>]*?syvum=\"userid:$contributorUserId&[^&]*?messId:$messageId\s*[^>]*?>.*?<img\s*[^>]*?src=\"\/s_i\/csc.gif\"\s*[^>]*?>//s;

    my $fileData = Syvum::Online::Files::getFile($fileName);
    $fileData =~ s/<cans c=\"$contributorUserId;$messageId;([^>]*?)\">(.*?)<\/cans>//s;

    my $diff = iodb::diffForVersioning($fileName, $txtData);
    Syvum_data::updateSyvum_data($fileName, $fileData, $txtData, $diff);

  }

sub mathDiv
  {
    my $mathdiv_display =<<EOF;
<div id = "matheq" style="position:absolute;left:250px; top:10px;z-index:7;background-color:#c4cfde;padding:2px;visibility:hidden"; >
<span style="float:left;"><a style="color:blue;cursor:pointer;" onclick ="hide();"><u>Hide</u></a></span><br />
<table width="120" height="50" border="0" cellspacing="5" align="left">
<tr>
                        <td><img src="http://scripts.syvum.com/s_i/mtr.gif" title="Matrix" onclick="matrix();" /></td>
                        <td><img src="http://scripts.syvum.com/s_i/fr1.gif" title="Fraction" onclick="fractions();" /></td><td><img src="http://scripts.syvum.com/s_i/fr3.gif" title="Integral" onclick="integral();" /></td>
                        <td><img src="http://scripts.syvum.com/s_i/fr4.gif" title="Summation" onclick="summation();" /></td>
                        <td><img src="http://scripts.syvum.com/s_i/fr2.gif" title="radic" onclick="radic();"/></td>
</tr>
</table>
</div>
EOF
    return($mathdiv_display);
  }


1;


