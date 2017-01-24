package Syvum::Online::InfoPage;

use strict;
use Syvum::Online::XMLParser;
use Syvum::Debug;
use Syvum::Members::Session;

sub html_gen
  {
#    my $xml_file = shift;
    my $buffer = shift;
    my $ipf = shift;
    my $dirPath = shift;
    my $html_text = "";
    #theory_link customize affiliation filename

    my ($title, $description, $heading, $keywords, $author, $infoTheme, $topdetails, $autonumber, $buffers) = Syvum::Online::XMLParser::xml_info($buffer);
    my $head_text = head_text($title, $keywords, $description, $author);
    my $middle_portion = qset_process($ipf, $heading, $infoTheme, $keywords, $topdetails, $autonumber, $buffers, $dirPath);

    my $leftstrip = "navy";
    my $rightstrip = "navy";

    if (defined $infoTheme && length $infoTheme > 0)
      {
        $leftstrip = $infoTheme;
        $rightstrip = $infoTheme;
      }

    $leftstrip =~ s/navy/\#13b9c1/si;
    $leftstrip =~ s/maroon/\#ffcc88/si;
    
    $rightstrip =~ s/navy/\#006699/si;
    $rightstrip =~ s/maroon/\#ffcc88/si;

    my $body = "<body>";
    my $encrypt_open = "";
    my $encrypt_close = "";

    if ($ENV{REQUEST_URI} =~ /cgi\/exam\//
        || $ENV{REQUEST_URI} =~ /cgi\/u\/www\/exam\//
        || $ENV{REQUEST_URI} =~ /cgi\/iit_jee\//
        || $ENV{REQUEST_URI} =~ /cgi\/u\/www\/iit_jee\//)
      {
        $body = <<EOF;
<style>
* { -moz-user-select: none; }
</style>
<body onselectstart="return false" unselectable="on">
EOF

        $middle_portion =~ s/<\/?encrypt>//igs;
        $middle_portion = "<encrypt>".$middle_portion."</encrypt>";
#        $encrypt_open = "<encrypt>";
#        $encrypt_close = "</encrypt>";
      }

    $html_text =<<EOF;
<html>
$head_text
$body
 <div style = "display:none;" id = "head">$heading</div>
 <!-- addtopbar -->
 <!-- adddirbar -->
 <br/>
 <table cellpadding = "10" width = "100%">
  <tr>
   <td bgcolor= "$leftstrip" width = "4%" height = "100%"></td>
   <td>    
$encrypt_open
    $middle_portion
$encrypt_close
   </td>
   <td bgcolor= "$rightstrip" width = "4%" height = "100%"></td>
  </tr>
 </table>
 <!-- adddirbar -->
 <!-- addbotbar -->
</body>
</html>
EOF

    return $html_text;
  }

sub head_text
  {
    my $title = shift;
    my $keywords = shift;
    my $description = shift;
    my $author = shift;

    my $head_text = "";

    if (defined $author && $author =~ /Syvum/)
      {
        $author = "Syvum Editorial Team";
      }

    $head_text =<<EOF;
<head>
 <title>$title</title>
 <meta name = "keywords" content = "$keywords" />
 <meta name = "description" content = "$description" />
 <meta name = "author" content = "$author" />
 <meta name = "copyright" content = "© 1999-2007, Syvum Technologies Inc." />
 <link rel = "stylesheet" href = "/saw/jscripts/saws/themes/advanced/css/editor_content.css" type = "text/css" />
 <script language = "javascript" src = "/xsl/keywords.js"></script>
 <script src = "/xsl/sortable.js"></script>
</head>
EOF

    return $head_text;
  }

sub top_portion
  {
    my $heading = shift;
    my $info_theme = shift;

    if (defined $info_theme && length $info_theme > 0)
      {
#        $info_theme = lc($info_theme);
        $heading = "<h2><span style = \"color:$info_theme;\">$heading</span></h2>";
      }
    else
      {
        $heading = "<h2><span style = \"color:#006699;\">$heading</span></h2>";
      }

    # rapid_review String (type entire table part)
    my $rapid_review =<<EOF;
<table align = "center">
 <tr>
  <td rowspan = "2" align = "right"><img src = "/images/r.gif" alt = "About Button" /></td>
  <td><span style = "font-size=110%;">apid</span></td>
  <td rowspan = "2" bgcolor = "yellow"><span style = "font-size=110%;">Just what you need to know!</span></td>
 </tr>
 <tr>
  <td><span style = "font-size=110%;">eview</span></td>
 </tr>
</table>
EOF

    my $top_portion =<<EOF;
<div style = "text-align:center;">
  $heading
  <table border = "1" align = "center" ><tr><td>
 $rapid_review
  </td></tr></table>
  </div>
  <br/>
  <!-- insertContentAd -->
  <br/>
EOF

    return $top_portion;
  }

sub bottom_portion
  {
    my $keywords = shift;

    my $rel_key = "";

    if (defined $keywords && length $keywords > 0)
      {
  # related keyword String (type just string number variable i.e. \$String...)
        $rel_key = Syvum::Online::XMLParser::searchable_keywords($keywords);
        $rel_key =<<EOF;
<br/>
<span style = "font-size:80%; color:brown;">
 Related Keywords :-
</span><br/>
<span style = "font-size:80%;">
 $rel_key
</span>
EOF
      }

    my $bottom_portion =<<EOF;
<br/>
<!-- insertContentAd -->
$rel_key
EOF

    return $bottom_portion;
  }

sub qset_process
  {
    my $ipf = shift;
    my $heading = shift;
    my $info_theme = shift;
    my $keywords = shift;
    my $topdetails = shift;
    my $autonumber = shift;
    my $buffer = shift;
    my $current_userId = Syvum::Members::Session::getCurrentUserID();
    my $dirPath = shift;
    my $middle_portion = "";
    my $top_portion = top_portion($heading, $info_theme);
    my $bottom_portion = bottom_portion($keywords);

    if (defined $topdetails && length $topdetails > 0)
      {
        $topdetails =<<EOF;
<div style = "text-align:center;"><step name="Show / Hide Top Details">
$topdetails
</step></div>
EOF
      }
    else
      {
        $topdetails = "";
      }

    if ($ipf eq "table" || $ipf eq "list")
      {
        $middle_portion .= "$top_portion";
      }
    else
      {
        $info_theme = lc($info_theme);
        $info_theme = "<h2><span style = \"color:$info_theme;\">$heading</span></h2>";
        $middle_portion .=<<EOF;
<!-- insertContentAd -->
<div style = "text-align:center;">$info_theme</div>
$topdetails
EOF
      }

    #    <xsl:for-each select="tdf/qset">      
    if ($ipf eq "table")
      {
        $middle_portion .= table($buffer, $info_theme, $ipf);
      }
    elsif ($ipf eq "list")
      {
        $middle_portion .= list($buffer, $ipf);
      }
    elsif ($ipf eq "question_hide" || $ipf eq "question_rhide" || $ipf eq "question_only" || $ipf eq "question_ronly" 
        || $ipf eq "answer_only" || $ipf eq "answer_ronly")
      {
        $middle_portion .= test_paper($buffer, $ipf, $autonumber, $current_userId, $dirPath);
      }
    elsif ($ipf eq "question_hide_ocr")
      {
        $middle_portion .= ocr_test_paper($buffer, $ipf, $autonumber);
      }
    #    </xsl:for-each>

#    if ($ipf eq "table" || $ipf eq "list")
#      {
        $middle_portion .= "$bottom_portion";
#      }

    return $middle_portion;
  }


sub table
  {
    my $buffer = shift;
    my $infoTheme = shift;
    my $current_format = shift;

    my $qset_arrayRef = Syvum::Online::XMLParser::separate_qset($buffer);
    my @qset_array = @$qset_arrayRef;

    my $table_text = "";
    my $count_qset = 0;

#    print "Qset Length => ".scalar(@qset_array)."\n";

    foreach my $process_qset (@qset_array)
      {        
        my ($prm, $psg, $sectionheading, $sectiondetails, $ips_arrayRef, $ipf, $ipo, $ipp, $lang, $input_tts, 
            $output_tts, $showsrc, $sourceinfo, $dmarks, $showmark, $inp, $out, $exp, $des, $rdes, $fixedchoice, $mrk, $anst, $mrk_dis, $perq, $fix_choices_arrayRef, $show_choices, $mark_align, $auto_number_start_with);
        my $count_ips = 0;

        ($prm, $psg, $sectionheading, $sectiondetails, $ips_arrayRef, $ipf, $ipo, $ipp, $lang, $input_tts, 
         $output_tts, $showsrc, $sourceinfo, $dmarks, $showmark, $inp, $out, $exp, $des, $rdes, 
         $fixedchoice, $mrk, $anst, $mrk_dis, $perq, $fix_choices_arrayRef, $show_choices, $mark_align, $auto_number_start_with) = Syvum::Online::XMLParser::qset_each_prm($process_qset);
      
        if (defined $current_format && defined $ipf && $ipf =~ /$current_format/si)
          {
            my $info_percent = $ipp;
            if ($info_percent == 100)
              {
                $info_percent = 99.99;
              }
            my $mod_val = 100 / $info_percent;
            #print $mod_val."\n";

            my @ips_array = @$ips_arrayRef;

            my @ipo_array;
            if (defined $ipo && length $ipo > 0)
              {
                @ipo_array = split(//is,$ipo);
              }

#        print "$count_qset IPS Length => ".scalar(@ips_array)."\n";
            if ($count_qset > 0) #   (If question set is not first then)
              {
                $table_text .= "<br/><br/>";
              } 

            if (defined $psg && length $psg > 0)
              {
                $table_text .= "<div style=\"text-align:center;\">$psg</div><br/>";
              }

            foreach my $process_ips (@ips_array)
              {
                my $count_qts = 1;
                my $exp_flag = 0;
                my @que_array;
                my $ips = ""; # Info Page Subheading
                my $random = "";

                $exp_flag = Syvum::Online::XMLParser::exp_col_null($process_ips);
            
                my $que_arrayRef;
                ($ips, $que_arrayRef) = Syvum::Online::XMLParser::separate_que($process_ips);
                @que_array = @$que_arrayRef;

                my $anspos = Syvum::Online::XMLParser::get_first_anspos($que_array[0]);
                $random = Syvum::Online::XMLParser::check_for_random_choice($anspos, $process_ips);

#            print "$count_ips IPS Length => ".scalar(@ipo_array)."\n";
#            print "$count_ips IPS Length => ".scalar(@que_array)."\n";

                if ($count_ips > 0) # (position of Info Page Subheading if greater than one)
                  {
                    $table_text .= "<br/>";
                  } 

                if (length $ips > 0)
                  {
                    $table_text .= "$ips<br/><br/>";
                  }

                my ($style_color, $cap_bgcolor) = table_caption_color($infoTheme);
                my $data_bgcolor = table_data_color($infoTheme);

                $table_text .=<<EOF;     
<table border = "1" cellpadding = "2" cellspacing = "2" align = "center" class = "sortable" id = "sort">
<tr style = "color:$style_color;" bgcolor = "$cap_bgcolor">
EOF

            # *** Note Here All 16 format order should be printed i.e combination of Q, A, E.
                foreach my $each_ipo (@ipo_array)
                  {
                    if ($each_ipo eq "Q")
                      {
                        $table_text .= "<th>$inp</th>"; #Question Caption
                      }
                    elsif ($each_ipo eq "A")
                      {
                        $table_text .= "<th>$out</th>"; #Answer Caption
                      }
                    elsif ($each_ipo eq "E" && $exp_flag == 1)
                      {
                        $table_text .= "<th>$exp</th>"; #Explanation Caption
                      }
                  }
            
            #Caption Columns of Question set or Info Page SubHeading...
                $table_text .= "</tr>";
            # Data Columns of each question or Info Page SubHeading....
  
                foreach my $que (@que_array)
                  {
                    if (length $que > 0 && $que =~ /<inp>/si)
                      {
                        if (($count_qts - int($count_qts/$mod_val) * $mod_val) < 1.0001 && 
                            ($count_qts - int($count_qts/$mod_val) * $mod_val) > 0.0001)
                          {
                            my $question_data_bg_color = "";
                            if ($infoTheme =~ /navy/si)
                              {
                                $question_data_bg_color = " bgcolor = \#DDFFFF";
                              }

                            $table_text .= "<tr$question_data_bg_color>";
                            my $question = "";
                            my $answer = "";
                            my $explanation = "";
                            if ($que =~ /<inp>(.*?)<\/inp>/si)
                              {
                                $question = $1;
                                if (defined $input_tts && length $input_tts > 0)
                                  {
                                    $input_tts =~ s/(\w)\w.*/$1/si;
                                    $input_tts = lc($input_tts);
                                    $question = "<tts l=\"$input_tts\">$question</tts>";
                                  }
                              }
                            if ($que =~ /<out>(.*?)<\/out>/si)
                              {
                                $answer = $1;
                                if (defined $fixedchoice && length $fixedchoice > 0)
                                  {
                                    my @fixed_choice_array = @$fix_choices_arrayRef;
                                    my $count_choice = 1;
                                    foreach my $choice (@fixed_choice_array)
                                      {
                                        if ($answer == $count_choice)
                                          {
                                            $answer = $choice;
                                          }
                                        $count_choice++;
                                      }
                                  }
                                  
                                if (defined $output_tts && length $output_tts > 0)
                                  {
                                    $output_tts =~ s/(\w)\w.*/$1/si;
                                    $output_tts = lc($output_tts);
                                    $answer = "<tts l=\"$output_tts\">$answer</tts>";
                                  }
                              }
                            if ($que =~ /<exp>(.*?)<\/exp>/si)
                              {
                                $explanation = $1;
                              }
                            if ($ipo !~ /A/)
                              {
                                $question =~ s/\_{7}/$answer/si;
                              }
                            foreach my $each_ipo (@ipo_array)
                              {
                                if ($each_ipo eq "Q")
                                  {
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
                                            $choices = Syvum::Online::XMLParser::choices($que, $random);
                                          }
                                      }
                                    $table_text .= "<td>$question$choices</td>"; #Question
                         # if input contains seven underscore (_) replace it with answer.
                                  }
                                elsif ($each_ipo eq "A")
                                  {
                                    $table_text .= "<td>$answer</td>"; #Answer
                                  }
                                elsif ($each_ipo eq "E" && $exp_flag == 1)
                                  {
                                    $table_text .= "<td>$explanation</td>"; #Explanation
                                  }
                              }  
                            $table_text .= "</tr>";
                          }
                        $count_qts++;
                      }
                  }

                $table_text .= "</table>";

                if (defined $ipp && $ipp > 0 && $ipp < 100)
                  {
                    $count_qts = $count_qts - 1;
                    my $percent_text = Syvum::Online::XMLParser::percent_note($lang);
            
                    $percent_text =~ s/_var2_/$count_qts/gs;
                    my $qts_shown = int(($count_qts * $ipp)/100);
                    $percent_text =~ s/_var1_/$qts_shown/gs;
                    $percent_text =~ s/_var3_/$ipp/gs;

#_var1_ is round(($total_question * $info_percent) div 100)
#_var2_ is total_question
#_var3_ is info_percent
                    $table_text .= "<br/>".$percent_text;
                  }
                $count_ips++;
              }
            $count_qset++;
          }
      }
    return $table_text;
  }

