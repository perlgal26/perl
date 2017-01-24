#!/usr/bin/perl -w
use strict;
use Syvum::Fs::Dirs;
use Syvum::Fs::Fsfiles;

package Syvum::Online::XMLParser;

sub xml_info
  {
    my $buffer = shift;

    my $title = "";
    my $description = "";
    my $heading = "";
    my $keywords = "";
    my $author = "";
    my $infoTheme = "navy";
    my $topdetails = "";
    my $autonumber = "";

    if ($buffer =~ /<preamble>(.*?)<\/preamble>/si)
      {
        my $preamble = $1;        
        pos($preamble) = 0;        
        if ($preamble =~ /<title>(.*?)<\/title>/si)
          {
            $title = $1;
          }
        pos($preamble) = 0;
        if ($preamble =~ /<description>(.*?)<\/description>/si)
          {
            $description = $1;
          }
        pos($preamble) = 0;
        if ($preamble =~ /<heading>(.*?)<\/heading>/si)
          {
            $heading = $1;
          }
        pos($preamble) = 0;
        if ($preamble =~ /<keywords>(.*?)<\/keywords>/si)
          {
            $keywords = $1;
          }
        pos($preamble) = 0;
        if ($preamble =~ /<infoTheme>(.*?)<\/infoTheme>/si)
          {
            $infoTheme = $1;
          }
        pos($preamble) = 0;
        if ($preamble =~ /<topdetails>(.*?)<\/topdetails>/si)
          {
            $topdetails = $1;
          }
        pos($preamble) = 0;
        if ($preamble =~ /<autonumber>(.*?)<\/autonumber>/si)
          {
            $autonumber = $1;
          }
        pos($preamble) = 0;
        if ($preamble =~ /<author>(.*?)<\/author>/si)
          {
            $author = $1;
          }

#        my $ipf = "";
#        qset_each_prm($buffer);
        #print "$title \n\n $description \n\n $heading \n\n $keywords \n\n $author \n\n $infoTheme \n\n $topdetails \n\n $autonumber";
        #theory_link customize affiliation filename
      }
    $buffer =~ s/<preamble>(.*?)<\/preamble>//si;
    return ($title, $description, $heading, $keywords, $author, $infoTheme, $topdetails, $autonumber, $buffer);
  }

sub separate_qset
  {
    my $buffer = shift;

    $buffer =~ s/.*?<qset>/<qset>/si;
    $buffer =~ s/<opentxt>.*?<\/opentxt><\/tdf>//si;
    $buffer =~ s/<\/qset>\s*\r*\n*$/<\/qset>/si;
#    print $buffer;

    my @qset_array = split(/<\/qset>/,$buffer);
    return \@qset_array;
  }

