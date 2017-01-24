#!/usr/bin/perl

package Syvum::Members::changepw;

use strict;
use CGI;
use Syvum::Common::DBInit;
use Syvum::Members::Functions;
use Syvum::Members::Session;
use Syvum::Members::Info;
use Syvum::Topbot;
use Syvum::Strings::Members_texts;
use Syvum::Fs::Fsfiles;
use uploadFunction;
use Syvum::Members::UploadFunctions;
use Image::Size 'html_imgsize';
use Syvum::Utils;
# IS_ENTRY_POINT
# DB NEEDS : memdb

# BEGIN INIT BLOCK ******************
#
  Syvum::Common::DBInit::initHandler();
  Syvum::Members::Session::init();
#
# END INIT BLOCK ********************

my $userID = Syvum::Members::Session::getCurrentUserID();

my $topString = Syvum::Topbot::getTop();
my $botString = Syvum::Topbot::getBottom();
my $formdata = new CGI();
if (length $userID == 0)
  {
    print "Content-type:text/html\n";
    print "\n";

    print <<EOF;
    <html>
    <head>
    <title>$STRINGS{$ENV{DOCUMENT_ROOT}}->[53]</title>
    <base href=\"http://$ENV{HTTP_HOST}/index.html\">
    </head>
    <body bgcolor=white>
    $topString
    <h1>$STRINGS{$ENV{DOCUMENT_ROOT}}->[53]</h1>
    $STRINGS{$ENV{DOCUMENT_ROOT}}->[54]
    $botString
    </body></html>
EOF
    die;
  }