sub table_caption_color
  {
    my $infoTheme = shift;

    my $style_color = $infoTheme;
    my $bgcolor = $infoTheme;

    $style_color =~ s/black/white/i;
    $style_color =~ s/green/black/i;
    $style_color =~ s/maroon/black/i;
    $style_color =~ s/orange/black/i;
    $style_color =~ s/pink/black/i;
    $style_color =~ s/purple/black/i;
    $style_color =~ s/red/black/i;
    $style_color =~ s/silver/black/i;
    $style_color =~ s/navy/white/i;

    $bgcolor =~ s/black/black/i;
    $bgcolor =~ s/green/green/i;
    $bgcolor =~ s/maroon/\#ffcc88/i;
    $bgcolor =~ s/orange/orange/i;
    $bgcolor =~ s/pink/pink/i;
    $bgcolor =~ s/purple/purple/i;
    $bgcolor =~ s/red/red/i;
    $bgcolor =~ s/silver/silver/i;
    $bgcolor =~ s/navy/navy/i;

    return ($style_color, $bgcolor);
  }

sub table_data_color
  {
    my $infoTheme = shift;

    my $bgcolor = $infoTheme;
    $bgcolor =~ s/black/white/i;
    $bgcolor =~ s/green/white/i;
    $bgcolor =~ s/maroon/white/i;
    $bgcolor =~ s/orange/white/i;
    $bgcolor =~ s/pink/white/i;
    $bgcolor =~ s/purple/white/i;
    $bgcolor =~ s/red/white/i;
    $bgcolor =~ s/silver/white/i;
    $bgcolor =~ s//\#DDFFFF/i;

    return $bgcolor;
  }