sub create_contans
  {
    my $que = shift;
    my $contans_flag = shift;
    my $queNum = shift;
    my $current_userId = shift;
    my $dirPath = shift;
    my $ca_text = "";
    my $cans = "";
    my $answer = "";
    my $contributor_userId = "";
    my $messageId = "";
    my $tup = "";
    my $tdn = "";
    my $exp = "";
    my $board_num = "";
    my $thread_num = "";
    my $tupString = "";
    my $tdnString = "";
    my $counter = 0;
    my $class = "_temp_div_class";
    my $rating_diff = "";
    my $cans_counter = "";

    $que =~ /<\/inp>(.*)/si;
    $cans = $1;

    my %div_hash; # key = "cans$num", value = cadiv
    my %rating_hash; # key = "cans$num', value = rating_diff

    if (defined $cans && length $cans > 0)  
      {
        my @cans_array =  split(/<\/cans>/,$cans);
        foreach my $ca (@cans_array)
          { 
            $counter++;
            if ($ca =~ /<cans\s*c=\"(.*?);(.*?);(.*?);(.*?)\">/gsi)
	      {
                $contributor_userId = $1;
                $messageId = $2;
                $tup = $3; 
                $tdn = $4;
                $messageId =~ /(\d+)_(\d+)_(\d+)/gsi;
                $board_num = $1;
                $thread_num = $2;
                $tupString = "$messageId"."_tup";
                $tdnString = "$messageId"."_tdn";     
                $rating_diff = $tup - $tdn;
                if ($ca =~ /<out>(.*?)<\/out>/gsi)
                  {
                    $answer = $1;
                  }
                if ($ca =~ /<exp>(.*?)<\/exp>/gsi)
                  {
                    $exp = $1;
                    # change the regular expression.
                    $exp =~ s/\(Contributed by\s*:\s*$contributor_userId\)$//g;
                  }
		$cans_counter = "cans"."$counter";
		 
		$div_hash{$cans_counter} = createEachAnsExpDiv($contributor_userId, $queNum, $messageId, $tupString, $tup, $tdnString, $tdn, $board_num, $thread_num, $answer, $exp, $contans_flag, $current_userId, $dirPath, $class);
                $rating_hash{$cans_counter} = $rating_diff;
		
              }
	  }
      } 

    my @rating_sortedArray = sort {$rating_hash{$b} <=> $rating_hash{$a}} keys %rating_hash;
    
    my $count = 0;
    foreach my $key (@rating_sortedArray)
      {
        $count++;
	if ($count % 2 == 0)
	  {
	    $div_hash{$key} =~s/$class/even/g;
	  }
	else
	  {
	    $div_hash{$key} =~s/$class/odd/g;
	  }
        $ca_text .= $div_hash{$key};
      }

    return $ca_text;
  }

sub createEachAnsExpDiv
  {
    my $contributor_userId = shift;
    my $queNum = shift; 
    my $messageId = shift;
    my $tupString = shift;
    my $tup = shift;
    my $tdnString=shift;
    my $tdn = shift;
    my $board_num = shift;
    my $thread_num =shift;
    my $answer = shift;
    my $explanation = shift;
    my $contans_flag = shift;
    my $divId = "$queNum"."_"."$contributor_userId";
    
    my $delete_text;
    my $edit_text;
    my $bestans_buttontext;
    my $bestans = 'BestAnswer';
    my $current_userId = shift;
    my $dirPath = shift;
    
    my $class = shift;
    $dirPath =~ /^\/u\/(.*?)\/.*?/g;
    my $authorId = $1;

    my $perm = Syvum::Fs::Dirs::checkPermissions($current_userId, $dirPath, Syvum::Fs::Dirs::getEditAction());
    my $path = "http://syvum.com/cgi/online/serve.cgi/u/01/".$contributor_userId.".gif";
    
    if ($contributor_userId eq $current_userId || $perm == 1 || $current_userId eq $authorId)
      { 
        $edit_text = "<li class=\"left\"><span id =\"$queNum\" name=\"contrians\" style=\"font-size:80%; color:blue; text-align:center; cursor:pointer; text-decoration:underline;\" onClick=\"openContansWin(this.id, '$contans_flag');\">Edit</span></li>";
	$delete_text = "<li class=\"right\"><img src =\"/s_i/cancel.png\" title=\"Delete answer\" onclick=\"deleteAnswer('$divId', '$messageId', '$contributor_userId');\"></li>";
      }
    else
      {
        $delete_text = "";
        $edit_text = "";
      }
					 
#    if ($current_userId eq $authorId)
#      {
#	$bestans_buttontext ="<li class=\"left\"><button type=\"button\" onclick=\"bestAns('$bestans', '$messageId');\">BA</button></li>";
#      }
#    else
#      {
#        $bestans_buttontext = "";
#      }

    my $eachAnsExpDiv = <<EOF;
<div id='$divId'><div class='$class'><p class='rightimg'><span style='font-size:80%;color:#660000'><i>Contributed by</i></span><br/><img src='$path' alt='userpic' width='48' height='48' title='$contributor_userId' /><br/><a href='/cgi/members/profile.cgi?$contributor_userId' title ='$contributor_userId'><span style='font-size:80%'>$contributor_userId</span></a></p>
EOF
    if ($contans_flag == 0)
      { 
        $eachAnsExpDiv .= <<EOF;
<p class='ansexp'><span style='color: #660000;'><i>Answer </i>:</span> $answer</p>
EOF
      }   
    if ($explanation !~ /^\s*$/g)
      { 
        $eachAnsExpDiv .= <<EOF;
<p class='ansexp'><span style='color: #660000;'><i>Explanation </i>:</span> $explanation</p>
EOF
      }
    $eachAnsExpDiv .=<<EOF;
<div class='footer'><ul class='container'><li class='left'><a href ='/cgi/board/read.cgi?replies=1&message=$messageId&board=$board_num&thread=$thread_num' style='font-size:80%;'>Comments</a></li>$edit_text $bestans_buttontext $delete_text<li class='right'><img onmouseout=\"this.src='/s_i/greytd.png';\" onmouseover=\"this.src='/s_i/thumbsdn.png';\" src =\"/s_i/greytd.png\"  onclick=\"openRateAns('tdn', '$messageId');\" align='absmiddle' title=\"Thumbs Down\">&nbsp;&nbsp;<span id='$tdnString' style ='color:#666362;'>$tdn</span></li><li class='right'><img onmouseout=\"this.src='/s_i/greyup.png';\" onmouseover=\"this.src='/s_i/thumbsup.png';\" src =\"/s_i/greyup.png\" onclick=\"openRateAns('tup', '$messageId');\" title=\"Thumbs Up\">&nbsp;&nbsp;<span id='$tupString' style='color:#666362;'>$tup</span></li></ul></div></div></div><br/>
EOF

    return $eachAnsExpDiv;
  }

sub qset_each_prm
  {
#    my $buffer = shift;
    my $each_qset = shift;
    my $test_fmt_flag = shift;

    my $prm = "";
    my @ips_array;
    my $psg = ""; # Passage
    my $lang = "english"; # Language in <lang> tag
    my $sectionheading = "";
    my $sectiondetails = "";
 
    my $ipp = 100; # Info Percent
    my $ipf = "";
    my $ipo = "";
    my $input_tts = "";
    my $output_tts = "";
    my $showsrc = "";
    my $sourceinfo = "";
    my $show_choices = "1";
    my $dmarks = "";
    my $showmark = "";
    my $mark_align = "";
    my $auto_number_start_with = "";
    my $inp = "";
    my $out = "";
    my $exp = "";
    my $des = "";
    my $rdes = "";
    my $fixedchoice = "";
    my $mrk = "";
    my $anst = "";
    my $mrk_dis = "";
    my $perq = 0;
    my @fix_choices;


#    my @qset_array = separate_qset($buffer);

#    foreach my $each_qset (@qset_array)
#       {
    if ($each_qset =~ /<prm>(.*?)<\/prm>/is)
      {
        $prm = $1;
        if ($prm =~ /<lang>(.*?)<\/lang>/is)
          {
            $lang = $1;
          }
        pos($prm) = 0;
        if ($prm =~ /<ipp>(.*?)<\/ipp>/is)
          {
            $ipp = $1;
          }
        pos($prm) = 0;
        if ($prm =~ /<ipf>(.*?)<\/ipf>/is)
          {
            $ipf = $1;
          }
        pos($prm) = 0;
        if ($prm =~ /<ipo>(.*?)<\/ipo>/is)
          {
            $ipo = $1;
            $ipo =~ s/([^\,]+)\,.*/$1/si;
            if ($ipo eq "Select")
              {
                $ipo = "QAE";
              }                
          }
        pos($prm) = 0;
        if ($prm =~ /<input_tts>(.*?)<\/input_tts>/is)
          {
            $input_tts = $1;
          }
        pos($prm) = 0;
        if ($prm =~ /<output_tts>(.*?)<\/output_tts>/is)
          {
            $output_tts = $1;
          }
        pos($prm) = 0;
        if ($prm =~ /<showsrc>(.*?)<\/showsrc>/is)
          {
            $showsrc = $1;
          }
        pos($prm) = 0;
        if ($prm =~ /<showfcs>(.*?)<\/showfcs>/is)
          {
            $show_choices = $1;
          }
        pos($prm) = 0;
        if ($prm =~ /<sourceinfo>(.*?)<\/sourceinfo>/is)
          {
            $sourceinfo = $1;
          }
        pos($prm) = 0;
        if ($prm =~ /<dmarks>(.*?)<\/dmarks>/is)
          {
            $dmarks = $1;
          }
        pos($prm) = 0;
        if ($prm =~ /<showmark>(.*?)<\/showmark>/is)
          {
            $showmark = $1;
            if ($showmark =~ /\,/sg)
              {
                ($auto_number_start_with = $showmark) =~ s/.*\,(.*)/$1/sg;
                $showmark =~ s/(.*)\,.*/$1/sg;
                if ($showmark eq "middle" || $showmark eq "bottom")
                  {
                    $mark_align = $showmark;
                    $showmark = "";
                  }
              }
            else
              {
                if ($showmark eq "middle" || $showmark eq "bottom")
                  {
                    $mark_align = $showmark;
                    $showmark = "";
                  }
              }
          }
        pos($prm) = 0;
        if ($prm =~ /<inp>(.*?)<\/inp>/is)
          {
            $inp = $1;
          }         
        pos($prm) = 0;
        if ($prm =~ /<out>(.*?)<\/out>/is)
          {
            $out = $1;
          }
        pos($prm) = 0;
        if ($prm =~ /<exp>(.*?)<\/exp>/is)
          {
            $exp = $1;
          }
        if (length $inp < 1)
          {
            $inp = "Question";
          }
        if (length $out < 1)
          {
            $out = "Answer";
          }
        if (length $exp < 1)
          {
            $exp = "Explanation";
          }
        pos($prm) = 0;
        if ($prm =~ /<des>(.*?)<\/des>/is)
          {
            $des = $1;
          }
        pos($prm) = 0;
        if ($prm =~ /<rdes>(.*?)<\/rdes>/is)
          {
            $rdes = $1;
          }
        pos($prm) = 0;
        if ($prm =~ /<fixedchoice>(.*?)<\/fixedchoice>/is)
          {
            $fixedchoice = $1;
            $fixedchoice =~ s/<\/choice>[^<]*$//si;
            @fix_choices = split(/<\/choice>/is,$fixedchoice);
            $fixedchoice = "";
            foreach my $choice (@fix_choices)
              {
                $choice =~ s/^[^<]*<choice>//si;
                $fixedchoice .= "&#927; $choice <br/>";
              }
          }
        pos($prm) = 0;
        if ($prm =~ /<mrk\s*([^>]*)>(.*?)<\/mrk>/is)
          {
            $mrk_dis = $1;
            $mrk = $2;

            if ($mrk_dis =~ /perq\=\"([^\"]*)\"\s+dis\=\"[^\"]*\"/si)
              {
                $perq = $1;
              }
            $mrk_dis =~ s/perq\=\"[^\"]*\"\s+dis\=\"([^\"]*)\"/$1/si;
            #print "\n $mrk_dis";
          }
        pos($prm) = 0;
        if ($prm =~ /<anst>(.*?)<\/anst>/is)
          {
            $anst = $1;
          }
#             print $prm;
##              tse, fixedorder, tdfarrange
        $each_qset =~ s/<prm>(.*?)<\/prm>//is;
      }
    pos($each_qset) = 0;
    if ($each_qset =~ /<psg[^>]*>(.*?)<\/psg>/is)
      {
        $psg = $1;
#             print $psg;
        $each_qset =~ s/<psg[^>]*>(.*?)<\/psg>//is;
      }
    pos($each_qset) = 0;
    if ($each_qset =~ /<sectionheading>(.*?)<\/sectionheading>/is)
      {
        $sectionheading = $1;
#             print $sectionheading;
        $each_qset =~ s/<sectionheading>(.*?)<\/sectionheading>//is;
      }
    pos($each_qset) = 0;
    if ($each_qset =~ /<sectiondetails>(.*?)<\/sectiondetails>/is)
      {
        $sectiondetails = $1;
#             print $sectiondetails;
        $each_qset =~ s/<sectiondetails>(.*?)<\/sectiondetails>//is;
      }
    pos($each_qset) = 0;
    if ($each_qset !~ /<ips>/si && undef $test_fmt_flag)
      {
        $each_qset .= "<ips>";
      }
    $each_qset =~ s/^\s*\r*\n*<qset>\s*\r*\n*//si;
    my @ips_temp_array = split(/<ips>/is, $each_qset);
    my $text = "";

    foreach my $each_ips (@ips_temp_array)
      {
        if (length $each_ips > 0 && ($each_ips =~ /<que>/si || $each_ips =~ /<\/ips>/si))
          {
            $text .= $each_ips."<-;;;->";
          }
      }
    $text =~ s/<-;;;->$//si;
    @ips_array = split(/<-;;;->/is, $text);
#       print @ips_array;
#ips, que
#        }

    return ($prm, $psg, $sectionheading, $sectiondetails, \@ips_array, $ipf, $ipo, $ipp, $lang, $input_tts, 
    $output_tts, $showsrc, $sourceinfo, $dmarks, $showmark, $inp, $out, $exp, $des, $rdes, $fixedchoice, $mrk, 
    $anst, $mrk_dis, $perq, \@fix_choices,$show_choices,$mark_align,$auto_number_start_with);
  }

sub exp_col_null
  {
    my $buffer = shift;

   my $exp_flag = 0;

    if (defined $buffer && length $buffer > 0)
      {
        my ($ips, $que_arrayRef) = separate_que($buffer);
        my @que_array = @$que_arrayRef;
        foreach my $que (@que_array)
          {
            if ($que =~ /<exp>(.*?)<\/exp>/si)
              {
                $exp_flag = 1;
                return $exp_flag;
              }
          }
      }
    return $exp_flag;
  }

sub separate_que
  {
    my $buffer = shift;
    my $ips = "";

    if ($buffer =~ /(.*?)<\/ips>/si)
      {
        $ips = $1;
      }
    my @que_array = split(/<\/que>/,$buffer);
    return ($ips, \@que_array);
  }

sub choices
  {
    my $que = shift;
    my $random = shift;

    my $anspos = 0;
    my $firstans = "";
    my $choices_text = "";

    if ($que =~ /<opto>(.*?)<\/opto>/si)
      {
        $anspos = $1;
      }
    
    pos($que) = 0;
    if ($que =~ /<out>(.*?)<\/out>/si)
      {
        $firstans = $1;
        $firstans = "&#927; $firstans<br/>";
      }

    my $count = 1;

#    $que =~ s/.*(<ans[^>]*>.*<\/ans>).*/$1/isg;
#    $que =~ s/<\/ans>$/$1/si;

    my @choice_arr = split(/<\/ans>/, $que);
    my $random_number = int(rand(scalar(@choice_arr) - 1)) + 1;
      
    foreach my $choices (@choice_arr)
      {
        $choices .= "</ans>";
        pos($choices) = 0;
        if ($choices =~ s/(<ans[^>]*>.*?)<\/ans>//is)
          {
            my $choice = $1;
#        print "\n Choices $count=> $choice \n";
            my $options = "";
            if ($anspos > 0)
              {
                if ($count == 1 && $anspos == 1)
                  {
                    $choices_text .= $firstans;
                  }
                else
                  {
                    if ($choice =~ /<ans\s+t\s*\=\s*(\"|\')opt(\"|\')>/si && $count == $anspos)
                      {
                        if ($choice =~ /<ans\s+t\s*\=\s*(\"|\')opt(\"|\')>(.*)/si)
                          {
                            $options = $3;
                          }
                        $choices_text .= "&#927; ".$options."<br/>".$firstans;
                      }
                    elsif ($choice =~ /<ans\s+t\s*\=\s*(\"|\')opt(\"|\')>/si && $count != $anspos)
                      {
                        if ($choice =~ /<ans\s+t\s*\=\s*(\"|\')opt(\"|\')>(.*)/si)
                          {
                            $options = $3;
                          }
                        $choices_text .= "&#927; ".$options."<br/>";
                      }
                  }
              }
            elsif ($random =~ /No/s)
              {
                #print "\n Choices => $choices_text \n";
                if ($choice =~ /<ans\s+t\s*\=\s*(\"|\')opt(\"|\')>(.*)/si)
                  {
                    $options = $3;
                    $choices_text .= "&#927; ".$options."<br/>";
                  }
                else
                  {
                    if ($choice =~ /<out>(.*?)<\/out>/si)
                      {
                        $options = $1;
                        $choices_text .= "&#927; ".$options."<br/>";
                      }
                  }
              }
            else
              {
                #print "\n $random_number Choices => $choices_text \n";
                if ($choice =~ /<ans\s+t\s*\=\s*(\"|\')opt(\"|\')>/si && $count == $random_number)
                  {
                    if ($choice =~ /<ans\s+t\s*\=\s*(\"|\')opt(\"|\')>(.*)/si)
                      {
                        $options = $3;
                      }
                    $choices_text .= "&#927; ".$options."<br/>".$firstans;
                  }
                elsif ($choice =~ /<ans\s+t\s*\=\s*(\"|\')opt(\"|\')>/si && $count != $random_number)
                  {
                    if ($choice =~ /<ans\s+t\s*\=\s*(\"|\')opt(\"|\')>(.*)/si)
                      {
                        $options = $3;
                      }
                    $choices_text .= "&#927; ".$options."<br/>";
                  }
                elsif ($count == $random_number)
                  {
                    $choices_text .= $firstans;
                  }
              }
            $count++;
          }
      }
    if (length $choices_text > 0)
      {
        $choices_text = "<br/>".$choices_text;
      }
    #print "\n Choices => $choices_text \n";
    return $choices_text;
  }

sub check_for_random_choice
  {
    my $anspos = shift;
    my $process_ips = shift;

    my ($ips, $que_arrayRef) = separate_que($process_ips);
    my @que_array = @$que_arrayRef;
    my $random = "";

    foreach my $que (@que_array)
      {
        my $count = 1;

#        $que =~ s/.*(<ans[^>]*>.*<\/ans>).*/$1/isg;
#        $que =~ s/<\/ans>$//si;

#        my @choice_arr = split(/<\/ans>/, $que);
#        foreach my $choice (@choice_arr)
        while ($que =~ s/<ans[^>]*>(.*?)<\/ans>//is && $count < 7)
          {
            my $choice = $1;
            if ($choice !~ /<out>/ && $anspos == $count)
              {
                $random = "No";
                #print "\n Random => $random \n";
                return $random;
              }
            $count++;
          }
      }
    #print "\n Random => $random \n";

    return $random;
  }

sub get_first_anspos
  {
    my $first_qts = shift;

    my $anspos = 0;
    my $count = 1;

#    $first_qts =~ s/^.*(<ans[^>]*>)/$1/is;
#    $first_qts =~ s/<\/ans>.*$//si;

 #   my @choice_arr = split(/<\/ans>/, $first_qts);
 #   foreach my $choice (@choice_arr)
    while ($first_qts =~ s/<ans[^>]*>(.*?)<\/ans>//is && $count < 7)
      {
        my $choice = $1;
        if ($choice =~ /<out>/si && $anspos == 0)
          {
            $anspos = $count;
            #print "\n Anspos => $anspos \n";
            return $anspos;
          }
        $count++;
      }

    #print "$first_qts\n Anspos => $anspos \n";
    return $anspos;
  }

sub percent_note
  {
    my $lang = shift;

    my $percent_text = "";
    if (defined $lang && $lang =~ /english/i) #Set the Note for all different language using String...
      {
        $percent_text .=<<EOF;
<p style = "font-size:80%;"><b><font color = "red">Note:
</font> Only <i>_var1_ out of _var2_</i> database entries (_var3_%) are shown above. To view all <i>
_var2_</i> entries, please purchase our premier membership. For more information, <a href = "/cgi/redirect.cgi?tdfres">
<font color = "red">click here</font></a>.</b></p>
EOF
      }
    else
      {
        $percent_text .=<<EOF;
<p style = "font-size:80%;"><b><font color = "red">Note:
</font> Only <i>_var1_ out of _var2_</i> database entries (_var3_%) are shown above. To view all <i>
_var2_</i> entries, please purchase our premier membership. For more information, <a href = "/cgi/redirect.cgi?tdfres">
<font color = "red">click here</font></a>.</b></p>
EOF
      }
    return $percent_text;
  }

sub searchable_keywords
  {
    my $keywords = shift;

    my @each_keyword;
    @each_keyword = split(/\,/, $keywords);
    $keywords = "";

    foreach my $keys(@each_keyword)
      {
        $keys =~ s/^\s+//sg;
        $keys =~ s/\s+$//sg;
        $keys =~ s/\&amp\;\#39\;/\'/sgi;
        if (length $keys > 0)
          {
            $keywords .= "<a href=\"/cgi/search.cgi?words=$keys\">$keys</a>&#160;,&#160;";
          }
      }    
    $keywords =~ s/\,(&\#160;)$//sgi;
    return $keywords;
  }

sub list_que_for_info_order
  {
    my $question = shift;
    my $answer = shift;
    my $explanation = shift;
    my $ipo = shift;
    my $que = shift;
    my $anst = shift;
    my $fixedchoice = shift;
    my $random = shift;
    my $exp_flag = shift;

    my $que_text = "";

    my $choices = "";
    if ($que =~ /<anst>odd_one<\/anst>/si || $anst eq "odd_one")
      {
        # get $choices with all condition check i.e. anspos, fixedchoice
        if (defined $fixedchoice && length $fixedchoice > 0)
          {
            $choices = "<br/>".$fixedchoice;
          }
        elsif ($que =~ /<ans\s+t\s*\=\s*(\"|\')opt(\"|\')>/si)
          {
            $choices = choices($que, $random);
          }
      }


    if ($ipo eq "Q" && length $question > 0)
      {
        $que_text .= "<li>$question$choices</li>"; #Question
        # if input contains seven underscore (_) replace it with answer.
      }
    elsif ($ipo eq "A" && length $answer > 0)
      {
        $que_text .= "<li>$answer</li>"; #Answer
      }
    elsif ($ipo eq "E" && length $explanation > 0)
      {
        $que_text .= "<li>$explanation</li>"; #Explanation
      }
    elsif ($ipo eq "QA")
      {
        $que_text .= "<li>$question$choices : $answer</li>";
      }
    elsif ($ipo eq "QE")
      {
        $que_text .= "<li>$question$choices";
        if (length $explanation > 0)
          {
            $que_text .= "<br/>- $explanation";
          }
        if ($exp_flag == 1)
          {
            $que_text .= "<br/><br/>";
          }
        $que_text .= "</li>";
      }
    elsif ($ipo eq "AQ")
      {
        $que_text .= "<li>$answer : $question$choices</li>";
      }
    elsif ($ipo eq "AE")
      {
        $que_text .= "<li>$answer";
        if (length $explanation > 0)
          {
            $que_text .= "<br/>- $explanation";
          }
        if ($exp_flag == 1)
          {
            $que_text .= "<br/><br/>";
          }
        $que_text .= "</li>";
      }
    elsif ($ipo eq "EQ")
      {
        $que_text .= "<li>";
        if (length $explanation > 0)
          {
            $que_text .= "$explanation<br/>";
          }
        $que_text .= "$question$choices";
        if ($exp_flag == 1)
          {
            $que_text .= "<br/><br/>";
          }
        $que_text .= "</li>";
      }
    elsif ($ipo eq "EA")
      {
        $que_text .= "<li>";
        if (length $explanation > 0)
          {
            $que_text .= "$explanation<br/>";
          }
        $que_text .= "$answer";
        if ($exp_flag == 1)
          {
            $que_text .= "<br/><br/>";
          }
        $que_text .= "</li>";
      }
    elsif ($ipo eq "QAE")
      {
        $que_text .= "<li>$question$choices : $answer";
        if (length $explanation > 0)
          {
            $que_text .= "<br/>- $explanation";
          }
        if ($exp_flag == 1)
          {
            $que_text .= "<br/><br/>";
          }
        $que_text .= "</li>";
      }
    elsif ($ipo eq "QEA")
      {
        $que_text .= "<li>$question$choices";
        if (length $explanation > 0)
          {
            $que_text .= "<br/>- $explanation<br/>$answer";
          }
        else
          {
            $que_text .= " : $answer";
          }
        if ($exp_flag == 1)
          {
            $que_text .= "<br/><br/>";
          }
        $que_text .= "</li>";
      }
    elsif ($ipo eq "AQE")
      {
        $que_text .= "<li>$answer : $question$choices";
        if (length $explanation > 0)
          {
            $que_text .= "<br/>- $explanation";
          }
        if ($exp_flag == 1)
          {
            $que_text .= "<br/><br/>";
          }
        $que_text .= "</li>";
      }
    elsif ($ipo eq "AEQ")
      {
        $que_text .= "<li>$answer";
        if (length $explanation > 0)
          {
            $que_text .= "<br/>- $explanation<br/>$question$choices";
          }
        else
          {
            $que_text .= " : $question$choices";
          }
        if ($exp_flag == 1)
          {
            $que_text .= "<br/><br/>";
          }
        $que_text .= "</li>";
      }
    elsif ($ipo eq "EQA")
      {
        $que_text .= "<li>";
        if (length $explanation > 0)
          {
            $que_text .= "$explanation<br/>";
          }
        $que_text .= "$question$choices : $answer";
        if ($exp_flag == 1)
          {
            $que_text .= "<br/><br/>";
          }
        $que_text .= "</li>";
      }
    elsif ($ipo eq "EAQ")
      {
        $que_text .= "</li>";
        if (length $explanation > 0)
          {
            $que_text .= "$explanation<br/>";
          }
        $que_text .= "$answer : $question$choices";
        if ($exp_flag == 1)
          {
            $que_text .= "<br/><br/>";
          }
        $que_text .= "</li>";
      }

    return $que_text;
  }
  1;