else
  {
    my %uinfo = Syvum::Members::Info::getMemberInfo($userID);
    my @showInProfile = Syvum::Members::Info::getData($userID, "ShowInProfile");
    my %checkedForProfile;
    if (@showInProfile)
      {
        foreach my $sip (@showInProfile)
          {
            $checkedForProfile{$sip} = " checked";
          }
      }
    else
      {
        $checkedForProfile{Name} = " checked";
        $checkedForProfile{Photo} = " checked";
        $checkedForProfile{AboutMe} = " checked";
        $checkedForProfile{Age} = " checked";
        $checkedForProfile{Gender} = " checked";
        $checkedForProfile{Profession} = " checked";
        $checkedForProfile{Organization} = " checked";
        $checkedForProfile{Achievements} = " checked";
        $checkedForProfile{Location} = " checked";
      }

    my $dirText = Syvum::Members::Functions::getDirText("account", 2, $uinfo{type}, $userID);

    my $len = $ENV{'CONTENT_LENGTH'} ? $ENV{'CONTENT_LENGTH'} : 0;

    my %table;

    if ($len <= 0)
      {
        my $str478 = $STRINGS{$ENV{DOCUMENT_ROOT}}->[478];
        $str478 =~ s/_var1_/$userID/s;
        my $disable = "";
        print "Content-type:text/html\n\n";
        print <<EOF;
<html><head>
<title>$str478</title>
<script language=JavaScript1.2>
function setMemberType()
{
  var memberAge = document.regForm.Age.value;
  if (memberAge == "13-")
    {  
      document.regForm.type.value = "k";
      document.getElementById("imagediv").style.display = "none";
      document.getElementById("removeimage").style.display = "none";
      document.getElementById("age").style.display = "";
      document.getElementById("gender").style.display = "";  
      document.getElementById("name").style.display = "none";
      document.getElementById("email").style.display = "none";
      document.getElementById("profession").style.display = "none";
      document.getElementById("organization").style.display = "none";
      document.getElementById("location").style.display = "none";
      document.getElementById("change_pwd").style.display = ""; 
    }
  else if (memberAge == "13+")
    {
      document.regForm.type.value = "t";
      document.getElementById("imagediv").style.display = "";
      document.getElementById("removeimage").style.display = "";
      document.getElementById("age").style.display = "";
      document.getElementById("gender").style.display = "";
      document.getElementById("name").style.display = "";
      document.getElementById("email").style.display = "";
      document.getElementById("profession").style.display = "";
      document.getElementById("organization").style.display = "";
      document.getElementById("location").style.display = "";
      document.getElementById("change_pwd").style.display = "";
    }
  else
    {
      document.regForm.type.value = "g";
      document.getElementById("imagediv").style.display = "";
      document.getElementById("removeimage").style.display = "";
      document.getElementById("age").style.display = "";
      document.getElementById("gender").style.display = "";
      document.getElementById("name").style.display = "";
      document.getElementById("email").style.display = "";
      document.getElementById("profession").style.display = "";
      document.getElementById("organization").style.display = "";
      document.getElementById("location").style.display = "";
      document.getElementById("change_pwd").style.display = "";
    }
}

function checkForm()
{
  if (document.regForm.Age.value != "0")
    {
      return true;
    }
  else
    {
      alert ('$STRINGS{$ENV{DOCUMENT_ROOT}}->[479]');
      document.regForm.Age.focus();
      return false;
    }
}

function showDiv (id, checkbox)
{
  var visible = (checkbox.checked) ? "" : "none";
  document.getElementById(id).style.display = visible;
}

function validateImage()
{
  var extensions = new Array("jpg","jpeg","gif","png","tif");
  var imgFile = document.getElementById("imgfile1").value;
  var imageLength = document.getElementById("imgfile1").value.length;
  var position = imgFile.lastIndexOf('.') + 1;
  var extension = imgFile.substring(position, imageLength);
  var finalExt = extension.toLowerCase();  
 
  for (i = 0; i < extensions.length; i++)  
     {  
       if (extensions[i] == finalExt)  
         {  
           return true;  
         }  
     }  
   
  alert("$STRINGS{$ENV{DOCUMENT_ROOT}}->[480]");
  document.getElementById('imgfile1').value = "";
}

function CheckFeilds()
{
  var reg = /^([A-Za-z0-9_\\-\\.])+\\@([A-Za-z0-9_\\-\\.])+\\.([A-Za-z]{2,4})\$/;
  var address = document.getElementById("emailId").value; 
  var message = 1;
  var imgFile = document.getElementById("imgfile1").value ;
  var name = document.getElementById("myName").value;
  var profession = document.getElementById("myProfession").value;
  var organization = document.getElementById("myOrganization").value; 
  var location = document.getElementById("myLocation").value;
  var currentPassword = document.getElementById("currentpwd").value;
  var chkbxValue = document.getElementById("checkbox1").checked;
  var chkbx2Value = document.getElementById("chkbx2").checked;
  var newpwd = document.getElementById("newpwd").value;
  var newconfpwd = document.getElementById("newconfpwd").value;
  if(chkbxValue == true && imgFile == "")
    {
      message = 0;
      alert("$STRINGS{$ENV{DOCUMENT_ROOT}}->[481]");
      return false;
    }

  if(name == "")
    {
      message = 0;
      alert('$STRINGS{$ENV{DOCUMENT_ROOT}}->[485] ');
      return false;
    }
  if(name.match(/\</g)!= null || profession.match(/\</g)!= null || organization.match(/\</g)!= null || location.match(/\</g)!= null)
    {
      message = 0;
      alert('$STRINGS{$ENV{DOCUMENT_ROOT}}->[486] ');
      return false;
    } 

  if(reg.test(address) == false) 
    { 
      message = 0;
      alert('$STRINGS{$ENV{DOCUMENT_ROOT}}->[482] ');
      return false;
    }
 
  if(currentPassword == "")
    {
      message = 0;
      alert('$STRINGS{$ENV{DOCUMENT_ROOT}}->[487] ');
      return false;
    }
  
  if((chkbx2Value == true) && (newpwd == "" || newconfpwd ==""))
    {
      message = 0;
      alert('$STRINGS{$ENV{DOCUMENT_ROOT}}->[488] ');
      return false;
   }
     
  if(message != 0)
    {
      document.getElementById("update").click();  
    }
 
} 

function checkUncheck()
{ 
  
  var chkbxValue = document.getElementById("checkbox1").checked;
  if(chkbxValue == true)
    {
      document.getElementById("rmvimage").disabled = true;
    }
}

function remove_image()
{
  var rmvimg = document.getElementById("rmvimage").checked;
  if (rmvimg == true )
    {
      document.getElementById("checkbox1").disabled = true;   
      var answer = confirm('$STRINGS{$ENV{DOCUMENT_ROOT}}->[489] ');
      if(answer)
       {
       }
      else
       {
         document.getElementById("rmvimage").checked = false;
       }
    }
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
</head><body bgcolor=white>
$topString
<center>
<font color=maroon><h1>$str478</h1></font>
</center>
<font color = red size = -1 >$STRINGS{$ENV{DOCUMENT_ROOT}}->[466]</font><br/>
$STRINGS{$ENV{DOCUMENT_ROOT}}->[483]
<center>
<form method="post" name="regForm" action=/cgi/members/changepw.cgi enctype="multipart/form-data" >
<table border=0>

EOF

        my $selectAge = "";
        my $other_display = "";
        my $selectGenderM = " ";
        my $selectGenderF = " ";
        my $displayrows="";

        if ($uinfo{type} eq "k")
          {
            $selectAge = <<EOF;
<select name="Age" onChange="setMemberType();">
<option value="13-" selected> &lt; 13 </option>
<option value="13+"> 13 - 18 </option>
<option value="19+"> &gt; 18 </option>
</select>
EOF
            $displayrows = "none";
          }
        else
          {
            if ($uinfo{type} eq "t")
              {
                $selectAge = <<EOF;
<select name="Age" onChange="setMemberType();">
<option value="13+" selected> 13 - 18 </option>
<option value="19+"> &gt; 18 </option>
</select>
EOF
            
              }
            else
              {
                $selectAge = <<EOF;
<select name="Age" onChange="setMemberType();">
<option value="19+" selected> &gt; 18 </option>
</select>
EOF
              }

          
          }
        my $path = "/u/01/".$userID.".gif";
        my ($ret,$fname) = Syvum::Fs::Fsfiles::doesFileExist($path);
        if ($ret == 0)
          {
            $path = "http://syvum.com/images/default_user.jpg";
            $disable = "disabled";
          }
        else
          {
            $path = "/cgi/online/serve.cgi/u/01/".$userID.".gif";
          }
        if ($uinfo{Gender} eq "M")
          {
            $selectGenderM = " checked";
          }
        elsif ($uinfo{Gender} eq "F")
          {
            $selectGenderF = " checked";
          }


print <<EOF;
<table border = 0>
<tr id ="name" style="display:$displayrows;" ><td><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[75]:</b> </td><td> <input name=xxxName  id ="myName" type=text size=40 maxlength=40 value="$uinfo{xxxName}"></td></tr>
<tr id ="email" style="display:$displayrows;" ><td valign=top ><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[76]:</b></td><td><input name=xxxEmail id = emailId type=text size=40 maxlength=40 value="$uinfo{xxxEmail}"><br><font color=red size=-1>$STRINGS{$ENV{DOCUMENT_ROOT}}->[62]</font></td></tr>
</table><br/>
<div align="left"  style="border: 1px solid black;">
<table id="other_details" style="display:$other_display;" border = 0>
<tr id ="imagediv" style="display:$displayrows;" ><td><div id = 'image'; style='width:64px;height:64px; background-color:'white><img src ='$path'; width = "64"; height = "64"></img></div></td><td colspan=2><input type="checkbox" id ="checkbox1" onchange = "checkUncheck()" name="checkbox1"  onclick="showDiv('uploadimage',this)"><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[467]</b><div id ='uploadimage'style='display:none;width:300px;height:20px; background-color:white'><input type="file" onchange ="return validateImage()" name="imgfile1" id="imgfile1"></div></td> </tr>
<tr id ="removeimage" style="display:$displayrows;" ><td></td><td><input type ="checkbox" id ="rmvimage" name ="removeImg" onchange = "remove_image()" $disable ><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[497]</b></td>
<tr id ="aboutme" style="display:$displayrows;"><td><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[495]:</b></td><td><textarea id="abtme" name="abtme" cols="40" rows="5" onkeydown="textCounter(this.form.abtme, this.form.abtmeLen, 256);" onkeyup="textCounter(this.form.abtme, this.form.abtmeLen, 256); ">$uinfo{AboutMe}</textarea>&nbsp;&nbsp;&nbsp;<input name="abtmeLen" type="text" id="abtmeLen" value="256" size="3" disabled/><font size="-2">characters still available.</font></td></tr>
<tr id ="age" style="display:;" ><td valign = top ><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[322]:</b></td><td >$selectAge<input type=hidden name=type value="$uinfo{type}"></td></tr><tr>
<tr id ="gender" style="display:;" ><td><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[472]:</b> </td> <td><INPUT TYPE=RADIO NAME="Gender" VALUE="M" $selectGenderM> $STRINGS{$ENV{DOCUMENT_ROOT}}->[65]  &nbsp; <INPUT TYPE=RADIO NAME="Gender" VALUE="F" $selectGenderF> $STRINGS{$ENV{DOCUMENT_ROOT}}->[66]</td></tr>
<tr id ="profession" style="display:$displayrows;" ><td><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[468]:</b></td><td><input type=text size=40 maxlength=40 value="$uinfo{Occupation}" name="profession" id="myProfession"></td></tr>
<tr id ="organization" style="display:$displayrows;" ><td><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[471]:</b></td><td><input type=text size=40 maxlength=40 value="$uinfo{xxxCompany}"name="organization" id="myOrganization" ></td></tr>
<tr id ="achieve" style="display:$displayrows;"><td><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[496]:</b></td><td><textarea id="achievements" name="achievements" cols="40" rows="3" onkeydown="textCounter(this.form.achievements, this.form.achLen, 175);" onkeyup="textCounter(this.form.achievements, this.form.achLen, 175); ">$uinfo{Achievements}</textarea>&nbsp;&nbsp;&nbsp;<input name="achLen" type="text" size="3" value="175" disabled/><font size="-2">characters still available.</font></td></tr>
<tr id ="location" style="display:$displayrows;" ><td ><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[469]:<b></td><td><input type=text size=40 maxlength=40 value="$uinfo{xxxCity}" name="location" id="myLocation"></td></tr>
<tr id ="profileOptions" style="display:$displayrows;" ><td ><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[493]:<b></td><td>$STRINGS{$ENV{DOCUMENT_ROOT}}->[494]<br\>
<table>
<tr>
<td><input type="checkbox" name="showName" value="1" $checkedForProfile{Name} />$STRINGS{$ENV{DOCUMENT_ROOT}}->[75]</td>
<td><input type="checkbox" name="showPhoto" value="1" $checkedForProfile{Photo} />$STRINGS{$ENV{DOCUMENT_ROOT}}->[498]</td>
<td><input type="checkbox" name="showAboutMe" value="1" $checkedForProfile{AboutMe} />$STRINGS{$ENV{DOCUMENT_ROOT}}->[495]</td>
</tr>
<tr>
<td><input type="checkbox" name="showAge" value="1" $checkedForProfile{Age} />$STRINGS{$ENV{DOCUMENT_ROOT}}->[322]</td>
<td><input type="checkbox" name="showGender" value="1" $checkedForProfile{Gender} />$STRINGS{$ENV{DOCUMENT_ROOT}}->[472]</td>
<td><input type="checkbox" name="showProfession" value="1" $checkedForProfile{Profession} />$STRINGS{$ENV{DOCUMENT_ROOT}}->[468]</td>
</tr>
<tr>
<td><input type="checkbox" name="showOrganization" value="1" $checkedForProfile{Organization} />$STRINGS{$ENV{DOCUMENT_ROOT}}->[471]</td>
<td><input type="checkbox" name="showAchievements" value="1" $checkedForProfile{Achievements} />$STRINGS{$ENV{DOCUMENT_ROOT}}->[496]</td>
<td><input type="checkbox" name="showLocation" value="1" $checkedForProfile{Location} />$STRINGS{$ENV{DOCUMENT_ROOT}}->[469]</td>
</tr>
</table>
</td></tr>
<tr id ="change_pwd" style="display:;"><td><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[473]:</b><font color=red size =+1><b>*</b></font><td><input name=oldpw id="currentpwd" type=password size=10 maxlength=25>&nbsp;<input type="checkbox" name="checkbox2" id="chkbx2" value = "on" onClick="showDiv('password',this)"><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[470]</b></td></tr>
<tr><td colspan='2'><div id ='password'; style='width:400px;height:100px; display:none;background-color:white'><font color =red size =-1>$STRINGS{$ENV{DOCUMENT_ROOT}}->[484]</font><br/>
<table><tr><td><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[58]</b></td><td><input name=newpw id=newpwd type=password size=10 maxlength=25></td></tr>
<tr><td><b>$STRINGS{$ENV{DOCUMENT_ROOT}}->[59]</td><td><input name=newpwconf id=newconfpwd type=password size=10 maxlength=25></td></tr></table></div></td></tr>
</table></div>
EOF


#          }
#        else
#          {
#            print <<EOF;
#<tr><td align=center colspan=2><font color=red size=-2>$STRINGS{$ENV{DOCUMENT_ROOT}}->[67]<font></td></tr>
#EOF
#          }

        print <<EOF;
<p align=center><input name=button type=button value="$STRINGS{$ENV{DOCUMENT_ROOT}}->[68]" onclick = "CheckFeilds()"></p>
<p align=center><input name=submit type=submit id = "update"  style="display:none" ></p>
</form>
$botString
</body>\n</html>
EOF
      }
    else
      {
#       my $buffer;
#      read(STDIN, $buffer, $len);
#     my @pairs = split(/&/, $buffer);

#        foreach my $pair (@pairs) 
#          {  
#            my ($name, $value) = split(/=/, $pair);
#            $value =~ tr/+/ /;
#            $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
#            $value =~ s/~!/ ~!/g; 

#            $table{$name} = $value;
#        print "$name = $table{$name}<br>";
            
        my $oldpw = $formdata->param('oldpw');
        my $newpw = $formdata->param('newpw');
        my $newpwconf = $formdata->param('newpwconf');
        my $image = $formdata->param('imgfile1');
        my $checkbox1 = $formdata->param('checkbox1');
        my $removeimage = $formdata->param('removeImg');
        my $checkbox2 = $formdata->param('checkbox2');
        my ($fdref,$flref) = Syvum::Members::UploadFunctions::getFiles(5,$formdata);
        my %filedata = %$fdref;
        my %formlen = %$flref;
        my $FileData = '';
        my $buffer1 = "";       
        my $title ='synew02';
        my $Description = 'synew02';       
        my $Keywords = 'synew02';
      
        $table{oldpw} = $formdata->param('oldpw');
        $table{newpw} = $formdata->param('newpw');
        $table{xxxEmail} = $formdata->param('xxxEmail');
        $table{xxxName} = $formdata->param('xxxName');
        $table{newpwconf} = $formdata->param('newpwconf'); 
        $table{type} = $formdata->param('type');
        $table{Age} = $formdata->param('Age');  
        $table{Occupation} = $formdata->param('profession');
        $table{xxxCity} = $formdata->param('location');
        $table{Gender} = $formdata->param('Gender');
        $table{xxxCompany} = $formdata->param('organization');
        $table{AboutMe} = $formdata->param('abtme');
        $table{Achievements} = $formdata->param('achievements');

        my $showInProfile = "";
        if ($formdata->param('showName') == 1)
          {
            $showInProfile .= "Name,";
          }
        if ($formdata->param('showPhoto') == 1)
          {
            $showInProfile .= "Photo,";
          }
        if ($formdata->param('showAboutMe') == 1)
          {
            $showInProfile .= "AboutMe,";
          }
        if ($formdata->param('showAge') == 1)
          {
            $showInProfile .= "Age,";
          }
        if ($formdata->param('showGender') == 1)
          {
            $showInProfile .= "Gender,";
          }
        if ($formdata->param('showProfession') == 1)
          {
            $showInProfile .= "Profession,";
          }
        if ($formdata->param('showOrganization') == 1)
          {
            $showInProfile .= "Organization,";
          }
        if ($formdata->param('showAchievements') == 1)
          {
            $showInProfile .= "Achievements,";
          }
        if ($formdata->param('showLocation') == 1)
          {
            $showInProfile .= "Location,";
          }
        if (length $showInProfile == 0)
          {
            $showInProfile = "None,";
          }

        my $retString = "";
        my $errorCount = 0;
          
        if (!$table{oldpw} || length $table{oldpw} == 0 || length $table{xxxName} == 0 || length $table{xxxEmail} == 0 || length $table{Age} == 0 || length $table{Gender} == 0)
          {
            $errorCount++;
          }
        elsif ($table{type} ne "k"
               && (!$table{xxxEmail} || length $table{xxxEmail} == 0)
               && (!$table{xxxName} || length $table{xxxName} == 0))
          {
            $errorCount++;
          }
         elsif($table{type} eq "k" && (length $table{Gender} > 0))
          {
            $errorCount = 0;
          }


        if ($errorCount == 0)
          {
            my $rightPW = Syvum::Members::Info::verifyPassword($userID, $table{oldpw});
       
            if ($rightPW == 1)
              {
                if ($checkbox1 eq 'on')
                  {
                    foreach my $fm (keys %filedata)
                      {
                        $buffer1 .= $filedata{$fm};
                      }

                    my $inFile = $image; 
                    my $outFilerz = $userID.".jpg";
                    my $imgdata = Syvum::Members::UploadFunctions::ConvertnResize($buffer1,$inFile,$outFilerz,800,600);
                    my $path = "/u/00/".$userID.".jpg";
                    uploadFunction::uploadFiles($path,$imgdata,$title,$Description,$Keywords);     
                    
                    my $outFileth = $userID.".gif";
                    my $imgdataTh = Syvum::Members::UploadFunctions::ConvertnResize($buffer1,$inFile,$outFileth,64,64);
                    $path = "/u/01/".$userID.".gif";
                    uploadFunction::uploadFiles($path,$imgdataTh,$title,$Description,$Keywords);
                 }
                 
                if ($removeimage eq 'on')
                     {
                       my $path = "/u/01/".$userID.".gif";
                       uploadFunction::deleteFiles($path);
                     }   
               my $oldpw = $table{oldpw};
               my $newpw = $table{newpw};
               my $newpwconf = $table{newpwconf};
         
               if ((length $newpw < 6 || length $newpw > 25 || $newpw =~ /\s/) && $checkbox2 eq "on")
                 {
                   $retString = $STRINGS{$ENV{DOCUMENT_ROOT}}->[69];
                 }
               elsif ($newpw ne $newpwconf && $checkbox2 eq "on")
                 {
                   $retString = $STRINGS{$ENV{DOCUMENT_ROOT}}->[70];
                 }
               elsif ($rightPW == 1)
                 { 
                   if ($newpw eq $newpwconf && $checkbox2 eq "on")
                     {
                       $uinfo{Password} = Syvum::Members::Info::encodePassword($newpw); 
                     }
                   if ($table{type} eq "t" || $table{type} eq "g")
                     {
                       $uinfo{xxxEmail} = $table{xxxEmail};
                       $uinfo{xxxName} = $table{xxxName};
                       $uinfo{Gender} = $table{Gender};
                       $uinfo{xxxCity} = $table{xxxCity};
                       $uinfo{xxxCompany}=$table{xxxCompany};
                       $uinfo{Occupation}= $table{Occupation};
                       $uinfo{type} = $table{type};
                       $uinfo{Age} = $table{Age};        
		       $uinfo{AboutMe} = $table{AboutMe};
		       $uinfo{Achievements} = $table{Achievements};
                     }
                   
                   if ($table{type} eq "k")
                     {
                       $uinfo{Gender} = $table{Gender};
                       $uinfo{Age} = $table{Age};
                       $uinfo{type} = $table{type};
                     }  
                   Syvum::Members::Info::saveMemberPrefs($userID, \%uinfo);
                   my %memData = Syvum::Members::Info::getAllData($userID);
                   $memData{ShowInProfile} = $showInProfile;
                   warn "saving ShowInProfile as $showInProfile";
                   Syvum::Members::Info::saveAllData($userID, \%memData);

                   $retString =$STRINGS{$ENV{DOCUMENT_ROOT}}->[474];
                 }
              
             }
               else
                 {
                   $retString = $STRINGS{$ENV{DOCUMENT_ROOT}}->[72];
                 }

          }
        else
          {
            $retString = $STRINGS{$ENV{DOCUMENT_ROOT}}->[73];
          }

    print "Content-type:text/html\n\n";
    print <<EOF;
<html><head>
<title>$STRINGS{$ENV{DOCUMENT_ROOT}}->[74]</title>
</head><body bgcolor=white>
$topString

<p>$retString
<p>
<a href="/cgi/members/profile.cgi?$userID">View your profile</a></p>

$botString

</body>
</html>
EOF
      }
  }

# sub cleanUp
# {
  Syvum::Common::DBInit::closeConnection();
# }






