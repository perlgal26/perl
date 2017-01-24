#! /usr/bin/perl

use strict;
use CGI;
use Syvum::Fs::Dirs;
use Syvum::Online::InfoPage;
use Syvum::Members::Session;
use Syvum::Strings::Online_texts;
use Syvum::Board::Board;
use Syvum::editor::ContribAns;
use Syvum::editor::SatFunction;
#use Syvum::editor::HtmlChecker;
use Syvum::Utils;
use Syvum::Online::AddSteps;
#Syvum::Members::Session::init();

# IS_ENTRY_POINT
# DB NEEDS : memdb, fsdb

# BEGIN INIT BLOCK ******************
#

  Syvum::Common::DBInit::initHandler();
  Syvum::Members::Session::init();

#
# END INIT BLOCK ********************


print "Content-type: text/html\n\n";

my $userID = Syvum::Members::Session::getCurrentUserID();
my $dname = "Syvum Technologies Inc.";

my $queryString = $ENV{QUERY_STRING};
my @queryData = split(/%%%/, $queryString);

my $id = $queryData[0];
my $title = $queryData[1];
my $fileName = $queryData[2];
$fileName = Syvum::Fs::Dirs::longenPath($fileName);
my $contans_flag = $queryData[3];
$fileName =~ /^\/u\/(.*?)\/.*?/g;
my $divId = "$id"."_"."$userID";
my $class = "odd";

my $thread = "";
my $messageId = "";