sub list
  {
    my $buffer = shift;
    my $current_format = shift;
    
    #my $infoTheme = shift;

    my $qset_arrayRef = Syvum::Online::XMLParser::separate_qset($buffer);
    my @qset_array = @$qset_arrayRef;

    my $list_text = "";
    my $count_qset = 0;

#    print "Qset Length => ".scalar(@qset_array)."\n";

    foreach my $process_qset (@qset_array)
      {        
        my ($prm, $psg, $sectionheading, $sectiondetails, $ips_arrayRef, $ipf, $ipo, $ipp, $lang, $input_tts, 
        $output_tts, $showsrc, $sourceinfo, $dmarks, $showmark, $inp, $out, $exp, $des, $rdes, $fixedchoice, $mrk, $anst, $mrk_dis, $perq, $fix_choices_arrayRef, $show_choices, $mark_align, $auto_number_start_with);
        my $count_ips = 0;

        ($prm, $psg, $sectionheading, $sectiondetails, $ips_arrayRef, $ipf, $ipo, $ipp, $lang, $input_tts, 
         $output_tts, $showsrc, $sourceinfo, $dmarks, $showmark, $inp, $out, $exp, $des, $rdes, 
         $fixedchoice, $mrk, $anst, $mrk_dis, $perq, $fix_choices_arrayRef, $show_choices, $mark_align, $auto_number_start_with) = Syvum::Online::XMLParser::qset_each_prm($process_qset);

        if (defined $current_format && defined $ipf && $ipf =~ /$current_format/si)
          {
            my $info_percent = $ipp;
            if ($info_percent == 100)
              {
                $info_percent = 99.99;
              }
            my $mod_val = 100 / $info_percent;
        #print $mod_val."\n";

            my @ips_array = @$ips_arrayRef;
            my @ipo_array;
            if (defined $ipo && length $ipo > 0)
              {
                @ipo_array = split(//is,$ipo);
              }

#        print "$count_qset IPS Length => ".scalar(@ips_array)."\n";
            if ($count_qset > 0) #   (If question set is not first then)
              {
                $list_text .= "<br/><br/>";
              } 

            if (defined $psg && length $psg > 0)
              {
                $list_text .= "<div style=\"text-align:center;\">$psg</div><br/>";
              }

            foreach my $process_ips (@ips_array)
              {
                my $count_qts = 1;
                my @que_array;
                my $ips = ""; # Info Page Subheading
                my $random = "";
            
                my $que_arrayRef;
                ($ips, $que_arrayRef) = Syvum::Online::XMLParser::separate_que($process_ips);
                @que_array = @$que_arrayRef;
                my $exp_flag = 0;
                $exp_flag = Syvum::Online::XMLParser::exp_col_null($process_ips);

                my $anspos = Syvum::Online::XMLParser::get_first_anspos($que_array[0]);
                $random = Syvum::Online::XMLParser::check_for_random_choice($anspos, $process_ips);

#            print "$count_ips IPS Length => ".scalar(@ipo_array)."\n";
#            print "$count_ips IPS Length => ".scalar(@que_array)."\n";

                if ($count_ips > 0) # (position of Info Page Subheading if greater than one)
                  {
                    $list_text .= "<br/>";
                  } 

                if (length $ips > 0)
                  {
                    $list_text .= "$ips<br/><br/>";
                  }


            # *** Note Here All 16 format order should be printed i.e combination of Q, A, E.
                my $count_ipoformat_cap = 1;
                foreach my $each_ipo (@ipo_array)
                  {
                    if ($each_ipo eq "Q")
                      {
                        $list_text .= "<b>$inp</b>"; #Question Caption
                      }
                    elsif ($each_ipo eq "A")
                      {
                        $list_text .= "<b>$out</b>"; #Answer Caption
                      }
                    elsif ($each_ipo eq "E" && $exp_flag == 1)
                      {
                        $list_text .= "<b>$exp</b>"; #Explanation Caption
                      }
                    if ($count_ipoformat_cap < scalar @ipo_array)
                      {
                        $list_text .= " : ";
                      }
                    $count_ipoformat_cap++;
                  }

                $list_text =~ s/\s\:\s$//si;
            
            #Caption Columns of Question set or Info Page SubHeading...
                $list_text .= "<br/><ul>";
            # Data Columns of each question or Info Page SubHeading....
  
                foreach my $que (@que_array)
                  {
                    if (length $que > 0 && $que =~ /<inp>/si)
                      {
                        if (($count_qts - int($count_qts/$mod_val) * $mod_val) < 1.0001 && 
                            ($count_qts - int($count_qts/$mod_val) * $mod_val) > 0.0001)
                          {
                            my $question = "";
                            my $answer = "";
                            my $explanation = "";
                            my $count_ipoformat = 1;
                            if ($que =~ /<inp>(.*?)<\/inp>/si)
                              {
                                $question = $1;
                                if (defined $input_tts && length $input_tts > 0 && length $question > 0)
                                  {
                                    $input_tts =~ s/(\w)\w.*/$1/si;
                                    $input_tts = lc($input_tts);
                                    $question = "<tts l=\"$input_tts\">$question</tts>";
                                  }
                              }
                            if ($que =~ /<out>(.*?)<\/out>/si)
                              {
                                $answer = $1;
                                if (defined $fixedchoice && length $fixedchoice > 0)
                                  {
                                    my @fixed_choice_array = @$fix_choices_arrayRef;
                                    my $count_choice = 1;
                                    foreach my $choice (@fixed_choice_array)
                                      {
                                        if ($answer == $count_choice)
                                          {
                                            $answer = $choice;
                                          }
                                        $count_choice++;
                                      }
                                  }
                                if (defined $output_tts && length $output_tts > 0 && length $answer > 0)
                                  {
                                    $output_tts =~ s/(\w)\w.*/$1/si;
                                    $output_tts = lc($output_tts);
                                    $answer = "<tts l=\"$output_tts\">$answer</tts>";
                                  }
                                if (length $answer > 0)
                                  {
                                    $answer = "<b>$answer</b>";
                                  }
                              }
                            if ($que =~ /<exp>(.*?)<\/exp>/si)
                              {
                                $explanation = $1;
                              }
                            if ($ipo !~ /A/)
                              {
                                $question =~ s/\_{7}/$answer/si;
                              }
                            $list_text .= Syvum::Online::XMLParser::list_que_for_info_order($question, $answer, $explanation, $ipo, $que, $anst, $fixedchoice, $random, $exp_flag);
                          }
                        $count_qts++;
                      }
                  }

                $list_text .= "</ul>";

                if (defined $ipp && $ipp > 0 && $ipp < 100)
                  {
                    $count_qts = $count_qts - 1;
                    my $percent_text = Syvum::Online::XMLParser::percent_note($lang);
            
                    $percent_text =~ s/_var2_/$count_qts/gs;
                    my $qts_shown = int(($count_qts * $ipp)/100);
                    $percent_text =~ s/_var1_/$qts_shown/gs;
                    $percent_text =~ s/_var3_/$ipp/gs;

#_var1_ is round(($total_question * $info_percent) div 100)
#_var2_ is total_question
#_var3_ is info_percent
                    $list_text .= $percent_text;
                  }
                $count_ips++;
              }
            $count_qset++;
          }
      }
    return $list_text;
  }

sub test_paper
  {
    my $buffer = shift;
    my $current_ipf = shift;
    my $auto_number = shift;
    my $current_userId = shift;
    my $dirPath = shift;

    $buffer =~ s/<ocr>(.*?)<\/ocr>//igs;
    my $contans = "";
    #my $file = "/tmp/sheetz.txt";
    #open FILEO,">$file";
    #print FILEO $contans;
    #close FILEO;

    my $qset_arrayRef = Syvum::Online::XMLParser::separate_qset($buffer);
    my @qset_array = @$qset_arrayRef;

    my $test_paper_text = "";
    my $count_qset = 0;
    my $auto_num_count = 1;

#    print "Qset Length => ".scalar(@qset_array)."\n";
    if ($qset_array[0] =~ m/<contans>(.*?)<\/contans>/g)
      {
        $contans = $1;         
      } 
    foreach my $process_qset (@qset_array)
      {        
        my ($prm, $psg, $sectionheading, $sectiondetails, $ips_arrayRef, $ipf, $ipo, $ipp, $lang, $input_tts, 
        $output_tts, $showsrc, $sourceinfo, $dmarks, $showmark, $inp, $out, $exp, $des, $rdes, $fixedchoice, $mrk, 
        $anst, $mrk_dis, $perq, $fix_choices_arrayRef, $show_choices, $mark_align, $auto_number_start_with);
        my $count_ips = 0;

        ($prm, $psg, $sectionheading, $sectiondetails, $ips_arrayRef, $ipf, $ipo, $ipp, $lang, $input_tts, $output_tts, 
        $showsrc, $sourceinfo, $dmarks, $showmark, $inp, $out, $exp, $des, $rdes, $fixedchoice, $mrk, $anst, $mrk_dis, 
        $perq, $fix_choices_arrayRef, $show_choices, $mark_align, $auto_number_start_with) = Syvum::Online::XMLParser::qset_each_prm($process_qset, $current_ipf);
        
        if ($inp eq "Question")
          {
            $inp = "";
          }
        if ($out eq "Answer")
          {
            $out = "";
          }
        if ($exp eq "Explanation")
          {
            $exp = "";
          }
        if ($mark_align ne "middle" && $mark_align ne "bottom")
          {
            $mark_align = "top";
          }
        if (defined $auto_number_start_with && length $auto_number_start_with > 0)
          {
            $auto_num_count = $auto_number_start_with;
          }

        if ((defined $current_ipf && defined $ipf && $ipf =~ /$current_ipf/si)
            || $contans == 1)
          {
            my $info_percent = $ipp;
            if ($contans == 1)
              {
                $info_percent = 99.99;
              }

            if ($info_percent == 100)
              {
                $info_percent = 99.99;
              }
            my $mod_val = 100 / $info_percent;
            #print $mod_val."\n";

            my @ips_array = @$ips_arrayRef;

#        my @ipo_array;
#        if (defined $ipo && length $ipo > 0)
#          {
#            @ipo_array = split(//is,$ipo);
#          }

#        print "$count_qset IPS Length => ".scalar(@ips_array)."\n";
            if ($count_qset > 0) #   (If question set is not first then)
              {
                $test_paper_text .= "<br/><!--<br/>-->";
              }

            if (defined $sectionheading && length $sectionheading > 0)
              {
                $test_paper_text .= "<div style=\"text-align:center;\"><br/>$sectionheading</div>";
              }

            if (defined $sectiondetails && length $sectiondetails > 0)
              {
                $test_paper_text .= "<div style=\"text-align:center;\"><br/><step name=\"Show / Hide Section Details\">$sectiondetails</step></div>";
              }

            if ((defined $des && length $des > 0 && defined $current_ipf && $current_ipf !~ /\_r/is) || 
                (defined $rdes && length $rdes > 0 && defined $current_ipf && $current_ipf =~ /\_r/is))
              {
                $test_paper_text .= "<table width=\"100%\"><tr>";
              }

            if (defined $des && length $des > 0 && defined $current_ipf && $current_ipf !~ /\_r/is)
              {
                $test_paper_text .= "<td>$des</td>";
                if (defined $current_ipf && $current_ipf !~ /^answer\_/is && length $mrk > 0 && $mrk_dis eq "Total")
                  {                    
                    $test_paper_text .= "<td align=\"right\" valign=\"".$mark_align."\" width=\"10%\">$mrk</td>";
                  }
              }
            elsif (defined $inp && length $inp > 0 && defined $out && length $out > 0 && defined $current_ipf && $current_ipf !~ /\_r/is)
              {
                #String for different language description i.e. Given the _var1_(e.g. inp), identify the _var2_(e.g. out)
                if (defined $current_ipf && $current_ipf !~ /^answer\_/is && length $mrk > 0 && $mrk_dis eq "Total")
                  {
                    $test_paper_text .= "<table width=\"100%\"><tr><td>Given the $inp, identify the $out </td><td align=\"right\" valign=\"".$mark_align."\" width=\"10%\">$mrk</td></tr></table>";
                  }
                else
                  {
                    $test_paper_text .= "Given the $inp, identify the $out <br/><br/>";                
                  }
              }

            if (defined $rdes && length $rdes > 0 && defined $current_ipf && $current_ipf =~ /\_r/is)
              {
                $test_paper_text .= "<td>$rdes</td>";
              }
            elsif (defined $inp && length $inp > 0 && defined $out && length $out > 0 && defined $current_ipf && $current_ipf =~ /\_r/is)
              {
                #String for different language description i.e. Given the _var2_(e.g. out), identify the _var1_(e.g. inp)
                $test_paper_text .= "Given the $out, identify the $inp <br/><br/>";
              }

            if ((defined $des && length $des > 0 && defined $current_ipf && $current_ipf !~ /\_r/is) || 
                (defined $rdes && length $rdes > 0 && defined $current_ipf && $current_ipf =~ /\_r/is))
              {
                $test_paper_text .= "</tr></table><br/>";
              }

            if (defined $psg && length $psg > 0)
              {
                $test_paper_text .= "$psg<br/>";
              }

            foreach my $process_ips (@ips_array)
              {
                my $count_qts = 1;
                my $count_qts1 = 1;
                my @que_array;
                my $ips = ""; # Info Page Subheading
                my $random = "";
            
                my $que_arrayRef;
                ($ips, $que_arrayRef) = Syvum::Online::XMLParser::separate_que($process_ips);
                @que_array = @$que_arrayRef;

                my $anspos = Syvum::Online::XMLParser::get_first_anspos($que_array[0]);
                $random = Syvum::Online::XMLParser::check_for_random_choice($anspos, $process_ips);

#            print "$count_ips IPS Length => ".scalar(@ipo_array)."\n";
#            print "$count_ips IPS Length => ".scalar(@que_array)."\n";

            #if ($count_ips > 0) # (position of Info Page Subheading if greater than one)
            #  {
            #    $test_paper_text .= "<br/>";
            #  } 

# In Test Paper we not include the IPS.
#            if (length $ips > 0)
#              {
#                $test_paper_text .= "$ips<br/><br/>";
#              }


            # *** Note Here All 16 format order should be printed i.e combination of Q, A, E.
            
            #Caption Columns of Question set or Info Page SubHeading...
            #$test_paper_text .= "<br/>";
            # Data Columns of each question or Info Page SubHeading....
  
                foreach my $que (@que_array)
                  {
                    if (length $que > 0 && $que =~ /<inp>/si)
                      {
                        if (($count_qts1 - int($count_qts1/$mod_val) * $mod_val) < 1.0001 && 
                            ($count_qts1 - int($count_qts1/$mod_val) * $mod_val) > 0.0001)
                          {                              
                            $count_qts = $auto_num_count;
                            my $question = "";
                            my $answer = "";
                            my $explanation = "";
                            my $kwd = "";
                            my $que_mrk = "";
                            my $count_ipoformat = 1;
                            my $count_ans = 1;
                            if ($que =~ /<inp>(.*?)<\/inp>/si)
                              {
                                $question = $1;
                                if (defined $input_tts && length $input_tts > 0)
                                  {
                                    $input_tts =~ s/(\w)\w.*/$1/si;
                                    $input_tts = lc($input_tts);
                                    $question = "<tts l=\"$input_tts\">$question</tts>";
                                  }
                              }

                            my $que_ans = $que;
                            
                            while ($que_ans =~ s/<ans[^>]*>[^<]*<out>(.*?)<\/out>//si && $count_ans < 6)
                              {
                                my $each_answer = $1;
                                
                                if (defined $fixedchoice && length $fixedchoice > 0)
                                  {
                                    my @fixed_choice_array = @$fix_choices_arrayRef;
                                    my $count = 1;
                                    foreach my $choice (@fixed_choice_array)
                                      {
                                        if ($each_answer == $count)
                                          {
                                            $each_answer = $choice;
                                          }
                                        $count++;
                                      }
                                  }
                                  
                                if (defined $output_tts && length $output_tts > 0)
                                  {
                                    $output_tts =~ s/(\w)\w.*/$1/si;
                                    $output_tts = lc($output_tts);
                                    $each_answer = "<tts l=\"$output_tts\">$each_answer</tts>";
                                  }
                                  
                                if ($count_ans > 1)
                                  {
                                    $each_answer = "<br/>".$each_answer;
                                  }                                
                                $answer .= $each_answer;
                                $count_ans++;
                              }
                            if ($que =~ /<exp>(.*?)<\/exp>/si)
                              {
                                $explanation = $1;
                                if (length $explanation > 0)
                                  {
                                    $explanation = "<br/>".$explanation;
                                  }
                              }

                            if ($que =~ /<kwd>(.*?)<\/kwd>/si)
                              {
                                $kwd = $1;
                                $kwd =~ s/<span[^>]*>//gsi;
                                $kwd =~ s/<\/span>//gsi;
                              }

                            if ($que =~ /<mrk>(.*?)<\/mrk>/si)
                              {
                                $que_mrk = $1;
                              }

                            my $choices = "";
                            if (defined $fixedchoice && length $fixedchoice > 0 && defined $show_choices && $show_choices != 0)
                              {
                                $choices = "<br/>".$fixedchoice;
                              }
                            elsif ($que =~ /<ans\s+t\s*\=\s*(\"|\')opt(\"|\')>/si && defined $show_choices && $show_choices != 0)
                              {
                                $choices = Syvum::Online::XMLParser::choices($que, $random);
                              }
                        

                            if (defined $current_ipf && $current_ipf !~ /^answer\_/is)
                              {
                                if (length $mrk > 0 && $mrk_dis eq "Individual" && length $showmark < 1)
                                  {
                                    $perq =~ s/\.5/\&\#189\;/si;
                                    $perq =~ s/\.25/\&\#188\;/si;
                                    $perq =~ s/\.75/\&\#190\;/si;
                                    if (length $que_mrk < 1)
                                      {
                                        $que_mrk = $perq;
                                      }

                                    $test_paper_text .= "<table width=\"100%\"><tr>";

                                    if ($auto_number ne "No")
                                      {
                                        $test_paper_text .= "<td valign=\"top\"><b>$count_qts. </b></td>";
                                      }
                                    $test_paper_text .= "<td>";

                                    if ($current_ipf eq "question_only" || $current_ipf eq "question_hide")
                                      {
                                        $test_paper_text .= "$question$choices";
                                      }
                                    else
                                      {
                                        $test_paper_text .= "$answer<br/>";
                                      }

                                    $test_paper_text .= "</td><td align=\"right\" valign=\"".$mark_align."\" width=\"10%\">$que_mrk</td></tr>";

                                    if ($kwd =~ /\:/si)
                                      {
                                        my $kwd_count = 0;
                                        my $multi_keys = $kwd;
                                        if ($multi_keys =~ /\,/s)
                                          {
                                            my @multi_kwd = split(/\,/s, $multi_keys);
                                            $kwd = "";
                                            foreach my $keys (@multi_kwd)
                                              {
                                                $keys =~ s/[^\:]*\:(.*?)/$1/si;
                                                $kwd .= $keys.", ";
                                              }
                                            $kwd =~ s/\,\s$//si;
                                          }
                                        else
                                          {
                                            $kwd =~ s/[^\:]*\:(.*?)/$1/si;
                                          }
                                    
                                        $test_paper_text .= "<tr style=\"margin-top:0px;margin-bottom:0px;\"><td align=\"right\" colspan=\"2\">($kwd)</td></tr>";
                                      }
                                    elsif (length $sourceinfo > 0 and $showsrc eq "Yes")
                                      {
                                        $test_paper_text .= "<tr style=\"margin-top:0px;margin-bottom:0px;\"><td align=\"right\" colspan=\"2\">($sourceinfo)</td></tr>";
                                      }
    
                                    $test_paper_text .= "</table>";
                                  }
                                elsif (length $mrk < 1 && $mrk_dis eq "Individual" && length $showmark < 1)
                                  {
                                    $test_paper_text .= "<table width=\"100%\"><tr>";

                                    if ($auto_number ne "No")
                                      {
                                        $test_paper_text .= "<td valign=\"top\"><b>$count_qts. </b></td>";
                                      }

                                    $perq =~ s/\.5/\&\#189\;/si;
                                    $perq =~ s/\.25/\&\#188\;/si;
                                    $perq =~ s/\.75/\&\#190\;/si;
                                    $test_paper_text .= "<td>";

                                    if ($current_ipf eq "question_only" || $current_ipf eq "question_hide")
                                      {
                                        $test_paper_text .= "$question$choices";
                                      }
                                    else
                                      {
                                        $test_paper_text .= "$answer<br/>";
                                      }

                                    $test_paper_text .= "</td><td align=\"right\" valign=\"".$mark_align."\" width=\"10%\">$perq</td></tr>";

                                    if ($kwd =~ /\:/si)
                                      {
                                        $kwd =~ s/[^\:]*\:(.*?)/$1/si;
                                        $test_paper_text .= "<tr style=\"margin-top:0px;margin-bottom:0px;\"><td align=\"right\" colspan=\"2\">($kwd)</td></tr>";
                                      }
                                    elsif (length $sourceinfo > 0 and $showsrc eq "Yes")
                                      {
                                        $test_paper_text .= "<tr style=\"margin-top:0px;margin-bottom:0px;\"><td align=\"right\" colspan=\"2\">($sourceinfo)</td></tr>";
                                      }
    
                                    $test_paper_text .= "</table>";
                                  }
                                else
                                  {
                                    if ($auto_number ne "No")
                                      {
                                        $test_paper_text .= "<b><span style=\"vertical-align: top;\">$count_qts. </span></b>";
                                      }

                                    if ($current_ipf eq "question_only" || $current_ipf eq "question_hide")
                                      {
                                        if ($current_ipf eq "question_hide" && length $choices < 1)
                                          {
                                            $choices = "<br/>";
                                          }
                                        $test_paper_text .= "$question$choices";
                                      }
                                    else
                                      {
                                        $test_paper_text .= "$answer<br/>";
                                      }                                

                                    if ($showsrc eq "Yes")
                                      {
                                        $test_paper_text .= "<table width=\"100%\">";

                                        if ($kwd =~ /\:/si)
                                          {
                                            $kwd =~ s/[^\:]*\:(.*?)/$1/si;
                                            $test_paper_text .= "<tr style=\"margin-top:0px;margin-bottom:0px;\"><td align=\"right\" colspan=\"2\">($kwd)</td></tr>";
                                          }
                                        elsif (length $sourceinfo > 0 and $showsrc eq "Yes")
                                          {
                                            $test_paper_text .= "<tr style=\"margin-top:0px;margin-bottom:0px;\"><td align=\"right\" colspan=\"2\">($sourceinfo)</td></tr>";
                                          }

                                        $test_paper_text .= "</table>";
                                      }
                                    else
                                      {
                                        #$test_paper_text .= "<br/>";
                                      }
                                  }                            
                              }
                            else
                              {
                                if ($auto_number ne "No")
                                  {
                                    $test_paper_text .= "<b><span style=\"vertical-align: top;\">$count_qts. </span></b>";
                                  }
                                $test_paper_text .= "$answer$explanation<br/>";
                              }
                            if (defined $current_ipf && $current_ipf eq "question_hide")
                              {  
                                my $cans_text = "";
                                my $ans_text = "";
                                my $contans_flag = 0;
                               
			        #Code for Controlled Collaborative Authoring Project. 
                                #Syvum::Debug::debugOut('sheetz.txt','question'.$que);
                                if ($que =~ /<ans>(.*?)<\/ans>/gs)
                                  {
                                    
                                    #$contans_flag = 1;
                                    ($ans_text = $1) =~ s/<\/out>(.*?)$//s;
                                    $ans_text =~ s/<out>//s;
                                    if (defined $ans_text && length $ans_text > 0 && $ans_text !~ /<out>\s*<\/out>/gs)
                                      {
                                        $contans_flag = 1;  
                                      }  
                                    else
                                      {
                                        $contans_flag = 0;
                                      }   
                                  }    
                                if ($que =~ /<cans.*>/gs)
                                  {
                                    $cans_text = Syvum::Online::XMLParser::create_contans($que, $contans_flag, $count_qts, $current_userId, $dirPath);
                                  }
                               # Syvum::Debug::debugOut('sheetz.txt','question'.$que);
                                if ($que =~ /<ans>.*?<\/ans>/gs && $que =~ /<exp>.*?<\/exp>/gs)
                                  {
                                    $contans_flag = 2;
                                  }  
                                if ($contans == 1)
                                  {
                                    if ($count_qts == 1)
                                      { 
                                        $test_paper_text .=<<EOF;
<script src="/saw/ajax.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="/saw/ccap.css" />
<script language =javascript>
function openContansWin(id,contans_flag)
{
var title = document.title;
var fullPath = window.location.href;
var lastSlash = fullPath.lastIndexOf('/serve.cgi') + 10;
//alert(lastSlash);
var fileName = fullPath.substring(lastSlash,fullPath.length);
//alert(fileName);
var OnlyFileName = fileName.split('?')[0];
//alert(OnlyFileName);
var cawin = window.open('/cgi/editor/contans.cgi?' + id +'%%%' + title +'%%%' + OnlyFileName +'%%%'+ contans_flag,'cawindow','toolbar=no,location=no,directories=no,status=no,menubar=no,resizable,scrollbars,width=700,height=400,left=200,top=200');
}

function openRateAns(name,messageId)
{
var fullPath = window.location.href;
var lastSlash = fullPath.lastIndexOf('/serve.cgi') + 10;
var fileName = fullPath.substring(lastSlash,fullPath.length);
var OnlyFileName = fileName.split('?')[0];
var tup = '_tup';
var tdn = '_tdn';
var ajax = 'ajax';
var divnames = new Array(2);
divnames[0] = messageId+tup;
divnames[1] = messageId+tdn;
//alert("MessID"+messageId);
//alert("divnames[0]"+divnames[0]);
//alert("divnames[1]"+divnames[1]);
var current_user = getuid();
if (current_user.length > 1)
  {
    var ratewin = makeRequest('/cgi/editor/rateanswer.cgi?' + name +'%%%'+ messageId +'%%%' + OnlyFileName +'%%%'+ ajax, divnames);
  }
else
  {
    alert("You must sign in to vote.");
    var ratewin = window.open('/cgi/editor/rateanswer.cgi?'+ name +'%%%'+ messageId +'%%%' + OnlyFileName,'ratewindow','toolbar=no,location=no,directories=no,status=no,menubar=no,resizable,scrollbars,width=400,height=180,left=350,top=300');
  }
}

function deleteAnswer(divId, messageId, contributorUserId)
{
//alert("hello" + divId);
var fullPath = window.location.href;
var lastSlash = fullPath.lastIndexOf('/serve.cgi') + 10;
var fileName = fullPath.substring(lastSlash,fullPath.length);
var OnlyFileName = fileName.split('?')[0];
var divnames = new Array(1);
divnames[0] = divId;
//alert (contributorUserId);
var confirmDelete = confirm ("Are you sure you want to delete the answer?");
//alert(confirmDelete);
if (confirmDelete)
  {
    var delans = makeRequest('/cgi/editor/deleteanswer.cgi?' + messageId +'%%%' + OnlyFileName +'%%%'+ contributorUserId, divnames);
  }
else
  {
  } 
}
</script>
EOF
                                      }  
                                    if ($contans_flag == 0)
                                      {
                                        if (defined $cans_text && length $cans_text > 0)
                                          {   
                                            $test_paper_text .=<<EOF;
<step name=\"View Answer(s)\">$cans_text</step><br/>
<div id="empty_$count_qts">
</div>
EOF
                                          }
                                        else
                                          {
                                            $test_paper_text .=<<EOF; 
<div id="empty_$count_qts">
</div>
EOF
                                          }
                                        $test_paper_text .=<<EOF;
<span id =\"$count_qts\" name=\"contrians\" style=\"font-size:100%; color:blue; text-align:center; cursor:pointer; text-decoration:underline;\" onClick=\"openContansWin(this.id, '$contans_flag');\">Contribute Your Answer / Explanation</span><br/>
EOF
   
                                      }
                                    elsif ($contans_flag == 1)
                                      {
                                        $test_paper_text .=<<EOF;
<step name=\"View Answer(s)\">$ans_text<br/>$cans_text</step><br/>
<div id="empty_$count_qts">
</div>
<span id =\"$count_qts\" name=\"contrians\" style=\"font-size:100%; color:blue; text-align:center; cursor:pointer; text-decoration:underline;\" onClick=\"openContansWin(this.id, '$contans_flag');\">Contribute Your Answer / Explanation</span><br/>
EOF
                                      }
                                    elsif ($contans_flag == 2)
                                      {
                                        $test_paper_text .= "<step name=\"View Answer(s)\">$answer$explanation</step><br/>";
                                      }
 
                                  }
                                else
                                  {
                                    $test_paper_text .= "<step name=\"Answer\">$answer$explanation</step><br/>";
                                  } 
                              }
                            elsif (defined $current_ipf && $current_ipf eq "question_rhide")
                              {
                                $test_paper_text .= "<step name=\"Answer\">$question$explanation</step><br/>";
                              }

                            $test_paper_text .= "<br/> ";
                          }
                        $auto_num_count ++;
                        $count_qts1++;
                      }
                  }

                if (defined $ipp && $ipp > 0 && $ipp < 100)
                  {
                    $count_qts1 = $count_qts1 - 1;
                    my $percent_text = Syvum::Online::XMLParser::percent_note($lang);
            
                    $percent_text =~ s/_var2_/$count_qts1/gs;
                    my $qts_shown = int(($count_qts1 * $ipp)/100);
                    $percent_text =~ s/_var1_/$qts_shown/gs;
                    $percent_text =~ s/_var3_/$ipp/gs;

#_var1_ is round(($total_question * $info_percent) div 100)
#_var2_ is total_question
#_var3_ is info_percent
                    $test_paper_text .= $percent_text;
                  }
                $count_ips++;
              }
            $count_qset++;
          }
      }
    return $test_paper_text;
  }

sub ocr_test_paper
  {
    my $buffer = shift;
    my $current_ipf = shift;
    my $auto_number = shift;

    $current_ipf = "question_hide";

    my $qset_arrayRef = Syvum::Online::XMLParser::separate_qset($buffer);
    my @qset_array = @$qset_arrayRef;

    my $test_paper_text = "";
    my $count_qset = 0;
    my $auto_num_count = 1;

#    print "Qset Length => ".scalar(@qset_array)."\n";

    foreach my $process_qset (@qset_array)
      {        
        my ($prm, $psg, $sectionheading, $sectiondetails, $ips_arrayRef, $ipf, $ipo, $ipp, $lang, $input_tts, 
        $output_tts, $showsrc, $sourceinfo, $dmarks, $showmark, $inp, $out, $exp, $des, $rdes, $fixedchoice, $mrk, 
        $anst, $mrk_dis, $perq, $fix_choices_arrayRef, $show_choices, $mark_align, $auto_number_start_with);
        my $count_ips = 0;

        ($prm, $psg, $sectionheading, $sectiondetails, $ips_arrayRef, $ipf, $ipo, $ipp, $lang, $input_tts, $output_tts, 
        $showsrc, $sourceinfo, $dmarks, $showmark, $inp, $out, $exp, $des, $rdes, $fixedchoice, $mrk, $anst, $mrk_dis, 
        $perq, $fix_choices_arrayRef, $show_choices, $mark_align, $auto_number_start_with) = Syvum::Online::XMLParser::qset_each_prm($process_qset, $current_ipf);
        $psg =~ s/.*?<ocr>(.*?)<\/ocr>.*?/$1/sgi;
        $sectionheading =~ s/.*?<ocr>(.*?)<\/ocr>.*?/$1/sgi;
        $sectiondetails =~ s/.*?<ocr>(.*?)<\/ocr>.*?/$1/sgi;
        $des =~ s/.*?<ocr>(.*?)<\/ocr>.*?/$1/sgi;
        $rdes =~ s/.*?<ocr>(.*?)<\/ocr>.*?/$1/sgi;
        
        if ($inp eq "Question")
          {
            $inp = "";
          }
        if ($out eq "Answer")
          {
            $out = "";
          }
        if ($exp eq "Explanation")
          {
            $exp = "";
          }
        if ($mark_align ne "middle" && $mark_align ne "bottom")
          {
            $mark_align = "top";
          }
        if (defined $auto_number_start_with && length $auto_number_start_with > 0)
          {
            $auto_num_count = $auto_number_start_with;
          }

        if (defined $current_ipf && defined $ipf && $ipf =~ /$current_ipf/si)
          {
            my $info_percent = $ipp;
            if ($info_percent == 100)
              {
                $info_percent = 99.99;
              }
            my $mod_val = 100 / $info_percent;
            #print $mod_val."\n";

            my @ips_array = @$ips_arrayRef;

#        my @ipo_array;
#        if (defined $ipo && length $ipo > 0)
#          {
#            @ipo_array = split(//is,$ipo);
#          }

#        print "$count_qset IPS Length => ".scalar(@ips_array)."\n";
            if ($count_qset > 0) #   (If question set is not first then)
              {
                $test_paper_text .= "<br/><!--<br/>-->";
              }

            if (defined $sectionheading && length $sectionheading > 0)
              {
                $test_paper_text .= "<div style=\"text-align:center;\"><br/>$sectionheading</div>";
              }

            if (defined $sectiondetails && length $sectiondetails > 0)
              {
                $test_paper_text .= "<div style=\"text-align:center;\"><br/><step name=\"Show / Hide Section Details\">$sectiondetails</step></div>";
              }

            if ((defined $des && length $des > 0 && defined $current_ipf && $current_ipf !~ /\_r/is) || 
                (defined $rdes && length $rdes > 0 && defined $current_ipf && $current_ipf =~ /\_r/is))
              {
                $test_paper_text .= "<table width=\"100%\"><tr>";
              }

            if (defined $des && length $des > 0 && defined $current_ipf && $current_ipf !~ /\_r/is)
              {
                $test_paper_text .= "<td>$des</td>";
                if (defined $current_ipf && $current_ipf !~ /^answer\_/is && length $mrk > 0 && $mrk_dis eq "Total")
                  {                    
                    $test_paper_text .= "<td align=\"right\" valign=\"".$mark_align."\" width=\"10%\">$mrk</td>";
                  }
              }
            elsif (defined $inp && length $inp > 0 && defined $out && length $out > 0 && defined $current_ipf && $current_ipf !~ /\_r/is)
              {
                #String for different language description i.e. Given the _var1_(e.g. inp), identify the _var2_(e.g. out)
                if (defined $current_ipf && $current_ipf !~ /^answer\_/is && length $mrk > 0 && $mrk_dis eq "Total")
                  {
                    $test_paper_text .= "<table width=\"100%\"><tr><td>Given the $inp, identify the $out </td><td align=\"right\" valign=\"".$mark_align."\" width=\"10%\">$mrk</td></tr></table>";
                  }
                else
                  {
                    $test_paper_text .= "Given the $inp, identify the $out <br/><br/>";                
                  }
              }

            if (defined $rdes && length $rdes > 0 && defined $current_ipf && $current_ipf =~ /\_r/is)
              {
                $test_paper_text .= "<td>$rdes</td>";
              }
            elsif (defined $inp && length $inp > 0 && defined $out && length $out > 0 && defined $current_ipf && $current_ipf =~ /\_r/is)
              {
                #String for different language description i.e. Given the _var2_(e.g. out), identify the _var1_(e.g. inp)
                $test_paper_text .= "Given the $out, identify the $inp <br/><br/>";
              }

            if ((defined $des && length $des > 0 && defined $current_ipf && $current_ipf !~ /\_r/is) || 
                (defined $rdes && length $rdes > 0 && defined $current_ipf && $current_ipf =~ /\_r/is))
              {
                $test_paper_text .= "</tr></table><br/>";
              }

            if (defined $psg && length $psg > 0)
              {
                $test_paper_text .= "$psg<br/>";
              }

            foreach my $process_ips (@ips_array)
              {
                my $count_qts = 1;
                my $count_qts1 = 1;
                my @que_array;
                my $ips = ""; # Info Page Subheading
                my $random = "";
            
                my $que_arrayRef;
                ($ips, $que_arrayRef) = Syvum::Online::XMLParser::separate_que($process_ips);
                @que_array = @$que_arrayRef;

                my $anspos = Syvum::Online::XMLParser::get_first_anspos($que_array[0]);
                $random = Syvum::Online::XMLParser::check_for_random_choice($anspos, $process_ips);

#            print "$count_ips IPS Length => ".scalar(@ipo_array)."\n";
#            print "$count_ips IPS Length => ".scalar(@que_array)."\n";

            #if ($count_ips > 0) # (position of Info Page Subheading if greater than one)
            #  {
            #    $test_paper_text .= "<br/>";
            #  } 

# In Test Paper we not include the IPS.
#            if (length $ips > 0)
#              {
#                $test_paper_text .= "$ips<br/><br/>";
#              }


            # *** Note Here All 16 format order should be printed i.e combination of Q, A, E.
            
            #Caption Columns of Question set or Info Page SubHeading...
            #$test_paper_text .= "<br/>";
            # Data Columns of each question or Info Page SubHeading....
  
                foreach my $que (@que_array)
                  {
                    if (length $que > 0 && $que =~ /<inp>/si)
                      {
                        if (($count_qts1 - int($count_qts1/$mod_val) * $mod_val) < 1.0001 && 
                            ($count_qts1 - int($count_qts1/$mod_val) * $mod_val) > 0.0001)
                          {                              
                            $count_qts = $auto_num_count;
                            my $question = "";
                            my $answer = "";
                            my $explanation = "";
                            my $kwd = "";
                            my $que_mrk = "";
                            my $count_ipoformat = 1;
                            my $count_ans = 1;

                            if ($que =~ /<inp>(.*?)<\/inp>/si)
                              {
                                $question = $1;
                                $question =~ s/.*?<ocr>(.*?)<\/ocr>.*?/$1/sgi;
                                if (defined $input_tts && length $input_tts > 0)
                                  {
                                    $input_tts =~ s/(\w)\w.*/$1/si;
                                    $input_tts = lc($input_tts);
                                    $question = "<tts l=\"$input_tts\">$question</tts>";
                                  }
                              }

                            my $que_ans = $que;
                            
                            while ($que_ans =~ s/<ans[^>]*>[^<]*<out>(.*?)<\/out>//si && $count_ans < 6)
                              {
                                my $each_answer = $1;
                                $each_answer =~ s/.*?<ocr>(.*?)<\/ocr>.*?/$1/sgi;
                                
                                if (defined $fixedchoice && length $fixedchoice > 0)
                                  {
                                    my @fixed_choice_array = @$fix_choices_arrayRef;
                                    my $count = 1;
                                    foreach my $choice (@fixed_choice_array)
                                      {
                                        if ($each_answer == $count)
                                          {
                                            $each_answer = $choice;
                                            $each_answer =~ s/.*?<ocr>(.*?)<\/ocr>.*?/$1/sgi;
                                          }
                                        $count++;
                                      }
                                  }
                                  
                                if (defined $output_tts && length $output_tts > 0)
                                  {
                                    $output_tts =~ s/(\w)\w.*/$1/si;
                                    $output_tts = lc($output_tts);
                                    $each_answer = "<tts l=\"$output_tts\">$each_answer</tts>";
                                  }
                                  
                                if ($count_ans > 1)
                                  {
                                    $each_answer = "<br/>".$each_answer;
                                  }                                
                                $answer .= $each_answer;
                                $count_ans++;
                              }

                            if ($que =~ /<exp>(.*?)<\/exp>/si)
                              {
                                $explanation = $1;
                                $explanation =~ s/.*?<ocr>(.*?)<\/ocr>.*?/$1/sgi;
                                if (length $explanation > 0)
                                  {
                                    $explanation = "<br/>".$explanation;
                                  }
                               }

                            if ($que =~ /<kwd>(.*?)<\/kwd>/si)
                              {
                                $kwd = $1;
                                $kwd =~ s/.*?<ocr>(.*?)<\/ocr>.*?/$1/sgi;
                                $kwd =~ s/<span[^>]*>//gsi;
                                $kwd =~ s/<\/span>//gsi;
                              }

                            if ($que =~ /<mrk>(.*?)<\/mrk>/si)
                              {
                                $que_mrk = $1;
                                $que_mrk =~ s/.*?<ocr>(.*?)<\/ocr>.*?/$1/sgi;
                              }

                            my $choices = "";
                            if (defined $fixedchoice && length $fixedchoice > 0 && defined $show_choices && length $show_choices < 1)
                              {
                               $fixedchoice =~ s/<\/ocr>.*?<ocr>//sgi;
                               $fixedchoice =~ s/<\/ocr>//sgi;
                               $fixedchoice =~ s/<ocr>//sgi;                               
                                $choices = "<br/>".$fixedchoice;
                              }
                            elsif ($que =~ /<ans\s+t\s*\=\s*(\"|\')opt(\"|\')>/si && defined $show_choices && length $show_choices < 1)
                              {
                                $choices = Syvum::Online::XMLParser::choices($que, $random);
                                $choices =~ s/<\/ocr>.*?<ocr>//sgi;
                                $choices =~ s/<\/ocr>//sgi;
                                $choices =~ s/<ocr>//sgi;  
                              }
                        

                            if (defined $current_ipf && $current_ipf !~ /^answer\_/is)
                              {
                                if (length $mrk > 0 && $mrk_dis eq "Individual" && length $showmark < 1)
                                  {
                                    $perq =~ s/\.5/\&\#189\;/si;
                                    $perq =~ s/\.25/\&\#188\;/si;
                                    $perq =~ s/\.75/\&\#190\;/si;
                                    if (length $que_mrk < 1)
                                      {
                                        $que_mrk = $perq;
                                      }

                                    $test_paper_text .= "<table width=\"100%\"><tr>";

                                    if ($auto_number ne "No")
                                      {
                                        $test_paper_text .= "<td valign=\"top\"><b>$count_qts. </b></td>";
                                      }
                                    $test_paper_text .= "<td>";

                                    if ($current_ipf eq "question_only" || $current_ipf eq "question_hide")
                                      {
                                        $test_paper_text .= "$question$choices";
                                      }
                                    else
                                      {
                                        $test_paper_text .= "$answer<br/>";
                                      }

                                    $test_paper_text .= "</td><td align=\"right\" valign=\"".$mark_align."\" width=\"10%\">$que_mrk</td></tr>";

                                    if ($kwd =~ /\:/si)
                                      {
                                        my $kwd_count = 0;
                                        my $multi_keys = $kwd;
                                        if ($multi_keys =~ /\,/s)
                                          {
                                            my @multi_kwd = split(/\,/s, $multi_keys);
                                            $kwd = "";
                                            foreach my $keys (@multi_kwd)
                                              {
                                                $keys =~ s/[^\:]*\:(.*?)/$1/si;
                                                $kwd .= $keys.", ";
                                              }
                                            $kwd =~ s/\,\s$//si;
                                          }
                                        else
                                          {
                                            $kwd =~ s/[^\:]*\:(.*?)/$1/si;
                                          }
                                    
                                        $test_paper_text .= "<tr style=\"margin-top:0px;margin-bottom:0px;\"><td align=\"right\" colspan=\"2\">($kwd)</td></tr>";
                                      }
                                    elsif (length $sourceinfo > 0 and $showsrc eq "Yes")
                                      {
                                        $test_paper_text .= "<tr style=\"margin-top:0px;margin-bottom:0px;\"><td align=\"right\" colspan=\"2\">($sourceinfo)</td></tr>";
                                      }
    
                                    $test_paper_text .= "</table>";
                                  }
                                elsif (length $mrk < 1 && $mrk_dis eq "Individual" && length $showmark < 1)
                                  {
                                    $test_paper_text .= "<table width=\"100%\"><tr>";

                                    if ($auto_number ne "No")
                                      {
                                        $test_paper_text .= "<td valign=\"top\"><b>$count_qts. </b></td>";
                                      }

                                    $perq =~ s/\.5/\&\#189\;/si;
                                    $perq =~ s/\.25/\&\#188\;/si;
                                    $perq =~ s/\.75/\&\#190\;/si;
                                    $test_paper_text .= "<td>";

                                    if ($current_ipf eq "question_only" || $current_ipf eq "question_hide")
                                      {
                                        $test_paper_text .= "$question$choices";
                                      }
                                    else
                                      {
                                        $test_paper_text .= "$answer<br/>";
                                      }

                                    $test_paper_text .= "</td><td align=\"right\" valign=\"".$mark_align."\" width=\"10%\">$perq</td></tr>";

                                    if ($kwd =~ /\:/si)
                                      {
                                        $kwd =~ s/[^\:]*\:(.*?)/$1/si;
                                        $test_paper_text .= "<tr style=\"margin-top:0px;margin-bottom:0px;\"><td align=\"right\" colspan=\"2\">($kwd)</td></tr>";
                                      }
                                    elsif (length $sourceinfo > 0 and $showsrc eq "Yes")
                                      {
                                        $test_paper_text .= "<tr style=\"margin-top:0px;margin-bottom:0px;\"><td align=\"right\" colspan=\"2\">($sourceinfo)</td></tr>";
                                      }
    
                                    $test_paper_text .= "</table>";
                                  }
                                else
                                  {
                                    if ($auto_number ne "No")
                                      {
                                        $test_paper_text .= "<b><span style=\"vertical-align: top;\">$count_qts. </span></b>";
                                      }

                                    if ($current_ipf eq "question_only" || $current_ipf eq "question_hide")
                                      {
                                        if ($current_ipf eq "question_hide" && length $choices < 1)
                                          {
                                            $choices = "<br/>";
                                          }
                                        $test_paper_text .= "$question$choices";
                                      }
                                    else
                                      {
                                        $test_paper_text .= "$answer<br/>";
                                      }                                

                                    if ($showsrc eq "Yes")
                                      {
                                        $test_paper_text .= "<table width=\"100%\">";

                                        if ($kwd =~ /\:/si)
                                          {
                                            $kwd =~ s/[^\:]*\:(.*?)/$1/si;
                                            $test_paper_text .= "<tr style=\"margin-top:0px;margin-bottom:0px;\"><td align=\"right\" colspan=\"2\">($kwd)</td></tr>";
                                          }
                                        elsif (length $sourceinfo > 0 and $showsrc eq "Yes")
                                          {
                                            $test_paper_text .= "<tr style=\"margin-top:0px;margin-bottom:0px;\"><td align=\"right\" colspan=\"2\">($sourceinfo)</td></tr>";
                                          }

                                        $test_paper_text .= "</table>";
                                      }
                                    else
                                      {
                                        #$test_paper_text .= "<br/>";
                                      }
                                  }                            
                              }
                            else
                              {
                                if ($auto_number ne "No")
                                  {
                                    $test_paper_text .= "<b><span style=\"vertical-align: top;\">$count_qts. </span></b>";
                                  }
                                $test_paper_text .= "$answer$explanation<br/>";
                              }

                            if (defined $current_ipf && $current_ipf eq "question_hide")
                              {
                                $test_paper_text .= "<step name=\"Answer\">$answer$explanation</step><br/>";
                              }
                            elsif (defined $current_ipf && $current_ipf eq "question_rhide")
                              {
                                $test_paper_text .= "<step name=\"Answer\">$question$explanation</step><br/>";
                              }

                            $test_paper_text .= "<br/> ";
                          }
                        $auto_num_count ++;
                        $count_qts1++;
                      }
                  }

                if (defined $ipp && $ipp > 0 && $ipp < 100)
                  {
                    $count_qts1 = $count_qts1 - 1;
                    my $percent_text = Syvum::Online::XMLParser::percent_note($lang);
            
                    $percent_text =~ s/_var2_/$count_qts1/gs;
                    my $qts_shown = int(($count_qts1 * $ipp)/100);
                    $percent_text =~ s/_var1_/$qts_shown/gs;
                    $percent_text =~ s/_var3_/$ipp/gs;

#_var1_ is round(($total_question * $info_percent) div 100)
#_var2_ is total_question
#_var3_ is info_percent
                    $test_paper_text .= $percent_text;
                  }
                $count_ips++;
              }
            $count_qset++;
          }
      }
    return $test_paper_text;
  }
  1;