my $len = $ENV{CONTENT_LENGTH} ? $ENV{CONTENT_LENGTH} : 0;
my $tableref = Syvum::Utils::getPostVars($Syvum::Utils::DO_CHECK);
my %table = %$tableref;
if ($len > 0)
  {

    if ($table{replyto})
      {
      }
    else
      {
        $table{replyto} = "";
      }

    if (!defined $table{threadURL})
      {
        $table{threadURL} = "";
      }
    if ($contans_flag == 0 && defined $table{answer} && length $table{answer} == 0)
      {
        print "No answer was provided.  Please <span onclick=\"history.go(-1);\" style=\"cursor:pointer;color:blue;\">go back</span> and enter the answer.";
        exit;
      }
    elsif ($contans_flag == 1 && defined $table{explanation} && length $table{explanation} == 0)
      {
        print "No answer/explanation was provided.  Please <span onclick=\"history.go(-1);\" style=\"cursor:pointer;color:blue;\">go back</span> and enter the answer/explanation.";
        exit;
      }
    my $subject = "Contributed Answer/Explanation to Q. $id";
    my $message = "";

# Contans_flag is set to 1 when the author has already provided the answer.
    if ($contans_flag == 1)
      {
        $message = $table{hiddenanswer}."\n".$table{explanation};
      }
    else 
      {
        $message = $table{answer}."\n".$table{explanation};   
      }    
 
    $message =~ s/<(.*?)>//g;
    if (!defined $table{oldMsgId})
      {
        $table{oldMsgId} = "";
      }

    ($thread, $messageId) = Syvum::Board::Board::post($table{board}, $table{thread}, $table{threadURL}, $subject, $userID, $userID, $message, $table{oldMsgId});

    Syvum::editor::ContribAns::insertContAnsTxt($userID, $table{answer}, $table{explanation}, $id, $fileName, $title, $messageId, $table{oldMsgId}, $contans_flag, $table{board}, $table{thread});
    if (defined $table{oldMsgId} && length $table{oldMsgId} > 0)
      { 
        $messageId = $table{oldMsgId};
      }  
    my $allDivCont = Syvum::Online::XMLParser::createEachAnsExpDiv($userID, $id, $messageId, $messageId."_tup", "0", $messageId."_tdn", "0", $table{board}, $table{thread}, $table{answer}, $table{explanation}, $contans_flag, $userID, $fileName, $class);

#    if (defined $table{send})
#      {
#        my $emailMessage =<<EOF;
#        From: $table{name}
#        To: $table{email}
#        Subject: Contribute Answers
#        Content-type: text/plain; charset=utf-8
#        Your friend has invited to contribute answers.
#EOF
#       Syvum::Members::Messages::sendEmail($emailMessage); 
#       open(SENDMAIL, "|/usr/lib/sendmail from ymakwana\@gmail.com>>/tmp/email.txt");
#       print SENDMAIL<<EOF;  
#       To: < pawarsheetal26\@gmail.com >
#       Subject: TESTING CCAP.HAVE FUN!!!!!!!!
#EOF
#       close(SENDMAIL);
 
#	print <<EOF;
#content type: text/html

#<html>
#<body>
#<h3>Invitation sent from $table{name} to $table{email}</h3>
#</body>
#</html>

#EOF
#      }

print<<EOF;
<html>
<head>
<script language ='Javascript' text='text/javasript'>
function setParentDivCont()
  {
    document.getElementById('divCont').style.visibility="hidden";
    if (window.opener.document.getElementById(\'$divId\') != null)
      {
        window.opener.document.getElementById(\'$divId\').innerHTML = document.getElementById('divCont').value;
        window.close();   
      }
    else
      {
        window.opener.document.getElementById("empty_$id").innerHTML = document.getElementById('divCont').value;
        window.close(); 
      }
  }
</script>
</head> 
<body onload='setParentDivCont()'>
Your Answer/Explanation has been successfully posted.<br/><br/>
<textarea rows="10" cols="50" id="divCont">$allDivCont</textarea>
</body>
</html>
EOF

#Invite your friends to Contribute answers.
#<form method="post" action="/cgi/editor/contans.cgi">
#<table><tr><td>Your First Name:</td><td><input size="10" name="name" value="ymakwana\@gmail.com" type="text"></td></tr>
#<tr><td>Email Address to Send to:</td><td><input size="10" name="email" value="" type="text"></td></tr>
#<tr><td><input name="send" value="Send" type="submit"></td></tr>
#</table>
  } 
else
  {
    $fileName =~ s/\.html$/.tdf/g;  
    if (defined $fileName && length $fileName > 0)
      {
        my ($tref, $nref) = Syvum::Board::Board::getThreadsFromURL($fileName);
        my %threads = %$tref;
        my @threadKeys = keys %threads;
    	$table{board} = $threads{$threadKeys[0]};
    	$table{thread} = $threadKeys[0];
      }

    if (length $userID == 0)
      {
        my $loginform =<<EOF;
<form method="post" action="/cgi/members/login.cgi"><table><tr><td><b>User ID</b></td><td><input type="text" size="10" maxlength="20" name="UserID"></td></tr><tr><td><b>Password</b></td><td><input type="password" size="10" maxlength="20" name="Password"></td></tr></table><input type="hidden" name="TargetURL" value="/cgi/editor/contans.cgi?$queryString"><input type="submit" name="submit" value = "Login"></form>
EOF

        print <<EOF;
        <html>
        <body>
        You must be signed in as a member to use this feature.<br/><br/>
        $loginform</br></br>
        If you are not yet a member, you can <a href="/members/register.html" target="_blank">register here</a>.<br/>
        </body>
        </html>
EOF
      }
    else
      {
        my $oldMsgId = "";
        my $que = "";  
        my $answer = "";
        my $disabledAnswer = "";
        my $explanation = "";
        my $onlyExplanation = ""; 
        my $finalExplanation = "";
        my $ccapString = "";  
        my $fileData = Syvum::Online::Files::getFile($fileName);#To retrieve the answers.
        my $mathDiv = Syvum::editor::ContribAns::mathDiv();# To get the math div.


        if (defined $fileData && length $fileData > 0)
          { 
            $fileData =~ s/.*?<que>/<que>/si;
            my @queArray = split(/<\/que>/, $fileData);
            my $qatext = $queArray[$id - 1];
 
 #           Syvum::Debug::debugOut('sheetz1.txt',$qatext);  
             
            $qatext =~ /<inp>(.*?)<\/inp>/gs;
            $que = $1;
            if ($contans_flag == 1 && $qatext =~ /<ans>(.*?)<\/ans>/gs)
              {
                my $new_qatext = $1;
                $new_qatext =~ /<out>(.*?)<\/out>/gs;  
                $disabledAnswer = $1;
                if ($qatext =~ /<cans\s*c=\"$userID;(.*?);(.*?);(.*?)\">/gsi)
                  {
                    $oldMsgId = $1;
                    $qatext =~ /<exp>(.*?)<\/exp>/gs;
                    $explanation = $1;
                    # change the regular expression.
                    $explanation =~ s/\(Contributed by\s*:\s*$userID\)$//gs;
                    if ($explanation =~ /\S+/gs)
                      {
                        $finalExplanation = $explanation;
                      }
                  }
 
              }
            if ($contans_flag == 0 && $qatext =~ /<cans\s*c=\"$userID;(.*?);(.*?);(.*?)\">/gsi)
              {
                $oldMsgId = $1;
                $qatext =~ /<out>(.*?)<\/out>/gs;
                $answer = $1;
                $qatext =~ /<exp>(.*?)<\/exp>/gs; 
                $explanation = $1;
                # change the regular expression. 
                $explanation =~ s/\(Contributed by\s*:\s*$userID\)$//gs;
                if ($explanation =~ /\S+/gs)
                  {
                    $finalExplanation = $explanation;
                  }
              } 
          }

        my $title_twt = $title;
        $title_twt =~ tr/+/ /;
        $title_twt =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
        $title_twt =~ s/~!/ ~!/g;

        my $max_length_twt_title = 30;
        if (length $title_twt > $max_length_twt_title)
          {
            $title_twt = substr ($title_twt, 0 , 27)."...";
          }

        $ccapString .=<<EOF;
        <html>
        <head>
        <baseurl href="/cgi/online/serve.cgi$fileName"/>
	<script language="javascript" type="text/javascript" src="/saw/jscripts/saws/saws_src.js"></script>
	<script type="text/javascript" src="/saw/jscripts/saws/saws_gzip.js"></script>
	<script type="text/javascript" src="/saw/SatFunction_Editor.js"></script>

        <script language="javascript" type="text/javascript">
        var current_browser = navigator.appName;  
        SAWs.init({
	                 mode : "textareas",
			 theme : "ccap",
			 plugins : "akindicplugin,equation_ccap,searchreplace,contextmenu,paste,spellchecker,advimage",
//                         theme_advanced_buttons2_add_before: "fontselect,fontsizeselect,link,spellchecker",
	                 theme_advanced_buttons2_add_before: "undo,redo,akindicplugin,advimage,spellchecker",
                         file_browser_callback : "fileBrowserCallBack", 
	                 theme_advanced_toolbar_location : "top",
	                 theme_advanced_toolbar_align : "left",
	                 theme_advanced_path_location : "bottom",
	                 theme_advanced_resize_horizontal : false,
	                 theme_advanced_resizing : true,
	                 nonbreaking_force_tab : true,
	                 theme_advanced_path : false,
                         relative_urls : false,
                         entities : "",
                         remove_traling_nbsp : true,
	                 apply_source_formatting : true,
	                 spellchecker_languages : "+English=en,French=fr,Portuguese=pt",
	                 spellchecker_report_mispellings : true
																													                 });
        function fileBrowserCallBack(field_name, url, type, win) 
          {
           // This is where you insert your custom filebrowser logic
           alert("Example of filebrowser callback: field_name: " + field_name + ", url: " + url + ", type: " + type);
           // Insert new URL, this would normaly be done in a popup
           win.document.forms[0].elements[field_name].value = "someurl.htm";
          } 
																															 
        function validateForm()
          {
            var answer = document.getElementById("answer").value;
            var explanation = document.getElementById("explanation").value;
            if (answer == "")
              {
                alert("Please enter the answer");
                return false;
              }
            var winloc = window.opener.location;
            var ranindx = Math.floor(Math.random()*6);
            var twtmsgarr  = new Array(6);
            twtmsgarr[0] = 'Check my contribution to $title_twt at Syvum: ';
            twtmsgarr[1] = 'I provided an answer to $title_twt at Syvum: ';
            twtmsgarr[2] = 'I contributed an answer to $title_twt at Syvum: ';
            twtmsgarr[3] = 'Just added an answer to $title_twt at Syvum: ';
            twtmsgarr[4] = 'Rate my answer to $title_twt at Syvum: ';
            twtmsgarr[5] = 'Vote for my answer to $title_twt at Syvum: ';  
            var twtURL   = 'http://twitter.com/home?source=syvum&status=';    
            var twtmsg = twtURL + encodeURIComponent(twtmsgarr[ranindx]+ winloc);
            var fbmsg = 'http://www.facebook.com/sharer.php?u='+encodeURIComponent(winloc)+'&t='+encodeURIComponent("$title_twt");
            if(document.getElementById('fb').checked == true)
	      {
                window.open(fbmsg);
              }
            if(document.getElementById('twt').checked == true)
              {
                window.open(twtmsg);
              }
             
            return true; 

          }   
        function textCounter(field, countfield, maxlimit) 
          {
            if (field.value.length > maxlimit) 
              {
                field.value = field.value.substring(0, maxlimit); 
              }
            else
              {
                countfield.value = maxlimit - field.value.length; 
              }
          }

        </script>  
        </head>
        <body>
        <table align="right"><td><a target="_blank" href="/"><font size="2">Syvum Home</font></a></td></table><br/>
EOF
        my $showque = "<step name=\"Show Question\">$que</step>";
        my $showans = "";

        if (defined $table{board} && $table{board} > 0)
          {
            $ccapString .=<<EOF;            
            <form method="post" name="ccapForm" onsubmit="return validateForm();">
	    <input type="hidden" name="board" value="$table{board}">
	    <input type="hidden" name="thread" value="$table{thread}">
            <input type="hidden" name="oldMsgId" value="$oldMsgId"> 
            $showque<br/>
            <table>
EOF
          }
        else # To start a new board
          {
            $ccapString .=<<EOF;
            <form method="post" name="ccapForm" onsubmit="return validateForm();">
            <input type="hidden" name="board" value="11">
            <input type="hidden" name="thread" value="new">
            <input type="hidden" name="threadURL" value = "$fileName">
            $showque<br/>
            <table>
EOF
          }    
        if ($contans_flag == 1)
          { 
	    $showans = "<step name=\"Show Model Answer\">$disabledAnswer</step>";
		    
            $ccapString .=<<EOF;
            $showans<br/>  
	    <tr><td><b>Enter Your Answer / Explanation Below:</b></td></tr>
            <tr> <td><textarea id="explanation" name="explanation" cols="70" rows="10" maxlength="4096" onkeydown="textCounter(this.form.explanation, this.form.expLen, 4096);" onkeyup="textCounter(this.form.explanation, this.form.expLen, 4096); ">$finalExplanation</textarea></td></tr>

EOF
          }
        else
          {
            $ccapString .=<<EOF;
            <tr><td><b>Enter Your Answer Below:</b></td></tr>
            <tr><td><input type="text" id="answer" name="answer" size="65" value="$answer" maxlength="256" onkeydown="textCounter(this.form.answer, this.form.ansLen, 256);" onkeyup="textCounter(this.form.answer, this.form.ansLen, 256);">&nbsp;&nbsp;<input name="ansLen" type="text" id="ansLen" value="256" size="3" disabled/><font size="-1">characters still available.</font></td></tr>
	    <tr><td><b>Enter Your Explanation Below:</b></td></tr>
	    <tr><td><textarea id="explanation" name="explanation" cols="70" rows="10" maxlength="4096" onkeydown="textCounter(this.form.explanation, this.form.expLen, 4096);" onkeyup="textCounter(this.form.explanation, this.form.expLen, 4096); ">$finalExplanation</textarea></td></tr>

EOF
          }
        $ccapString .=<<EOF;
        <tr><td><span style="color:blue;font-size=70%;cursor:pointer;text-decoration:underline;" onclick="SAWs.execInstanceCommand('mce_editor_0','mceSpellCheck');return false;">Spellcheck your answer</span></td></tr>
    	<tr>
        <td><input type="submit" value="Submit"/>&nbsp;&nbsp;<input type="button" value="Cancel" onClick="window.close();"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Share your answer:<input type="checkbox" id="fb" name="fb" /><img border='0' src ='/s_i/sh/fcb.png' title='facebook'/>&nbsp;&nbsp;<input type="checkbox" id="twt" name="twt" /><img border='0' src ='/s_i/sh/twt.png' title='twitter'/></td>
        <td>$mathDiv</td>
        </tr>
    	</table>
        <input type="hidden" id="probletflag">
        </form>
        <table width="100%" bgcolor="#000088" cellspacing="0" border="0">
        <tr>
        <td><a target="_blank" href="/contact.html"><font color="#ffffff" size="-2" face="verdana">$STRINGS{$ENV{DOCUMENT_ROOT}}->[61]</font></a></td>
        <td align="center"><font color="#ffffff" size="-2" face="verdana"> &copy; 1999 - 2009, $dname</font></td>
        <td align=right>
        <a target="_blank" href="/legal/privacy.html"><font color="#ffffff" size="-2" face="verdana">$STRINGS{$ENV{DOCUMENT_ROOT}}->[62]</font></a>
        <a target="_blank" href="/legal/copyrt.html"><font color="#ffffff" size="-2" face="verdana">$STRINGS{$ENV{DOCUMENT_ROOT}}->[63]</font></A></td>
        </tr>
        </table>
        </body>
    	</html>
EOF
       $ccapString = Syvum::Online::AddSteps::performSteps($ccapString);
       print $ccapString;
      }

  }
