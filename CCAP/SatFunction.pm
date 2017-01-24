package SatFunction;
#package SatFunction;
#use Exporter;
use XML::LibXML;
use strict;
use Apache2::Const qw (OK DECLINED NOT_FOUND HTTP_MOVED_PERMANENTLY FORBIDDEN);
use Syvum::Online::Sal;
use io;
use Syvum::Fs::Fsfiles;
use listingmodule;
use languagestring;
use Compress::Zlib;
use Convert::UU qw(uudecode uuencode);
use Syvum::Online::Problet;
use cleanXML;
use Syvum::Members::Info;
use Syvum::Debug;

my %title;

sub removehtmltags
  {
     my $temp = shift;
     $temp =~ s/</\&lt\;/gis;
     $temp =~ s/>/\&gt\;/gis;
     $temp =~ s/\&lt;b\&gt;/<b>/gi;
     $temp =~ s/\&lt;\/b\&gt;/<\/b>/gi;
     $temp =~ s/\&lt;br\&gt;/<br>/gi;
     $temp =~ s/\&lt;i\&gt;/<i>/gi;
     $temp =~ s/\&lt;\/i\&gt;/<\/i>/gi;
     $temp =~ s/\&lt;u\&gt;/<u>/gi;
     $temp =~ s/\&lt;\/u\&gt;/<\/u>/gi;
     $temp =~ s/\&lt;sub\&gt;/<sub>/gi;
     $temp =~ s/\&lt;\/sub\&gt;/<\/sub>/gi;
     $temp =~ s/\&lt;sup\&gt;/<sup>/gi;
     $temp =~ s/\&lt;\/sup\&gt;/<\/sup>/gi;
     $temp =~ s/\&lt;strong\&gt;/<strong>/gi;
     $temp =~ s/\&lt;\/strong\&gt;/<\/strong>/gi;
     $temp =~ s/\&lt;li\&gt;/<li>/gi;
     $temp =~ s/\&lt;\/li\&gt;/<\/li>/gi;
     $temp =~ s/\&lt;ul\&gt;/<ul>/gi;
     $temp =~ s/\&lt;\/ul\&gt;/<\/ul>/gi;
     $temp =~ s/\&lt;ol\&gt;/<ol>/gi;
     $temp =~ s/\&lt;\/ol\&gt;/<\/ol>/gi;
     $temp =~ s/\&lt;p([^&gt;]*?)\&gt;/<p$1>/gi;
     $temp =~ s/\&lt;\/p\&gt;/<\/p>/gi;
     $temp =~ s/\&lt;em\&gt;/<em>/gi;
     $temp =~ s/\&lt;\/em\&gt;/<\/em>/gi;
     $temp =~ s/\&lt;filexml\&gt;/<filexml>/gi;
     $temp =~ s/\&lt;\/filexml\&gt;/<\/filexml>/gi;
     $temp =~ s/\&#39;/\'/gi;
     $temp =~ s/\&quot;/\"/gi;
     $temp =~ s/\&lt\;img (.*?)\&gt\;/<img $1>/gsi;
     return($temp);
  }


sub addnewtabs
  {
     my $table_ref = shift;

     my %table = %$table_ref;

     my $htmlsource_txt = "";
     my @qset_arr;
     my @loadtabname;
     my $tdffile = 0;
     my $tab_var = 1;
     my $dynamic_tabs = $table{tab} + 1;
     $tab_var = $dynamic_tabs;
     for (my $j = 1; $j <= $tab_var; $j++)
       {
          my $i = "elm$j";
          my $k = "tab$j";
          if (length $table{$i} > 0 && $table{$i} !~ /^\s+$/s)
            { 
              $table{$k} =~ s/&/&amp\;/gis;
              $htmlsource_txt .= $table{$i}."<new_tab>";
            }

       }
     @qset_arr = split (/<new_tab>/,$htmlsource_txt);

     SatFunction::opendraft("","","","","",\@loadtabname,\@qset_arr,$tdffile,"",$tab_var);

  }


#----------------------------------Brain teasers-------------------------------------------------

sub brainteasers
  {
  
    my $table_ref = shift;
    
    my %table = %$table_ref;
    my $puzzles_cont = shift; 
    my $fortxt = $puzzles_cont;
    my $prob_num = "";
    
    my ($brain_teaser,$prm_cont,$question,$answer,$table_prob,$title,$heading,$description,$prm,$problet);
    $puzzles_cont =~ s/\n\r/ /gs;
    $puzzles_cont =~ s/\n/ /gs;
    $puzzles_cont =~ s/\r/ /gs;
    $puzzles_cont =~ s/\t*//gs;
    $puzzles_cont =~ s/<p>&nbsp\;<\/p>//gs;
    $puzzles_cont =~ s/&nbsp\;//gs;
    $puzzles_cont =~ s/<p>(.*?)<\/p>/<br \/>$1/gs;
    if ($puzzles_cont =~ s/<title>(.*?)<\/title>//gs)                                   
      {
        $title = "<title>".$1."</title>";
        
      }
      
    if ($puzzles_cont =~ s/<img src\s*=\s*\"http:\/\/[^\/]*?\/s_i\/th\.gif[^>]*?>(.*?)<img src\s*=\s*\"http:\/\/[^\/]*?\/s_i\/thc\.gif[^>]*?>//gs)                                   
      {
        $heading = "<heading>".$1."</heading>";
        
      }
    
    if ($puzzles_cont =~ s/<img src\s*=\s*\"http:\/\/[^\/]*?\/s_i\/fi\.gif[^>]*?>(.*?)<img src\s*=\s*\"http:\/\/[^\/]*?\/s_i\/fic\.gif[^>]*?>//gs)                                   
      {
        $description = $1;
        
      }
     if ($puzzles_cont =~ s/<img src\s*=\s*\"http:\/\/[^\/]*?\/s_i\/qp\.gif\" (syvum=\"[^\"]*?\")[^>]*?>(.*?)<img src\s*=\s*\"http:\/\/[^\/]*?\/s_i\/qpc\.gif[^>]*?>//gs)                                   
      {
        $prm_cont = "<s_inst>".$1.$2."</s_inst>";
        #print $prm_cont;
        $prm_cont = preamble($prm_cont);
        $prm_cont =~ s/<eachmrk perq=\"\" dis=\"\"><\/eachmrk>//gs;
        $prm_cont =~ s/<prm>//gs;
        $prm_cont =~ s/<\/prm>//gs;
      }
       
    $prm = "<prm><brainteaser/>".$prm_cont.$title.$heading."</prm>";  
    
    $puzzles_cont =~ s/.*?<body>(.*?)<\/body>.*/$1/gs;
    
    $puzzles_cont =~ s/(\.\.\/){1,}/\//gs;
    $puzzles_cont =~ s/<img src=\"http:\/\/([^\/]*?)\//<img src=\"\//gs;
    
    
    my @puzzle_arr = split(/<img src\s*=\s*\"http:\/\/[^\/]*?\/s_i\/q\.gif/,$puzzles_cont);
    for (my $i = 1; $i < scalar @puzzle_arr; $i++)
      {
        $prob_num = $i;
        $puzzle_arr[$i] = "<img src=\"http:\/\/scripts.syvum.com\/s_i\/q\.gif".$puzzle_arr[$i];
        ($problet,$question,$answer,$puzzles_cont) = eachproblet ($puzzle_arr[$i],$prob_num);
        $brain_teaser .= "<qset><que><inp>".$problet.$question."<input name=\"num\" problet=\"puzzle$prob_num\" type=\"text\" sal=\"true\" grabfocus=\"true\" /></inp>".$answer.$puzzles_cont."</que></qset>";
      }
    
    $brain_teaser = "<tdf>".$prm.$brain_teaser."</tdf>";
       #--------- end of creation of exp,ans hin-------------------------
    
       #--- integrating all the content to create the xml----------   
       
    $fortxt = "<title_doc>$table{name}<\/title_doc><filename>$table{file}<\/filename><desc>$table{desc}</desc><keyword_adv_prop>$table{keywords}</keyword_adv_prop><author>$table{author_name}</author>".$fortxt;
    
    my $fullpath_draft = $ENV{DOCUMENT_ROOT};
    $fullpath_draft =~ s/([^\/]*?)$//;
    $fullpath_draft .= "info/online_data/users/";
    my $fullpath_draft_xml = $fullpath_draft.$table{file}.".xml";
    my $fullpath_draft_txt = $fullpath_draft.$table{file}.".txt";
    open OFILEXML,">$fullpath_draft_xml";
    print OFILEXML "$brain_teaser";
    close (OFILEXML);
    
    open OFILETXT,">$fullpath_draft_txt";
    print OFILETXT "$fortxt";
    close (OFILETXT);
    
    if (-e $fullpath_draft_xml)
      {
        print "puzzle saved";
      }
    else
      {
        print "check path";
      }    
    
  }


sub probvalue
  {
    my $prb_data = shift;
    my $org_prb = $prb_data;

    $prb_data =~ s/\n*\r*//sg;

    if ($prb_data =~ /val=\"[^\"]*?\"/gs)
      {
        my @prbl_args = split (/<args var/,$prb_data);
        $prb_data = "";
        for (my $i = 1; $i < scalar @prbl_args; $i++)
          {
            $prbl_args[$i] = "<args var".$prbl_args[$i];
            if ($prbl_args[$i] =~ s/val=\"([^\"]*?)\" //s)
             {
               my $val = $1;
               $prbl_args[$i] =~ s/min=\"[^\"]*?\"/min=\"$val\"/s;
               $prbl_args[$i] =~ s/max=\"[^\"]*?\"/max=\"$val\"/s;
               
               $prb_data .= $prbl_args[$i];
             }
           else
             {
               $prb_data .= $prbl_args[$i];
             }
          }
         $prb_data = $prbl_args[0].$prb_data; 
         
      }   
    
    my %var_hash;
    (my $pdata, my $userDataRef, my $varString2) = Syvum::Online::Problet::parseProbletOnly($prb_data, \%var_hash, "no");
    %var_hash = %$userDataRef;

     my $ret = "";
     foreach my $e (sort keys %var_hash)
       {
         if ($e !~ /^format_|^type_/)
           {
             if (defined $var_hash{"format_".$e})
               {
                 $ret .= "$e=";
                 $ret .= Syvum::Online::Problet::formatValue($var_hash{$e}, $var_hash{"format_".$e});
                 $ret .= ";";
               }
             else
               {
                 $ret .= "$e=$var_hash{$e};";
               }
           }
       }

    $prb_data =~ s/</\&lt;/gs;
    $prb_data =~ s/>/><br>/gs;
    $varString2 =~ s/</\&lt;/gs;
    $varString2 =~ s/>/><br>/gs;
    
    $ret = $ret."<;&;>".$org_prb;
    io::validprob($ret);
  }

sub eachproblet
  {
    my $puzzles_cont = shift;
    my $prob_num = shift;
    
    $puzzles_cont =~ s/\n+/ /gs;
    $puzzles_cont =~ s/\r+/ /gs;
    my @problet_arr;
    my @each_th;
    my @transNames;
    my ($question,$answer,$table_prob,$th_count,$title,$heading,$description,$prm,$transfilename,$rtol);
    my $transflag = 0;

    if ($puzzles_cont =~ /<vr.gif\" title=\"([^\.]*?\.[^\"]*)\" \/>/gs)
      {
        my $titleWithProbletNum = $1;
        (my $newProbletNum = $titleWithProbletNum) =~ s/([^\.]*?)\..*/$1/gs;
        $puzzles_cont =~ s/title=\"$newProbletNum\./title=\"/gs;
        $newProbletNum =~ s/[^\d]*?(\d+)/$1/g;
        $prob_num = $newProbletNum;
      }

    pos ($puzzles_cont) = 0;
    if ($puzzles_cont =~ /<vr.gif\" title=\"([^\"]*?)\" \/>[^\d]*<vrc.gif\"[^>]*?>/gs)
      {
        my $buffer = $puzzles_cont;
        my $termWhile = 0;
        my $i = 0;
        
        while ($buffer =~ /<vr.gif\" title=\"([^\"]*?)\" \/>[^\d]*<vrc.gif\"[^>]*?>/ && $termWhile <= 100)
          {
            if ($buffer =~ s/<vr.gif\" title=\"([^\"]*?)\" \/>[^\d]*<vrc.gif\"[^>]*?>//s)
              {
                my $title = $1;
                if ($title =~ /:(.*)/gs)
                  {
                    my $temp = lc($1);
                    if ($transfilename !~ /$temp/sg)
                      {
                        $transfilename .= $temp.";;;;";
                        $transNames[$i] = $temp;
                        $i++;
                      }  
                    
                  }  
              }
            $termWhile++;
          }
        #my $title = $1;
        #@if ($title =~ /:(.*)/gs)
        #  {
        #    $transfilename = lc($1);
        #    $transflag = 1;
        #  }
        $transflag = 1;
      }

    if ($puzzles_cont =~ s/<que><inp>(.*?)<\/inp>//gs)  # $puzzles_cont has content all content except question
      {
        $question = $1;
        if ($question =~ s/<variablesetting\s*(rtol=\"([^\"]*?)\")?>(.*?)<\/variablesetting>//gs)
          {
            $rtol = $2;
            $table_prob = $3;
            
            if (length($rtol) > 0)
              {
                $rtol = "<args var=\"rtol\" type=\"double\" min=\"".$rtol."\" max=\"".$rtol."\" />";
              } 
            
            $table_prob =~ s/<span[^>]*?>//gs;
            $table_prob =~ s/<\/span>//gs;
          }  
      }
    if ($puzzles_cont =~ s/<variablesetting\s*(rtol=\"([^\"]*?)\")?>(.*?)<\/variablesetting>//gs)  
      {
        $rtol = $2;
        $table_prob = $3;
        
        if (length($rtol) > 0)
          {
            $rtol = "<args var=\"rtol\" type=\"double\" min=\"".$rtol."\" max=\"".$rtol."\"/>";
          } 
        $table_prob =~ s/<span[^>]*?>//gs;
        $table_prob =~ s/<\/span>//gs;
      }  
    $table_prob =~ s/<table[^>]*?>(.*?)<\/table>.*/$1/gs;
    $table_prob =~ s/<tbody>//gis;
    $table_prob =~ s/<\/tbody>//gis;

    $table_prob =~ s/<th>(.*?)<\/th>/<th>\{\[$1\]\}/gis;
    
    $table_prob =~ s/<tr[^>]*?>/<tr>/gis;
    
    my @each_row = split (/<tr>/,$table_prob);
    for (my $i = 1; $i < scalar @each_row; $i++)
      {
        
        if ($i == 1)
          {
            @each_th = split (/<th>/,$each_row[$i]);
            for (my $j = 1; $j < scalar @each_th; $j++)
              {
                $each_th[$j] = "custxml".$j;
              }
          }
        else
          {
            
            my @each_td = split (/<td>/,$each_row[$i]);
            for (my $j = 1; $j < scalar @each_td; $j++)
              {
                $problet_arr[$i] .= "<".$each_th[$j].">".$each_td[$j]."</".$each_th[$j].">";
              }           
            
          } 
           
      }   
      
    my $problet = "";
      
    for (my $i = 2; $i < scalar @problet_arr; $i++)
      {
        my $variable_name = "";
        my $min = "";
        my $max = "";
        my $org_value = "";
        my $value = "";
        my $formula = "";
        my $type = "";
        my $format = "";
        my $comments = "";
        $problet_arr[$i] =~ s/<\/tr>//gs;
        $problet_arr[$i] =~ s/<\/td>//gs;
        $problet_arr[$i] =~ s/<\{\[/</gs;
        $problet_arr[$i] =~ s/\]\}>/>/gs;
        $problet_arr[$i] =~ s/<\/\{\[/<\//gs;
        $problet_arr[$i] =~ s/\&nbsp\;//gs;
        
        if ($problet_arr[$i] =~ /<custxml1>(.*?)<\/custxml1>/gis)
          {
            $variable_name = $1;
            $variable_name =~ s/^\s*//gs;
            $variable_name =~ s/\s*$//gs;
            #$variable_name =~ s/^(\u00A0)*$//gis;
          }
          
        if ($problet_arr[$i] =~ /<custxml2>(.*?)<\/custxml2>/gis)
          {
            $min = $1;
            $min =~ s/^\s*//gs;
            $min =~ s/\s*$//gs;
          }
          
        if ($problet_arr[$i] =~ /<custxml3>(.*?)<\/custxml3>/gis)
          {
            $max = $1;
            $max =~ s/^\s*//gs;
            $max =~ s/\s*$//gs;
          }  
        if ($problet_arr[$i] =~ /<custxml4>(.*?)<\/custxml4>/gis)
          {
            $org_value = $1;
            $org_value =~ s/^\s*//gs;
            $org_value =~ s/\s*$//gs;
            if ($org_value =~ /\d+/s)
              {
                $org_value = " valorg=\"$org_value\""
              }
            else
              {
                $org_value = "";
              }  
          }  
        if ($problet_arr[$i] =~ /<custxml5>(.*?)<\/custxml5>/gis)
          {
            $value = $1;
            $value =~ s/^\s*//gs;
            $value =~ s/\s*$//gs;
            if ($value =~ /\d+/ | /\w+/)
              {
                $value = " val=\"$value\""
              }
            else
              {
                $value = "";
              }  
          }  
          
        if ($problet_arr[$i] =~ /<custxml6>(.*?)<\/custxml6>/gis)
          {
            $formula = $1;
            $formula =~ s/^\s*//gs;
            $formula =~ s/\s*$//gs;
            $formula =~ s/=//s;
          }  
          
        if ($problet_arr[$i] =~ /<custxml7>(.*?)<\/custxml7>/gis)
          {
            $type = $1;
            $type =~ s/^\s*//gs;
            $type =~ s/\s*$//gs;
            if ($type =~ /real/is)
              {
                 $type = " type=\"double\"";              
              }
            else
              {
                $type = "";
              }
          }
          
        if ($problet_arr[$i] =~ /<custxml8>(.*?)<\/custxml8>/gis)
          {
            $format = $1;
            $format =~ s/^\s*//gs;
            $format =~ s/\s*$//gs;
            if ($format =~ /(\d+)\s*Decimals/is)
              {
                 my $type = $1;
                 $format = " format=\"\%.".$type."f\"";
              }
            elsif ($format =~ /Fraction/is)
              {
                 $format = " format=\"quarters\"";              
              }
            else
              {
                $format = "";              
              }

          }    
        if ($problet_arr[$i] =~ /<custxml9>(.*?)<\/custxml9>/gis)
          {
            $comments = $1;
            $comments =~ s/<([^>]*?)>/\{\[$1\]\}/gs;
            $comments =~ s/>/&gt;/gs;
            $comments =~ s/</&lt;/gs;
            $comments =~ s/\{\[([^>]*?)\]\}/<$1>/gs;
         #   $comments =~ s/\//this;;is;;test;;slash/gs; 
            $comments =~ s/^\s*//gs;
            $comments =~ s/\s*$//gs;
            $comments =~ s/^\W*<br\s*\/>\W*$//gs;
#            print "cmnts".$comments."end";
            if ($comments =~ /\w+|\d+/gs)
              {
                $comments = " cmnt=\"$comments\"";
              }
            else
              {
                $comments = "";
              }  
          }  
        if ($min =~ /\d+/ && $max =~ /\d+/)
          {
            $problet .= "<args var=\"$variable_name\" min=\"$min\" max=\"$max\"".$type.$format.$org_value.$value. $comments." />\n";
          }
          
        if ($formula =~ /\d+|\w+/s)
          {
            $problet .= "<args var=\"$variable_name\"".$type.$format.$org_value.$value.$comments." />\n<args left=\"$variable_name\" right=\"$formula\" />\n";
          }
        $problet =~ s/<br \/>//gs;
      }
    if ($transflag == 1)
      {
        my $transform = "";
        foreach my $transNames(@transNames)
          {
            $transform .= "<transform type=\"$transNames\" src=\"$transNames\.tdf\" />";
          }    
        $problet = $transform."<problet type=\"com.syvum.syvumbook.problet.FormulaProblet\" name=\"prob$prob_num\">".$problet."</problet>";  
      }
    else
      {    
        if (length ($problet) > 0)
          {
            $problet = "<problet type=\"com.syvum.syvumbook.problet.FormulaProblet\" name=\"prob$prob_num\">".$problet.$rtol."</problet>";
          }  
      } 

         #----- start converting rest of the question from numbers to invars ----
    my $termWhile = 0;
    while ($question =~ /<vr\.gif\" title=\"([^:|\"]*?):([^\"]*?)\"[^>]*?>\s*([^\d]*)\s*<vrc\.gif[^>]*?>/gis && $termWhile <= 100)
      {
        if ($question =~ /<vr\.gif\" title=\"([^:|\"]*?):([^\"]*?)\"[^>]*?>\s*([^\d]*)\s*<vrc\.gif[^>]*?>/s)
          {
            my $temp = lc($2);
            $question =~ s/<vr\.gif\" title=\"([^:|\"]*?):([^\"]*?)\"[^>]*?>\s*([^\d]*)\s*<vrc\.gif[^>]*?>/<invar transform=\"$temp\" name=\"$1\" \/>/s;
          } 
        $termWhile++;
      }     
    $question =~ s/<vr\.gif\" title=\"([^\"]*?)\"[^>]*?>(.*?)<vrc\.gif[^>]*?>/<invar problet=\"prob$prob_num\" name=\"$1\" \/>/gis;
    

        #----------end of convertions of all vrs to invars --------------
        
        
        #---- Remaining content $puzzles_cont to be converted to ans exp and hin tags -- 
     if ($puzzles_cont =~ s/<ans><out>(.*?)<\/out><\/ans>//gs)
      {
         $answer = $1;
         $answer =~ s/^\s*//gs;
         $answer =~ s/\s*$//gs;
         $answer = "\n<ans><out>$answer<\/out><\/ans>";
         
         $answer =~ s/<vr\.gif\" title=\"([^\"]*?)\"[^>]*?>(.*?)<vrc\.gif[^>]*?>/<outvar problet=\"prob$prob_num\" name=\"$1\" \/>/gis;
      }
     #print "HERE".$puzzles_cont."TILLHERE";
     $puzzles_cont =~ s/<vr\.gif\" title=\"([^:|\"]*?):[^\"]*?\"[^>]*?>\s*([^\d]*)\s*<vrc\.gif[^>]*?>/<invar transform=\"$transfilename\" name=\"$1\" \/>/gis;      
     $puzzles_cont =~ s/<vr\.gif\" title=\"([^\"]*?)\"[^>]*?>(.*?)<vrc\.gif[^>]*?>/<invar problet=\"prob$prob_num\" name=\"$1\" \/>/gis;   
    
    $puzzles_cont =~ s/<br \/>/\n<br \/>/gs; 
    $puzzles_cont =~ s/<div class=\"mceNonEditable\">[\s*\r*\n*]*<br \/>[\s*\r*\n*]*<\/div>//sgi;
    return ($problet,$question,$answer,$puzzles_cont);
  }





#----------------------------------End Brain teasers------------------------------------------
#-----------------------------Recipes-----------------------------------------

sub recipes
  { 
    my $table_ref = shift;
    my $recicont = shift;
    my $flag = shift;
    my $save_pub_flag = shift;
    
    my %table = %$table_ref;
        
    $recicont =~ s/<img src=\"http:\/\/[^\/]*?\//<img src=\"\//gs;
    
    my $title = "";
    my $author = "";
    my $keywords = "";
    my $description = "";
    my $txtcont = $recicont;
    $txtcont =~ s/.*?<body>(.*?)<\/body>.*/$1/gs;
    
    $recicont =~ s/\n\r/<;tmpln;>/g;
    $recicont =~ s/\n/<;tmpln;>/g;
    $recicont =~ s/\r/<;tmpln;>/g;
    
    
    if ($recicont =~ s/<title>(.*?)<\/title>//sg)
      {
        $title = "<title>".$1."</title>";
      }
    if ($recicont =~ s/<meta name=\"keywords\" content=\"([^\"]*?)\" \/>//sg)
      {
        $keywords = "<keywords>".$1."</keywords>";
      }
    if ($recicont =~ s/<meta name=\"description\" content=\"([^\"]*?)\" \/>//sg)
      {
        $description = "<description>".$1."</description>";
      }    
    if ($recicont =~ s/<meta name=\"author\" content=\"([^\"]*?)\" \/>//sg)
      {
        $author = $1;
      }
    $recicont =~ s/.*?<body>(.*?)<\/body>.*/$1/gs;
    
    
    $recicont =~ s/<p>&nbsp\;<\/p>//gs;
    $recicont =~ s/&nbsp\;//gs;
    $recicont =~ s/<p>(.*?)<\/p>/<br \/>$1/gis;
    my $serves = 0;
    my $TextForTextbox = "";
    my $vartime = 0;
    my $heading = "";
    my $totaltime = "";
    my $preamble = "";
    my $countingre = 0;
    my $tproblet = "";
    my $problet = "";
    my $nutri_table = "";
    my $autoChangeStr = "";
    my $temp = "";
    my $salfile = "<fmt>rcp</fmt>";
    #print "Strt-->".$recicont."<--End";
    if ($recicont =~ s/(<table id=\"AutoChangeString\"[^>]*?>(.*?)<\/table>)//s)
      {
        $autoChangeStr = $1;
      }
    if ($recicont =~ s/<table id=\"DisplayTextBox\"[^>]*?>(.*?)<\/table>//gs)
      {
        my $NoPeopleString = $1;
        if ($NoPeopleString =~ s/.*?syvum=\"([^\"]*?)\".*/$1/gs)
          {
            $TextForTextbox = "<p><input type=\"hidden\" name=\"alwaysRecalculate\" value=\"true\" /></p>".$autoChangeStr."<p><input type=\"submit\" value=\"$NoPeopleString\" name=\"score\" /><input type=\"text\" name=\"rcp1_x1\" size=\"5\" edit=\"true\" /></p>";
          } 
      }
    elsif ($recicont =~ s/<table id=\"DisplayDropDown\"[^>]*?>(.*?)<\/table>//gs)
      {
        my $NoPeopleString = $1;
        if ($NoPeopleString =~ s/.*?syvum=\"([^\"]*?)\".*/$1/gs)
          {
            $TextForTextbox = $autoChangeStr."<p><input type=\"submit\" value=\"$NoPeopleString\" name=\"score\" /><select onChange=\"submit()\" name=\"rcp1_x1\"><option value=\"4\">Select</option><option value=\"2\"> 2 </option><option value=\"4\"> 4 </option><option value=\"6\"> 6 </option><option value=\"8\"> 8 </option><option value=\"10\"> 10 </option><option value=\"12\"> 12 </option></select></p>";
          }     
      }    
    if ($recicont =~ s/<table id=\"JustDisplay\".*?(<table id=\"ServesInfo\"[^>]*?>.*?<\/table>).*?<\/table>/$1/gs)
      {  
        $temp = $1;
        if ($temp =~ /<serves>(.*?)<\/serves>/s) # for taking the number infornt of serves :
          {
            $serves = $1;
            $vartime = $serves ** 0.666666667; # $serves gives number of people to the power 2/3 (0.66)  
          }    
      }
    $recicont =~ s/<table id=\"JustDisplay\"[^>]*?>.*?<\/table>//gs;
      
    
    $recicont =~ s/<img src\s*=\s*\"\/s_i\/t\.gif\" syvum=\"totalCookingTime\" \/>(.*?)<img src\s*=\s*\"\/s_i\/tc\.gif[^>]*?>/<invar name=\"total\" problet=\"rcp1\" value=\"$1\" \/>/sig;                       # total cooking time being converted initially.
    if ($recicont =~ s/.*?<img src\s*=\s*\"\/s_i\/th\.gif[^>]*?>(.*?)<img src\s*=\s*\"\/s_i\/thc\.gif[^>]*?>//sg)
      {
        $heading = "<heading>".$1."</heading>";
      }
    $preamble = "<?xml version=\"1.0\" encoding=\"utf-8\" ?> 
<tdf ver=\"1.1\"><preamble>".$title.$keywords.$description.$heading."<author>".$author."</author></preamble>"; 
 
 # The below given while loop extracts each ingredient quantity and puts it within $ingredvals. The  $recicont is the entire content without the problet. The "o" indicates that the tag is for ingredients.
      
# The below given while loop extracts each variable time and puts it within $timevals.
     
        
    ($problet,$recicont) =  ingredients ($recicont,$serves);  
    
    ($tproblet,$recicont,$totaltime,$countingre) =  recipetime ($recicont,$vartime);

    $recicont =~ s/<table border=\"1\"\s*class=\"mceNonEditable\"[^>]*?>(.*?<\/table>)/<nutri><table border=\"1\" align=\"center\" style=\"font-size:70%; background-color: \#f4f5f4;\">$1<\/nutri>/gs;

    if ($recicont =~ s/<table id=\"nutrilabel\"\s*border=\"1\"\s*class=\"mceNonEditable\"\s*syvum=\"([^\"]*?)\">(.*?)<\/table>/<tempnutrival>/gs)
      {  
        my $values = $1;       
        my $tempNutri = getNutriTable($values);
        $recicont =~ s/<tempnutrival>/$tempNutri/gs;
      } 
    $problet = "<qset><prm>".$salfile."</prm><que><inp><problet type=\"com.syvum.syvumbook.problet.FormulaProblet\" name=\"rcp1\">  
        <args var=\"x1\" min=\"$serves\" max=\"$serves\" /> ".$problet;
      
    $countingre = $countingre + 1; 
    $recicont =~ s/<invar name=\"total\" problet=\"rcp1\" value=\"([^\"]*?)\" \/>/<invar name=\"t$countingre\" problet=\"rcp1\" value=\"$1\" \/>/s;          # $countingre + 1 for the total time.
     
    $totaltime =~ s/^\+//;  
    $problet .= "$tproblet<args var=\"t$countingre\" type=\"double\" format=\"\%.0f\" /> 
        <args left=\"t$countingre\" right=\"$totaltime\" /><args rtol=\"0.02\" /> 
    </problet>"; 
    
    
    $problet =~ s/<args/\t<args/g;  
    
    $recicont =~ s/<br\s*\/>/<br \/>/g;
    $problet = $preamble.$problet.$TextForTextbox.$recicont;
    $problet .= "</inp><ans><out>$author</out></ans></que></qset></tdf>";
    $problet =~ s/<serves>\s*(\d*)\s*<\/serves>/<invar problet=\"rcp1\" name=\"x1\" value=\"$1\" \/>/s; 
    


    #$problet =~ s/<span[^>]*?>//gs;
    #$problet =~ s/<\/span>//gs;
    my $fullpath_draft = "";
    #$fullpath_draft =~ s/([^\/]*?)$//;
    #$fullpath_draft .= "info/online_data";
    $txtcont = "<title_doc>$table{name}<\/title_doc><filename>$table{file}<\/filename><desc>$table{desc}</desc><keyword_adv_prop>$table{keywords}</keyword_adv_prop><author>$table{author_name}</author>".$txtcont;
    my $fullpath_draft_xml = $fullpath_draft.$table{file}.".xml";
    my $fullpath_draft_txt = $fullpath_draft.$table{file}.".txt";
    
    $problet =~ s/<;tmpln;>/\n/gs;
    #my $dest = Compress::Zlib::memGzip($txtcont);
    #my $encoded_string = uuencode($dest);
    #$encoded_string =~ s/\]\]>/;;;--syvum_cdata_close--;;;/gs;
    
    #$encoded_string = "<![CDATA[".$encoded_string."]]>";
    
    #print "HEREZIP".$dest."ENDZIP";
    #$problet =~ s/<\/tdf>/<opentxt>$encoded_string<\/opentxt><\/tdf>/gs;
    #`echo '$fullpath_draft_xml' >>/tmp/testfiles.txt`;
    #open OFILEXML,">$fullpath_draft_xml";
    #print OFILEXML "$problet";
    #close (OFILEXML);
    #open OFILETXT,">$fullpath_draft_txt";
    #print OFILETXT "$txtcont";
    #close (OFILETXT);
    my ($check_err,$err)  = io::xml_check($fullpath_draft_xml,$problet);
    if ($check_err == -1)
      {
        $problet = cleanXML::clean($problet);
      }
    
    
    #my $path_check_overwrite = $fullpath_draft_xml."%";
      
    #my $allcont_ref = iodb::readdb($path_check_overwrite,1);
    #my @allcont = @$allcont_ref;
    my $scal_arr = 0;
    my $FileId = 0;
    my $over_write_flag = 0;
    (my $Fsfiles_path = $fullpath_draft_xml) =~ s/\.xml$/\.tdf/g;
    ($scal_arr, $FileId)  = Syvum::Fs::Fsfiles::doesFileExist($Fsfiles_path);
     
    #$scal_arr = scalar @allcont;
    if ($scal_arr == 1)
      {
        $over_write_flag = 1;
        iodb::createdb ($fullpath_draft_xml, $problet, $txtcont, "",$over_write_flag,\%table);
      }
    else
      {  
        iodb::createdb ($fullpath_draft_xml, $problet, $txtcont, "",$over_write_flag,\%table);
      }
    
    my ($check_err,$err)  = io::xml_check($fullpath_draft_xml,$problet);
    if ($check_err == -1)
      {
        print "$err Error: Possible mismatch of tags. <;error;>";
        exit(0);
      }
    else
      {  
        print "Recipe saved"; 
      }
  }
  
sub getNutriTable
  {
    my $contents = shift;
    my ($contents1,$contents2) = split(';;;', $contents);
    my @totals =  split(',', $contents1);
    my @percent = split(',', $contents2);

    my $htmlNutriTable = <<EOF;
    <script language="javascript">
    var carbo = '$totals[0]';
    var fiber = '$totals[1]';
    var protein = '$totals[2]';
    var fat = '$totals[3]';
    var calFat = 9 * $totals[3];  
    var energy = '$totals[4]'; 
    var SF = '$totals[5]'; 
    var MUF = '$totals[6]';  
    var PUF = '$totals[7]';
    var TransF = '$totals[8]';  
    var cholesterol = '$totals[9]'; 
    var sodium = '$totals[10]';  
    var potassium = '$totals[11]'; 
    var sugar = '$totals[12]'; 
    var vitamin_A = '$totals[13]'; 
    var vitamin_C = '$totals[14]';  
    var calcium = '$totals[15]'; 
    var iron = '$totals[16]';
    var servings = '$totals[17]';
    var percentCarbo = '$percent[0]';  
    var percentFiber = '$percent[1]'; 
    var percentProtein = '$percent[2]';  
    var percentFat = '$percent[3]'; 
    var percentEnergy = '$percent[4]'; 
    var percentSF = '$percent[5]'; 
    var percentMUF = '$percent[6]';  
    var percentPUF = '$percent[7]';
    var percentTransF = '$percent[8]';  
    var percentCholesterol = '$percent[9]'; 
    var percentSodium = '$percent[10]';  
    var percentPotassium = '$percent[11]'; 
    var percentSugar = '$percent[12]'; 
    var percentVitamin_A = '$percent[13]'; 
    var percentVitamin_C = '$percent[14]';  
    var percentCalcium = '$percent[15]'; 
    var percentIron = '$percent[16]'; 
    
    function toggle()
      {
        var tablev = document.getElementById('tablev');
        var tableh = document.getElementById('tableh');
        if (tablev.style.display == 'block')
          {
            tablev.style.display = 'none';
            tableh.style.display = 'block';
            document.getElementById("format").innerHTML = "View this table in Vertical format";
          }
        else if (tableh.style.display == 'block' )
          {
            tablev.style.display = 'block';
            tableh.style.display = 'none';
            document.getElementById("format").innerHTML = "View this table in Horizontal format";
          }
      }

    document.write('<br/><br/><div style="text-align:center;"><span id="format" onclick="toggle();" style="text-decoration:underline; font-size:80%; color:blue; cursor:pointer; align:center;">View this table in Vertical format.</span></div>');

    document.write('<center><table id ="tablev" class="nutri" style="display:none;border-color:black;border-width:1px; border-style:solid; font-size:80%;"><tbody><tr> <th colspan="2">Nutrition Facts</th> </tr><tr id="thickrule"> <td colspan="2">Serving Size ' + servings +'g</td> </tr><tr> <td colspan="2"><span style="font-size: 80%"> <strong>Amount Per Serving</strong></span></td> </tr><tr id="thinrule"> <td colspan="2"><strong>Calories</strong> '+ energy + ' <span style="color: #ffffff">---------</span> Calories from Fat ' + calFat + '</td> </tr><tr> <td class="dv" colspan="2">% Daily Value*</td> </tr><tr> <td><strong>Total Fat</strong> ' + fat +'g</td> <td class="dv">' + percentFat +'</td></tr><tr> <td class="sub">Saturated Fat ' + SF +  'g</td> <td class="dv">' + percentSF +'</td> </tr> <tr> <td class="sub">Monounsaturated Fat ' + MUF + 'g</td> <td class="dv">' + percentMUF +' </td> </tr> <tr> <td class="sub">Polyunsaturated Fat '+ PUF + 'g</td> <td class="dv">' + percentPUF +' </td> </tr> <tr> <td class="sub"><em>Trans</em> Fat ' + TransF +'g</td> <td class="dv">' + percentTransF +' </td> </tr> <tr> <td><strong>Cholesterol</strong> '+ cholesterol +'g</td> <td class="dv">' + percentCholesterol +'</td> </tr><tr> <td><strong>Sodium</strong> ' + sodium + 'mg</td> <td class="dv">' + percentSodium +'</td> </tr><tr> <td><strong>Potassium</strong> ' + potassium + 'mg</td> <td class="dv">' + percentPotassium +'</td> </tr><tr> <td><strong>Total Carbohydrate</strong> ' + carbo + 'g</td> <td class="dv">' + percentCarbo +'</td> </tr> <tr> <td class="sub">Dietary Fiber ' + fiber +'g</td> <td class="dv">' + percentFiber +'</td> </tr> <tr> <td class="sub">Sugars '+ sugar +'g</td> <td class="dv">' + percentSugar +' </td> </tr> <tr id="thickrule"> <td><strong>Protein</strong> '+ protein + 'g</td> <td class="dv">' + percentProtein +' </td> </tr><tr> <td>Vitamin A  </td> <td class="dv">' + percentVitamin_A +'</td> </tr><tr> <td>Vitamin C </td> <td class="dv">' + percentVitamin_C +'</td> </tr> <tr> <td>Calcium </td> <td class="dv">' + percentCalcium +'</td> </tr><tr> <td>Iron</td> <td class="dv">' + percentIron +'</td> </tr> <tr> <td class="disclaimer" colspan="2"> * Percent Daily Values are based on a 2,000 calorie diet. Your Daily Values may be higher or lower depending on your calorie needs. </td> </tr> </tbody></table></center>');
    document.write('<table id = "tableh"  style = "display :block; border-color: black;border-width: 1px; border-style: solid;"><tr><td><table class="nutri" style ="font-size:80%;"><tr><th colspan="2">Nutrition Facts</th></tr><tr><td colspan="2">Serving Size ' + servings +'g</td></tr><tr><td colspan="2"><strong>Calories</strong> '+ energy + '</td></tr><tr><td colspan="2">Calories from Fat ' + calFat + '</td></tr><tr><td class="disclaimer" colspan="2">* Percent Daily Values are based on a 2,000 calorie diet. Your Daily Values may be higher or lower depending on your calorie needs.</td></tr></table></td><td><table class="nutri" style ="font-size:80%;"><tr id="thinrule"><td><span style="font-size:80%;"><strong>Amount Per Serving</strong></span></td><td class="dv">% Daily Value*</td></tr><tr><td><strong>Total Fat</strong> ' + fat +'g</td> <td class="dv">' + percentFat +'</td></tr><tr> <td class="sub">Saturated Fat ' + SF +  'g</td> <td class="dv">' + percentSF +'</td></tr><tr><td class="sub">Monounsaturated Fat ' + MUF + 'g</td> <td class="dv">' + percentMUF +' </td></tr><tr><td class="sub">Polyunsaturated Fat '+ PUF + 'g</td> <td class="dv">' + percentPUF +' </td></tr><tr><td class="sub"><em>Trans</em> Fat ' + TransF +'g</td> <td class="dv">' + percentTransF +' </td></tr><tr><td><strong>Cholesterol</strong> '+ cholesterol +'g</td> <td class="dv">' + percentCholesterol +'</td></tr><tr><td><strong>Sodium</strong> ' + sodium + 'mg</td> <td class="dv">' + percentSodium +'</td> </tr><tr><td><strong>Potassium</strong> ' + potassium + 'mg</td> <td class="dv">' + percentPotassium +'</td></tr></table></td><td><table class="nutri" style="font-size:80%;"><tr id="thinrule"><td><span style="font-size:80%;"><strong>Amount Per Serving</strong></span></td> <td class="dv">% Daily Value*</td></tr><tr><td><strong>Total Carbohydrate</strong> ' + carbo + 'g</td> <td class="dv">' + percentCarbo +'</td></tr><tr> <td class="sub">Dietary Fiber ' + fiber +'g</td> <td class="dv">' + percentFiber +'</td></tr><tr><td class="sub">Sugars '+ sugar +'g</td> <td class="dv">' + percentSugar +' </td></tr><tr><td><strong>Protein</strong> 2g</td><td></td></tr><tr><td>Vitamin A </td> <td class="dv">' + percentVitamin_A +'</td></tr><tr><td>Vitamin C </td> <td class="dv">' + percentVitamin_C +'</td></tr><tr><td>Calcium </td> <td class="dv">' + percentCalcium +'</td></tr><tr><td>Iron</td> <td class="dv">' + percentIron +'</td></tr></table></td></tr></table>');
</script>

EOF

return ($htmlNutriTable);

}
  
  
sub ingredients
  {
    my $recicont = shift; 
    
    my $serves = shift;
    
    my $ingredvals = "";
    my $counting = 1;
    my @actualvalues;
    my %var_ing;
    my $countingre = 0;
    my $problet = "";
    my $term_while = 0;
    while ($recicont =~ /<img src\s*=\s*\"\/s_i\/i\.gif[^>]*?>(.*?)<img src\s*=\s*\"\/s_i\/ic\.gif[^>]*?>/ && $term_while < 400)
      {
        $ingredvals .= $1.";,,;";
        
        $recicont =~ s/<img src\s*=\s*\"\/s_i\/i\.gif[^>]*?>(.*?)<img src\s*=\s*\"\/s_i\/ic\.gif[^>]*?>/<invar name=\"o\" problet=\"rcp1\" value=\"$1\" \/>/;
        $counting++;
        $term_while++;
      }
    my @ingrequan = split (/\;\,\,\;/,$ingredvals);
     
    for (my $i = 0; $i < scalar @ingrequan; $i++)
      {
        $actualvalues[$i] = $ingrequan[$i];
        
        $ingrequan[$i] =~ s/½/\.5/s;
        $ingrequan[$i] =~ s/¼/\.25/s;
        $ingrequan[$i] =~ s/¾/\.75/s;
        if ($serves > 0)
          {
            $ingrequan[$i] = $ingrequan[$i] / $serves;
          }  
        
      }
     
      
    for (my $i = 0; $i < scalar @ingrequan; $i++)
      {
        pos ($problet) = 0;
        if ($problet =~ /value=\"$actualvalues[$i]\"/gs)
          {
             
          } 
        elsif ($ingrequan[$i] =~ /\d+\.\d+/gs && $problet !~ /value=\"$actualvalues[$i]\"/gs)
          {
            $countingre++;
            $var_ing{$actualvalues[$i]} = $countingre;
            $problet .= "<args var=\"o$countingre\" type=\"double\" format=\"quarters\" value=\"$actualvalues[$i]\" />";
            
            $problet .= "<args left=\"o$countingre\" right=\"x1 * $ingrequan[$i]\" />";
          }
        elsif ($problet !~ /value=\"$actualvalues[$i]\"/gs && $ingrequan[$i] =~ /[^\.]/gs)
          {
            $countingre++;
            $var_ing{$actualvalues[$i]} = $countingre;
            $problet .= "<args var=\"o$countingre\" value=\"$actualvalues[$i]\" />";
            $problet .= "<args left=\"o$countingre\" right=\"x1 * $ingrequan[$i]\" />";
          }  
       $recicont =~ s/<invar name=\"o\" problet=\"rcp1\" value=\"$actualvalues[$i]\" \/>/<invar name=\"o$var_ing{$actualvalues[$i]}\" problet=\"rcp1\" value=\"$actualvalues[$i]\" \/>/gs;   
      }
    
    return ($problet,$recicont); 
      
  }  
  
  
sub recipetime
  {
    my $recicont = shift;
    my $vartime = shift;
    
    my $timevals = "";
    my $totaltime = "";
    my $countingre = 0;
    my @actualtime;
    my %var_time;
    my $time_problet;
    
    my $counting = 1;  
    my $term_while = 0;
    while ($recicont =~ /<img src\s*=\s*\"\/s_i\/t\.gif[^>]*?>(.*?)<img src\s*=\s*\"\/s_i\/tc\.gif[^>]*?>/ && $term_while < 400)
      {
        $timevals .= $1.";,,;";
        
        $recicont =~ s/<img src\s*=\s*\"\/s_i\/t\.gif[^>]*?>(.*?)<img src\s*=\s*\"\/s_i\/tc\.gif[^>]*?>/<invar name=\"t\" problet=\"rcp1\" value=\"$1\" \/>/;
        $counting++;
      }  
          
    my @timearray = split (/\;\,\,\;/,$timevals);
    
    for (my $i = 0; $i < scalar @timearray; $i++)
      {
        $actualtime[$i] = $timearray[$i];
        $timearray[$i] =~ s/½/0\.5/s;
        if ($vartime > 0)
          {
            $timearray[$i] = $timearray[$i] / $vartime;
          }  
      }  

    for (my $i = 0; $i < scalar @timearray; $i++)
      {
        pos ($time_problet) = 0;
        if ($time_problet =~ /value=\"$actualtime[$i]\"/g)
          {
            
          }
        else
          { 
            $countingre++;
            $var_time{$actualtime[$i]} = $countingre; 
            $time_problet .= "<args var=\"t$countingre\" type=\"double\" format=\"\%.0f\" value=\"$actualtime[$i]\"/>";
            $time_problet .= "<args left=\"t$countingre\" right=\"$timearray[$i] * x1 ** 0.6667\" />";
          }  
          
        $recicont =~ s/<invar name=\"t\" problet=\"rcp1\" value=\"$actualtime[$i]\" \/>/<invar name=\"t$var_time{$actualtime[$i]}\" problet=\"rcp1\" value=\"$actualtime[$i]\" \/>/gs;
        $totaltime .= "+ t$countingre";    
      }
    return ($time_problet,$recicont,$totaltime,$countingre);  
  }  
  
#-----------------------------End  Recipes-----------------------------------------  


sub convertMEImages
  {
    my $htmlsource_raw = shift;

    $htmlsource_raw =~ s/<img src=\"?\/s_i\/me\.gif\"\s*syvum=\"\&lt\;title_eq\&gt\;(.*?)&lt;\/title_eq&gt;\s*&lt;keywd_eq&gt;(.*?)&lt;\/keywd_eq&gt;[^\"]*?\"[^>]*?>/<encrypt title=\"$1\" key=\"$2\">/gsi;
    $htmlsource_raw =~ s/<img src=\"?\/s_i\/mec\.gif\"?[^>]*?>/<\/encrypt>/gis;

    return ($htmlsource_raw);
  }



#-----------------------------------CODE DUPLICATION PRINTANAL------------------------------------
#-----------------------------------CODE SAVE FRONT PAGE------------------------------------------
sub printAnalXML
  {
    my $table_ref = shift;
    my $flag = shift;
    my $save_pub_flag = shift;
    my $DB_flag = shift;
    my %table = defined $table_ref ? %$table_ref : undef;
    
    my $htmlName = $table{file}."\.html";
    my $tdfname = $table{file}."\.tdf";
    my $tab_var = $table{tab};
    my $stats_table = "";
    
#---------- Removing <p></p>, newlines, <span>, <image> and adding quiz tags -----------------

#   my $htmlsource_raw = $table{elm1}.$table{elm2}.$table{elm3};

    my $htmlsource_raw = "";
    my $htmlsource_txt = "";
    my $len = "";
    for (my $j = 1; $j <= $tab_var; $j++)
      {
        my $i = "elm$j";
        my $k = "tab$j";
        if (length $table{$i} > 0 && $table{$i} !~ /^\s+$/s)
          { 
            $table{$i} =~ s/.*?<body>(.*?)<\/body>.*/$1/gis;
            $table{$i} =~ s/.*?<meta http-equiv=\"Content-Type\"//;
            $table{$k} =~ s/&/&amp\;/gis;
            
            if ($table{$i} =~ m/(.*?)<img([^>]*?)\/v?q\.gif([^>]*?)>/is)
              { 
                 
                 my $content_before_first_question = $1;
                 if ($content_before_first_question !~ /<img([^>]*?)\/qp\.gif([^>]*?)>/is)
                   { 
                     my $default_qp = "";
                     $default_qp .=<<EOF;
<div class="mceNonEditable">
<p>
<img src="http://scripts.syvum.com/s_i/qp.gif" syvum="&lt;fmt&gt;cmult, tgamem, bfillin, tgamef, djumble, tgamej, amtcda, hangman_en, hangman0_en, flash&lt;/fmt&gt;&lt;rfmt&gt;cmult, tgamem, bfillin, tgamef, djumble, tgamej, amtcda, hangman_en, hangman0_en, flash&lt;/rfmt&gt;&lt;ipf&gt;table,list,question_hide,question_only,answer_only,question_rhide,question_ronly,answer_ronly&lt;/ipf&gt;&lt;ipo&gt;Select&lt;/ipo&gt;&lt;ipp&gt;100&lt;/ipp&gt;&lt;lang&gt;english&lt;/lang&gt;&lt;tsc&gt;1&lt;/tsc&gt;" title="Question-set Properties" />
</p>
Question-set Properties - Basic
<table border="1" class="mceNonEditable" style="font-size: 70%; background-color: #f0efee">
	<tbody>
		<tr>
			<th align="left"><span style="color: #2b6fd2">Quiz</span></th><th align="left"><span style="color: #2b6fd2">Reverse Quiz</span></th><th align="left"><span style="color: #2b6fd2">Info Page</span></th>
		</tr>
		<tr>
			<td valign="top">Multiple choice<br />
			Fill in the blanks<br />
			Jumble<br />
			Match the columns<br />
			Hangman<br />
			Clueless Hangman<br />
			Flash Cards<br />
			</td>
			<td valign="top">Multiple choice<br />
			Fill in the blanks<br />
			Jumble<br />
			Match the columns<br />
			Hangman<br />
			Clueless Hangman<br />
			Flash Cards<br />
			</td>
			<td valign="top">Table<br />
			List<br />
			Questions &amp; Answers<br />
			Questions<br />
			Answers<br />
			Questions &amp; Answers<br />
			Questions<br />
			Answers<br />
			</td>
		</tr>
	</tbody>
</table>
<p>
<img src="http://scripts.syvum.com/s_i/qpc.gif" title="End Question-set Properties" />
</p>
</div>
EOF
                     $table{$i} = "$default_qp".$table{$i};
                   }
              }
            $htmlsource_raw .= $table{$i};
            $htmlsource_txt .= "<tab_name$j>$table{$k}</tab_name$j>".$table{$i}."<new_tab>";
          }
      
      }
    $htmlsource_raw =~ s/\&nbsp\;//gis;

    $htmlsource_raw =~ s/\r\n/ /gis;
    $htmlsource_raw =~ s/\r/ /gis;
    $htmlsource_raw =~ s/\n/ /gis;
#print "<textarea rows=\"20\" cols=\"20\">".$htmlsource_raw."</textarea>";
    $htmlsource_raw =~ s/(<div[^>]*>\s*)?((<p>)?\s*<img src\s*=\s*\"(http:\/\/[^\/]*)?\/s_i\/qp\.gif[^>]*>.*?<img src\s*=\s*\"(http:\/\/[^\/]*)?\/s_i\/qpc\.gif[^>]*>\s*(<\/p>)?)(\s*<\/div>)?/$2/sg;
    
    $htmlsource_raw =~ s/<img src\s*=\s*\"http:\/\/[^\/]*?\/s_i\//<img src=\"\/s_i\//gis;
    $htmlsource_raw =~ s/<img src\s*=\s*\"http:\/\/[^\/]*?\//<img src=\"\//gis;
    $htmlsource_raw =~ s/<img src=\"(\.\.\/){1,}s_i\//<img src=\"\/s_i\//gis;

    if ($htmlsource_raw =~ m/<img src=\"\/s_i\/me\.gif([^>]*?)>/gis)
      {
        $htmlsource_raw = convertMEImages($htmlsource_raw);
      }
    
    $htmlsource_raw =~ s/<p[^>]*?>\s*(<img src=\"\/s_i\/[^>]*?>)\s*<\/p>/<p>$1<\/p>/gis;
    
#    $htmlsource_raw =~ s/(\.\.\/){2,}/\//gis;
    $htmlsource_raw =~ s/\&nbsp\;/\s/gis;
 #   print $htmlsource_raw;
    

    $htmlsource_raw =~ s/\t*//gis;
  #  $htmlsource_raw =~ s/<div.*?>//gis;
  #  $htmlsource_raw =~ s/<\/div>//gis;      

# code for removing unwanted xml tags.
    $htmlsource_raw =~ s/<strong>\s*(\&nbsp\;)*(\u00A0)*<\/strong>//gis;
    $htmlsource_raw =~ s/<span[^>]*?>\s*(\&nbsp\;)*(\u00A0)*<\/span>//gis;    
    $htmlsource_raw =~ s/<em>\s*(\&nbsp\;)*(\u00A0)*<\/em>//sgi;
    $htmlsource_raw =~ s/<h\d[^>]*>\s*(\&nbsp\;)*(\u00A0)*<\/h\d>//sgi;    
    $htmlsource_raw =~ s/<a[^>]*>\s*(\&nbsp\;)*(\u00A0)*<\/a>//sgi;
    $htmlsource_raw =~ s/<div[^>]*>\s*(\&nbsp\;)*(\u00A0)*<\/div>//sgi;
    
    
    $htmlsource_raw =~ s/(<span[^>]*>)\s*<strong>\s*(<span[^>]*>\s*<strong>)/$1$2/sgi;
    $htmlsource_raw =~ s/(<\/strong>\s*<\/span>)\s*<\/strong>\s*(<\/span>)/$1$2/sgi;
    $htmlsource_raw =~ s/(<span style=\"[^\"]*)(\">)\s*<span style=\"([^\"]*)\">(.*?)(<\/span>)\s*<\/span>/$1\; $3$2$4$5/sgi;
    $htmlsource_raw =~ s/<strong>\s*(<img[^>]*>)\s*<\/strong>/$1/sgi;
    $htmlsource_raw =~ s/<span[^>]*>\s*(<img[^>]*>)\s*<\/span>/$1/sgi;
    $htmlsource_raw =~ s/<p[^>]*?>\s*(\&nbsp\;)*(\u00A0)*<\/p>/<br \/>/gis;
#-------------------------------------------    
    
  #  $htmlsource_raw =~ s/(.*?)mce_src[^>]*?>/$1\/>/gis;
#    $htmlsource_raw =~ s/<\/span>//gis;
 #   $htmlsource_raw =~ s/<span([^>]*)>(.*?)<\/span>/$2/gis;
    $htmlsource_raw =~ s/<p>(.*?)<\/p>/<br \/>$1/gis;
  #  $htmlsource_raw =~ s/(<img\s*src=\"\/s_i\/qp\.gif[^>]*?>).*?(<img\s*src=\"\/s_i\/qpc\.gif[^>]*?)/$1$2/gs;
    $htmlsource_raw =~ s/(<img\s*src\s*=\s*\"\/s_i\/qp\.gif[^>]*?>).*?(<img\s*src\s*=\s*\"\/s_i\/qpc\.gif[^>]*?)/$1$2/gs;    
    
    my $q_prop_spreadsheet;
    my $cont_post_table_spreadsheet;
    my $htmlsource;
    my $htmlsource_1;
    my $pattern = "";
    
    
    if ($htmlsource_raw =~ m/<img src=\"\/s_i\/qp\.gif([^>]*?)>/gis)
      {
        my @tab_doc_style = split (/\/s_i\/qp\.gif/,$htmlsource_raw);
        foreach my $tab_doc_style(@tab_doc_style)
          {
            my $converted_to_document = "";
            $tab_doc_style =~ s/<img src=\"(http:\/\/[^\/]*)?$//gis;

            if ($tab_doc_style =~ m/<img src=\"(http:\/\/[^\/]*)?\/s_i\/v?q\.gif/gis)
              {
                $htmlsource_1 = "<qp.gif".$tab_doc_style;
                
                if ($htmlsource_1 =~ m/<img src=\"(http:\/\/[^\/]*)?\/s_i\/vq\.gif/gis)
                  {
                    pos ($htmlsource_1) = 0;
                    
                    if ($htmlsource_1 =~ m/(<qp\.gif[^>]*>.*?)<img src=\"(http:\/\/[^\/]*)?\/s_i\/v[qaeh]\.gif/gis)
                      {
                         $cont_post_table_spreadsheet = $1;
                         $cont_post_table_spreadsheet =~ s/(.*)<table.*$/$1/gis;

                         if ($cont_post_table_spreadsheet =~ s/(<qp\.gif[^>]*>(.*?)<img[^>]*>)//gis)
                           {
                             $q_prop_spreadsheet = $1;
                           }
                      }
                    pos ($htmlsource_1) = 0;
                    my $term_while = 0;
                    
                    if ($htmlsource_1 =~ s/<img src=\"(http:\/\/[^\/]*)?\/s_i\/is\.gif/<img is\.gif/gis)
                      {
                        my $firstinfosub = 0;
                        my @info_sub_arr = split(/<img is\.gif/,$htmlsource_1);
                        foreach my $info_sub_var(@info_sub_arr)
                          {
                             if ($info_sub_var =~ m/\/s_i\/isc\.gif/gis)
                               {
                                  if ($firstinfosub == 0)
                                    {
                                      while ($info_sub_var =~ /\/s_i\/v([aqehc])\.gif/gs && $term_while < 100)
                                        {
                                          $pattern .= $1; 
                                          $firstinfosub = 1;
                                          $term_while++;
                                        }
                                    }   
                                  $info_sub_var = "<is\.gif".$info_sub_var;
                                  my $info_subheading = $info_sub_var;
                                  $info_subheading =~ s/(<is\.gif[^>]*>.*?<img.*?isc\.gif[^>]*>).*/$1/gis;
                                  $converted_to_document .= $info_subheading;
                                  $converted_to_document .= convertToDocument($info_sub_var);
                                  
                               }
                          }
                        
                      }
                    else
                      {
                         while ($htmlsource_1 =~ /\/s_i\/v([aqehc])\.gif/gs && $term_while < 100)
                           {
                             $pattern .= $1; 
                             $term_while++;
                           }
                         $converted_to_document = convertToDocument($htmlsource_1);
                         
                      }
                      
                    if ($cont_post_table_spreadsheet !~ /<img.*?qh\.gif[^>]*>/gis)
                      {
                        if ($converted_to_document =~ s/<inputCaption>(.*?)<\/inputCaption>//gis)
                          {
                            $q_prop_spreadsheet .= "{[inputCaption]}".$1."{[\/inputCaption]}";
                          }
                        if ($converted_to_document =~ s/<outputCaption>(.*?)<\/outputCaption>//gis)
                          {
                            $q_prop_spreadsheet .= "{[outputCaption]}".$1."{[\/outputCaption]}";
                          }
                        if ($converted_to_document =~ s/<explainCaption>(.*?)<\/explainCaption>//gis)
                          {
                            $q_prop_spreadsheet .= "{[explainCaption]}".$1."{[\/explainCaption]}";
                          }
                      }
                    else
                      {
                         $cont_post_table_spreadsheet =~ s/<img src=\"(http:\/\/[^\/]*)?\/s_i\/qh\.gif/qh\.gif/gis;
                         $cont_post_table_spreadsheet =~ s/<img src=\"(http:\/\/[^\/]*)?\/s_i\/ah\.gif/ah\.gif/gis;
                         $cont_post_table_spreadsheet =~ s/<img src=\"(http:\/\/[^\/]*)?\/s_i\/eh\.gif/eh\.gif/gis;
                         if ($cont_post_table_spreadsheet =~ s/qh\.gif[^>]*>(.*?)<img.*?qhc\.gif[^>]*>//gis)
                           {
                              $q_prop_spreadsheet .= "{[inputCaption]}".$1."{[\/inputCaption]}";
                           }
                         if ($cont_post_table_spreadsheet =~ s/ah\.gif[^>]*>(.*?)<img.*?ahc\.gif[^>]*>//gis)
                           {
                              $q_prop_spreadsheet .= "{[outputCaption]}".$1."{[\/outputCaption]}";
                           }
                         if ($cont_post_table_spreadsheet =~ s/eh\.gif[^>]*>(.*?)<img.*?ehc\.gif[^>]*>//gis)
                           {
                              $q_prop_spreadsheet .= "{[explainCaption]}".$1."{[\/explainCaption]}";
                           }
                         $converted_to_document =~ s/(<inputCaption>.*?<\/inputCaption>)//gis;
                         $converted_to_document =~ s/(<outputCaption>.*?<\/outputCaption>)//gis;
                         $converted_to_document =~ s/(<explainCaption>.*?<\/explainCaption>)//gis;
                      } 
                     
                    $cont_post_table_spreadsheet =~ s/<img src=\"(http:\/\/[^\/]*)?\/s_i\/is\.gif[^>]*>.*?<img src=\"(http:\/\/[^\/]*)?\/s_i\/isc\.gif[^>]*>//gis;
                     
                    $htmlsource .= $q_prop_spreadsheet.$cont_post_table_spreadsheet.$converted_to_document;
                    
                 }
               else
                 {
                   $htmlsource .= $htmlsource_1;
                 }
             }
           else
             {
               $htmlsource .= $tab_doc_style;
             }
         }
      }
    else
      {
        $htmlsource = $htmlsource_raw;
      }

    $htmlsource =~ s/<img src=\"(http:\/\/[^\/]*)?\/s_i\//</gis;
    #$htmlsource =~ s/ / /gis;
    $htmlsource =~ s/_button\.gif\"(.*?)\/>/\#opentag>/gis;
    $htmlsource =~ s/_button_1\.gif\"(.*?)\/>/\/closetag>/gis;
    $htmlsource =~ s/(<p[^>]*>)\s*<q\.gif\"[^\/]*\/>\s*(\u00A0)*/\{\[que\]\}$1\{\[inp\]\}/gis;
    $htmlsource =~ s/<q\.gif\"[^\/]*\/>\s*( )*(\u00A0)*(\u0020)*/\{\[que\]\}\{\[inp\]\}/gis;
    $htmlsource =~ s/( )*(\u00A0)*\s*<qc\.gif\"[^\/]*\/>/\{\[\/inp\]\}/gis;

    $htmlsource =~ s/<aq\.gif\"[^\/]*\/>\s*( )*(\u00A0)*/\{\[altinput\]\}/gis;
    $htmlsource =~ s/( )*(\u00A0)*\s*<aqc\.gif\"[^\/]*\/>/\{\[\/altinput\]\}/gis;
    $htmlsource =~ s/<ci\.gif\"[^\/]*\/>\s*( )*(\u00A0)*/\{\[cip\]\}/gis;
    $htmlsource =~ s/( )*(\u00A0)*\s*<cic\.gif\"[^\/]*\/>/\{\[\/cip\]\}/gis;
    #=========== Contributed answer and explanation 18_07_09 ============================
    
    my $contribUserId = "";
    my $messId = "";
    my $quesNo = 0;
    my $tups = "";
    my $tdns = "";
    my $contans_flag = "";
    my $whileTerm = 0;
    

  	pos($htmlsource) = 0;
  	my $test = "";
  	
    while ($htmlsource =~ m/<cs\.gif/g && $whileTerm < 500)
      {
        $whileTerm++;
        my $contSol = "";
        my $contExp = "";
        
        if ($htmlsource =~ s/<cs\.gif\".*?syvum=\"([^\"|>]*?)\"[^>]*?>(.*?)<csc\.gif[^>]*?>/<::::REPLACED--CONTRIB--Ans--Exp--Tag::>/)
          {
            my $syvumAttCont = $1;
	          $contSol = $2;
	    			
            $syvumAttCont =~ s/&amp;/&/g;
            
             
            ($contribUserId,$messId,$contans_flag,$tups,$tdns) = split(/&/,$syvumAttCont);

            #$contSol = $2;
            $contribUserId =~ s/userid://;
            $messId =~ s/messId://;
            $contans_flag =~ s/contans_flag://;   
            $tups =~ s/tup://igs;
            $tdns =~ s/tdn://igs;
            
						#open (FILE,">>/tmp/testfile111.txt");
            #print FILE "->".$contSol."<-\n";
           # close (FILE);
            $contSol =~ s/<a\.gif\"[^\/]*\/>/<ca\.gif\" syvum=\"$contribUserId;$messId;$tups;$tdns\" \/>/g;
            $contSol =~ s/<ac\.gif\"[^\/]*\/>/<cac\.gif\" \/>/g;
            $contSol =~ s/<e\.gif\"[^\/]*\/>/<ce\.gif\" \/>/g;
            $contSol =~ s/<ec\.gif\"[^\/]*\/>/<cce\.gif\" \/>/g;
            
            if ($contans_flag == 1)
              {
                $contSol ="<ca\.gif\" syvum=\"$contribUserId;$messId;$tups;$tdns\" \/><cac\.gif\" \/>".$contSol; 
              }
            
    				
            $htmlsource =~ s/<::::REPLACED--CONTRIB--Ans--Exp--Tag::>/$contSol/;           
          }
      }
     
    $htmlsource =~ s/<ca\.gif\"\s*syvum=\"([^;]*);([^;]*);([^;]*);([^\"]*)\"[^\/]*\/>\s*/\{\[cans c=\"$1;$2;$3;$4\"\]\}\{\[CONTRIBOUT\]\}/gis;
    
    $htmlsource =~ s/<ca\.gif\"\s*syvum=\"([^\"]*?)\"[^\/]*\/>\s*/\{\[cans c=\"$1\"\]\}\{\[CONTRIBOUT\]\}/gis;
    $htmlsource =~ s/\s*<cac\.gif\"[^\/]*\/>/\{\[\/CONTRIBOUT\]\}/gis;
    $htmlsource =~ s/<ce\.gif\"[^\/]*\/>\s*/\{\[exp\]\}/gis;
    $htmlsource =~ s/\s*<cce\.gif\"[^\/]*\/>/\{\[\/exp\]\}\{\[\/cans\]\}/gis;
    
    
    #========================= End ======================================================
    $htmlsource =~ s/<a\.gif\"[^\/]*\/>\s*( )*(\u00A0)*/\{\[out\]\}/gis;
    $htmlsource =~ s/( )*(\u00A0)*\s*<ac\.gif\"[^\/]*\/>/\{\[\/out\]\}/gis;
    

    $htmlsource =~ s/<c\.gif\"[^\/]*\/>\s*/\{\[option\]\}/gis;
    $htmlsource =~ s/\s*<cc\.gif\"[^\/]*\/>/\{\[\/option\]\}/gis;
    $htmlsource =~ s/<e\.gif\"[^\/]*\/>\s*( )*(\u00A0)*/\{\[exp\]\}/gis;
    $htmlsource =~ s/\s*( )*(\u00A0)*<ec\.gif\"[^\/]*\/>/\{\[\/exp\]\}/gis;
    $htmlsource =~ s/<h\.gif\"[^\/]*\/>\s*( )*(\u00A0)*/\{\[hnt\]\}/gis;
    $htmlsource =~ s/\s*( )*(\u00A0)*<hc\.gif\"[^\/]*\/>/\{\[\/hnt\]\}/gis;
    $htmlsource =~ s/<fp\.gif\"[^\/]*\/>\s*/\{\[psg\]\}/gis;
    $htmlsource =~ s/\s*<fpc\.gif\"[^\/]*\/>/\{\[\/psg\]\}/gis;
    $htmlsource =~ s/<fc\.gif\"[^\/]*\/>\s*/\{\[choice\]\}/gis;
    $htmlsource =~ s/\s*<fcc\.gif\"[^\/]*\/>/\{\[\/choice\]\}/gis;
    $htmlsource =~ s/<aa\.gif\"[^\/]*\/>\s*/\{\[alt\]\}/gis;
    $htmlsource =~ s/  \|\|\|/\|\|\|/gis;
    $htmlsource =~ s/ \|\|\|/\|\|\|/gis;
    $htmlsource =~ s/\s*( )*(\u00A0)*\|\|\|\s*/\{\[alt\]\}/gis;
    $htmlsource =~ s/\s*<aac\.gif\"[^\/]*\/>/\{\[\/alt\]\}/gis;
    $htmlsource =~ s/<qt\.gif\"[^\/]*\/>\s*/\{\[questiontype\]\}/gis;
    $htmlsource =~ s/\s*<qtc\.gif\"[^\/]*\/>/\{\[\/questiontype\]\}/gis;
    $htmlsource =~ s/(\{\[out\]\})\s*Fixed Choice\s*((\d*)\s*\{\[\/out\]\})/$1$2/gs;
    $htmlsource =~ s/<ap\.gif\"[^\/]*\/>\s*/\n\{\[opto\]\}/gis;
    $htmlsource =~ s/\s*<apc\.gif\"[^\/]*\/>/\{\[\/opto\]\}/gis;
    $htmlsource =~ s/(\{\[opto\]\})\s*Answer Position\s*([^\{]*\{\[\/opto\]\})/$1$2/gs;
#print "<textarea rows=\"20\" cols=\"20\">".$htmlsource."</textarea>";
    $htmlsource =~ s/<qp\.gif\"\s*syvum=\"([^\"]*?)\"[^\/]*\/>\s*/\{\[s_inst\]\}syvum=\"$1\"/gis;
    $htmlsource =~ s/\s*<qpc\.gif\"[^\/]*\/>/\{\[\/s_inst\]\}/gis;
    $htmlsource =~ s/<ti\.gif\"[^\/]*\/>\s*/\{\[topinst\]\}/gis;
    $htmlsource =~ s/\s*<tic\.gif\"[^\/]*\/>/\{\[\/topinst\]\}/gis;
    $htmlsource =~ s/<me\.gif\"[^\/]*\/>\s*/\{\[enc\]\}/gis;
    $htmlsource =~ s/\s*<mec\.gif\"[^\/]*\/>/\{\[\/enc\]\}/gis;
    $htmlsource =~ s/<th\.gif\"[^\/]*\/>\s*/\{\[topheading\]\}/gis;
    $htmlsource =~ s/\s*<thc\.gif\"[^\/]*\/>/\{\[\/topheading\]\}/gis;
    $htmlsource =~ s/<fi\.gif\"[^\/]*\/>\s*/\{\[forwardinst\]\}/gis;
    $htmlsource =~ s/\s*<fic\.gif\"[^\/]*\/>/\{\[\/forwardinst\]\}/gis;
    $htmlsource =~ s/<ri\.gif\"[^\/]*\/>\s*/\{\[reverseinst\]\}/gis;
    $htmlsource =~ s/\s*<ric\.gif\"[^\/]*\/>/\{\[\/reverseinst\]\}/gis;
    $htmlsource =~ s/<qr\.gif\"[^\/]*\/>/\{\[theory\]\}/gs;
    $htmlsource =~ s/<qrc\.gif\"[^\/]*\/>/\{\[\/theory\]\}/gs;
    
    $htmlsource =~ s/<ocr\.gif\"[^\/]*\/>/\{\[ocr\]\}/gs;
    $htmlsource =~ s/<ocrc\.gif\"[^\/]*\/>/\{\[\/ocr\]\}/gs;
    
    $htmlsource =~ s/<qi\.gif\"[^\/]*\/>\s*/\{\[q_inst\]\}/gis;
    $htmlsource =~ s/\s*<qic\.gif\"[^\/]*\/>/\{\[\/q_inst\]\}/gis;
    $htmlsource =~ s/<sh\.gif\"[^\/]*\/>\s*/\{\[sectionheading\]\}/gis;
    $htmlsource =~ s/\s*<shc\.gif\"[^\/]*\/>/\{\[\/sectionheading\]\}/gis;
    $htmlsource =~ s/<sd\.gif\"[^\/]*\/>\s*/\{\[sectiondetails\]\}/gis;
    $htmlsource =~ s/\s*<sdc\.gif\"[^\/]*\/>/\{\[\/sectiondetails\]\}/gis;
    $htmlsource =~ s/<td\.gif\"[^\/]*\/>\s*/\{\[topdetails\]\}/gis;
    $htmlsource =~ s/\s*<tdc\.gif\"[^\/]*\/>/\{\[\/topdetails\]\}/gis;
    $htmlsource =~ s/<qh\.gif\"[^\/]*\/>\s*/\{\[inputCaption\]\}/gis;
    $htmlsource =~ s/\s*<qhc\.gif\"[^\/]*\/>/\{\[\/inputCaption\]\}/gis;
    $htmlsource =~ s/<ah\.gif\"[^\/]*\/>\s*/\{\[outputCaption\]\}/gis;
    $htmlsource =~ s/\s*<ahc\.gif\"[^\/]*\/>/\{\[\/outputCaption\]\}/gis;
    $htmlsource =~ s/<eh\.gif\"[^\/]*\/>\s*/\{\[explainCaption\]\}/gis;
    $htmlsource =~ s/\s*<ehc\.gif\"[^\/]*\/>/\{\[\/explainCaption\]\}/gis;
    
#---Expression for blip on mouseover & step on click----   

    $htmlsource =~ s/<hs\.gif\"\s*syvum=\"blip\"\s*title=\"Mouseover - ([^\"]*)\"[^>]*\/>/\{\[step name=\"$1\" method=\"blip\"\]\}/gis;

    $htmlsource =~ s/<hs\.gif\"\s*syvum=\"step\"\s*title=\"Click - ([^\"]*)\"[^>]*\/>\s*/\{\[step name=\"$1\"\]\}/gis;
    $htmlsource =~ s/\s*<hsc\.gif\"[^>]*\/>/\{\[\/step\]\}/gis;   
#-------------------------------------------------------

    $htmlsource =~ s/<is\.gif\"[^\/]*\/>\s*/\{\[ips\]\}/gis;
    $htmlsource =~ s/\s*<isc\.gif\"[^\/]*\/>/\{\[\/ips\]\}/gis;
    $htmlsource =~ s/<qr\.gif\"[^\/]*\/>\s*/\{\[quickref\]\}/gis;
    $htmlsource =~ s/\s*<qrc\.gif\"[^\/]*\/>/\{\[\/quickref\]\}/gis;
    $htmlsource =~ s/<vp\.gif\" rtol=\"([^\"]*?)\"[^\/]*\/>\s*/\{\[variablesetting rtol=\"$1\"\]\}/gis;
    $htmlsource =~ s/<vp\.gif\"[^\/]*\/>\s*/\{\[variablesetting\]\}/gis;
    $htmlsource =~ s/\s*<vpc\.gif\"[^\/]*\/>/\{\[\/variablesetting\]\}/gis;
    $htmlsource =~ s/<at\.gif\"[^\/]*\/>\s*/\{\[anst\]\}/gis;
    $htmlsource =~ s/\s*<atc\.gif\"[^\/]*\/>/\{\[\/anst\]\}/gis;
    $htmlsource =~ s/<m\.gif\"[^\/]*\/>\s*/\{\[mrk\]\}/gis;
    $htmlsource =~ s/\s*<mc\.gif\"[^\/]*\/>/\{\[\/mrk\]\}/gis;
    $htmlsource =~ s/<k\.gif\"[^\/]*\/>\s*/\{\[kwd\]\}/gis;
    $htmlsource =~ s/\s*<kc\.gif\"[^\/]*\/>/\{\[\/kwd\]\}/gis;

    #removing unwanted BR tags from the main content.
    #$htmlsource =~ s/(\{\[\/[^>]*?\]\})\s*(<br \/>)*\s*(\{\[[^\/]*\]\})/$1\[br\]$3/gis; 
    $htmlsource =~ s/<div class=\"mceNonEditable\">(.*?)<\/div>/$1/gis;
    $htmlsource =~ s/\s*<br \/>\s*<br \/>\s*/<br \/><br \/>/gs;
    
    
    #$htmlsource =~ s/\s*<br \/>\W*?[^\w]*\s*<br \/>\s*/<br \/><br \/>/gs;
    #$htmlsource =~ s/\]\}\W*?[^\w]*\s*(<br \/>)*\W*?[^\w]*\s*\{\[/\]\}\{\[/gis; 


    $htmlsource =~ s/\]\}\s*(<br \/>)*\s*\{\[/\]\}\{\[/gis; 
    $htmlsource =~ s/^\s*(<br \/>)*//sg;
    $htmlsource =~ s/\s*(<br \/>)*\s*$//sg;
    $htmlsource =~ s/\[br\]//gis;
#end.
    $htmlsource =~ s/\{\[/</gis;
    $htmlsource =~ s/\]\}/>/gis;
    $htmlsource =~ s/(<\/step>)[^<]*(<step[^>]*>)/$1<p>  <\/p>$2/sg;

    my $language = "";
    my $read_theory_on = "";
    pos($htmlsource) = 0;
    if ($htmlsource =~ /\&lt\;lang\&gt\;(.*?)\&lt\;\/lang\&gt\;/gis)
      {
        $language = $1;
      }
     
    $read_theory_on = readtheory($language);
    my $top_heading = "";
    pos($htmlsource) = 0;
    
    if ($htmlsource =~ /<topheading>(.*?)<\/topheading>/gis)
      {
        $top_heading = "$1";     
        
        $top_heading =~ s/<br[^>]*>/<br\/> /gis;
        $htmlsource =~ s/<topheading>(.*?)<\/topheading>//gis;
      }
    my $qck_ref = "";
    pos($htmlsource) = 0;  
    if ($htmlsource =~ s/(<theory>.*?<\/theory>)//gis)
      {
        $qck_ref = $1;
      }  

    my $cip = "";
    pos($htmlsource) = 0;  
    if ($htmlsource =~ s/(<cip>.*?<\/cip>)//gis)
      {
        $cip = $1;
      }  

    my $top_details = "";
    if ($htmlsource =~ s/(<topdetails>.*?<\/topdetails>)//gis)
      {
        $top_details = "\n$1";
      }
    my $infotheme = "";
    $htmlsource =~ s/&lt;(infoTheme)&gt;(.*?)&lt;(\/infoTheme)&gt;/<$1>$2<$3>/gs;
    if ($htmlsource =~ s/(<infoTheme>.*?<\/infoTheme>)//gis)
      {
        $infotheme = "\n$1";
      }
    my $autonum = "";
    if ($htmlsource =~ /<autonumber>(.*?)<\/autonumber>/gis)
      {
        $autonum = "$1";  
        $htmlsource =~ s/<autonumber>(.*?)<\/autonumber>//gis   
      }
    my $title_head = $table{name};
    #$title_head =~ s/\&/&amp;/gi;
    $htmlsource =~ s/(<tab_name(\d)*>(.*?)<\/tab_name(\d)*>)(<br \/>)*(<s_inst>(.*?)<\/s_inst>)/$6$1/gis;
#------------------------END-----------------------------------------------------------------
    $htmlsource =~ s/<anst>Multiple\sAnswer<\/anst>/<anst>mult_ma<\/anst>/gis;
    $htmlsource =~ s/<anst>Short\sAnswer<\/anst>/<anst>fillin_sa<\/anst>/gis;
    $htmlsource =~ s/<anst>Odd One Out<\/anst>/<anst>odd_one<\/anst>/gis;
    
    my $htmlsource_count_tags = $htmlsource;
    $htmlsource =~ s/<altinput>\s*/<inp>/gis;
    $htmlsource =~ s/<\/altinput>\s*/<\/inp>/gis;
#    $htmlsource_count_tags =~ s/<s_inst>.*?<\/s_inst>//gis;
    $htmlsource_count_tags =~ s/<que[^>]*>/<que>/gis;
    
    if ($htmlsource_count_tags =~ /<alt>/gs && $htmlsource_count_tags !~ /<\/alt>/gs)
      {
        $htmlsource_count_tags = AltAnswerVertFormat($htmlsource_count_tags);
      }
    $stats_table = display_tag_count($htmlsource_count_tags);   
     
    my $auto_number = "";
    if ($htmlsource =~ s/Auto_Number_Questions_No//gis)
      {
        $auto_number = "No";
      }
 
#--------- Creating section sets and question OR only question set-------------------------------
    if ($htmlsource =~ m/<s_inst>/gis)
      {
         $htmlsource = createsectionset($htmlsource);
      }
    else
      {
        $htmlsource = createquestionset($htmlsource);
      }
#---------------- Code for Info sub heading without question following them --------------------------------



#flag for theory link tag   
     my $theorylinkflag = 0;     
     if ($htmlsource =~ /<ipf>.*?<\/ipf>/sg)
       {
         $theorylinkflag = 1;
       }
     my $autonumberflag = 0;  
     if ($htmlsource =~ s/<autonumber>No<\/autonumber>//sg)
       {
         $autonumberflag = 1;
       }       
#----------------------------
        
#--------------  END ------------------------------------------------------------------
    $htmlsource =~ s/<option>/\n<ans t=\"opt\">/gis;
    $htmlsource =~ s/<\/option>/<\/ans>/gis;
#-----------------Arrange all the content ---------------------------------------------
    $htmlsource =~ s/<quickref>/\n<quickref>/gis;
    $htmlsource =~ s/<que>/\n\n<que>/gis;
    $htmlsource =~ s/<inp>\s*( )*(\u00A0)*/\n<inp>/gis;
    $htmlsource =~ s/( )*(\u00A0)*\s*<\/inp>/<\/inp>/gis;
    $htmlsource =~ s/<out>\s*( )*(\u00A0)*/\n<out>/gis;
    $htmlsource =~ s/( )*(\u00A0)*\s*<\/out>/<\/out>/gis;
    $htmlsource =~ s/<exp>/\n<exp>/gis;
    $htmlsource =~ s/<hnt>/\n<hnt>/gis;
    $htmlsource =~ s/<option>/\n<option>/gis;
    $htmlsource =~ s/<\/que>/\n<\/que>/gis;
    $htmlsource =~ s/<s_inst>/\n\n<s_inst>/gis;
    $htmlsource =~ s/<psg>/\n\n<psg>/gis;
    $htmlsource =~ s/<fixedchoice>/\n<fixedchoice>/gis;
    $htmlsource =~ s/<choice>/\n<choice>/gis;
    $htmlsource =~ s/<\/fixedchoice>/\n<\/fixedchoice>/gis;
    $htmlsource =~ s/<prm>/\n<prm>/gis;             
    $htmlsource =~ s/<\/prm>/\n<\/prm>/gis;
    $htmlsource =~ s/<des>/\n<des>/gis;
    $htmlsource =~ s/<rdes>/\n<rdes>/gis;
    $htmlsource =~ s/<fmt>/\n<fmt>/gis;
    $htmlsource =~ s/<rfmt>/\n<rfmt>/gis;
    $htmlsource =~ s/<ipo>/\n<ipo>/gis;
    $htmlsource =~ s/<ipf>/\n<ipf>/gis;   
    $htmlsource =~ s/<input_tts>/\n<input_tts>/gis;
    $htmlsource =~ s/<output_tts>/\n<output_tts>/gis;
    $htmlsource =~ s/<tdfcasesensitive>/\n<tdfcasesensitive>/gis;
    $htmlsource =~ s/<lang>/\n<lang>/gis;
    $htmlsource =~ s/<fixedorder>/\n<fixedorder>/gis;
    $htmlsource =~ s/<alr>/\n<alr>/gis;   
    $htmlsource =~ s/<tsc>/\n<tsc>/gis;   
    $htmlsource =~ s/<ans>/\n<ans>/gis;       
    $htmlsource =~ s/<qs_name>/\n<qs_name>/gis;
    $htmlsource =~ s/<anst>/\n<anst>/gis;
    $htmlsource =~ s/<\/ans>/\n<\/ans>/gis;
    $htmlsource =~ s/<tab_name(\d*)>/\n<tab_name$1>/gis;
    $htmlsource =~ s/<step name=\"Show\/Hide\">/\n<step name=\"Show\/Hide\">/gis;
    $htmlsource =~ s/<sectionheading>/\n<sectionheading>/gis;
    $htmlsource =~ s/<sectiondetails>/\n<sectiondetails>/gis;
    $htmlsource =~ s/<mrk>/\n<mrk>/gis;
    $htmlsource =~ s/<kwd>/\n<kwd>/gis;
   # $htmlsource =~ s/<([^\/>]*?)>(<img[^>]*?>)?<\/[^>]*?>/<$1> $2<\/$1>/gis;
    $htmlsource =~ s/\_{3,}/_______/sgi;

  
#-------------- The main preamble  for XML file -------------------------------     
   # $table{keywords} =~ s/\&/&amp;/g;
   # $table{desc} =~ s/\&/\&amp\;/g;
   my $keywords_value = "";
   if ($language eq "german")
     {
       $keywords_value = $table{keywords};
     }
   else
     {  
       $keywords_value = lc($table{keywords});
     }  

    $keywords_value =~ s/\,*\s*$//gi;
    
    $keywords_value =~ s/\'/\&amp\;\#39\;/gi;
    
    my $xmlText = "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<tdf ver=\"1.1\">
<preamble>
<title>$title_head</title><keywords>$keywords_value</keywords><description>$table{desc}</description>$qck_ref";
   
    if (length($top_heading) > 0)
      {
        $xmlText .= "\n<heading>$top_heading</heading>";
      }
    else
      {
        $xmlText .= "\n<heading>$title_head</heading>";
      }
    if (length($top_details) > 0)
      {
        $xmlText .= "$top_details";
      }

    if (length($cip) > 0)
      {
      	$xmlText .= "\n$cip";
      }

    my $tdflinkTextHere = $table{name};
    $xmlText .= $infotheme;
    my $theory = $tdflinkTextHere;
    $theory =~ s/\&/&amp;/gi;
    $htmlName =~ s/\..*?$//gi;
    $htmlName =~ s/^.*\/(.*)?/$1/gi;
    $htmlName = $htmlName.".html";

#check flag for theory link tag   
    if ($theorylinkflag == 1)
      {
        $xmlText .= "\n<theory_link><a href=\"$htmlName\">$read_theory_on $theory</a></theory_link>";
      }
    if ($autonumberflag == 1)  
      {
        $xmlText .= "\n<autonumber>No</autonumber>";
      }
#------------------------------      

#    my $titleHere = $table{name};
#    my $title_head1 = $titleHere;
#    $title_head1 =~ s/\&/,/gi;
#    $title_head1 =~ s/\:/,/gi;
    
#    my $keywords_value = $title_head1.", ".$table{keywords};  #The title will be added as the keyword. 
    
#    $xmlText .= "\n";
    my $folderpath = $table{file};
    $folderpath =~ s/^(pawan)\///gis;
    $folderpath =~ s/^(praful)\///gis;              
    $folderpath =~ s/^(pallavi)\///gis;              
    $folderpath =~ s/^(shruti)\///gis;              
    $folderpath =~ s/^(maya)\///gis;              
    $folderpath =~ s/^(akshay)\///gis;              
    $folderpath =~ s/^(uday)\///gis;    
#    $xmlText .= "\n<customize>$folderpath</customize>";
    $table{author_name} =~ s/^\s+$//g;
    if (length($table{author_name}) > 0)
      {
        $table{author_name} =~ s/\&/&amp;/g;
        $xmlText .= "\n<author>$table{author_name}</author>";
      }
    else
      {
        $xmlText .= "\n<author>Guest</author>";
      }
    if (length($table{affiliation}) > 0)
      {
        $table{affiliation} =~ s/\&/&amp;/g;
        $xmlText .= "\n<affiliation>$table{affiliation}</affiliation>";
      }  
    if (length($table{file}) > 0)
      {
        my $file_name = $table{file};
        $file_name =~ s/\..*?$//gi;
        $file_name =~ s/^.*\/(.*)?/$1/gi;
        $xmlText .= "\n<filename>$file_name</filename>";    
      }
    if (length($autonum) > 0)
      {        
        $xmlText .= "\n<autonumber>$autonum</autonumber>";    
      }

    $xmlText .= "\n</preamble>";

# ----------------------------------END------------------------------------------------------

#----------- Adding all content to save in the XML file ----------------
    
    $xmlText .= "\n$htmlsource"."\n\n</tdf>";

  #  $xmlText =~ s/\'/\&\#8217\;/gis;

# ------------------------------END ------------------------------------------------------------
 #   $htmlsource_txt =~ s/(\.\.\/){2,}/\//gis; 
     $htmlsource_txt =~ s/<img src=\"(\.\.\/){1,}s_i\//<img src=\"\/s_i\//gis;
     $htmlsource_txt =~ s/<img src\s*=\s*\"http:\/\/[^\/]*?\/s_i\//<img src=\"\/s_i\//gis;
    my $text = "<title_doc>$table{name}<\/title_doc><filename>$table{file}<\/filename><desc>$table{desc}</desc><keyword_adv_prop>$table{keywords}</keyword_adv_prop><author>$table{author_name}</author><affiliation>$table{affiliation}</affiliation>".$htmlsource_txt;
#    $text =~ s/<img src\s*=\s*\"http:\/\/[^\/]*?\/s_i\///
#    $text =~ s/\r\n*//gis;
    $text =~ s/(<p>(\&nbsp\;)*<\/p>){2,}/<p><\/p>/gis;
    #`echo $xmlText >/tmp/testfiles1.xml`; 
   
    if ($DB_flag == 1)
      {
        iodb::savefiledataDB(\%table,$text,$xmlText,$flag,$save_pub_flag,$stats_table);
      }
    elsif ($DB_flag == 2)
      {
        return ($text,$xmlText);
      }
    else
      {
        io::savefiledata(\%table,$text,$xmlText,$flag,$save_pub_flag);
      }
  }
  
  
sub AltAnswerVertFormat
  {
    my $source = shift;
    $source =~ s/<alt>/<\/out><alt>/gs;
    $source =~ s/<alt>(.*?)<\/out>/<alt>$1<\/alt>/gs;
    return ($source);
  }
  
sub readtheory
  {
    my $language = shift;
    my $read_theory_on = "";
    if ($language =~ /english/gis)
      {
        $read_theory_on = "Read Theory on";
      }
    if ($language =~ /spanish/gis)
      {
        $read_theory_on = "Leer la teoría encendido";
      }
    if ($language =~ /french/gis)
      {
        $read_theory_on = "Lisez l'information sur";
      }
    if ($language =~ /german/gis)
      {
        $read_theory_on = "Lesen Information auf";
      }
    if ($language =~ /italian/gis)
      {
        $read_theory_on = "Leggere la teoria sopra";
      }
    if ($language =~ /portuguese/gis)
      {
        $read_theory_on = "Ler a teoria sobre";
      }
    if ($language =~ /japanese/gis)
      {
        $read_theory_on = "理論を読みなさい";
      }
    if ($language =~ /hindi/gis)
      {
        $read_theory_on = "";
      }
    if ($language =~ /russian/gis)
      {
        $read_theory_on = "Читать теория";
      }
    if ($language =~ /chinese/gis)
      {
        $read_theory_on = "经过理论";
      }
    return ($read_theory_on);
  }

sub display_tag_count
  {
    my $htmlsource_count_tags = shift;

    my $count_ans_open = 0;
    my $count_ans_close = 0;
    my $count_multiple_ans_open = 0;
    my $count_multiple_ans_close = 0;
    my $count_alt_ans_open = 0;
    my $count_alt_ans_close = 0;
    my $stats_table = "";
    my $commentCollection = "";
    my $commenttemp = "";
    my $comment = "";
    my $commentFlag = 0;
    my $source_for_multi_ans = $htmlsource_count_tags;
    my $qp_number = -1;

    $htmlsource_count_tags = $htmlsource_count_tags."</que>";
    my @section_level = split (/<s_inst>/,$htmlsource_count_tags);
    foreach my $section_level (@section_level)
      {
         $qp_number++;
         pos($section_level) = 0; 
         if ($section_level =~ m/<\/s_inst>/gis)
           {
              pos($section_level) = 0; 
              if ($section_level !~ m/<ips>/gis)
                {
                   my $flag = 0;
                   $stats_table .= withoutinfosub($section_level, $flag, $qp_number);
                }
              else
                {
                   $stats_table .= withinfosub($section_level, $qp_number);
                }
                
              ($commenttemp = $stats_table) =~ s/.*?<commentFlagOpen>(.*?)<\/commentFlagEnd>/$1/gsi;
              $commentCollection .= $commenttemp;
              $stats_table =~ s/<commentFlagOpen>(.*?)<\/commentFlagEnd>//gsi;
           }
      }
    $commentCollection =~ s/\n*\r*//gs;

    if ($commentCollection =~ s/<Mis;;<:::>;;MatchTag=question>//gis)  
      {
        $comment .= "<br /><font color='red'>There might be missing opening or closing question tag.</font>";
        $commentFlag = 1;
      }
    if ($commentCollection =~ s/<Mis;;<:::>;;MatchTag=answer>//gis)  
      {
        $comment .= "<br /><font color='red'>There might be missing opening or closing answer tag.</font>";    
        $commentFlag = 1;  
      }
    if ($commentCollection =~ s/<Mis;;<:::>;;MatchTag=Alt:&&:question>//gis)  
      {
        $comment .= "<br /><font color='red'>There might be missing opening or closing alternative question tag.</font>";
        $commentFlag = 1;      
      }
    if ($commentCollection =~ s/<Mis;;<:::>;;MatchTag=Mult&&&;Answer>//gis)  
      {
        $comment .= "<br /><font color='red'>There might be missing opening or closing multiple answer tag.</font>";
        $commentFlag = 1;    
      }
    if ($commentCollection =~ s/<Mis;;<:::>;;MatchTag=alt&&&;Answer>//gis)  
      {
        $comment .= "<br /><font color='red'>There might be missing opening or closing alternative answer tag.</font>";
        $commentFlag = 1; 
      }
    if ($commentCollection =~ s/<Mis;;<:::>;;MatchTag=Choice>//gis)  
      {
        $comment .= "<br /><font color='red'>There might be missing opening or closing choice tag.</font>";
        $commentFlag = 1;   
      }
    if ($commentCollection =~ s/<Mis;;<:::>;;MatchTag=Explain>//gis)  
      {
        $comment .= "<br /><font color='red'>There might be missing opening or closing explain tag.</font>";
        $commentFlag = 1;   
      }    
    if ($commentCollection =~ s/<Mis;;<:::>;;MatchTag=hint>//gis)  
      {
        $comment .= "<br /><font color='red'>There might be missing opening or closing hint tag.</font>";
        $commentFlag = 1;
      }          
    $stats_table = "<step name=\"Show\/Hide Quiz Statistics\">
<table border=\"1\">
<tr align=\"center\"><th>No.</b></th><th>Question-set Name</th><th><b>Questions</b></th><th><b>Answers</b></th><th><b>Alternative Questions</b></th>
<th><b>Multiple Answers</b></th>
<th><b>Alternative Answers</b></th>
<th><b>Choices</b></th>
<th><b>Explanations</b></th>
<th><b>Hints</b></th></tr>
".$stats_table;

    $stats_table = removejunkcolumns ($stats_table);
    
    if ($commentFlag == 1)
      {
        $comment .= "<br /><font color='red'>WARNING : Due to mis-match of tags, this quiz might not function as expected.</font>";
      }
    $stats_table = "
<table border=\"1\">
".$stats_table."</table>".$comment;
    return ($stats_table);

  }


sub removejunkcolumns
  {
    my $otherInfo = shift;    
    
    my $clean_stat = $otherInfo;
    my @head_arr;
    my $i;
    my $flag = 0;
    my $qarrange;
    my $aarrange;
    my $arrange;
    my $len_arr;
    my $arrange_1;
    my $table_head = "<tr><td>QP</td><td>Info Page Subheading</td>";
    my $head_answer = "";
    my $head_explain = "";
    my $col_no_del;
    my @arrange;
    $otherInfo =~ s/.*?(<table.*)/$1/gis;  
    $otherInfo =~ s/\t*//gis;
    $otherInfo =~ s/<style> html,body\{border\:0px\;\}p\{margin-top\:0px\;margin\-bottom\:2px\;\}<\/style>//gis;
    #$otherInfo =~ s/\r*\n*//gis;
    
    $otherInfo =~ s/\r\n//gis;
    $otherInfo =~ s/\r//gis;
    $otherInfo =~ s/\n//gis;
    
    $otherInfo =~ s/<\/tr>//gsi;

    $otherInfo =~ s/<tr[^>]*?>/\[tr\]/gis;
    $otherInfo =~ s/<br\s?\/?>/\[br\]/gis;
    $otherInfo =~ s/<tr><td.*?>/\n\[tr\]/gis;
    $otherInfo =~ s/<th.*?>/\[th\]/gis;
    $otherInfo =~ s/<td.*?>/\[td\]/gis;
    $otherInfo = removehtmltags($otherInfo);
    $otherInfo =~ s/\&lt\;(.*?)\&gt\;//gis;
    $otherInfo =~ s/\[br\]/<br \/>/gis;


    my @row_arr = split(/\[tr\]/,$otherInfo);
    foreach my $row_arr(@row_arr)
      {

#This if loop is allowed to be executed just once for the first row which has the table heading as [question_button.gif] or [answer_button.gif] etc
        if ($flag == 0 && length($row_arr) > 0)                
          {
             @head_arr = split(/\[th\]/,$row_arr);  
#Splitting the the first row gives us the column type, if its a question, answer, etc. 
            foreach my $head_arr(@head_arr)
              {
                
                $len_arr++;
              }
            $flag = 1;
          }
        my @col_arr = split(/\[td\]/,$row_arr);
        for ($i = 0; $i < $len_arr; $i++)
          {
            if (length($col_arr[$i]) > 0)
              {
                         $arrange[$i] .= $col_arr[$i]; 

              }
          }   
      }
    for ($i = 0; $i < $len_arr; $i++)
      {
         if ($arrange[$i] =~ m/[1-9]/gis)
           {
       
           }
         else
           {
              $col_no_del .= $i.",";
           }
      }

    #$clean_stat =~ s/\r*\n*//gis;
    $clean_stat =~ s/\r\n/ /gis;
    $clean_stat =~ s/\r/ /gis;
    $clean_stat =~ s/\n/ /gis;
    $clean_stat =~ s/<tr[^>]*?>/<tr>/gis;
    my @col_no_del = split (/,/,$col_no_del);
    my @tr_cont = split(/<tr>/,$clean_stat);
    my $count = 0;
    my @elm_no;
    my $final_tab = "";
    my $wanted_cols = "";
    my $i = 0;
    my $term_while1 = 0;
    my $term_while2 = 0;    
    foreach my $col_no_del(@col_no_del)
      {
         if ($col_no_del > 4)
           {
             $elm_no[$i++] =  $col_no_del;
           }
      }
    foreach my $tr_cont(@tr_cont)
      {
         if ($tr_cont =~ m/<td>/gis || $tr_cont =~ m/<th>/gis)
           {
              $tr_cont = "<tr align=\"center\">".$tr_cont;
              my $count = 0;

              while ($tr_cont =~ m/(.*?<th>.*?<\/th>)/gis && $term_while1 < 100)
                {
                  my $flag = 0;                
                  ++$count;
                  $term_while1++;
                  foreach my $elm_no(@elm_no)
                    {
                      if ($count == $elm_no)
                        {
                          $flag = 1;
                        }

                    }
                  if ($flag == 1)
                    {
                           
                    }
                  else
                    {
                       $wanted_cols .= $1;
                    }
                }
              while ($tr_cont =~ m/(.*?<td>.*?<\/td>)/gis)
                {
                  my $flag = 0;
                  ++$count;
#                  $term_while2++;
                  foreach my $elm_no(@elm_no)
                    {
                      if ($count == $elm_no)
                        {
                          $flag = 1;
                        }

                    }
                  if ($flag == 1)
                    {
               
                    }
                  else
                    {
                       $wanted_cols .= $1;
                    }
                }
                     
                     $wanted_cols = $wanted_cols."</tr>";
           }
      }
    $final_tab .= $wanted_cols;
    return($final_tab);
  }


sub withinfosub
  {
    my $html_source_info = shift;
    my $qp_number = shift;

    my $stats_table = "";
    my $flag = 0;
    my @info_sub_level = split (/<ips>/,$html_source_info);
    foreach my $info_sub_level(@info_sub_level)
      { 
         
         if ($info_sub_level =~ m/<\/ips>/gis)
           {
              $info_sub_level = "<ips>".$info_sub_level;

              my $info_sub_heading = $info_sub_level;
              $info_sub_heading =~ s/<ips>(.*?)<\/ips>.*/$1/gis;
     
              if ($info_sub_heading =~ m/</g)
                {
                    $info_sub_heading = "Table";
                }
              elsif ( length($info_sub_heading) > 20)
                {
                     $info_sub_heading = substr($info_sub_heading,0,17);
                } 
  
#              my $count_question_open_tags = 0;
              $info_sub_level =~ s/<ips>(.*?)<\/ips>//gis;
              my $stats_temp = withoutinfosub($info_sub_level,$flag,$qp_number);
              #$stats_temp =~ s/\r*\n*//gis;
              
              $stats_temp =~ s/\r\n/ /gis;
              $stats_temp =~ s/\r/ /gis;
              $stats_temp =~ s/\n/ /gis;
              
              $stats_temp =~ s/(<table border=\"1\">)<tr([^>]*?><td>).*?<\/td>.*?<\/td>/$1\[tr$2<b>QP<\/b><td><b>Info Page Subheading<\/b><\/td>/gis;
#              $stats_temp =~ s/(<tr[^>]*?>\s*<td>.*?<\/td>)<td>(.*?)<\/td>/$1<td>$info_sub_heading<\/td>/gis;
              $stats_temp =~ s/(<tr[^>]*?>\s*<td>.*?<\/td>)<td>(.*?)<\/td>/$1<td>$info_sub_heading...<\/td>/gis;
              $stats_temp =~ s/\[tr/<tr/gis;
              $stats_temp =~ s/<step name=\"Show\/Hide Quiz Statistics\">//gis;
              $stats_temp =~ s/<\/step>//gis;                      
              $stats_table .= $stats_temp;
#              $flag = 1;
           }

      }
#    $stats_table = $stats_table."</table>             
#</body></html></step>";
    return ($stats_table);

  }



sub withoutinfosub
  {
    my $source_for_multi_ans = shift;
    my $flag = shift;
    my $qp_number = shift;
    
    my $count_ans_open = 0;
    my $count_ans_close = 0;
    my $count_multiple_ans_open = 0;
    my $count_multiple_ans_close = 0;
    my $count_alt_ans_open = 0;
    my $count_alt_ans_close = 0;
    my $htmlsource_count_tags = $source_for_multi_ans;
    my $qp_name;
    my @question_level = split (/<que>/,$source_for_multi_ans);
    $source_for_multi_ans =~ /(<|&lt;)qpname(>|&gt;)(.*?)(<|&lt;)\/qpname(>|&gt;)/gs;
    if (defined $3 && length $3 > 0)
      { 
        $qp_name = $3;
      }
    else
      {
        $qp_name = '-';
      }
    foreach my $question_level(@question_level)
      {
        if ($question_level =~ m/\w+/gis)
          {
             $question_level = "<que>".$question_level."</que>";
             my @count_mult_ans_open = split(/<out>/,$question_level);
             my $count_open = scalar(@count_mult_ans_open) - 1;
             my @count_mult_ans_close = split(/<\/out>/,$question_level);
             my $count_close = scalar(@count_mult_ans_close) - 1; 
             $count_multiple_ans_open += $count_open;
             $count_multiple_ans_close += $count_close; 
             if ($count_open >= 1)
               {
                 $count_ans_open++;
                 $count_multiple_ans_open--;
                 
               }
             elsif ($count_open == 0)
               {
                 $count_ans_open;
#                 $count_multiple_ans_open++;
               }
             if ($count_close >= 1)
               {
                 $count_ans_close++;
                 $count_multiple_ans_close--;
                 
               }
             elsif ($count_close == 0)
               {
                 $count_ans_close;
#                 $count_multiple_ans_close++;
               }
             
          }
      }

    my $count_question_open_tags = 0;
    while ($htmlsource_count_tags =~ /<inp>/g && $count_question_open_tags < 500)
      {
         $count_question_open_tags++;
      }
    my $count_question_close_tags = 0;
    while ($htmlsource_count_tags =~ /<\/inp>/g && $count_question_close_tags < 500)
      {
         $count_question_close_tags++;
      }
    my $count_altquestion_open_tags = 0;
    while ($htmlsource_count_tags =~ /<altinput>/g && $count_altquestion_open_tags < 500)
      {
         $count_altquestion_open_tags++;
      }
    my $count_altquestion_close_tags = 0;
    while ($htmlsource_count_tags =~ /<\/altinput>/g && $count_altquestion_close_tags < 500)
      {
         $count_altquestion_close_tags++;
      }
    my $count_output_open_tags = 0;
    while ($htmlsource_count_tags =~ /<alt>/g && $count_output_open_tags < 500)
      {
         $count_output_open_tags++;
      }
    my $count_output_close_tags = 0;
    while ($htmlsource_count_tags =~ /<\/alt>/g && $count_output_close_tags < 500)
      {
         $count_output_close_tags++;
      }
    my $count_explain_open_tags = 0;
    while ($htmlsource_count_tags =~ /<exp>/g && $count_explain_open_tags < 500)
      {
         $count_explain_open_tags++;
      }
    my $count_explain_close_tags = 0;
    while ($htmlsource_count_tags =~ /<\/exp>/g && $count_explain_close_tags < 500)
      {
         $count_explain_close_tags++;
      }
    my $count_hint_open_tags = 0;
    while ($htmlsource_count_tags =~ /<hnt>/g && $count_hint_open_tags < 500)
      {
         $count_hint_open_tags++;
      }
    my $count_hint_close_tags = 0;
    while ($htmlsource_count_tags =~ /<\/hnt>/g && $count_hint_close_tags < 500)
      {
         $count_hint_close_tags++;
      }

    my $count_option_open_tags = 0;
    while ($htmlsource_count_tags =~ /<option>/g && $count_option_open_tags < 500)
      {
         $count_option_open_tags++;
      }
    my $count_option_close_tags = 0;
    while ($htmlsource_count_tags =~ /<\/option>/g && $count_option_close_tags < 500)
      {
         $count_option_close_tags++;
      }

    $count_alt_ans_open = $count_output_open_tags; # - ($count_ans_open + $count_multiple_ans_open);
    $count_alt_ans_close = $count_output_close_tags; # - ($count_ans_close + $count_multiple_ans_open);
my $stats_table = "";
my $commentFlag = "<commentFlagOpen>";
if ($flag == 0 || $flag < 0)
  {
 
  }
$stats_table .= <<EOF;
<tr align="center"><td>$qp_number.</td><td>$qp_name</td>
EOF

    if ($count_question_open_tags == $count_question_close_tags)
      {
$stats_table .= <<EOF;
<td>$count_question_open_tags</td>
EOF
      }
    elsif($count_question_open_tags > 0 || $count_question_close_tags > 0)
      {
$stats_table .= <<EOF;
<td><font color="red">$count_question_open_tags,$count_question_close_tags</font></td>
EOF
$commentFlag .= "<Mis;;<:::>;;MatchTag=question>";
      }
    if ($count_ans_open == $count_ans_close)
      {
$stats_table .= <<EOF;
<td>$count_ans_open</td>
EOF
      }
    elsif($count_ans_open > 0 || $count_ans_close > 0)
      {
$stats_table .= <<EOF;
<td><font color="red">$count_ans_open,$count_ans_close</font></td>
EOF
$commentFlag .= "<Mis;;<:::>;;MatchTag=answer>";
      }
    if ($count_altquestion_open_tags == $count_altquestion_close_tags)
      {
$stats_table .= <<EOF;
<td>$count_altquestion_open_tags</td>
EOF
      }
    elsif($count_altquestion_open_tags > 0 || $count_altquestion_close_tags > 0)
      {
$stats_table .= <<EOF;
<td><font color="red">$count_altquestion_open_tags,$count_altquestion_close_tags</font></td>
EOF
$commentFlag .= "<Mis;;<:::>;;MatchTag=Alt:&&:question>";
      }
    if ($count_multiple_ans_open == $count_multiple_ans_close)
      {
$stats_table .= <<EOF;
<td>$count_multiple_ans_open</td>
EOF
      }
    elsif ($count_multiple_ans_open > 0 || $count_multiple_ans_close > 0)
      {
$stats_table .= <<EOF;
<td><font color="red">$count_multiple_ans_open,$count_multiple_ans_close</font></td>
EOF
$commentFlag .= "<Mis;;<:::>;;MatchTag=Mult&&&;Answer>";
      }
    if ($count_alt_ans_open == $count_alt_ans_close)
      {
$stats_table .= <<EOF;
<td>$count_alt_ans_open</td>
EOF
      }
    elsif ($count_alt_ans_open > 0 || $count_alt_ans_close > 0)
      {
$stats_table .= <<EOF;
<td><font color="red">$count_alt_ans_open,$count_alt_ans_close</font></td>
EOF
$commentFlag .= "<Mis;;<:::>;;MatchTag=alt&&&;Answer>";
      }
    if ($count_option_open_tags == $count_option_close_tags)
      {
$stats_table .= <<EOF;
<td>$count_option_open_tags</td>
EOF
      }
    elsif ($count_option_open_tags > 0 || $count_option_close_tags > 0)
      {
$stats_table .= <<EOF;
<td><font color="red">$count_option_open_tags,$count_option_close_tags</font></td>
EOF
$commentFlag .= "<Mis;;<:::>;;MatchTag=Choice>";
      }
    if ($count_explain_open_tags == $count_explain_close_tags)
      {
$stats_table .= <<EOF;
<td>$count_explain_open_tags</td>
EOF
      }
    elsif ($count_explain_open_tags > 0 || $count_explain_close_tags > 0)
      {
$stats_table .= <<EOF;
<td><font color="red">$count_explain_open_tags,$count_explain_close_tags</font></td>
EOF
$commentFlag .= "<Mis;;<:::>;;MatchTag=Explain>";
      }
    if ($count_hint_open_tags == $count_hint_close_tags)
      {
$stats_table .= <<EOF;
<td>$count_hint_open_tags</td>
EOF
      }
    elsif ($count_hint_open_tags > 0 || $count_hint_close_tags > 0)
      {
$stats_table .= <<EOF;
<td><font color="red">$count_hint_open_tags,$count_hint_close_tags</font></td>
EOF
$commentFlag .= "<Mis;;<:::>;;MatchTag=hint>";
      }
      
$commentFlag = $commentFlag."</commentFlagEnd>";

if ($flag < 0)
  {
$stats_table .= <<EOF;
</table>             
</table></body></html>
</step>
EOF
  }
$stats_table = $stats_table.$commentFlag;
return ($stats_table);
  }

sub createsectionset
  {
     my $sectioncontent = shift;
     my $section_with_tags = "";
     my $question_with_tags = "";
     my @section_arr = split(/<s_inst>/,$sectioncontent);
     foreach my $section_var(@section_arr)
       {           
         if ($section_var =~ /<que>/gis)
           {
#                $section_var =~ s/<\/s_inst>/<\/s_inst>/gis;               
              if ($section_var =~ s/<\/s_inst>/<\/s_inst>/gis) 
                {
                  $section_with_tags = "<s_inst>".$section_var;
                }
              else
                {
                  $section_with_tags = $section_var;
                }
              $question_with_tags .= createquestionset($section_with_tags);
            }
          else
            {
              $question_with_tags .= $section_var;
            }
        }    
      return ($question_with_tags);
  }

sub preamble
  {
    my $ques_prop = shift;

    my $count_probs = 0;
    my ($allpreamblecontents,$qpname,$input_caption,$output_caption,$explain_caption,$forward_inst_no_fi,$forward_inst,$reverse_inst_no_ri,$reverse_inst,$theory,$fixed_choices,$language,$ver_or_hori_flag,$marks,$passage);
    $ques_prop =~ s/\&lt\;/</gs;
    $ques_prop =~ s/\&gt\;/>/gs;
    if ($ques_prop =~ s/<pattern>(.*?)<\/pattern>//gis)
      {
        $ver_or_hori_flag = "<pattern>".$1."<\/pattern>";
      }
    
    if ($ques_prop =~ s/<s_inst>syvum=\"([^\"]*?)\"(.*?)<\/s_inst>(.*)/$3/sg)
      {
        $allpreamblecontents = $1;
        $allpreamblecontents =~ s/<\/rfmt>/<\/rfmt><alr>1<\/alr>/s;
      }
    if ($allpreamblecontents =~ /<lang>(.*?)<\/lang>/sg)
      {
         $language = $1;
 
      }

    if ($ques_prop =~ s/<inputCaption>(.*?)<\/inputCaption>//gis)
      {
        $input_caption = $1;
        $input_caption = "<inp>".$input_caption."</inp>";
      } 
    if ($ques_prop =~ s/<outputCaption>(.*?)<\/outputCaption>//gis)
      {
        $output_caption = $1;
        $output_caption = "<out>".$output_caption."</out>";   
      } 
    if ($ques_prop =~ s/<explainCaption>(.*?)<\/explainCaption>//gis)
      {
        $explain_caption = $1;
        $explain_caption = "<exp>".$explain_caption."</exp>";
      } 
    if ($ques_prop =~ s/<forwardinst>(.*?)<\/forwardinst>//gis)
      {
        $forward_inst = $1;
        $forward_inst = "<des>".$forward_inst."</des>";
      }
     if ($ques_prop =~ s/<reverseinst>(.*?)<\/reverseinst>//gis)
      {
        $reverse_inst = $1;
        $reverse_inst = "<rdes>".$reverse_inst."</rdes>";
      }

    if ($ques_prop =~ s/<quickref>(.*?)<\/quickref>//gis)
      {
        $theory = $1;
        $theory = "<quickref>".$theory."</quickref>";
      }
    if ($ques_prop =~ s/<mrk>(.*?)<\/mrk>//sg)
      {
        my $mrk = $1; 
        my $dis_mks = "";
        if ($allpreamblecontents =~ /<dmarks>(.*?)<\/dmarks>/sg)
          {
            $dis_mks = $1;
          }
        $marks = "<totmrk perq=\"\" dis=\"$dis_mks\">".$mrk."</totmrk>";
      }
    else
      {
        my $dis_mks = "";
        if ($allpreamblecontents =~ /<dmarks>(.*?)<\/dmarks>/sg)
          {
            $dis_mks = $1;
          }
        $marks = "<eachmrk perq=\"\" dis=\"$dis_mks\"></eachmrk>";
      }  
    if ($ques_prop =~ s/<choice>(.*)<\/choice>//gis)
      {
        $fixed_choices = "<fixedchoice><choice>".$1."</choice></fixedchoice>";      }  
    if ($ques_prop =~ s/<psg>(.*)<\/psg>//gis)
      { 
        my $paspos = "";
        my $passcont = $1;
        
        if ($allpreamblecontents =~ s/<psg( [^>]*?)><\/psg>//sg)
          {
            $paspos = $1;
            $paspos =~ s/=/=\"/s;
            $paspos = $paspos."\"";
          }
        else
          {
            $paspos = " p=\"top\"";
          }  
        if ($passcont =~ /<variablesetting[^>]*?>/gs || $passcont =~ /vr\.gif/gs)
          {
            $count_probs++;
            my ($problet,$question,$answer,$puzzles_cont) = eachproblet ($passcont,$count_probs);
            $passcont = $puzzles_cont.$problet;
          }  
        $passage = "<psg$paspos>".$passcont."</psg>";
      } 
    $allpreamblecontents = "<prm>".$allpreamblecontents.$input_caption.$output_caption.$explain_caption.$forward_inst_no_fi.$forward_inst.$reverse_inst_no_ri.$reverse_inst.$theory.$fixed_choices.$ver_or_hori_flag.$marks."</prm>".$passage.$ques_prop;
    return ($allpreamblecontents,$count_probs);
  }



sub createquestionset
  {
    
    my $questioncontent = shift;
    
    my $answer_add_tags;
    my $question_add_tags = "";
    my $qset_with_preamble = "";
    my $fixed_choices = "";
    my $sect_inst = "";
    my $count_theme = 1;
    my $same_theme_question = 0;
    my $questioncount = 0;
    my $totalmarks = 0;
    my $totmarks_disp = "";
    my $term_while = 0;
    my $count_probs = 0;
    my $eachmark = 0;
    while ($questioncontent =~ /<inp>/sg && $term_while < 500)
      {
        $questioncount++;
        $term_while++;
      }
    if ($questioncontent =~ /<alt>/gs)
      {
        my $term_while = 0;
        $questioncontent =~ s/<\/inp>/\{\[\/inp\]\}/gis;   #For alternate answers 
                                                           #([^(<\/input>)] not matching
        while ($questioncontent =~ /<inp>([^\{\[]*?)<alt>/gs && $term_while < 500)
          {
            $questioncontent =~ s/<inp>([^\{\[]*?)<alt>/<inp>$1\{\[\/inp\]\}<inp>/gsi;
            $term_while++;
          }
        $questioncontent =~ s/\{\[\/inp\]\}/<\/inp>/gis;
        
      }
  
    
    if ($questioncontent =~ /<ips>/gis)
      {
        $questioncontent =~ s/(<ips>.*?)<que>/<que>$1/gis;
#        $questioncontent =~ s/<question>(.*?<\/infosubheading>)/$1<question>/gis;        
        my @question_arr = split (/<que>/,$questioncontent);
        my $term_while = 0;
        foreach my $question_var(@question_arr)
          {

             if ($question_var =~ /<inp>/gis)
               {
                 
                 while ($question_var =~ /<marks>(.*?)<\/marks>/gs && $term_while < 500)
                   {
                     $eachmark = $1;
                     $eachmark =~ s/\W*//gs;
                     $eachmark =~ s/\s*//gs;
                     $eachmark =~ s/[^\d]*(\d*).*/$1/gs;
                     $totalmarks += $eachmark;
                     $term_while++;
                   }
                 $question_var = "<que>".$question_var;
                 $question_var =~ s/<que>(.*?<\/ips>)/$1<que>/gis;
                
                 if ($question_var =~ s/<\/ips>\s*<que>/<\/ips><que t=\"$count_theme\">/gis)
                   {

                     $count_theme++;
                     $same_theme_question = $count_theme - 1;
                   }
                 else
                   {
                     $question_var =~ s/<que>/<que t=\"$same_theme_question\">/gis;
                   }
                 $question_var =~ s/(<p><\/p>)*$//gis;
                 $question_add_tags = $question_var."</que>"; 
                 $answer_add_tags .= MultipleAltAnswer($question_add_tags);
              }
            else
              {
                ($qset_with_preamble,$count_probs) = preamble($question_var);                            
                $answer_add_tags .= $qset_with_preamble;

              }
          } 

       }
     else
       {
         my $start_format = "";
         my $end_format = "";
         my $term_while = 0;
         my @question_arr = split (/<que>/,$questioncontent);
         foreach my $question_var(@question_arr)
           {
             
             if ($question_var =~ m/<inp>/gis)
               {
                 $start_format = $question_var;
                 if ($start_format =~ /<mrk>\s*(\W*)\s*\d+(\s*\w*\s*\W*)\s*<\/mrk>/)
                   {
                     $start_format = $1;
                     $end_format = $2;
                   }

                 $end_format =~ s/<mrk>\s*.*([^\d]*)\s*<\/mrk>/$1/s;
                 
                 while ($question_var =~ /<mrk>(.*?)<\/mrk>/gs && $term_while < 500)
                   {
                     $eachmark = $1;
                     $eachmark =~ s/\W*//gs;
                 #    $eachmark =~ s/\w*//gs;
                     $eachmark =~ s/\s*//gs;
                     $eachmark =~ s/[^\d]*(\d*).*/$1/gs;
                      
                     $totalmarks += $eachmark;
                      
                     $term_while++;
                   }
                 
                 
                 $question_var =~ s/(<p><\/p>)*$//gis;
                 $question_add_tags = "<que>".$question_var."</que>"; 
                 pos ($question_add_tags) = 0;

                 if ($question_add_tags =~ m/<variablesetting[^>]*?>/gis || $question_add_tags =~ m/<vr\.gif\"/gis)
                   {
                     pos ($question_add_tags) = 0;
                     if ($question_add_tags =~ m/<variablesetting[^>]*?>/gis)
                       {
                         $count_probs++;
                       }
                     my ($problet,$question,$answer,$puzzles_cont) = eachproblet ($question_add_tags,$count_probs);
                     $question_add_tags = "<que><inp>".$problet.$question."</inp>".$answer.$puzzles_cont;
                   }
                 $answer_add_tags .= MultipleAltAnswer($question_add_tags);
                 
               }
             else
               {
                 ($qset_with_preamble,$count_probs) = preamble($question_var,$count_probs);
                 $answer_add_tags .= $qset_with_preamble;
                 
               }
           }
          $totmarks_disp = $start_format.$totalmarks.$end_format; 
          
        }

      if ($answer_add_tags =~ /<totmrk([^>]*?)>(.*?)<\/totmrk>/sg)
        {
          my $attribute = $1;
          my $totmkspre = $2;
          my $start_format = "";
          my $end_format = "";
          
          $start_format = $totmkspre;
          if ($start_format =~ /^\s*(\W*)\s*\d+(\s*\w*\s*\W*)\s*$/)
            {
              $start_format = $1;
              $end_format = $2;
            }
         
          if ($attribute =~ /dis=\"total\"/is || $attribute =~ /dis=\"individual\"/is || $attribute =~ /dis=\"\"/is)
            {
              
              if ($totalmarks > 0)
                {
                  my $preq = $totalmarks / $questioncount;
                  $preq = $start_format.$preq.$end_format;
                  $answer_add_tags =~ s/<totmrk perq=\"\"/<totmrk perq=\"$preq\"/s;
                  $answer_add_tags =~ s/<totmrk([^>]*?)>(.*?)<\/totmrk>/<mrk$1>$totalmarks<\/mrk>/gs;
                }
              else
                {
                  $totmkspre =~ s/\W*//gs;
                  $totmkspre =~ s/\s*//gs;
                  $totmkspre =~ s/[^\d]*(\d*).*/$1/gs;
                  my $preq = $totmkspre / $questioncount;
                  $preq = $start_format.$preq.$end_format;
                  if ($attribute =~ /dis=\"\"/is && $totmkspre > 0)
                    {
                      $answer_add_tags =~ s/(<totmrk perq=\"\" )dis=\"\"/$1dis=\"Total\"/s;
                    }
                  $answer_add_tags =~ s/<totmrk perq=\"\"/<totmrk perq=\"$preq\"/s;
                  $answer_add_tags =~ s/<totmrk([^>]*?)>(.*?)<\/totmrk>/<mrk$1>$2<\/mrk>/gs;
                }    
            }
        }
      elsif ($answer_add_tags =~ /<eachmrk([^>]*?)><\/eachmrk>/sg)
        {
                  
          my $attribute = $1;
          if ($attribute =~ /dis=\"total\"/is || $attribute =~ /dis=\"individual\"/is || $attribute =~ /dis=\"\"/is)
            {
              if ($totalmarks > 0)
                {
                  my $preq = $totalmarks / $questioncount;
                  if ($attribute =~ /dis=\"\"/is)
                    {
                      $answer_add_tags =~ s/(<eachmrk perq=\"\" )dis=\"\"/$1dis=\"Individual\"/s;
                    }
                  $answer_add_tags =~ s/<eachmrk perq=\"\"/<eachmrk perq=\"$preq\"/s;
                  $answer_add_tags =~ s/<eachmrk([^>]*?)>(.*?)<\/eachmrk>/<mrk$1>$totmarks_disp<\/mrk>/gs;
                }
              else
                {
                  $answer_add_tags =~ s/<eachmrk([^>]*?)>(.*?)<\/eachmrk>//gs;
                }    
            } 
        }
 #     if ($answer_add_tags =~ s/(<psg [^>]*?>)//gis)
 #       {
#          my $position = $1;
#          $position = lc($position);
#          $answer_add_tags =~ s/<psg>/$position/gis;
#        }   
      $answer_add_tags = "\n<qset>".$answer_add_tags."\n<\/qset>";
      $fixed_choices = "";
      return ($answer_add_tags);
     
   }

sub permInternalUsers
  {
    my $userID  = shift;

    my $pub_flag = 0;
    
    if ($userID eq "yogesh" || $userID eq "ushenoy" || $userID eq "mayaushenoy" || $userID eq "sshenoy" || $userID eq "vyankateshkanvinde" || $userID eq "sheetal26")
      {
        $pub_flag = 1;
      }
    return ($pub_flag);
  }


#sub infosubheading
#  {
        
#  }
sub MultipleAltAnswer
  {
    my $i = 0;
    my $add_mult_ans;
    my $multiple_answer = shift;
#    my $contans; 
    
#    if ($multiple_answer =~ m/<CONTRIBOUT>(.*?)<\/CONTRIBOUT>/gis)
#      {
#        $contans = $1;
#        if (defined $contans && length $contans == 0)
#          {
#             $multiple_answer =~ s/<CONTRIBOUT>//gis;
#             $multiple_answer =~ s/<\/CONTRIBOUT>//gis;
#          } 
#      }  
        
    #print $multiple_answer;
    $add_mult_ans = $multiple_answer;

    $add_mult_ans =~ s/<out>/<ans><out>/gis;                     #1
    $add_mult_ans =~ s/<\/out>/<\/out><\/ans>/gis;               #2
    $add_mult_ans =~ s/<\/ans>\s*(<br \/>)*\s*<alt>/<out>/gis;         #3
    $add_mult_ans =~ s/<\/alt>\s*(\u0020)*( )*(\u00A0)*(<br \/>)*( )*(\u00A0)*(\u0020)*\s*<alt>/<\/out><out>/gis;  #4
    $add_mult_ans =~ s/<\/alt>/<\/out><\/ans>/gis;                  #5 

    $add_mult_ans =~ s/<alt>/<\/out><out>/gis; 
    
    #=================== Contrib Answers 18_07_09 ============================
    
    $add_mult_ans =~ s/<CONTRIBOUT>/<out>/gis; 
    $add_mult_ans =~ s/<\/CONTRIBOUT>/<\/out>/gis; 
    
    #=========================== End =========================================
    
    
    return($add_mult_ans);

# 1. Converts all the <output> tags to <answer><output> 
# 2. Converts all the </output> tags to </output></answer>. The alternate answers are assigned the <alt> tag
# 3. As we have to get the alternate answers within the </answer> tag we convert all the </answer><alt> tags to <output> tag.  
# 4. All the </alt> if followed by another <alt> tag is converted to </output><output> which comes within the same <answer> tag.
# 5. The last </alt> tag is coverted to </output></answer>. Eg : <answer><output>Answer1</output><output>Alternate answer</output></answer>.
  }

sub convertToDocument
  {
    my $otherInfo = shift;    
    
    my @head_arr;
    my $i;
    my $flag = 0;
    my $arrange;
    my $len_arr;
    my $arrange_1;
    my $head_question = "";
    my $head_answer = "";
    my $head_explain = "";

    $otherInfo =~ s/.*?(<img src=\"(http:\/\/[^\/]*)?\/s_i\/v[qaeh]\.gif.*)/$1/gis;  
    $otherInfo = "<table id=\"temp\" border=\"1\"> <tbody> <tr> <th>".$otherInfo;
    $otherInfo =~ s/(\s*<br \/>\s*)*$//gis;  
    $otherInfo =~ s/\t*//gis;
    $otherInfo =~ s/<style> html,body\{border\:0px\;\}p\{margin-top\:0px\;margin\-bottom\:2px\;\}<\/style>//gis;
    $otherInfo =~ s/\r*\n*//gis;
    $otherInfo =~ s/<\/tr>//gsi;

    $otherInfo =~ s/<tr>/\[tr\]/gis;
    $otherInfo =~ s/<br\s?\/?>/\[br\]/gis;
    $otherInfo =~ s/<tr><td.*?>/\n\[tr\]/gis;
    $otherInfo =~ s/<th.*?>/\[th\]/gis;
    $otherInfo =~ s/<td.*?>/\[td\]/gis;
    $otherInfo =~ s/<img src=\"(http:\/\/[^\/]*)?\/s_i\//\/s_i\//gis;   
    

    if ($otherInfo =~ s/\/s_i\/vq\.gif\"(.*?)>(.*?)\/s_i\/vqc\.gif\"(.*?)>\s*(<\/p>)*/[question_button\.gif]/gis)
      {
         $head_question = $2;
      }
    if ($otherInfo =~ s/\/s_i\/va\.gif\"(.*?)>(.*?)\/s_i\/vac\.gif\"(.*?)>\s*(<\/p>)*/[answer_button\.gif]/gis)
      {
         $head_answer = $2;
      }
    if ($otherInfo =~ s/\/s_i\/ve\.gif\"[^>]*?>(.*?)\/s_i\/vec\.gif\"[^>]*?>\s*(<\/p>)*/[explain_button\.gif]/gis)
      {
         $head_explain = $1;
      }
    $otherInfo =~ s/\/s_i\/vc\.gif\"(.*?)>(.*?)\/s_i\/vcc\.gif\"(.*?)>\s*(<\/p>)*/[choice_button\.gif]/gis;
    $otherInfo =~ s/\/s_i\/vh\.gif\"(.*?)>(.*?)\/s_i\/vhc\.gif\"(.*?)>\s*(<\/p>)*/[hint_button\.gif]/gis;

    $otherInfo = removehtmltags($otherInfo);
    
    $otherInfo =~ s/\&lt\;(.*?)\&gt\;//gis;
    $otherInfo =~ s/\[br\]/<br \/>/gis;

#print "HTMLSRC-->".$otherInfo."<--HTMLSRC";
    my @row_arr = split(/\[tr\]/,$otherInfo);
    for (my $j = 1; $j < scalar @row_arr; $j++)
      {
#This if loop is allowed to be executed just once for the first row which has the table heading as [question_button.gif] or [answer_button.gif] etc
        if ($flag == 0)                
          {
             @head_arr = split(/\[th\]/,$row_arr[$j]);  
#Splitting the the first row gives us the column type, if its a question, answer, etc. 
            foreach my $head_arr(@head_arr)
              {
                $head_arr =~ s/[^\[]*?(\[[^\]]*?\]).*/$1/gs;
                #$head_arr =~ s/\s*//gs;
                $len_arr++;
              }
            $flag = 1;
          }
        my @col_arr = split(/\[td\]/,$row_arr[$j]);
        for ($i = 1; $i < $len_arr; $i++)
          {
            if (length($col_arr[$i]) > 0)
              {
                $arrange .= "\#".$head_arr[$i].$col_arr[$i]."\/".$head_arr[$i];  
              }
          }   
      }
    #$arrange =~ s/\s*<br\s*\/>\s*//gs;
    #$arrange =~ s/||(.*?)//gis;

    $arrange =~ s/\#\[question_button\.gif\]/<q\.gif\"\/>/gis;
    $arrange =~ s/\/\[question_button\.gif\]/<qc\.gif\"\/>/gis;
    $arrange =~ s/\#\[answer_button\.gif\]/<a\.gif\"\/>/gis;
    $arrange =~ s/\/\[answer_button\.gif\]/<ac\.gif\"\/>/gis;
    $arrange =~ s/\#\s*\[explain_button\.gif\]/<e\.gif\"\/>/gis;
    $arrange =~ s/\/\s*\[explain_button\.gif\]/<ec\.gif\"\/>/gis;
    $arrange =~ s/\#\[choice_button\.gif\]/<c\.gif\"\/>/gis;
    $arrange =~ s/\/\[choice_button\.gif\]/<cc\.gif\"\/>/gis;
    $arrange =~ s/\#\[hint_button\.gif\]/<h\.gif\"\/>/gis;
    $arrange =~ s/\/\[hint_button\.gif\]/<hc\.gif\"\/>/gis;

    $arrange =~ s/\[(.*?)\.gif\]//gis;
    $arrange =~ s/\#\s*\///gis;
#    $arrange =~ s/\/s_i\/is.gif\"[^>]*?>/<is\.gif\"\/>/gis;
#    $arrange =~ s/\/s_i\/isc.gif\"[^>]*?>/<isc\.gif\"\/>/gis;
    if (length($head_question) > 0)
      {
        $head_question = "<inputCaption>$head_question</inputCaption>";
      }
    if (length($head_answer) > 0)
      {
        $head_answer = "<outputCaption>$head_answer</outputCaption>";
      }
    if (length($head_explain) > 0)
      {
        $head_explain = "<explainCaption>$head_explain</explainCaption>";
      }
    $arrange = $head_question.$head_answer.$head_explain.$arrange;

    return($arrange);
  }
#Sub routine for making a string short on 17.12.08 by SMP

#sub shortString
#{
#  my $string = shift;
#  my $length = shift;

#  my $shortstring = "";
#  pos ($string) = 0;

#  $string = substr($string,0,$length );
#  if ($string =~ m/</g)
#    {
#      $shortstring = "Table";
#    }
#  else
#    {
#      $shortstring = $string;
#    }

#  $shortstring .= "...";
#  return ($shortstring);
#}

sub customize
  {

    my $table_ref = shift;

    my %table = %$table_ref;
    my $text_box_filename ="";
    my $text_box_desc = "";
    my $text_box_title = "";
    my $doc = "";
    my $xmlText = "";
    my $keywords = "";
    my $author = "";
    my @qset_arr = "";
    my @loadtabname = "";
    my $i = 0;
    my $tdffile = 0;
    my $text = "";
    my $tab_var = 1;
    if (length($table{file}) > 0)
      {
        my $infoformat = "";
        if ($table{infoformat} eq "table")
          {
            $infoformat = "table";
          }
        if ($table{infoformat} eq "list")
          {
            $infoformat = "list";
          }
        if ($table{infoformat} eq "text")
          {
            $infoformat = "text";
          }
        if ($table{infoformat} eq "blank")
          {
            $infoformat = "blank";
          }
        $table{file} =~ s/\.(.*)$//gis;
        my $ppath = $table{file}.".html";   # path to file after info/online_data
        my $fullpath_draft = $ENV{DOCUMENT_ROOT};
        my $path = $fullpath_draft."/../info/online_data/users/".$ppath;  # complete path to file
        my ($out_string, $status) = Syvum::Online::Sal::getData($path, $ppath,undef, 0,"$infoformat");
        $text_box_filename = $table{file};
        $text_box_desc = $table{desc};
        @qset_arr = $out_string;
 #      opendraft();
        if ($status != Apache2::Const::OK)
          {
print <<EOF;
<html><body>
<script>alert("This file does not exist.");
history.back(-1);
</script>
EOF
          }
        else
          {
            print "request successful";
          }
      }
    else
      {
print <<EOF;
<html><body>
<script>
alert ("Please enter the file name.");
history.back(-1);
</script>
</body></html>
EOF
      }
    opendraft($text_box_title,$text_box_filename,$text_box_desc,$keywords,$author,\@loadtabname,\@qset_arr,$tdffile,$text,$tab_var,"");
#opendraft();
  }

sub savehtml
  {
    my $table_ref = shift;
    my $flag = shift;
    my $save_pub_flag = shift;
    my $DB_flag = shift;
    
    my %table = %$table_ref;    
    my $htmlfiletext = $table{elm1};
    my $ad_div = "";
    my $doc_length = 0;
    
    if ($htmlfiletext !~ /<link rel=\"stylesheet\" href=\"\/saw\/jscripts[^>]*?><\/head>/g)
      {
        $htmlfiletext =~ s/<\/head>/<link rel=\"stylesheet\" href=\"\/saw\/jscripts\/saws\/themes\/advanced\/css\/editor_content.css\" type=\"text\/css\" \/><\/head>/gs;
      }
    if ($htmlfiletext !~ /<\!-- addtopbar -->/g)
      {
        $htmlfiletext =~ s/<body>/<body><!-- addtopbar --><!-- adddirbar -->/gs;
        $htmlfiletext =~ s/<\/body>/<!-- adddirbar --><!-- addbotbar --><\/body>/gs; 
      }
   else
      {
        $htmlfiletext =~ s/<!-- addtopbar -->//gs;
        $htmlfiletext =~ s/<!-- adddirbar -->//gs;
        $htmlfiletext =~ s/<!-- addbotbar -->//gs;
        
        $htmlfiletext =~ s/<body>/<body><!-- addtopbar --><!-- adddirbar -->/gs;
        $htmlfiletext =~ s/<\/body>/<!-- adddirbar --><!-- addbotbar --><\/body>/gs;
      }  

    #if ($htmlfiletext !~ /<div[^>]*?>\s*<!-- insertContentAd -->\s*<\/div>/g)
    #  {      
    #    $htmlfiletext =~ s/<!-- insertContentAd -->//gsi;
    #    $doc_length = int (length ($htmlfiletext) / 2);
    #    my $half_doc = substr ($htmlfiletext,$doc_length);
    #    my $nearest_p_pos = index ($half_doc,'<p>','1');
    #    #print "Posi".$nearest_p_pos."End";
    #    my $p_replace_pos = $doc_length + $nearest_p_pos;
    #    substr $htmlfiletext, $p_replace_pos,'3','<div style=”display:block;margin: 5px 5px 5px 5px;”><!-- insertContentAd --></div><p>';
    #  }   
   # if ($htmlfiletext !~ /<\!-- insertContentAd -->/g)
   #    {   
   #      substr $htmlfiletext, index($htmlfiletext, '<p>', '1'), '<!-- insertContentAd --><p>';
   #    }   
      
    
    
    
    $table{file} = $table{file}.".html";
#---Expression for blip on mouseover & step on click----   
#    $htmlfiletext =~ s/<img src=\"(http:\/\/[^\/]*)?\/s_i\/hs\.gif\" title=\"(.*?)\"[^>]*>/<step name=\"$2\">/gis;
#    $htmlfiletext =~ s/<img src=\"(http:\/\/[^\/]*)?\/s_i\/hsc\.gif\"[^>]*>/<\/step>/gis;

    $htmlfiletext =~ s/<img src=\"(http:\/\/[^\/]*)?\/s_i\/hs\.gif\"\s*syvum=\"blip\"\s*title=\"Mouseover - ([^\"]*)\"[^>]*\/>(.*?)<img src=\"(http:\/\/[^\/]*)?\/s_i\/hsc\.gif\"\s*syvum=\"blip\"[^>]*\/>/<a href=\"http:\/\/www\.syvum\.com\" onmouseover=\"return escape(\'$3\'); this\.T_ABOVE=true\; this\.T_BGCOLOR=\'white\'\; this\.T_DELAY=50\; this\.T_WIDTH=150\; this\.T_FONTFACE=\'arial\'\;\">$2<script language=\"javascript\" src=\"\/users\/praful\/editor\/blip.js\"><\/script><\/a>/gis;

    $htmlfiletext =~ s/<img src=\"(http:\/\/[^\/]*)?\/s_i\/hs\.gif\"\s*syvum=\"step\"\s*title=\"Click - ([^\"]*)\"[^>]*\/>\s*/<step name=\"$2\">/gis;
    $htmlfiletext =~ s/\s*<img src=\"(http:\/\/[^\/]*)?\/s_i\/hsc\.gif\"[^>]*\/>/<\/step>/gis;   
#-------------------------------------------------------
    $htmlfiletext =~ s/<img src=\"(http:\/\/[^\/]*)?\/s_i\/au\.gif\" title=\"(\w{1})\w*\"[^>]*>/<tts l=\"$2\">/gis;
    $htmlfiletext =~ s/<img src=\"(http:\/\/[^\/]*)?\/s_i\/auc\.gif\"[^>]*>/<\/tts>/gis; 
    
    #`echo '$htmlfiletext' >>/tmp/testfiles.txt`;
    $htmlfiletext =~ s/<img src=\"(http:\/\/[^\/]*)?\/s_i\/me\.gif[^>]*?>/<encrypt>/gis;
    
    $htmlfiletext =~ s/<img src=\"(http:\/\/[^\/]*)?\/s_i\/mec\.gif[^>]*?>/<\/encrypt>/gis;
   #print $htmlfiletext;
   # $htmlfiletext = "<title_doc>$table{name}<\/title_doc><filename>$table{file}<\/filename><desc>$table{desc}</desc><keyword_adv_prop>$table{keywords}</keyword_adv_prop><author>$table{author_name}</author>".$htmlfiletext;
   
    if ($DB_flag == 0)
      {
        my $fullpath_draft = $ENV{DOCUMENT_ROOT};
        $fullpath_draft =~ s/([^\/]*?)$//;
        $fullpath_draft .= "info/online_data";
        my $fullpath_draft_html = $fullpath_draft.$table{file};
  
        open OFILEHTML,">$fullpath_draft_html";
        print OFILEHTML "$htmlfiletext";
        close (OFILEHTML);
        my $text_box_filename = $table{file};
        my $text_box_desc = $table{desc};
        if ($flag == 1 || $save_pub_flag == 2)
          {
            if ($save_pub_flag == 2)
              {
                print "HTML File Saved & Publish.";
              }
            else
              {
                print "HTML File Saved.";
              }
          }
        elsif ($flag == 0)
          {
            print "Title, Keywords and Description are mandatory.";
            exit(0);
          }
      }
    else
      {
        iodb::savefiledataDB (\%table,$htmlfiletext,"",2,"");
      }  
  }

sub shortString
  {}

sub documentimage
  {
    my $text = shift;
    
    my $input_doc;
    my $output_doc;
    my $explain_doc;
    my $hint_doc;
    my $ans_pos_doc;
    my $out_tts;
    my $in_tts;
    my $ansPos = 0;
    my $show_clues = "";
    my $count_output;
    my $option_doc;
    my $temp;
    my $format = "";
    my $rformat = "";
#    my ($rmatch, $rmult, $rhang);
    my $rmatch;
    my $rmult;
    my $rhang;
    my $rflash;
    my $rfill;
    my $qmatch;
    my $qmult;
    my $qhang;
    my $qflash;
    my $qfill;
    my $qjumble;
    my $doc;
    my $author;
    my $text_box_title;
  #  if ($text !~ /<\/input>/gis)
  #    {
        $text = convertbadfile($text);
       
  #    }
#    if ($text =~ /<format(s)?>(.*?)<\/format(s)?>//gi) 
#      {
        #$format = "<fmt>".$2."</fmt>";
      pos ($text) = 0;
      if ($text =~ s/<formats>(.*?)<\/formats>//gi)
        {
          $format = "<fmt>".$1."</fmt>";
        }
      elsif ($text =~ s/<format>(.*?)<\/format>//g)
        {
          if ($text =~ s/<salfile>([^\.]*?)\..*?<\/salfile>//gi)
            {
              $format = "<fmt>".$1."</fmt>";
            }
        }    
#---------------QUIZ -------------------------------------------------------------
#      }
# ---------REVERSE QUIZ -------------------

    if ($text =~ s/<rformat(s)?>(.*?)<\/rformat(s)?>//gis) 
      {
        $rformat = "<rfmt>".$2."</rfmt>";
      } 
    if ($text =~ s/(<input_tts>.*?<\/input_tts>)//gis)
      {
        $in_tts = $1;
      }
    if ($text =~ s/(<output_tts>.*?<\/output_tts>)//gis)
      {
        $out_tts = $1;
      }
    if ($text =~ s/<author>(.*?)<\/author>//gis)
      {
        $author = "<author>$1</author>";
      }
    if ($text =~ s/<tdfshowclues>1<\/tdfshowclues>//gis)
      {
        $show_clues = "<tsc>1</tsc>";
      }
    my $qpattri = $format.$rformat.$in_tts.$out_tts.$show_clues;
    $qpattri =~ s/</&lt;/gs;
    $qpattri =~ s/>/&gt;/gs;
    $temp .= "<p><img src=\"http:\/\/scripts.syvum.com\/s_i\/qp.gif\" syvum=\"$qpattri\" title=\"Question-set Properties\" /><img src=\"http:\/\/scripts.syvum.com\/s_i\/qpc.gif\" title=\"End Question-set Properties\" /><\/p>";
    if ($text =~ s/<title>(.*?)<\/title>//gi)
      {                   
        $text_box_title = "<title_doc>$1</title_doc>";
      }                  
    if ($text =~ s/<heading>(.*?)<\/heading>//gi) 
      {
        $temp .= "<p><img src=\"http:\/\/scripts.syvum.com\/s_i\/th.gif\" title=\"Top Heading\" />"."$1"."<img src=\"http:\/\/scripts.syvum.com\/s_i\/thc.gif\" title=\"End Top Heading\" /><\/p>"
      }
    if ($text =~ s/<description>(.*?)<\/description>//gi) 
      {
        $temp .= "<p><img src=\"http:\/\/scripts.syvum.com\/s_i\/fi.gif\" title=\"Forward Instruction\" />"."$1"."<img src=\"http:\/\/scripts.syvum.com\/s_i\/fic.gif\" title=\"End Forward Instruction\" /></p>"; 
      }
    if ($text =~ m/<rdescription>(.*?)<\/rdescription>/gi)
      {
        $temp .= "<p><img src=\"http:\/\/scripts.syvum.com\/s_i\/ri.gif\" title=\"Reverse Instruction\" />"."$1"."<img src=\"http:\/\/scripts.syvum.com\/s_i\/ric.gif\" title=\"End Reverse Instruction\" /></p>";
      }
    my @set = split(/<input>/,$text);
    foreach my $set(@set)
      {
        $count_output = 0;
        $set = "<input>"."$set";
        if ($set =~ m/<input>(.*?)<\/input>/gsi)
          {
            $input_doc ="<p>&nbsp\;</p><p><img src=\"http:\/\/scripts.syvum.com\/s_i\/q.gif\" title=\"Question\" />"."$1"."<img src=\"http:\/\/scripts.syvum.com\/s_i\/qc.gif\" title=\"End Question\" /></p>";
          }
        my @output_arr = split(/<output>/,$set);
        foreach my $output_var(@output_arr)
          {
            $output_var = "<output>"."$output_var";
            if ($output_var =~ m/<output>(.*?)<\/output>/gsi)
              {
                if ($count_output == 0)
                  {
                    $output_doc .= "<p><img src=\"http:\/\/scripts.syvum.com\/s_i\/a.gif\" title=\"Answer\" />"."$1"."<img src=\"http:\/\/scripts.syvum.com\/s_i\/ac.gif\" title=\"End Answer\" /><\/p>";
                    $count_output = $count_output + 1;
                  }
                else
                  {
                    $output_doc .= "<p><img src=\"http:\/\/scripts.syvum.com\/s_i\/aa.gif\" title=\"Alternative Answer\" />"."$1"."<img src=\"http:\/\/scripts.syvum.com\/s_i\/aac.gif\" title=\"End Alternative Answer\" /><\/p>";
                  }
              }                                  
          }
        pos($set) = 0;
        if ($set =~ m/<explain>(.*?)<\/explain>/gsi)
          {
            $explain_doc = "<p><img src=\"http:\/\/scripts.syvum.com\/s_i\/e.gif\" title=\"Explanation\" />"."$1"."<img src=\"http:\/\/scripts.syvum.com\/s_i\/ec.gif\" title=\"End Explanation\" /></p>";
          }
        pos($set) = 0;
        if ($set =~ m/<hint>(.*?)<\/hint>/gsi)
          {
            $hint_doc = "<p><img src=\"http:\/\/scripts.syvum.com\/s_i\/h.gif\" title=\"Hint\" />"."$1"."<img src=\"http:\/\/scripts.syvum.com\/s_i\/hc.gif\" title=\"End Hint\" /></p>";
          }
        pos($set) = 0;
        if ($set =~ s/<optionsOrder>(.*?)<\/optionsOrder>//gsi)
          {
            $ansPos = $1;
            $ansPos++;
            $ans_pos_doc = "<p><img src=\"http:\/\/scripts.syvum.com\/s_i\/ap.gif\" title=\"Answer Position\" />"."$ansPos"."<img src=\"http:\/\/scripts.syvum.com\/s_i\/apc.gif\" title=\"End Answer Position\"></p>";
          }
        my @option_arr = split(/<option>/,$set);
        foreach my $option_var(@option_arr)
          {
            $option_var = "<option>"."$option_var";
            if ($option_var =~ /<option>(.*?)<\/option>/gsi)
              {
                $option_doc .= "<p><img src=\"http:\/\/scripts.syvum.com\/s_i\/c.gif\" title=\"Choice\" />"."$1"."<img src=\"http:\/\/scripts.syvum.com\/s_i\/cc.gif\" title=\"End Choice\" /><\/p>";
              }
          }              
        $doc .= "$input_doc"."$output_doc"."$option_doc"."$explain_doc"."$hint_doc"."$ans_pos_doc"; 

        $option_doc = "";
        $output_doc = "";
        $explain_doc = "";
        $hint_doc = "";
        $ans_pos_doc = "";
        $input_doc = "";
      } 
    $doc = "<tdf>".$author.$text_box_title.$temp.$doc."<\/tdf>";
    return($doc);
  }

sub convertbadfile
  {
    my $content = shift;
    $content =~ s/\n*//gis;
    $content =~ s/\s*$//gis;
    $content =~ s/<input>/\{\[input\]\}/gis;
    $content =~ s/<output>/\{\[output\]\}/gis;
    $content =~ s/<option>/\{\[option\]\}/gis;
    $content =~ s/<explain>/\{\[explain\]\}/gis;
    $content =~ s/<hint>/\{\[hint\]\}/gis;
    $content =~ s/<optionsOrder>/\{\[optionsOrder\]\}/gis;
    $content =~ s/<arrange>/\{\[arrange\]\}/gis;
    #$content =~ s/<salfile>/\{\[salfile\]\}/gis;
    $content =~ s/\{\[([^\]]*)\]\}([^\{]*)/\{\[$1\]\}$2\{\[\/$1\]\}/gis;
    $content =~ s/\{\[/</gis;
    $content =~ s/\]\}/>/gis;
    return($content);
  }


sub counttagstdf
  {
    my $text = shift;
     
    my $count_ans_open = 0;
    my $count_ans_close = 0;
    my $count_multiple_ans_open = 0;
    my $count_multiple_ans_close = 0;
    my $count_alt_ans_open = 0;
    my $count_alt_ans_close = 0;
    my $htmlsource_count_tags = $text;
    my $count_question_open_tags = 0;
    while ($htmlsource_count_tags =~ /<input>/gis && $count_question_open_tags < 200)
      {
         $count_question_open_tags++;
      }
    my $count_question_close_tags = 0;
    while ($htmlsource_count_tags =~ /<\/input>/gis && $count_question_close_tags < 200)
      {
         $count_question_close_tags++;
      }
    my $count_answer_open_tags = 0;
    while ($htmlsource_count_tags =~ /<output>/gis && $count_answer_open_tags < 200)
      {
         $count_answer_open_tags++;
      }
    my $count_answer_close_tags = 0;
    while ($htmlsource_count_tags =~ /<\/output>/gis && $count_answer_close_tags < 200)
      {
         $count_answer_close_tags++;
      }
    my $count_output_open_tags = 0;
    while ($htmlsource_count_tags =~ /<alt>/gis && $count_output_open_tags < 200)
      {
         $count_output_open_tags++;
      }
    my $count_output_close_tags = 0;
    while ($htmlsource_count_tags =~ /<\/alt>/gis && $count_output_close_tags < 200)
      {
         $count_output_close_tags++;
      }
    my $count_explain_open_tags = 0;
    while ($htmlsource_count_tags =~ /<explain>/gis && $count_explain_open_tags < 200)
      {
         $count_explain_open_tags++;
      }
    my $count_explain_close_tags = 0;
    while ($htmlsource_count_tags =~ /<\/explain>/gis && $count_explain_close_tags < 200)
      {
         $count_explain_close_tags++;
      }
    my $count_hint_open_tags = 0;
    while ($htmlsource_count_tags =~ /<hint>/gis && $count_hint_open_tags < 200)
      {
         $count_hint_open_tags++;
      }
    my $count_hint_close_tags = 0;
    while ($htmlsource_count_tags =~ /<\/hint>/gis && $count_hint_close_tags < 200)
      {
         $count_hint_close_tags++;
      }

    my $count_option_open_tags = 0;
    while ($htmlsource_count_tags =~ /<option>/gis && $count_option_open_tags < 200)
      {
         $count_option_open_tags++;
      }
    my $count_option_close_tags = 0;
    while ($htmlsource_count_tags =~ /<\/option>/gis && $count_option_close_tags < 200)
      {
         $count_option_close_tags++;
      }

    $count_alt_ans_open = $count_answer_open_tags - $count_question_open_tags; 
    $count_answer_open_tags = $count_answer_open_tags - $count_alt_ans_open;
    $count_alt_ans_close = $count_answer_close_tags - $count_question_close_tags; 
    $count_answer_close_tags = $count_answer_close_tags - $count_alt_ans_close;
my $stats_table = "";
$stats_table .= <<EOF;
<step name="Show/Hide TDF Statistics"><html><body>
<table border="1">
<tr align="center"><td><b>Tag Names=></b></td><td><b>Questions</b></td><td><b>Answers</b></td>
EOF

    if ($count_alt_ans_open > 0 || $count_alt_ans_close > 0)
      {
$stats_table .= <<EOF;
<td><b>Alternate Answers</b></td>
EOF
      }
    if ($count_option_open_tags > 0 || $count_option_close_tags > 0)
      {
$stats_table .= <<EOF;
<td><b>Choices</b></td>
EOF
      }
    if ($count_explain_open_tags > 0 || $count_explain_close_tags > 0)
      {
$stats_table .= <<EOF;
<td><b>Explanations</b></td>
EOF
      }
    if ($count_hint_open_tags > 0 || $count_hint_close_tags > 0)
      {
$stats_table .= <<EOF;
<td><b>Hints</b></td></tr>
EOF
      }
$stats_table .= <<EOF;
<tr align="center"><td><i>Open</i></td>
EOF
    if ($count_question_open_tags > 0 || $count_question_close_tags > 0)
      {
$stats_table .= <<EOF;
<td>$count_question_open_tags</td>
EOF
      }
    if ($count_answer_open_tags > 0 || $count_answer_close_tags > 0)
      {
$stats_table .= <<EOF;
<td>$count_answer_open_tags</td>
EOF
      }
    if ($count_alt_ans_open > 0 || $count_alt_ans_close > 0)
      {
$stats_table .= <<EOF;
<td>$count_alt_ans_open</td>
EOF
      }
    if ($count_option_open_tags > 0 || $count_option_close_tags > 0)
      {
$stats_table .= <<EOF;
<td>$count_option_open_tags</td>
EOF
      }
    if ($count_explain_open_tags > 0 || $count_explain_close_tags > 0)
      {
$stats_table .= <<EOF;
<td>$count_explain_open_tags</td>
EOF
      }
    if ($count_hint_open_tags > 0 || $count_hint_open_tags > 0)
      {
$stats_table .= <<EOF;
<td>$count_hint_open_tags</td>
EOF
      }
$stats_table .= <<EOF;
</tr><tr align="center"><td><i>Close</i></td>
EOF
    if ($count_question_open_tags > 0 || $count_question_close_tags > 0)
      {
$stats_table .= <<EOF;
<td>$count_question_close_tags</td>
EOF
      }
    if ($count_answer_open_tags > 0 || $count_answer_close_tags > 0)
      {
$stats_table .= <<EOF;
<td>$count_answer_close_tags</td>
EOF
      }
    if ($count_alt_ans_open > 0 || $count_alt_ans_close > 0)
      {
$stats_table .= <<EOF;
<td>$count_alt_ans_close</td>
EOF
      }
    if ($count_option_open_tags > 0 || $count_option_close_tags > 0)
      {
$stats_table .= <<EOF;
<td>$count_option_close_tags</td>
EOF
      }
    if ($count_explain_open_tags > 0 || $count_explain_close_tags > 0)
      {
$stats_table .= <<EOF;
<td>$count_explain_close_tags</td>
EOF
      }
if ($count_hint_open_tags > 0 || $count_hint_open_tags > 0)
      {
$stats_table .= <<EOF;
<td>$count_hint_close_tags</td>
EOF
      }
$stats_table .= <<EOF;
</tr>
</table>             
</body></html></step>
EOF
return ($stats_table);
  }


sub opendraft
  {
#  my $arr_ref = shift;
#  my @loadtabname = @$arr_ref;
#    my $text_box_title = shift;
#    my $text_box_filename = shift;
#    my $text_box_desc = shift;
#    my $keywords = shift;
#    my $author = shift;
    my $text_box_title = shift;
    my $text_box_filename = shift;
    	 
    my $filedisplay = $text_box_filename;                 #filename in text box without extension
    $filedisplay =~ s/\.(.*)$//gis;                      #regular exp for removing .txt and .xml
    
    my $head = shift;
    
    my $loadtabname_ref = shift;

    my @loadtabname = @$loadtabname_ref;
    my $qset_arr_ref = shift;

    my @qset_arr = @$qset_arr_ref;

    my $tdffile = shift;
    my $text = shift;
#    my $n_tabs = shift;
    my $tab_var = shift;
    my $stats_table = shift;
    
    my $showdirlistingflag = shift;
    my $dirlisting = shift;
    my $openfileflag = shift;
    my $alldirs = shift;
    my $allfiles = shift;
    my $dirlist = shift;
    my $db_0r_files = shift;
    my $dir = shift;
    my $cont_folder = shift;
    my $XmlContent = shift;
    my $ref_table = shift;
    my %table = %$ref_table;
    
    
    my $userID = $table{userID};
    #($userID = $ENV{QUERY_STRING}) =~ s/^\/u\/([^\/]*).*/$1/;
    my $pub_flag = 0;
    
    if ($userID eq "yogesh" || $userID eq "ushenoy" || $userID eq "mayaushenoy" || $userID eq "sshenoy" || $userID eq "vyankateshkanvinde" || $userID eq "sheetal26")
      {
        $pub_flag = 1;
      }
    
    
    #`echo '$head' >>/tmp/testfile.txt`;
    my $hostName = $ENV{HTTP_HOST};
    my $javascript_true_path = "";

    if (defined $hostName && $hostName =~ /charlie|192\.168\.1\.2/)
      {
        $javascript_true_path = "\/users\/praful";
      }
    if ($showdirlistingflag == 1)
      {  
        $dirlisting = "/users/".$dirlisting;
        $dirlisting = listingmodule::dirlisting($dirlisting,$javascript_true_path);
        $dirlisting .= ":";
      }  

    my $saveIntoInfo = $dir;
    $saveIntoInfo =~ s/repac\;\-\%3E\;\%3C\-\;kFiles//gs;
    $saveIntoInfo =~ s/repac\;\-\>\;<\-\;kFiles//gs;
    $saveIntoInfo =~ s/versioning//gs;
    $saveIntoInfo =~ s/insertTemplate//gs;
    $saveIntoInfo = 'Folder : www.syvum.com'.$saveIntoInfo;
    #$saveIntoInfo =~ s/\/u\///gs;
    #$saveIntoInfo =~ s/\// > /gs;
    #$saveIntoInfo = "Save into -> ".$saveIntoInfo;
#defaulttab();

    for (my $no_tab = 1; $no_tab <= $tab_var; $no_tab++)
      {
        if (length($loadtabname[$no_tab-1]) == 0)
          {
             $loadtabname[$no_tab-1] = "Tab $no_tab";
          }
      }
#    $tdffile = $loadtabname[14];
    use Syvum::Online::AddSteps;
    $stats_table = Syvum::Online::AddSteps::performSteps($stats_table);
#    print "$stats_table";
    my $main_title = "";
    my $currheader = "ACTIVITY EDITOR";
    my $status = 1;
    my $actheader = io::topHeader($currheader,$userID,$status);

    if (length($text_box_title) > 0)
      {
         $main_title = $text_box_title." -";
      }
 print <<EOF;
 
<html>
<head>
<title>$main_title Activity Editor - Syvum Authoring Wizard </title>
<style>
a  {cursor: pointer; }

</style>
<!-- SAWS -->
<script type="text/javascript" src="/saw/tabs_new.js"></script>
<script type="text/javascript" src="/saw/folder_tree_struct.js"></script>
<script type="text/javascript" src="/saw/SatFunction_Editor.js"></script>
<script type="text/javascript" src="/saw/jscripts/saws/saws_gzip.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/saw/diff_match_patch.js"></SCRIPT>
<script type="text/javascript">
var userID = $pub_flag;

SAWs_GZ.init({
	plugins : 'equation,custom,style,advhr,advimage,advlink,preview,media,searchreplace,print,contextmenu,paste,fullscreen,fullpage,visualchars, template,spellchecker,qset_property,anspos,fontdd,tabledd,noneditable',
	themes : 'advanced',
	languages : 'en',
	disk_cache : false,
	debug : false
});
</script>
<script language="javascript" type="text/javascript">
	var init_fold_path = "/users";
	InitializeEditor(init_fold_path);
	function fileBrowserCallBack(field_name, url, type, win) {
		// This is where you insert your custom filebrowser logic
		alert("Example of filebrowser callback: field_name: " + field_name + ", url: " + url + ", type: " + type);

		// Insert new URL, this would normaly be done in a popup
		win.document.forms[0].elements[field_name].value = "someurl.htm";
	}
function InitializeEditor(curr_fold_path)
  {
    curr_fold_path = "/cgi/online/serve.cgi" + curr_fold_path + "/";
    //alert (curr_fold_path);
    SAWs.init({
		mode : "exact",

EOF
    my $elements = "";
    for (my $count_elm = 1; $count_elm <= $tab_var; $count_elm++)
      {
         $elements .= "elm$count_elm,";
      }
print <<EOF;
                elements : "$elements",
		theme : "advanced",
		plugins : "equation,custom,style,advhr,advimage,advlink,preview,media,searchreplace,print,contextmenu,paste,fullscreen,fullpage, template,spellchecker,qset_property,anspos,fontdd,tabledd,noneditable,nbspfix",
		//theme_advanced_buttons1_add_before : "newdocument,separator",
             	//theme_advanced_buttons1_add : "fontselect,fontsizeselect",
		theme_advanced_buttons2_add :"print,spellchecker", //"help",
		theme_advanced_buttons2_add_before: "undo,redo,|,cut,copy,paste",
	       	theme_advanced_buttons3 : "question_properties,question,answer,choice,explain,hint,altq,alt,fixed_passage,auto_format,anspos",
		theme_advanced_toolbar_location : "top",
		theme_advanced_toolbar_align : "left",
		theme_advanced_path_location : "bottom",
		auto_resize : false, 
		external_link_list_url : "/saw/examples/example_link_list.js",
		external_image_list_url : "/saw/examples/example_image_list.js",
		flash_external_list_url : "/saw/examples/example_flash_list.js",
		media_external_list_url : "/saw/examples/example_media_list.js",
		template_external_list_url : "/saw/examples/example_template_list.js",
		file_browser_callback : "fileBrowserCallBack",
		theme_advanced_resize_horizontal : false,
		theme_advanced_resizing : true,
                theme_advanced_path : false,
                nonbreaking_force_tab : true,
                convert_fonts_to_spans : true,
                button_tile_map : true, 
                cleanup : true,                
                cleanup_on_startup : true,
                fix_table_elements : true,
                valid_elements : "" +"+a[href|hreflang|target|type|name|title],"
+"-affiliation,"
+"-blockquote[title],"
+"body[bgcolor|title|text],"
+"br[title],"
+"-center[title],"
+"-div[align<center?justify?left?right|class|id|style|title],"
+"-em/i[title],"
+"-encrypt,"
+"-serves,"
+"-nopeople,"
+"-font[color|face|id|size|style|title],"
+"-h1[align<center?justify?left?right|title],"
+"-h2[align<center?justify?left?right|title],"
+"-h3[align<center?justify?left?right|title],"
+"-h4[align<center?justify?left?right|title],"
+"-h5[align<center?justify?left?right|title],"
+"-h6[align<center?justify?left?right|title],"
+"head,"
+"hr[align<center?left?right|color|noshade<noshade|size|title|width|height],"
+"html[version],"
+"img[align<bottom?left?middle?right?top|alt|border"
+"|src|class|rtol|syvum|style|title|width|height],"
+"-li[style|title|type],"
+"-meta[content|http-equiv],"
+"-ol[class|title|type],"
+"p[align<center?justify?left?right|style|title],"
+"pre[style|id],"
+"-span[align<center?justify?left?right|style|title|class],"
+"-strong/b[style|title],"
+"-style[title|type],"
+"-sub[style|title],"
+"-sup[style|title],"
+"-table[id|align<center?left?right|bgcolor|border|cellpadding|cellspacing|class|frame|rules|syvum"
+"|height|style|title|width],"
+"tbody[align<center?char?justify?left?right|style|title"
+"|valign<baseline?bottom?middle?top],"
+"td[d<sh|align<center?char?justify?left?right|bgcolor|class"
+"|colspan|headers|height|nowrap<nowrap|rowspan"
+"|style|title|valign<baseline?bottom?middle?top|width],"
+"tfoot[align<center?char?justify?left?right|style|title"
+"|valign<baseline?bottom?middle?top],"
+"-th[d<sh|align<center?char?justify?left?right|bgcolor|class|colspan|rowspan|height|nowrap<nowrap"
+"|style|title|valign<baseline?bottom?middle?top|width],"
+"thead[align<center?char?justify?left?right|style|title"
+"|valign<baseline?bottom?middle?top],"
+"title,"
+"-tr[d<sh|align<center?char?justify?left?right|bgcolor|rowspan|style|id"
+"|title|valign<baseline?bottom?middle?top],"
+"-tt[style|title],"
+"-u[style|title],"
+"-ul[style|title|type]",
                 document_base_url : curr_fold_path,
                 noneditable_noneditable_class : "mceNonEditable", 
                 noneditable_leave_contenteditable : true,
                 apply_source_formatting : true,
                 entity_encoding : "raw",
                 verify_html : true,
                 convert_urls : false,
                 relative_urls : true,
                 submit_patch : true,
                 spellchecker_languages : "+English=en,French=fr,German=de,Italian=it,Portuguese=pt,Spanish=es",
		 spellchecker_report_mispellings : true

	});

  }  	
</script>
<script language="javascript">
//document.write('<style type="text/css">.tabber{display:none;}<\/style>');
function display()
{
 var win = window.open("/saw/jscripts/saws/plugins/custom/syvum_output_format.html","_blank","Input/Output Format Property", "toolbar=no, menubar=no, personalbar=no, width=880, height=600, scrollbars=no, resizable=no"); 
}
// function for viewing the quiz,info page,XML page and index
function openwin()
{
 var name_file = document.getElementById('file').value;
 /*if (name_file=="")
 {
  alert('Please enter filename');
  exit();
 }*/

 var view_value = document.getElementById('format').value;
 if (name_file == "")
   {
     alert ("Please enter the file name");
     exit();
   }
 if (view_value == "quiz")
   {
     var slash = new RegExp("^\/");
     if (slash.test(name_file))
       {
         var file = "http://$ENV{HTTP_HOST}/cgi/online/serve.cgi" + name_file + ".tdf"; 
       }
     else
       {
         var file = "http://$ENV{HTTP_HOST}/cgi/online/serve.cgi/users/" + name_file + ".tdf"; 
       }
     window.open(file); 
   }
 else if (view_value == "infopage")
   {
     var slash = new RegExp("^\/");       
     if (slash.test(name_file))
       {
         var file = "http://$ENV{HTTP_HOST}/cgi/online/serve.cgi" + name_file + ".html"; 
       }
     else
       {
         var file = "http://$ENV{HTTP_HOST}/cgi/online/serve.cgi/users/" + name_file + ".html";
       } 
     window.open(file); 
   }
 else if (view_value == "xml")
   {
     var file = "http://$ENV{HTTP_HOST}/users/" + name_file + ".xml"; 
     window.open(file); 
   }
 else if (view_value == "html")
   {
     var file = "http://$ENV{HTTP_HOST}/users/" + name_file + ".txt"; 
     window.open(file); 
   }
 else if (view_value == "index")
   {
     var slash = new RegExp("^\/");
     
     if (slash.test(name_file))
       {
         var file = "http://$ENV{HTTP_HOST}/cgi/editor/quickindex.pl?" + name_file; 
       }
     else
       {
         var file = "http://$ENV{HTTP_HOST}/cgi/editor/quickindex.pl?/users/" + name_file; 
       }
     window.open(file,"_parent"); 
   }
}


/*function to add a new tab */
var syvum_selected_tab = 1;
shown_tab_contents[syvum_selected_tab] = 1;
var num_tabs = 1;
function addTab()
{
 var  tabname = prompt("Enter Tab Name :","");
if (tabname)
{
  num_tabs++;
  document.getElementById('tab_menu').innerHTML += '<span id = "syvum_'+num_tabs + '_tab_span" onClick = "toggleTab(' + num_tabs + ')" style = "cursor:pointer;background:white;border:1px solid maroon;font-family:arial;font-size:80%;color:maroon;"><b>'+ tabname + '</b></span> ';

  document.getElementById('tab_container').innerHTML +=  '<div id = "syvum_' + num_tabs + '_tab" style = "display:none;"><textarea id = "elm'+num_tabs+'" name = "elm'+num_tabs+'" rows = "20" cols = "80" style = "width: 100%"> </textarea></div>';
toggleTab(num_tabs);
   
var id = 'elm'+ num_tabs;
add(id);

}

}


/* function to convert textarea into saw */
function add(cId)
{
  
 SAWs.execCommand('mceAddControl', true, cId);
 SAWs.execCommand('mceFocus',true,id);

}

var templateTimer;
var templateCont;
function setTemplateCont()
{
  SAWs.setContent(templateCont);
  clearInterval(templateTimer);
}

function loadEditorImgTemplate()
  {
    templateCont = window.opener.document.getElementById("templateContent").value;
    if (navigator.appName == "Microsoft Internet Explorer")
      {
        templateTimer = setInterval("setTemplateCont()", 2000);
      }
    else
      {
        SAWs.setContent(templateCont);
      }
    document.getElementById('titleDocProp').value = window.opener.document.getElementById("title").value;
    document.getElementById('keysDocProp').value = window.opener.document.getElementById("keywords").value;
    document.getElementById('descDocProp').value = window.opener.document.getElementById("description").value;
  }
function loadeditorcont()
  {
    //alert (document.getElementById("pathindex").value);
    get();
    //var tinycont = SAWs.getContent();
    //var head = document.getElementById("problettable").value;
    //var body = document.getElementById("allorgcont").value; 
    //document.getElementById("problettable").value = "";
    //document.getElementById("allorgcont").value = "";
    //tinycont = tinycont.replace(/\\r*\\n*/gim,"");
    //tinycont = tinycont.replace(/<head>(.*?)<\\/head>/,"<head>"+ head +"</head>");
    //tinycont = tinycont.replace(/<body>(.*?)<\\/body>/,"<body>"+ body +"</body>");
    //document.getElementById('elm1').value = SAWs.setContent(tinycont);
  }
function loadtabname()
{
EOF
   for (my $no_tabs = 1; $no_tabs <= $tab_var; $no_tabs++)
     {
print <<EOF;
//var tab$no_tabs = document.getElementById("tab$no_tabs").value;
//document.getElementById("syvum_span_$no_tabs").innerHTML = "<b>&nbsp;"+tab$no_tabs+"&nbsp;</b>"; 
EOF
     }  
print <<EOF;
}


//------------------------- AJAX save ---------------------------------------------------------

function formData2QueryString(docForm,task)
  {
     //top.document.getElementById("IndexUpdate").value = "PleaseUpdateIndex";
     //alert ('formData2QueryString');
     
     var currentDate = new Date();
     var day = currentDate.getDate()
     var month = currentDate.getMonth()
     month = ++month;
     var year = currentDate.getFullYear()
     var hours = currentDate.getHours()
     var minutes = currentDate.getMinutes()
     if (minutes < 10)
     minutes = "0" + minutes;
     
     var date = hours + ':' + minutes + ' '+ day + '/' + month + '/' +year;
     document.getElementById('clientDateTime').value = date;
document.getElementById('currentIndexContent').value = document.getElementById('currentIndexContent').innerHTML;
     var URL_path = document.getElementById("db_or_files").value;
     var boundary = "pZZ67xaBcZ21f09;0;UioP8";
     if ((document.getElementById("file").value).length == 0)
       {
         alert ("Please enter a filename.");
         return;  
       }
     if (document.getElementById("db_or_files").value == "sat.cgi")
       {
         alert ('The file will not be saved. Please save the file in "ffms.cgi".');
         exit(0);
       }
     if (document.getElementById("file").value.match(/\\W+/g))
       {  
         alert ("Only Alphabets, Numbers and Underscore characters are allowed in a File Name. \\nChoose a directory from the Index on left.");
       }
     else
       {  
         //alert ('else')
         document.getElementById("savingfilewait").style.visibility = "visible";
         if (task == "popup")
           {
             SAWs.execInstanceCommand('mce_editor_0','mceFullPageProperties');
             document.getElementById("saveflag").value = "1";
             task = "";
           }
         document.getElementById("elm1").value = SAWs.getContent();
         var editorcont = document.getElementById("elm1").value;
         var strSubmit = '';
         var formElem;

         var strLastElemName = '';
         
        if (task == "savepublish")
          {
            //alert ('task => savepub')
            document.getElementById("ajax").value = "savepublish";   
            task = "SavePublish"; 
          }
        else
          {
            //alert ('task => save')
            document.getElementById("ajax").value = "true";
            task = "Save";
          }
         for (i = 0; i < docForm.elements.length; i++) 
           {
             formElem = docForm.elements[i];
             
             switch (formElem.type) 
               {
                   // Text, select, hidden, password, textarea elements
               
                 case 'text':
                 case 'textarea':
                 case 'select-one':
                 case 'hidden':
                 case 'password':
                 strSubmit += formElem.name + '=' + escape(encodeURIComponent(formElem.value)) + '&';
                 break;
               }
           }
         strSubmit += 'SaveInThisFolder=' + escape(encodeURIComponent(document.getElementById('pathindex').value)) + '&';    
         strSubmit = '--' + boundary + '\\n\\n' + strSubmit;
         strSubmit += '\\n\\n--' + boundary + '\\n\\n' + editorcont;
         document.getElementById("ajax").value = "false";
         
         xmlhttpPost(URL_path, strSubmit,boundary);
       }
  }

 function xmlhttpPost(strURL, strSubmit,boundary) 
   {
      //alert ('xmlhttpPost');

      var xmlHttpReq = false;
      strURL += "?savefile";  
      // IE
      if (window.ActiveXObject) 
        {
          xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP");
        }
      // Mozilla/Safari
      else if (window.XMLHttpRequest) 
        {
          xmlHttpReq = new XMLHttpRequest();
          xmlHttpReq.overrideMimeType('text/xml');
        }
        //alert (strURL);
        xmlHttpReq.open('POST', strURL, true);
        xmlHttpReq.setRequestHeader("Content-type", "multipart/form-data;boundry="+boundary);
        xmlHttpReq.setRequestHeader("Content-length", strSubmit.length);
        xmlHttpReq.setRequestHeader("Connection", "close");
        xmlHttpReq.onreadystatechange = function() 
          {
             //alert (xmlHttpReq.status); 
             if (xmlHttpReq.readyState == 4 && xmlHttpReq.status == 200) 
               {

                 //alert('status=>200 and readystate=>4');
                  var result = xmlHttpReq.responseText;
                  //prompt("",result);

                  document.getElementById("savingfilewait").style.visibility = "hidden";
                  if (result == "Title, Keywords and Description are mandatory.")
                    {
                      alert (result);
                      var doc = "";
                      var task = "popup"; 
                      formData2QueryString(doc,task);
                    }
                  else if (result == "No permission for this directory.")
                    {
                      alert (result);
                    }                   
                  else if (result == "Please enter a valid file name.")
                    {
                      alert (result);
                    }
                  else if (result == "You--Are--Not--Allowed--To--Make--Change")
                    {
                      alert ("You are not allowed to edit this file.");
                    }  
                  else if (result.match(/ConfirmWriteOtherUsers/))
                    {
                      result = result.replace(/.*?:;;::;;:/,"");
                      result = "'" + result + "'"
                     //var conf_write = confirm("Are you sure you want to write the file to " + result + "/ folder");
                     //if (conf_write)
                     //  {
                         document.getElementById("pathdelete").value = "allowoverwrite";
                         formData2QueryString(document.forms['rte1'],'savedraft');
                     //  } 
                    // else
                     //  {
                       
                    //   }  
                   } 
                 else if (result == "Please check.")
                    {
                      //alert (result);
                       var answer = confirm("Overwrite an existing file ?");
                       if (answer)
                         {
                           var full_path = "";
                           if (!(document.getElementById("file").value).match(/\\//))
                             {
                               if (document.getElementById("folderpathsaving").value.length > 0)
                                 {
                                   if (document.getElementById("db_or_files").value == "satdb.cgi")
                                     {
                                       document.getElementById("folderpathsaving").value = document.getElementById("folderpathsaving").value.replace (/\\/\$/gm,"");
                                     }
                                   full_path = document.getElementById("folderpathsaving").value + "/" + document.getElementById("file").value;
                                   
                                 }
                               else
                                 {
                                   full_path = document.getElementById("file").value;
                                 }
                             }
                           else 
                             {
                               full_path = document.getElementById("file").value;
                             }      
                           //full_path = full_path.replace(/^\\/users(\\/)?/,"");
                           document.getElementById("checkoverwrite").value = full_path;
                           formData2QueryString(document.forms['rte1'],'savedraft');
                         }
                       else
                       {
                         document.getElementById("savingfilewait").style.visibility = "hidden";
                       }  
                    }
                 else
                   {
                     var array = new Array();
                     result = result.replace(/\\n*\\r*/gm,"");
                     result = result.replace(/.*?<;;;junkinfront;;;>/gm,"");
                     array = result.split(/\;delimi\;/);
                     document.getElementById("pathdelete").value = "";
                     if (array[0] == "File has been saved. " || array[0] == "File has been saved, no ipf found. ")
                       {
                         if (array[0] == "File has been saved. ")
                           {
                             document.getElementById("stats_table_afterSave").innerHTML = array[1];
                             javascript:popup(array[4],array[0],array[1]);
                           }
                         else if (array[0] == "File has been saved, no ipf found. ")
                           {
                             javascript:popup(array[4],array[0],array[1]);
                           }   
                         
                         document.getElementById("tablestats1").innerHTML = "";
                         //document.getElementById("tdfcontent").style.display = "";
                        // document.getElementById("tdfcontent").value = array[2];
                         
                         //document.getElementById("indexcontentfortxtversion").value = array[5];
                         // if (array[3].match(/<;;;newupdates;;;>/gm))
                          // {
                         //    array[3] = array[3].replace(/.*?<;;;newupdates;;;>/gm,"");
                         //   document.getElementById("listing").innerHTML = array[3];               
                          // }  
                         //document.getElementById("indexdiv").value = "showindexcont";
                         //get();
                       }
                     else if (array[0] == "File has been saved & publish. " || array[0] ==  "HTML File Saved & Publish." || array[0] ==  "Recipe saved & publish")
                       {
                         document.getElementById('rte2').submit();
                       }
                     else if (array[0] == "HTML File Saved.")
                       {
                         javascript:popup(array[4],array[0],'');
                         //document.getElementById("indexdiv").value = "showindexcont";
                         //get();
                       }  
                     else if (array[0] == "Recipe saved")
                       {
                         javascript:popup(array[4],array[0],'');
                         //document.getElementById("indexdiv").value = "showindexcont";
                         //get();
                        // javascript:poptastic('http://$ENV{HTTP_HOST}/saw/savedpopup.html');
                         //alert (array[0]);
                       }
                     else if (array[0] == "puzzle saved")
                       {
                         javascript:popup(array[4],array[0],'');
                         //document.getElementById("indexdiv").value = "showindexcont";
                         //get();
                       }  
                     else if (array[0] == "check path")
                       {
                         alert ("The file has not been saved, please check the path.");
                       }  
                     else if (array[0].match(/<;error;>/))
                       {
                         array[0] = array[0].replace(/\\n*\\r*/gm,"");
                         array[0] = array[0].replace(/<;error;>.*/gm,"");
                         alert(array[0]);
                       }
                     if (array[0] != "check path" || !array[0].match(/<;error;>/))
                       {
                         //folderUpdateTreeStruct(array[5]);
                         //alert (top.document.getElementById('indexcont').innerHTML);
                         //document.getElementById("indexcont").value = top.document.getElementById('indexcont').innerHTML;
                         //if (array[2] == 1)
                         //  {
                         //    alert (document.getElementById('pathindex').value);
                             //window.opener.document.getElementById('indexcont').innerHTML = array[5];
                         //  }
                         //else
                         //  {   
                         //alert(document.getElementById('SaveAsAgain').value); 
                           
                           //alert (id);
                         // prompt ("",window.opener.top.document.getElementById('indexcont').innerHTML);
                         // alert (window.opener.top.rte.indexcont);
                           
                             //window.opener.document.getElementById("IndexUpdate").
                             //prompt ("",array[5]);
                             //if (top.document.getElementById("IndexUpdate").value == "PleaseUpdateIndex")
                           //    {
                                 //folderUpdateTreeStruct(array[5]);
                                 //window.opener.document.getElementById("IndexUpdate").value = "";
                          //     }
                         //  }      
                       }
                     if (window.opener)
                       {
                         window.opener.top.document.getElementById('indexcont').innerHTML = document.getElementById('indexContent').value;
                         window.opener.top.document.getElementById('idForRefresh').value  = document.getElementById('pathindex').value;
                         window.opener.top.document.getElementById('refreshIndex').click(); 
                       }
                     else
                       {
                         //alert ("The Index in the File Manager will not be updated. As it has been closed or has got refreshed.");
                       }  
                   }
               }
             else if (xmlHttpReq.readyState == 4
                      && (xmlHttpReq.status > 200 || xmlHttpReq.status < 200))
               {
                 var numberOfSaves = document.getElementById('noOfSaves').value;
                 if (numberOfSaves <= 9)
                   {
                     //document.getElementById('save').click();
                     numberOfSaves++;
                     document.getElementById('noOfSaves').value = numberOfSaves;
                     document.getElementById('save').click();  
                     //alert (numberOfSaves); 
                   }
                 else if (numberOfSaves > 9)
                   {
                     var saveFurther = confirm('Due to some network problem file could not be saved. Do you want to try saving this file ?');
                     if (saveFurther) 
                       {
                         document.getElementById('noOfSaves').value = 0;
                         document.getElementById('save').click();
                       }
                     else
                       {
                         xmlHttpReq.abort();
                         document.getElementById("savingfilewait").style.visibility = "hidden";
                       }
                   }
                 //xmlHttpReq.abort();
                 //document.getElementById("savingfilewait").style.visibility = "hidden";
               }
          }
         //    prompt("",strSubmit);
        xmlHttpReq.send(strSubmit);
   }


//------------------------- AJAX openfile -------------------------------------------------


   var http_request = false;
   function makeRequest(url, parameters) 
    {
     
     // prompt("",parameters);
      
      http_request = false;
      if (window.XMLHttpRequest) 
        { // Mozilla, Safari,...
          http_request = new XMLHttpRequest();
          if (http_request.overrideMimeType) 
            {
         	// set type accordingly to anticipated content type
                //http_request.overrideMimeType('text/xml');
              http_request.overrideMimeType('text/html');
           }
         } 
       else if (window.ActiveXObject) 
         { // IE
           try 
             {
               http_request = new ActiveXObject("Msxml2.XMLHTTP");
             }
           catch (e) 
             {
               try 
                 {
                    http_request = new ActiveXObject("Microsoft.XMLHTTP");
                 } 
               catch (e) {}
             }
          }
        if (!http_request) 
          {
            alert('Cannot create XMLHTTP instance');
            return false;
          }
        http_request.onreadystatechange = alertContents;
        http_request.open('POST', url, true);
        http_request.send(parameters);
     }

   function alertContents() 
     {
       if (http_request.readyState == 4) 
         {
           if (http_request.status == 200) 
             {
             // prompt ("",http_request.responseText);
                result = http_request.responseText;
                //alert ("fromGet"+result);
                //prompt("",result);
                if (result == "The entered file name is INVALID")
                  {
                    alert (result);
                  }
                else if (result == "Please enter a valid filename without extension")
                  {
                    alert (result);
                  }  
                else if (result == "Please enter the file name which has to be opened")
                  {
                    alert (result);
                  }
                else if (result == "ConfirmDelete")
                  {
                    var conf_del = confirm ("Are you sure you want to delete this file ?");
                    if (conf_del)
                      {
                        document.getElementById("indexdiv").value = "confirmdelete";
                        get();
                      }
                    else
                      {
                        document.getElementById("pathdelete").value = "";
                      }  
                  }
                else if (result == "No Permissions to delete")
                  {
                    alert ("You do not have permissions to delete this file.");
                  }  
                else if (result == "FILEDELETED")
                  {
                    //alert("File has been deleted.");
                    document.getElementById("indexdiv").value = "showindexcont";
                    get();
                  }
                else if (result == "ConfirmMoveFile")
                  {
                    var conf_del = confirm ("Are you sure you want to replace existing file ?");
                    if (conf_del)
                      {
                        document.getElementById("indexdiv").value = "ConfirmedMoveFileToFolder";
                        get();
                      }
                    else
                      {
                        document.getElementById("pathdelete").value = "";
                      }  
                  }
                else if (result == "No Permissions to Movefile")
                  {
                    alert ("You do not have permissions to move this file.");
                  }
                else if (result == "You--Are--Not--Allowed--To--Open--This--File")
                  {
                    alert ("You do not have permissions to edit this file.");
                  }  
                else if (result == "FILEMOVED")
                  {
                    //alert("File has been deleted.");
                    document.getElementById("pathdelete").value = "";
                    document.getElementById("indexdiv").value = "showindexcont";
                    get();
                    
                  }    
                else if (result.match(/createdtheproblettable/gm))
                  {  
                    var org_prob = document.getElementById("problettable").value;
                    result = result.replace(/.*?<&>/,"");
                    
                    result = '<div class="mceNonEditable">'+result+'</div><p>&nbsp;</p>';
                    result = document.getElementById('allorgcont').value + result;
                    document.getElementById('allorgcont').value = "";
                    document.getElementById("probletflag").value = "";
                    SAWs.execCommand("mceInsertContent", false, result);
                  } 
                else if (result.match(/creatednutritable/gm))
                  {
                    result = result.replace(/.*?<&>/,"");
                    var allorgcont = document.getElementById('allorgcont').value;
                    
                    allorgcont = allorgcont.replace (/<\\/body>/gm,result + "</body>");
                    
                    //prompt ("",allorgcont);
                   // result = document.getElementById('allorgcont').value + result;
                    document.getElementById("probletflag").value = "";
                    document.getElementById("problettable").value = "";
                    document.getElementById("allorgcont").value = "";
                    SAWs.setContent(allorgcont); 
                   // SAWs.execCommand("mceInsertContent", false, allorgcont);
                   
                  }   
                else if (result.match(/diffresult/gm))
                  {
                    result = result.replace(/.*?<&>/,"");
                //    document.getElementById("orgpath").value = "";
                    //prompt ("",result);
                    if (result.length > 0)
                      {
                        document.getElementById("tdfcontent").value = result;
                        document.getElementById("tdfcontent").style.display = "";
                      }  
                    
                  } 
                else if (result.match(/alldircontindex<&>/gm))
                  {
                    result = result.replace(/\\n*\\r*/gm,"");
                    result = result.replace(/.*?<&>/,"");
                    var index_cont = new Array();
                    index_cont = result.split(/<;;&;;>/);  
                    if (document.getElementById('db_or_files').value)
                      {
                        document.getElementById("indexcont").innerHTML = index_cont[0];
                        document.getElementById("listing").innerHTML = index_cont[1];
                      }
                    else
                      {
                       // alert(document.getElementById("indexcont").innerHTML);
                        if (document.getElementById("folderpathsaving").value.match(/^\\/u\\/[^\\/]*?\\/\$/))
                          {
                            document.getElementById("indexcont").innerHTML = index_cont[0];
                            document.getElementById("listing").innerHTML = index_cont[1];
                            //document.getElementById("dirlisting").innerHTML = index_cont[2];
                            document.getElementById("indexcontentfortxtversion").value = index_cont[3];
                          }
                        else
                          {    
                            folderUpdateTreeStruct(index_cont[4]);
                          }  
                      }  
                    
                  }   
                else if (result.match(/==>ThisIsTheFirstQp<==/gm))
                  {
                    result = result.replace(/==>ThisIsTheFirstQp<==/gm,"");
                    document.getElementById("firstQP").value = result;
                    var commandString= "qpMoreThanOne";
                    SAWs.execInstanceCommand('mce_editor_0',commandString);
                  }  
                else
                  {
                    var array = new Array();
                    array = result.split(/<&>/);
                    if (document.getElementById('file').value == "versioning")
                      {
                        document.getElementById('file').value = '';
                        var VerContant = window.opener.document.getElementById('PatchCont').value;
                        document.getElementById('indexContent').value = window.opener.document.getElementById('IndexFromVersion').value;
                        document.getElementById('DirContXml').value = window.opener.document.getElementById('DirXmlFromVersion').value;
                      
                        var headBody = new Array();
                        headBody = VerContant.split(/<tab_name1>.*?<\\/tab_name1>/);
                        var title = headBody[0].replace(/.*?<title_doc>/gmi,"");
                        title = title.replace(/<\\/title_doc>.*/,"");
                        document.getElementById("titleDocProp").value = title;
    
                        var des = headBody[0].replace(/.*?<desc>/gmi,"");
                        des = des.replace(/<\\/desc>.*/gmi,"");
                        document.getElementById("descDocProp").value = des;
    
                        var key = headBody[0].replace(/.*?<keyword_adv_prop>/gmi,"");
                        key = key.replace(/<\\/keyword_adv_prop>.*/gmi,"");
                        document.getElementById("keysDocProp").value = key;
     
                        var auth = headBody[0].replace(/.*?<author>/gmi,"");
                        auth = auth.replace(/<\\/author>.*/gmi,"");
                        document.getElementById("authorDocProp").value = auth;
     
                        var affil = headBody[0].replace(/.*?<affiliation>/gmi,"");
                        affil = affil.replace(/<\\/affiliation>.*/gmi,"");
                        document.getElementById("affilDocProp").value = affil; 
                        document.getElementById("elm1").value = SAWs.setContent(headBody[1]);
                        return;
                      }
                    else if (document.getElementById('file').value == "repac;-%3E;%3C-;kFiles" || document.getElementById('file').value == "repac;->;<-;kFiles")
                      {
                        array[1] = "<title></title>";
                        array[2] = top.window.opener.document.getElementById('addToEditorRepack').value;
                      }   
                  array[0] = array[0].replace(/\&amp;/,"&");
                  document.rte1.title.value = array[0];
                  InitializeEditor(document.getElementById("pathindex").value);
                  var path_for_checking = document.getElementById('pathindex').value + document.getElementById('file').value;
                  
               
                  document.rte1.checkoverwrite.value = path_for_checking;
                  SAWs.execCommand('mceFocus', false, 'elm1');
                  var tinycont = SAWs.getContent();
                  var noOfEdits = document.getElementById('noOfEdits').value;
                  if (tinycont.length == 0 && noOfEdits < 5)
                    { 
                      noOfEdits++;
                      document.getElementById('noOfEdits').value = noOfEdits;
                      var defaultVal = '<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en"><head><title></title></head><body></body></html>';
                      SAWs.setContent(defaultVal);
                      get();
                    }
                  else if (tinycont.length == 0 && noOfEdits == 5)
                    {
                      alert ("Due to a network problem, the file could not be opened. Please refresh the page to try again.");
                      document.getElementById('noOfEdits').value = 0;
                    }
                  else
                    {  
                      tinycont = tinycont.replace(/\\n*\\r*/gim,"");
                      
                      //tinycont = tinycont.replace(/<head>(.*?)<\\/head>/,"<head>"+ array[1] +"</head>");
                      //prompt ("","arrayElem=>"+array[2]);
                      //tinycont = tinycont.replace(/<body>(.*?)<\\/body>/,"<body>"+ array[2] +"</body>");
                      //prompt ("","1=>"+tinycont);
                      array[6] = array[6].replace(/^\\s+/,"");
                      array[7] = array[7].replace(/^\\s+/,"");
                      array[8] = array[8].replace(/^\\s+/,"");
                      array[9] = array[9].replace(/^\\s+/,"");
                  
                      array[6] = array[6].replace(/\\s+\$/,"");
                      array[7] = array[7].replace(/\\s+\$/,"");
                      array[8] = array[8].replace(/\\s+\$/,"");
                      array[9] = array[9].replace(/\\s+\$/,"");
                  
                      document.getElementById("titleDocProp").value = array[0];
                      document.getElementById("keysDocProp").value = array[6];
                      document.getElementById("descDocProp").value = array[7];
                      document.getElementById("authorDocProp").value = array[8];
                      document.getElementById("affilDocProp").value = array[9];
                      document.getElementById('noOfEdits').value = 0;
                      document.getElementById("tablestats1").innerHTML = array[3];
                      document.getElementById('file').value = document.getElementById('file').value.replace (/repac;-%3E;%3C-;kFiles/g,"");
                      document.getElementById('file').value = document.getElementById('file').value.replace (/repac;->;<-;kFiles/g,"");
                      if (window.opener)
                        {
                          if (window.opener.document.getElementById("allSharedFolderList"))
                            {
                              document.getElementById('SharedContent').value = window.opener.document.getElementById('allSharedFolderList').innerHTML;
                              document.getElementById('XmlContShared').value = window.opener.document.getElementById('DirXmlSharedTree').value;
                              document.getElementById('stateOfSharedMain').value = window.opener.document.getElementById('sharedFolder').innerHTML;
                            }
                          if (window.opener.document.getElementById("indexcont"))
                            {
                              document.getElementById("indexContent").value = window.opener.document.getElementById("indexcont").innerHTML;
                              document.getElementById("DirContXml").value = window.opener.document.getElementById("DirContXml").value;
                            }
                          else
                            {
                              document.getElementById('SaveAsAgain').value = 3;
                              document.getElementById("DirContXml").value = array[10];
                              document.getElementById("indexContent").value = array[11];
                            }
                        }      
                      document.getElementById("orgpath").value = "";
                      var newtinycont = SAWs.getContent();
                      document.getElementById("problettable").value = newtinycont;
                      document.getElementById("probletflag").value = "";
                      var current_browser = navigator.appName;
                      if (array[2].match(/&lt;browser&gt;internet_explorer/gm))
                        {
                          if (current_browser!="Microsoft Internet Explorer")
                            {
                              alert("Editing this file in a browser other than Internet Explorer may lead to data loss. Please edit the file in Internet Explorer.");
                              onbeforeunload='Any data not saved, will be lost.';
                              window.close();
                            }
                        }  
                      if (array[2].match(/&lt;browser&gt;mozilla_firefox/gm))
                        {
                          if (current_browser !="Netscape")
                            {
                              alert("Editing this file in a browser other than Firefox may lead to data loss. Please edit the file in Firefox.")
                              onbeforeunload='Any data not saved, will be lost.';  
                              window.close();
                            }
                        }      
                      document.getElementById("elm1").value = SAWs.setContent(array[2]);
               
                      if (array[4].match(/<::existingoldtdf::>/gm))
                        {
                         // document.getElementById("orgpath").value = "";
                          document.getElementById("tdfcontent").value = array[4];
                          document.getElementById("tdfcontent").style.display = "";
                        }
               //     else
              //        {  
              //          get();
               //       }  
                    }
          
                 }
               document.getElementById('loading').style.visibility = "hidden";  
             } 
          else 
            {
              alert('There was a problem with the request.');
              document.getElementById('loading').style.visibility = "hidden";
            }
          //  result = http_request.responseText;
         //   document.getElementById('myspan').innerHTML = result;            
         
      }
   }
function get() 
  {
    var getstr;
    var URL_path = document.getElementById("db_or_files").value;
    //alert (document.getElementById("indexdiv").value);
    if (document.getElementById("probletflag").value == "true")
      {
       // prompt ("","here"+document.getElementById("problettable").value);
        document.getElementById("ajaxopen").value = "false";
        getstr = 'pdata=' + escape(encodeURIComponent(document.getElementById("problettable").value)) + '&';
        getstr += 'probletflag=' + escape(document.getElementById("probletflag").value) + '&';
        makeRequest(URL_path, getstr);
        document.getElementById("probletflag").value == "false";
      }
    else if (document.getElementById("probletflag").value == "recipe")
      {
        document.getElementById("ajaxopen").value = "false";
        getstr = 'pdata=' + escape(encodeURIComponent(document.getElementById("problettable").value)) + '&';
        getstr += 'probletflag=' + escape(document.getElementById("probletflag").value) + '&';
        makeRequest(URL_path, getstr);
        document.getElementById("problettable").value = "";
        document.getElementById("probletflag").value = "";
      } 
    else if (document.getElementById("probletflag").value == "sendfordiff") 
      {
        document.getElementById("ajaxopen").value = "false";
        getstr = 'diffdata=' + escape(encodeURIComponent(document.getElementById("problettable").value)) + '&';
        getstr += 'probletflag=' + escape(document.getElementById("probletflag").value) + '&';
        getstr += 'file=' + escape(document.getElementById("file").value) + '&';
        getstr += 'folderpathsaving=' + escape(document.getElementById("folderpathsaving").value) + '&';
        makeRequest(URL_path, getstr);
        document.getElementById("problettable").value = "";
        document.getElementById("probletflag").value = "";
      } 
    else if (document.getElementById("indexdiv").value == "showindexcont")
      {
        document.getElementById("ajaxopen").value = "";
        getstr = 'indexdiv=' + escape(document.getElementById("indexdiv").value) + '&';
        getstr += 'pathindex=' + escape(document.getElementById("pathindex").value) + '&';
        makeRequest(URL_path, getstr);
        document.getElementById("problettable").value = "";
        document.getElementById("indexdiv").value = "";
      } 
    else if (document.getElementById("indexdiv").value == "showrootdir")
      {
        document.getElementById("ajaxopen").value = "";
        getstr = 'indexdiv=' + escape(document.getElementById("indexdiv").value) + '&';
        makeRequest(URL_path, getstr);
        document.getElementById("problettable").value = "";
        document.getElementById("indexdiv").value = "";
      }
    else if (document.getElementById("indexdiv").value == "createfolder")
      {
        document.getElementById("ajaxopen").value = "";
        getstr = 'indexdiv=' + escape(document.getElementById("indexdiv").value) + '&';
        getstr += 'userfoldername=' + escape(document.getElementById("userfoldername").value) + '&';
        getstr += 'pathindex=' + escape(document.getElementById("pathindex").value) + '&';
        document.getElementById("problettable").value = "";
        document.getElementById("indexdiv").value = "";
        makeRequest(URL_path, getstr);
      }
    else if (document.getElementById("indexdiv").value == "ExtractFirstQp")
      {
        var editorCont = SAWs.getContent()
        document.getElementById("ajaxopen").value = "";
        getstr = 'indexdiv=' + escape(document.getElementById("indexdiv").value) + '&';
        getstr += 'elm1=' + escape(encodeURIComponent(editorCont)) + '&';
        document.getElementById("indexdiv").value = "";
        makeRequest(URL_path, getstr);
      }  
    else if (document.getElementById("probletflag").value == "opentxtversion" || document.getElementById("probletflag").value == "openjusttxt")
      {
        var fullpathtxtver = "";
        if (document.getElementById("probletflag").value == "opentxtversion")
          {
            fullpathtxtver = document.getElementById("pathindex").value + "/" + document.getElementById("file").value;
          }
        else if (document.getElementById("probletflag").value == "openjusttxt")
          {
            fullpathtxtver = document.getElementById("pathindex").value + "/" + document.getElementById("file").value + ".txt";
          }    
        document.getElementById("ajaxopen").value = "true";
        if (document.getElementById("orgpath").value == "")
          {
            document.getElementById("orgpath").value = document.getElementById("file").value;
          }
        getstr = 'file=' + escape(fullpathtxtver) + '&';
        getstr += 'ajaxopen=' + escape(document.getElementById("ajaxopen").value) + '&';
        //alert (document.getElementById("orgpath").value);
        makeRequest(URL_path, getstr);
        document.getElementById("probletflag").value = "";
        document.getElementById("ajaxopen").value = "false";
      }
    else if (document.getElementById("indexdiv").value == "deletefile")
      {
        getstr = 'indexdiv=' + escape(document.getElementById("indexdiv").value) + '&';
        document.getElementById("indexdiv").value = "";
        makeRequest(URL_path, getstr);
      }
    else if (document.getElementById("indexdiv").value == "confirmdelete")
      {
        getstr = 'pathdelete=' + escape(document.getElementById("pathdelete").value) + '&';
        getstr += 'indexdiv=' + escape(document.getElementById("indexdiv").value) + '&';
        document.getElementById("pathdelete").value = "";
        document.getElementById("indexdiv").value = "";
        makeRequest(URL_path, getstr);
      }
    else if (document.getElementById("indexdiv").value == "MoveFileToFolder" || document.getElementById("indexdiv").value == "ConfirmedMoveFileToFolder")
      {
        getstr = 'pathdelete=' + escape(document.getElementById("pathdelete").value) + '&';
        getstr += 'indexdiv=' + escape(document.getElementById("indexdiv").value) + '&';
        document.getElementById("indexdiv").value = "";
        makeRequest(URL_path, getstr);
      } 
    else if (document.getElementById("taskMoveCopy").value == "MoveCopy" || document.getElementById("taskMoveCopy").value == "MoveCopyForDB")
      {
        getstr = 'FilesMovedCopied=' + escape(document.getElementById("FilesMovedCopied").value) + '&';
        getstr += 'SelectedDir=' + escape(document.getElementById("SelectedDir").value) + '&';
        getstr += 'taskMoveCopy=' + escape(document.getElementById("taskMoveCopy").value) + '&';
        getstr += 'OrgMovepath=' + escape(document.getElementById("OrgMovepath").value) + '&';
        document.getElementById("FilesMovedCopied").value = "";
        document.getElementById("folderpathsaving").value = document.getElementById("SelectedDir").value;
        document.getElementById("pathindex").value = document.getElementById("SelectedDir").value;
        document.getElementById("SelectedDir").value = "";
        document.getElementById("taskMoveCopy").value = "";
        document.getElementById("Orgpathindex").value = ""; 
        makeRequest(URL_path, getstr);
      }    
    else if (document.getElementById("taskMoveCopy").value == "AddKeysDesc")
      {
        getstr = 'FilesMovedCopied=' + escape(document.getElementById("FilesMovedCopied").value) + '&';
        getstr += 'titleMultFiles=' + escape(document.getElementById("titleMultFiles").value) + '&';
        getstr += 'pathindex=' + escape(document.getElementById("pathindex").value) + '&';
        getstr += 'taskMoveCopy=' + escape(document.getElementById("taskMoveCopy").value) + '&';
        getstr += 'keywordsMultFiles=' + escape(document.getElementById("keywordsMultFiles").value) + '&';
        getstr += 'descriptionMultFiles=' + escape(document.getElementById("descriptionMultFiles").value) + '&';
        getstr += 'QPMultFiles=' + escape(document.getElementById("QPMultFiles").value) + '&';
        getstr += 'authorMultFiles=' + escape(document.getElementById("authorMultFiles").value) + '&';
        document.getElementById("FilesMovedCopied").value = "";
        document.getElementById("titleMultFiles").value = "";
        document.getElementById("taskMoveCopy").value = "";
        document.getElementById("keywordsMultFiles").value = ""; 
        document.getElementById("descriptionMultFiles").value = "";
        document.getElementById("authorMultFiles").value = "";
        document.getElementById("QPMultFiles").value = "";
        makeRequest(URL_path, getstr);
      }    
    else
      {  
        
        document.getElementById("ajaxopen").value = "true";
        if (document.getElementById("orgpath").value == "")
          {
            document.getElementById("orgpath").value = document.getElementById("file").value;
          }
        getstr = 'file=' + escape(document.getElementById("orgpath").value) + '&';
        getstr += 'ajaxopen=' + escape(document.getElementById("ajaxopen").value) + '&';
        if (document.getElementById("folderpathsaving").value.length > 0)
          {
            getstr += 'SaveInThisFolder=' + escape(document.getElementById("folderpathsaving").value) + '&';
          }
        makeRequest(URL_path, getstr);
        document.getElementById("ajaxopen").value = "false";
      }  
       
       
  }
</script>

<!-- /SAWS -->
<SCRIPT LANGUAGE="JavaScript"><!--
function loadEmptyEditor()
  { 
    var template = new Array();
    var pageURL = window.location.href;
    var templateName = pageURL.indexOf('&') > 0 ? pageURL.substr(pageURL.indexOf('&') + 1, pageURL.length) : '';

    template['file'] = '/saw/jscripts/saws/plugins/custom/auto_format.htm?' + templateName;
    template['width'] = parseInt(SAWs.getParam("theme_advanced_source_editor_width", 770));
    template['height'] = parseInt(SAWs.getParam("theme_advanced_source_editor_height", 600));
    var flag_af = "";
    SAWs.openWindow(template, {editor_id : "elm1", flag_af : "first", resizable : "yes", scrollbars : "no", inline : "yes"});
    document.getElementById("indexContent").value = window.opener.top.document.getElementById("indexcont").innerHTML;
    document.getElementById("DirContXml").value = window.opener.top.document.getElementById("DirContXml").value;
  }  

//--></SCRIPT>
<script language="javascript">

 var mine = window.open('','','width=1,height=1,left=0,top=0,scrollbars=no');
 var popUpsBlocked = true;
 if(mine)
   popUpsBlocked = false;
 
 if(popUpsBlocked)
  alert('We have noticed that your popup-blocker has disabled a window. You must allow popups from this site in order to fully utilize this tool.'); 
  mine.close();
EOF
if ($openfileflag == 2)
  {
print <<EOF;
</script> 
</head>
<body onLoad="loadeditorcont();" onbeforeunload="return 'Any data not saved, will be lost.';">
EOF
  }
elsif ($openfileflag == 3)
  {
print <<EOF;
</script> 
</head>
<body onLoad="setVersionEditor();" onbeforeunload="return 'Any data not saved, will be lost.';">
EOF
  }
elsif ($openfileflag == 4)
  {
print <<EOF;
</script>
</head>
<body onLoad="loadEditorImgTemplate();" onbeforeunload="return 'Any data not saved, will be lost.';">
EOF
  }
else
  {
print <<EOF;
</script> 
</head>
<body onLoad="loadEmptyEditor();" onbeforeunload="return 'Any data not saved, will be lost.';">
EOF
  }  
print <<EOF;  

EOF
#if ($showdirlistingflag == 1 || $showdirlistingflag == 2)
#  {
 #   print "<table></table>";
#  }
print <<EOF;
<textarea id="eqn_text" style="display:none;"></textarea>
<input type="hidden" id="eqn_flag" value="0"/>
$actheader 
<form target = _parent method = "post" ENCTYPE="multipart/form-data" id ="rte1" name = "rte1" onsubmit="return confirm('Clear the contents?')"><div id = "savingfilewait" style="position:absolute;top:4;left:550px; top:220px;z-index:8;padding:2px;visibility:hidden";><p  align = "right"><img src ="http://scripts.syvum.com/s_i/loading.gif"><font size = "2" color ="777777">Saving...</font></div><div id = "loading" style="position:absolute;top:4;left:550px; top:220px;z-index:8;padding:2px;visibility:hidden";><p  align = "right"><img src ="http://scripts.syvum.com/s_i/loading.gif"><font size = "2" color ="777777">Loading...</font></div>
<div id = "matheq" style="position:absolute;top:100px;left:800px;z-index:7;background-color:#e2e2e2;padding:2px;visibility:hidden"; >
<span style="float:left;"><a style="color:blue;" onclick ="hide();"><u>Hide</u></a></span><br />
<span style="color:maroon; text-align:left;font-size:14;"><b>Math Equation Template</b></span><br /><br />
<table width="120" height="100" border="0" cellspacing="0" cellpadding="0" align="left">
 <tr>
   <td align="right" valign="top">
       <table border="0" cellspacing="1" cellpadding="0">
           <tr>
              <td>
                   <table cellspacing="1" border="0" cellpadding="1" >
                      <tr>
                        <td align="right"><img src="http://scripts.syvum.com/s_i/met.gif" title="Insert math equation" onclick="inserteq();"/></td>
                        <td><img src="/saw/jscripts/saws/plugins/tabledd/images/table_insert_col_after.gif" title="Insert cell" onclick="SAWs.execInstanceCommand('elm1','mcesettabledd',false,'mceTableInsertColAfter');" /></td>
                        <td><img src="/saw/jscripts/saws/plugins/tabledd/images/table_delete_col.gif" title="Delete cell" onclick="SAWs.execInstanceCommand('elm1','mcesettabledd',false,'mceTableDeleteCol');" /></td>
                        <td><img src="http://scripts.syvum.com/s_i/mtr.gif" title="Matrix" onclick="matrix();" /></td>
                        </tr>
                         <tr>
                          <td><img src="/saw/jscripts/saws/themes/advanced/images/charmap.gif" title="Insert custom character" onclick="SAWs.execInstanceCommand('elm1','mceCharMap',false);" /></td>
                          <td><img src="http://scripts.syvum.com/s_i/fr1.gif" title="Fraction" onclick="fractions();" /></td><td><img src="http://scripts.syvum.com/s_i/fr3.gif" title="Integral" onclick="integral();" /></td>
                          <td><img src="http://scripts.syvum.com/s_i/fr4.gif" title="Summation" onclick="summation();" /></td>
                          <td><img src="http://scripts.syvum.com/s_i/fr2.gif" title="radic" onclick="radic();"/></td>
                         </tr>
                          <td><img src="http://scripts.syvum.com/s_i/eq.jpg" title="Insert Standard Equations..." onclick="Equations();"/></td>
                         <!--<tr onclick="upload_eq();"><td colspan="5">Equation(s)</td></tr>-->
                    </table>
               </td>
            </tr>
        </table>
     </td>
  </tr>
</table>
</div>
<div id = "matheqNotAllOptions" style="position:absolute;top:100px;left:800px;z-index:7;background-color:#e2e2e2;padding:2px;visibility:hidden"; >
<span style="float:left;"><a style="color:blue;" onclick ="hidewithoutoptions();"><u>Hide</u></a></span>
<span style="float:right;">
<select id="selectLanguage" onclick ="change_language();">
<option value="">--Select--</option>
<option value="Math">Math</option>
<option value="French">French</option>
<option value="Spanish">Spanish</option>
<option value="Italian">Italian</option>
<option value="Latin">Latin</option>
</select>
</span><br />
<span style="color:maroon; text-align:left;font-size:14;"><b>Math Equation Template</b></span><br /><br />
<table width="120" height="100" border="0" cellspacing="0" cellpadding="0" align="left">
 <tr>
   <td align="right" valign="top">
       <table border="0" cellspacing="1" cellpadding="0">
           <tr>
              <td>
                   <table cellspacing="1" border="0" cellpadding="1" >
                      <tr>
                        <td align="right"><img src="http://scripts.syvum.com/s_i/met.gif" title="Insert math equation" onclick="inserteq(1);"/></td>
                        <td><img src="/saw/jscripts/saws/plugins/tabledd/images/table_insert_col_after.gif" title="Insert cell" onclick="alert('Please click the ME image before creating the equation.');" /></td>
                        <td><img src="/saw/jscripts/saws/plugins/tabledd/images/table_delete_col.gif" title="Delete cell" onclick="SAWs.execInstanceCommand('elm1','mcesettabledd',false,'mceTableDeleteCol');" /></td>
                        <td><img src="http://scripts.syvum.com/s_i/mtr.gif" title="Matrix" onclick="alert('Please click the ME image before creating the equation.');" /></td>
                        </tr>
                         <tr>
                          <td><img src="/saw/jscripts/saws/themes/advanced/images/charmap.gif" title="Insert custom character" onclick="alert('Please click the ME image before creating the equation.');" /></td>
                          <td><img src="http://scripts.syvum.com/s_i/fr1.gif" title="Fraction" onclick="fractions();" /></td><td><img src="http://scripts.syvum.com/s_i/fr3.gif" title="Integral" onclick="alert('Please click the ME image before creating the equation.');" /></td>
                          <td><img src="http://scripts.syvum.com/s_i/fr4.gif" title="Summation" onclick="alert('Please click the ME image before creating the equation.');" /></td>
                          <td><img src="http://scripts.syvum.com/s_i/fr2.gif" title="radic" onclick="alert('Please click the ME image before creating the equation.');" /></td>
                         </tr>
                          <td><img src="http://scripts.syvum.com/s_i/eq.jpg" title="Insert Standard Equations..." onclick="alert('Please click the ME image before creating the equation.');"/></td> 
                         <!--<tr onclick="upload_eq();"><td colspan="5">Equation(s)</td></tr>-->
                    
<td><div id = "overscript" style="text-align:center; width:15px;height:20px;  background:#E6E6E6;" name="overscript" onClick = "getSymbol('overscript')" onmouseOver ="this.style.cursor ='pointer'; this.style.border='1px solid black';"onmouseout="this.style.border='0'" >&nbsp;x<span style="right: 0.5em; bottom: 0.5em; position: relative">−</span></div>
</table>
               </td>
            </tr>
        </table>
     </td>
  </tr>
</table>
</div>
<div id = "audioProps" style="position:absolute;left:780px; top:120px;z-index:7;background-color:#fccec4;padding:2px;visibility:hidden"; >
<table>
<tr><td colspan="2" align="center"><b>Text to speech.</b></td></tr>
<tr>
<td>Language : </td><td><select id="langOption"><option value="english">English</option>
<option value="french">French</option>
<option value="german">German</option>
<option value="italian">Italian</option>
<option value="japnese">Japnese</option>
<option value="portugese">Portugese</option>
<option value="spanish">Spanish</option>
</select></td>
</tr>
<tr><!--<td>Voice of a : </td><td><select id="voiceOf"><option value="man">Man</option>
<option value="woman">Woman</option>
<option value="child">Child</option>
</select></td>-->
</tr>
<tr><td><input type="button" id="voiceAddtoTxt" value="OK" onclick="addAudioTags();"></td><td><input type="button" value="Close" onclick="document.getElementById('audioProps').style.visibility='hidden'"></td></tr>
</table></div>
<div id='keywordsAndTitles' name='keywordsAndTitles' style='position:absolute;left:730px; z-index:9;top:215px;border:solid 1px black;display:none;background-color:#e2e2e2;'>
<table>
<tr>
 <td>Title :</td><td> <input type='text' id='titleForEquation' name='titleForEquation' /></td></tr>
<tr>
  <td>Keywords :</td><td> <textarea id='keysForEquation' name='keysForEquation' rows='2' cols='18'></textarea></td></tr>
<tr>
  <td></td><td><input type="checkbox" id="makeInline" name="makeInline" />&nbsp;&nbsp;Inline equation<br /><span style="color:#666666;font-size:12px;">Use 'Shift + Enter' for an inline equation.</span></td></tr>
<tr>
  <td><input type='button' value='Ok' onclick='insertEqWithKeysTitle ();' /></td><td><input type='button' value='Cancel' onclick='document.getElementById("keywordsAndTitles").style.display="none"' /></td></tr>
</table>
</div>
<div id = "matheqs" style="position:absolute;top:150;left:575px;top:180px;z-index:7;background-color:#CCCCCC;padding:2px;visibility:hidden;width:50%;height:50%;overflow:auto;">
<u><FONT COLOR="blue"><span style="float:left;"><a onclick ="hide_equation();">Hide</a></span><br/>
<br /></FONT></u>
<table border="0">
	 	
	<tbody>
		 		
		<tr><td colspan="2"><hr/></td></tr>
<tr style ="cursor:pointer;" onclick = "area_of_circle();">
			 			 			
			<td>Area of Circle : </td> 			
			<td> <em>A</em> = <em>πr</em><sup>2</sup></td> 		
		</tr>
		 		
		<tr><td colspan="2"><hr/></td></tr>
<tr style ="cursor:pointer;" onclick = "binomial_theorem();">
			 			 			
			<td>Binomial Theorem : <br />
			 			</td> 			
			<td> 			
			<table>
				 				
				<tbody>
					 					
					<tr>
						 						
						<td align="center" nowrap="nowrap">(<em>x</em> + <em>a</em>)<em><sup>n</sup> = </em><br />
						 						 						 						 						 						</td> 						
						<td><span style="color: black"><em><span style="font-size: 70%"> n</span></em><br />
						 						 						 						 						 						<span style="font-size: 150%">∑</span><br />
						 						 						 						 						 						<span style="font-size: 70%"><em>k</em> = 0</span></span><br />
						 						 						 						 						 						</td> 						
						<td> <span style="font-size: x-large">(</span></td> 						
						<td><em><span style="font-size: medium"><sup>n</sup><br />
						 						 						 						 						 						<sub>k</sub></span></em> <br />
						 						 						 						 						 						</td> 						
						<td><span style="font-size: x-large">)</span> <em>x<sup>k</sup> a<sup>n </sup></em><sup>−<em> k</em></sup><br />
						 						 						 						 						 						</td> 					
					</tr>
					 				
				</tbody>
				 			
			</table>
			 			 </td> 		
		</tr>
		 		
		<tr><td colspan="2"><hr/></td></tr>
<tr style ="cursor:pointer;" onclick = "expansion_sum();">
			 			 			
			<td>Expansion of a sum : <br />
			 			</td> 			
			<td> 			
			<table>
				 				
				<tbody>
					 					
					<tr>
						 						
						<td align="center" nowrap="nowrap">(1 + <em>x</em>)<em><sup>n</sup></em> = 1 + <br />
						 						 						 						 						 						</td> 						
						<td><span><em>nx</em> </span> 						 						 						 						 						
						<div style="margin-top: -0.8ex; margin-bottom: -1ex; line-height: 0.9">
						 						 						 						 						 						 						 						 						 						
						<hr noshade="noshade" />
						 						 						 						 						 						 						 						 						 						
						</div>
						 						 						 						 						 						 						 						 						 						
						<div align="center">
						 						 						 						 						 						<span>1! </span> <br />
						 						 						 						 						 						 						 						 						 						
						</div>
						 						 						 						 						 						</td> 						
						<td> +   </td> 						
						<td><span><em>n</em>(<em>n</em> − 1)<em>x</em><sup>2</sup><br />
						 						 						 						 						 						</span> 						 						 						 						 						
						<div style="margin-top: -0.8ex; margin-bottom: -1ex; line-height: 0.9">
						 						 						 						 						 						 						 						 						 						
						<hr noshade="noshade" />
						 						 						 						 						 						 						 						 						 						
						</div>
						 						 						 						 						 						 						 						 						 						
						<div align="center">
						 						 						 						 						 						<span>2! </span> <br />
						 						 						 						 						 						 						 						 						 						
						</div>
						 						 						 						 						 						</td> 						
						<td> + …</td> 					
					</tr>
					 				
				</tbody>
				 			
			</table>
			 			 </td> 		
		</tr>
		 		
		<tr><td colspan="2"><hr/></td></tr>
<tr style ="cursor:pointer;" onclick = "fourier_series();">
			 			 			
			<td>Fourier Series : <br />
			 			</td> 			
			<td> 			
			<table>
				 				
				<tbody>
					 					
					<tr>
						 						
						<td align="center" nowrap="nowrap"><span style="font-size: small"><em>f</em>(<em>x</em>) = <em>a</em><sub>0 </sub> + <br />
						 						 						 						 						 						</span></td> 						
						<td><span style="color: black"><span style="font-size: 70%"> ∞</span><br />
						 						 						 						 						 						<span style="font-size: 150%">∑</span><br />
						 						 						 						 						 						<span style="font-size: 70%"><em>n</em> = 1</span></span> <br />
						 						 						 						 						 						</td> 						
						<td> <span style="font-size: x-large">(</span></td> 						
						<td> <em>a<sub>n </sub></em>cos<em><sub><br />
						 						 						 						 						 						</sub></em></td> 						
						<td><span><em>nπx</em> <br />
						 						 						 						 						 						</span> 						 						 						 						 						
						<div style="margin-top: -0.8ex; margin-bottom: -1ex; line-height: 0.9">
						 						 						 						 						 						 						 						 						 						
						<hr noshade="noshade" />
						 						 						 						 						 						 						 						 						 						
						</div>
						 						 						 						 						 						 						 						 						 						
						<div align="center">
						 						 						 						 						 						<span><em>L</em> </span> <br />
						 						 						 						 						 						 						 						 						 						
						</div>
						 						 						 						 						 						</td> 						
						<td> + <em>b<sub>n</sub></em> sin<em><sub><br />
						 						 						 						 						 						</sub></em></td> 						
						<td><span><em>nπx</em> <br />
						 						 						 						 						 						</span> 						 						 						 						 						
						<div style="margin-top: -0.8ex; margin-bottom: -1ex; line-height: 0.9">
						 						 						 						 						 						 						 						 						 						
						<hr noshade="noshade" />
						 						 						 						 						 						 						 						 						 						
						</div>
						 						 						 						 						 						 						 						 						 						
						<div align="center">
						 						 						 						 						 						<span><em>L</em></span> <br />
						 						 						 						 						 						 						 						 						 						
						</p>
						</div>
						 						 						 						 						 						</td> 						
						<td><span style="font-size: x-large">)</span> </td> 					
					</tr>
					 				
				</tbody>
				 			
			</table>
			 			 </td> 		
		</tr>
		 		
		<tr><td colspan="2"><hr/></td></tr>
<tr style ="cursor:pointer;" onclick = "pythagorean_theorem();">
			 			 			
			<td>Pythagorean Theorem : <br />
			 			</td> 			
			<td><em>a</em><sup>2</sup> + <em>b</em><sup>2</sup> =  <em>c</em><sup>2</sup> <br />
			 			</td> 		
		</tr>
		 		
		<tr><td colspan="2"><hr/></td></tr>
<tr style ="cursor:pointer;" onclick = "quadratic_formula();">
			 			 			
			<td>Quadratic Formula :<br />
			 			</td> 			
			<td> 			
			<table height="26" width="157">
				 				

						 						 						 						 						</span> 						 						 						 						
						<div style="margin-top: -0.8ex; margin-bottom: -1ex; line-height: 0.9">
						 						 						 						 						 						 						 						
						<hr noshade="noshade" />
						 						 						 						 						 						 						 						
						</div>
						 						 						 						 						 						 						 						
						<div align="center">
						 						 						 						 						<span>2<em>a</em> </span> <br />
						 						 						 						 						 						 						 						
						</div>
						 						 						 						 						</td> 					
					</tr>
					 				
				</tbody>
				 			
			</table>
			 			 </td> 		
		</tr>
		 		
		<tr><td colspan="2"><hr/></td></tr>
<tr style ="cursor:pointer;" onclick = "taylor_expansion();">
			 			 			
			<td>Taylor Expansion : <br />
			 			</td> 			
			<td> 			
			<table>
				 				
				<tbody>
					 					
					<tr>
						 						
						<td align="center" nowrap="nowrap"><em>e<sup>x</sup></em> = 1 + <br />
						 						 						 						 						 						</td> 						
						<td align="center"><span><em>x</em> </span> 						 						 						 						 						 						 						 						
						<hr noshade="noshade" />
						 						 						 						 						 						 						 						 						<span>1! </span> <br />
						 						 						 						 						 						</td> 						
						<td>+  </td> 						
						<td align="center"><span><em>x</em><sup>2</sup> </span> 						 						 						 						 						 						 						 						
						<hr noshade="noshade" />
						 						 						 						 						 						 						 						 						<span>2! </span> <br />
						 						 						 						 						 						</td> 						
						<td>+  </td> 						
						<td align="center"><span><em>x</em><sup>3</sup> </span> 						 						 						 						 						 						 						 						
						<hr noshade="noshade" />
						 						 						 						 						 						 						 						 						<span>3! </span> <br />
						 						 						 						 						 						</td> 						
						<td>+ …,          −∞ &lt; <em>x</em> &lt; ∞ </td> 					
					</tr>
					 				
				</tbody>
				 			
			</table>
			 			 </td> 		
		</tr>
		 		
		<tr><td colspan="2"><hr/></td></tr>
<tr style ="cursor:pointer;" onclick = "trig_identity_1();">
			 			 			
			<td>Trig Identity 1 : <br />
			 			</td> 			
			<td> 			
			<table>
				 				
				<tbody>
					 					
					<tr>
						 						
						<td align="center" nowrap="nowrap">sin<em> α</em> ± sin<em> β</em> = 2 sin 						 						</td> 						
						<td><span>1 </span> 						 						 						 						 						
						<div style="margin-top: -0.8ex; margin-bottom: -1ex; line-height: 0.9">
						 						 						 						 						 						 						 						 						 						
						<hr noshade="noshade" />
						 						 						 						 						 						 						 						 						 						
						</div>
						 						 						 						 						 						<span>2 </span> <br />
						 						 						 						 						 						</td> 						
						<td>(<em>α</em> ± <em>β</em>) cos<br />
						 						 						 						 						 						</td> 						
						<td><span>1 </span> 						 						 						 						 						
						<div style="margin-top: -0.8ex; margin-bottom: -1ex; line-height: 0.9">
						 						 						 						 						 						 						 						 						 						
						<hr noshade="noshade" />
						 						 						 						 						 						 						 						 						 						
						</div>
						 						 						 						 						 						<span>2 </span> <br />
						 						 						 						 						 						</td> 						
						<td>(<em>α</em> <span>∓</span> <em>β</em>)</td> 					
					</tr>
					 				
				</tbody>
				 			
			</table>
			 			 </td> 		
		</tr>
		 		
		<tr><td colspan="2"><hr/></td></tr>
<tr style ="cursor:pointer;" onclick = "trig_identity_2();">
			 			 			
			<td>Trig Identity 2 : <br />
			 			</td> 			
			<td> 			
			<table>
				 				
				<tbody>
					 					
					<tr>
						 						
						<td align="center" nowrap="nowrap">cos<em> α</em> + cos<em> β</em> = 2 cos 						 						</td> 						
						<td><span>1 </span> 						 						 						 						 						
						<div style="margin-top: -0.8ex; margin-bottom: -1ex; line-height: 0.9">
						 						 						 						 						 						 						 						 						 						
						<hr noshade="noshade" />
						 						 						 						 						 						 						 						 						 						
						</div>
						 						 						 						 						 						<span>2 </span> <br />
						 						 						 						 						 						</td> 						
						<td>(<em>α</em> + <em>β</em>) cos<br />
						 						 						 						 						 						</td> 						
						<td><span>1 </span> 						 						 						 						 						
						<div style="margin-top: -0.8ex; margin-bottom: -1ex; line-height: 0.9">
						 						 						 						 						 						 						 						 						 						
						<hr noshade="noshade" />
						 						 						 						 						 						 						 						 						 						
						</div>
						 						 						 						 						 						<span>2 </span> <br />
						 						 						 						 						 						</td> 						
						<td>(<em>α</em> − <em>β</em>) <br />
						 						 						 						 						 						</td> 					
					</tr>
					 				
				</tbody>
				 			
			</table>
			 			 </td> 		
		</tr>
		 	
	</tbody>
	 
</table>
 </div> 
EOF
   for (my $no_tabs = 1; $no_tabs <=  $tab_var; $no_tabs++)
     {
print <<EOF; 
<input type = "hidden" id = tab$no_tabs name = tab$no_tabs value = "$loadtabname[$no_tabs-1]">
EOF
     }
     
   if ($db_0r_files eq "sat.cgi")
     {
       print <<EOF;
<table>
<tr><td><div id=\"imageshowhide\" style='border:1px solid\#AAE;margin:0;position:relative;left:0px;height:20px; padding:2px;width:160px;background-color:#c4cfde;text-align:center;color:blue;' onmouseover='closepopupdiv()'><u><font size=\"-2\"><a onClick=\"expand();\">Hide</a></font></u>&nbsp;<b>INDEX</b></div></td><td><div style='border:1px solid #AAE;margin:0;position:relative;left:0px;height:20px; padding:2px;width:810px;background-color:#c4cfde;text-align:center;color:blue;' onmouseover='closepopupdiv()'><b>SYVUM AUTHORING WIZARD</b></div></td></tr>
<tr><td colspan="2"><div id = "listing" style="overflow: auto;">$dirlist</div></td></tr>
<tr><td valign="top"><div id="entireindex" style="visibility:visible"><div id = "moreactions" style="border:1px solid #AAE;margin:0;padding:2px;height:20px;width:160px;text-align:center;"><u><font size="-1" color="blue"><a onmouseover="createfolder(event.clientX,event.clientY);">More Actions</a></font></u></div><div id="indexcont" name="indexcont" style = "border:1px solid #AAE;margin:0;position:relative;left:0px;height:440px; padding:2px;width:160px;overflow:auto;"><br/>$alldirs<br/>$allfiles</div><div class="diveditmenu" ID="diveditmenu" style="position:absolute;top:4;left:110px; top:30px;z-index:5;visibility:hidden"></div></div></td><div style="position:absolute;top:200px;left:140px"></div><td valign="top">
EOF
     }
     
print <<EOF; 
<div id = "tab_container" style = "border:1px solid #AAE;margin:0;position:relative;left:0px;width:100%; height:460px; padding:5px;float:right;" onmouseover="closepopupdiv()"><div class="diveditmenu" ID="diveditmenu" style="position:absolute;top:4;left:110px; top:30px;z-index:5;visibility:hidden"></div>
<table style='width:100%'><tr><td colspan='5'><div id="saveIntoInfo">$saveIntoInfo</div></td><td align='right'>&nbsp;&nbsp;<font size = "-1"><b>File Name : </b><input type = "text" size = "30" id = "file" name = "file" value = "$filedisplay" style = "font-size:80%;background:lightgrey;" onclick ="saveAsPopup();" /><input type = "button" name = "saveAs" id = "saveAs" value = "Save As..." style = "font-size:80%;" onclick="saveAsPopup();"><br /><!--<a onclick="openRepackTool();"><font color="blue" size="-1"><u>Insert Questions from other Quizzes on Syvum.</u></font></a>--></td></tr></table>
<!--<p id = "tab_menu" style = "text-align:left;margin-bottom:0pt;border-collapse:collapse;border-width:0pt;position:relative;left:0px;width:900px;">-->


<!-- NEW CSS CODE-->

<link rel="stylesheet" type="text/css" href="/saw/menubar.css" />
<script type ="text/javascript"src="/saw/menubarnew.js"></script>

<body>

<ul id="nav">

         <li class="top"><a class="top_link"><span class="down">File</span></a>
                  <ul class="sub">
                            <li onclick= "saveAsPopup();"><a href="#"><img src="/saw/jscripts/saws/plugins/save/images/save.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Save As&#8230;<span style="font:12px; color:#394565; margin-left:55px;">Ctrl+S</span></a></li>
                            <li onclick="SAWs.execInstanceCommand('mce_editor_0','mcePrint');return false;"><a href="#"><img src="/saw/jscripts/saws/plugins/print/images/print.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Print&#8230;<span style="font:12px; color:#394565; margin-left:75px;">Ctrl+P</span></a></li>
                  </ul>
         </li>


         <li class="top"><a class="top_link"><span class="down">Edit</span></a>
                  <ul class="sub">
                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Undo',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/undo.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Undo<span style="font:12px; color:#394565; margin-left:82px;">Ctrl+Z</span></a></li>
        	           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Redo',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/redo.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Redo<span style="font:12px; color:#394565; margin-left:82px;">Ctrl+Y</span></a></li>
	                   <li><hr align="center" width="184" size="1" noshade="noshade"/></li>
	                   <li onclick ="SAWs.execInstanceCommand('mce_editor_0','Cut',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/cut.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Cut<span style="font:12px; color:#394565; margin-left:92px;">Ctrl+X</span></a></li>
                           <li onclick ="SAWs.execInstanceCommand('mce_editor_0','Copy',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/copy.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Copy<span style="font:12px; color:#394565; margin-left:83px;">Ctrl+C</span></a></li>
	                   <li onclick ="SAWs.execInstanceCommand('mce_editor_0','Paste',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/paste.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Paste<span style="font:12px; color:#394565; margin-left:80px;">Ctrl+V</span></a></li>
                           <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mcePasteText',true);return false;"><a href="#"><img src="/saw/jscripts/saws/plugins/paste/images/pastetext.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Paste Plain</a></li>
 	                    <li onclick="SAWs.execInstanceCommand('mce_editor_0','hvsort',false);return false;"><a href="#"><img src="/s_i/sb.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Sort&#8230;</a></li>
                           <li><hr align="center" width="184" size="1" noshade="noshade"/></li>
	                   <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceSearchReplace',true);return false;" ><a href="#"><img src="/saw/jscripts/saws/plugins/searchreplace/images/replace.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Find & Replace&#8230;<span style="font:12px; color:#394565; margin-left:17px;">Ctrl+F</span></a></li>
                           <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFullPageProperties');return false;"><a href="#"><img src="/saw/jscripts/saws/plugins/fullpage/images/fullpage.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Search Objects&#8230;</a></li>
                  </ul>
         </li>


         <li class="top"><a href="#" class="top_link"><span class="down">View</span></a>
                  <ul class="sub">
                           <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceCodeEditor',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/code.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Html Source</a></li>
	                   <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFullScreen');return false;"><a href="#"><img src="/saw/jscripts/saws/plugins/fullscreen/images/fullscreen.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Full Screen</a></li>
	                   <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceToggleVisualAid',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/visualaid.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Guidelines</a></li>
                  </ul>
         </li>


         <li class="top"><a href="#" class="top_link"><span class="down">Insert</span></a>
                  <ul class="sub">
                           <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceCharMap',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/charmap.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Symbol&#8230;</a></li>
                           <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceAdvImage');return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/image.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Picture&#8230;</a></li>
                           <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceMedia');return false;"><a href="#"><img src="/saw/jscripts/saws/plugins/media/images/media.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Embedded Media&#8230;</a></li>
	                   <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceInsertAnchor',false);return false;"><a href="#"><span onclick ="SAWs.execInstanceCommand('mce_editor_0','mceInsertAnchor',false);return false;"><img src="/saw/jscripts/saws/themes/advanced/images/anchor.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Anchor&#8230;</a></li>
                           <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceAdvLink');return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/link.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Link&#8230;</a></li>
                           <li onclick ="SAWs.execInstanceCommand('mce_editor_0','unlink',false);return false;"><a href="#"><span onclick ="SAWs.execInstanceCommand('mce_editor_0','unlink',false);return false;"><img src="/saw/jscripts/saws/themes/advanced/images/unlink.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Unlink&#8230;</a></li> 
                            <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceStyleProps',true);return false;"><a href="#"><img src="/saw/jscripts/saws/plugins/style/images/styleprops.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;CSS Styles&#8230;</a></li> 
	                   <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceAdvancedHr');return false"><a href="#"><img src="/saw/jscripts/saws/plugins/advhr/images/advhr.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Horizontal Line</a></li>
                           <li><hr align="center" width="184" size="1" noshade="noshade"/></li>
	                   <li onclick ="SAWs.execInstanceCommand('mce_editor_0','me');return false;"><a href="#"><img src="http://charlie.syvum.com/s_i/meb.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Math Equation&#8230;</a></li>
	                   <li onclick ="SAWs.execInstanceCommand('mce_editor_0','af',false);return false;"><a href="#"><img src="/saw/jscripts/saws/plugins/template/images/template.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Template&#8230;</a></li>
                  </ul>
         </li>


         <li class="top"><a href="#" class="top_link"><span class="down">Format</span></a>
                  <ul class="sub">
                           <li onclick ="SAWs.execInstanceCommand('mce_editor_0','Bold',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/bold.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Bold<span style="font:12px; color:#394565; margin-left:87px;">Ctrl+B</span></a></li>
	                   <li onclick= "SAWs.execInstanceCommand('mce_editor_0','Italic',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/italic.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Italic<span style="font:12px; color:#394565; margin-left:87px;">Ctrl+I</span></a></li>
	                <li onclick="SAWs.execInstanceCommand('mce_editor_0','Underline',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/underline.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Underline<span style="font:12px; color:#394565; margin-left:59px;">Ctrl+U</span></a></li>   
                         <li><a href="#" class ="fly"><img src="/s_i/fdnew.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Font Face</a>                                  <ul>
                                          <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFont',false,'arial');"><span style="margin-left:20px;"><a href="#"><span style="margin-left:20px;">Arial</span></a></li>
                                          <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFont',false,'arial black');"><a href="#"><span style="margin-left:20px;">Arial Black</span></a></li>                                           <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFont',false,'verdana');"><a href="#"><span style="margin-left:20px;">Verdana</span></a></li>
                                          <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFont',false,'times new roman');"><a href="#"><span style="margin-left:20px;">Times New Roman</span></a></li>
                                          <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFont',false,'courier new');"><a href="#"><span style="margin-left:20px;">Courier New</span></a></li>
                                          <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFont',false,'georgia');"><a href="#"><span style="margin-left:20px;">Georgia</span></a></li>
                                          <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFont',false,'andale mono');"><a href="#"><span style="margin-left:20px;">Andale Mono</span></a></li>
                                          <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFont',false,'book antiqua');"><a href="#"><span style="margin-left:20px;">Book Antiqua</span></a></li>
                                          <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFont',false,'comic sans ms');"><a href="#"><span style="margin-left:20px;">Comic Sans MS</span></a></li>
                                          <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFont',false,'helvetica');"><a href="#"><span style="margin-left:20px;">Helvetica</span></a></li>
                                 </ul>
                        </li>
                        <li><a href="#" class ="fly"><img src="/s_i/fsdnew.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Font Size</a>
                                <ul>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFontsize',false,'1');"><a href="#"><span style="margin-left:20px;">1 (8 pt)</span></a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFontsize',false,'2');"><a href="#"><span style="margin-left:20px;">2 (10 pt)</span></a></li>                                          <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFontsize',false,'3');"><a href="#"><span style="margin-left:20px;">3 (12 pt)</span></a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFontsize',false,'4');"><a href="#"><span style="margin-left:20px;">4 (14 pt)</span></a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFontsize',false,'5');"><span style="margin-left:20px;"><a href="#"><span style="margin-left:20px;">5 (18 pt)</span></a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFontsize',false,'6');"><a href="#"><span style="margin-left:20px;">6 (24 pt)</span></a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFontsize',false,'7');"><a href="#"><span style="margin-left:20px;">7 (36 pt)</span></a></li>
                                </ul>
                        </li>
                         <li><a href="#" class ="fly"><img src="/saw/jscripts/saws/plugins/style/images/style_info.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Styles</a>
                                <ul>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFormat',false,'pre');"><a href="#"><span style="margin-left:20px;">Preformatted</span></a></li>
                                         </li>

                                         <li><hr align="center" width="184" size="1" noshade="noshade"/></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFormat',false,'h1');"><a href="#"><span style="margin-left:20px;">Heading 1</span></a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFormat',false,'h2');"><a href="#"><span style="margin-left:20px;">Heading 2</span></a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFormat',false,'h3');"><a href="#"><span style="margin-left:20px;">Heading 3</span></a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFormat',false,'h4');"><a href="#"><span style="margin-left:20px;">Heading 4</span></a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFormat',false,'h5');"><a href="#"><span style="margin-left:20px;">Heading 5</span></a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFormat',false,'h6');"><a href="#"><span style="margin-left:20px;">Heading 6</span></a></li>
                                        <li><hr align="center" width="184" size="1" noshade="noshade"/></li>
                                        <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFormat',false,'p');"><a href="#"><span style="margin-left:20px;">Paragraph</span></a></li>
                                        <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceFormat',false,'address');"><a href="#"><span style="margin-left:20px;">Address</span></a></li>

                                </ul>
                        </li>
                        <li onclick ="SAWs.execInstanceCommand('mce_editor_0','removeformat',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/removeformat.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Clear Formatting</a></li>
 
    	                <li><hr align="center" width="184" size="1" noshade="noshade"/></li>  
                        <li onclick="SAWs.execInstanceCommand('mce_editor_0','forecolorMenu');return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/forecolor.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Font Color</a></li>
                        <li onclick="SAWs.execInstanceCommand('mce_editor_0','HiliteColorMenu');return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/backcolor.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Background Color</a></li> 
  
                        <li><hr align="center" width="184" size="1" noshade="noshade"/></li>
                        <li><a href="#" class = "fly"><img src="/saw/jscripts/saws/themes/advanced/images/justifyfull.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Align</a>
                                                  <ul>
                                                            <li onclick ="SAWs.execInstanceCommand('mce_editor_0','JustifyLeft',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/justifyleft.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Left</a></li>                                                             <li onclick ="SAWs.execInstanceCommand('mce_editor_0','JustifyCenter',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/justifycenter.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Center</a></li>
                                                            <li onclick ="SAWs.execInstanceCommand('mce_editor_0','JustifyRight',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/justifyright.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Right</a></li>
                                                            <li onclick ="SAWs.execInstanceCommand('mce_editor_0','JustifyFull',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/justifyfull.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Justified</a></li>
                                                  </ul> 
                        <li><a href="#" class ="fly"><img src="/saw/jscripts/saws/themes/advanced/images/bullist.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Bullets and Numbering</a>
                                <ul>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','InsertUnorderedList',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/bullist.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Bullets</a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','InsertOrderedList',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/numlist.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Numbering</a></li>
                                </ul>
                        </li>
                        <li><a href="#" class ="fly"><img src="/saw/jscripts/saws/themes/advanced/images/indent.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Indentation</a>
                                <ul>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','Indent',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/indent.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Increase Indent</a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','Outdent',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/outdent.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Decrease Indent</a></li>
                                </ul>
                        </li>
                       

		        <li><hr align="center" width="184" size="1" noshade="noshade"/></li>
			<li onclick ="SAWs.execInstanceCommand('mce_editor_0','subscript',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/sub.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Subscript</a></li>
                        <li onclick ="SAWs.execInstanceCommand('mce_editor_0','superscript',false);return false;"><a href="#"><img src="/saw/jscripts/saws/themes/advanced/images/sup.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Superscript</a></li>
		  </ul>

	 </li>

	<li class="top"><a href="#" class="top_link"><span class="down">Table</span></a>
	<ul class="sub">
		<li onclick="SAWs.execInstanceCommand('mce_editor_0','mcesettabledd',true,'mceInsertTable');"><a href="#"><span style="margin-left:25px;">Insert/Edit Table&#8230;</span></a></li>
  		<li onclick="SAWs.execInstanceCommand('mce_editor_0','mcesettabledd',true,'mceTableDelete');"><a href="#"><span style="margin-left:25px;">Delete Table</span></a></li>
		<li onclick="SAWs.execInstanceCommand('mce_editor_0','mcesettabledd',true,'mceTableRowProps');"><a href="#"><span style="margin-left:25px;">Row Properties&#8230;</span></a></li>
		<li onclick="SAWs.execInstanceCommand('mce_editor_0','mcesettabledd',true,'mceTableInsertRowBefore');"><a href="#"><span style="margin-left:25px;">Insert Row Before</span></a></li>
		<li onclick="SAWs.execInstanceCommand('mce_editor_0','mcesettabledd',true,'mceTableInsertRowAfter');"><a href="#"><span style="margin-left:25px;">Insert Row After</span></a></li>
	        <li onclick="SAWs.execInstanceCommand('mce_editor_0','mcesettabledd',true,'mceTableDeleteRow');"><a href="#"><span style="margin-left:25px;">Delete Row</span></a></li>
                <li onclick="SAWs.execInstanceCommand('mce_editor_0','mcesettabledd',true,'mceTableInsertColBefore');"><a href="#"><span style="margin-left:25px;">Insert Column Before</span></a></li>
		<li onclick="SAWs.execInstanceCommand('mce_editor_0','mcesettabledd',true,'mceTableInsertColAfter');"><a href="#"><span style="margin-left:25px;">Insert Column After</span></a></li>
		<li onclick="SAWs.execInstanceCommand('mce_editor_0','mcesettabledd',true,'mceTableDeleteCol');"><a href="#"><span style="margin-left:25px;">Delete Column</span></a></li>
		<li onclick="SAWs.execInstanceCommand('mce_editor_0','mcesettabledd',true,'mceTableCellProps');"><a href="#"><span style="margin-left:25px;">Cell Properties&#8230;</span></a></li>
		<li onclick="SAWs.execInstanceCommand('mce_editor_0','mcesettabledd',true,'mceTableMergeCells');"><a href="#"><span style="margin-left:25px;">Merge Cells&#8230;</span></a></li>
		<li onclick="SAWs.execInstanceCommand('mce_editor_0','mcesettabledd',true,'mceTableSplitCells');"><a href="#"><span style="margin-left:25px;">Split Cells</span></a></li>
 		<li onclick="SAWs.execInstanceCommand('mce_editor_0','mcesettabledd',true,'mceMoveColumns');"><a href="#"><span style="margin-left:25px;">Reorder Rows/Columns&#8230;</span></a></li>	
		<li onclick="SAWs.execInstanceCommand('mce_editor_0','mcesettabledd',true,'mceSort');"><a href="#"><span style="margin-left:25px;">Sort&#8230;</span></a></li>
        </ul>
	</li>
	
      
        <li class="top"><a href="#"  class="top_link"><span class="down">Tools</span></a>
                 <ul class="sub">
                          <li onclick ="SAWs.hideMenus();SAWs.execInstanceCommand('mce_editor_0','mceSpellCheck');return false;"><a href="#" class ="fly"><img src="/saw/jscripts/saws/plugins/spellchecker/images/spellchecker.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Spell-Check</a>
                                <ul>
                                         <li><a href="#"><span style="margin-left:20px;"><b>Languages</b></span></a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceSpellCheckerSetLang',false,'en');"><a href="#"><span style="margin-left:20px;">English</span></a></li>
				         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceSpellCheckerSetLang',false,'fr');"><a href="#"><span style="margin-left:20px;">French</span></a></li>					     
				         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceSpellCheckerSetLang',false,'de');"><a href="#"><span style="margin-left:20px;">German</span></a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceSpellCheckerSetLang',false,'it');"><a href="#"><span style="margin-left:20px;">Italian</span></a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceSpellCheckerSetLang',false,'pt');"><a href="#"><span style="margin-left:20px;">Portuguese</span></a></li>
                                         <li onclick ="SAWs.execInstanceCommand('mce_editor_0','mceSpellCheckerSetLang',false,'es');"><a href="#"><span style="margin-left:20px;">Spanish</span></a></li>
                                </ul>
                        </li>
                 </ul>
        </li>  
	                
      
        <li class="top"><a href="#"  class="top_link"><span class="down">Activity</span></a>
	         <ul class="sub">
                          <li onclick="SAWs.execInstanceCommand('mce_editor_0','qp');return false;"><a href="#"><img src="/s_i/qpb.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Question-Set Properties&#8230;</a></li>
                          <li onclick= "SAWs.execInstanceCommand('mce_editor_0','q',false);return false;"><a href="#"><img src="/s_i/qb.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Question</a></li>
                         <li onclick = "SAWs.execInstanceCommand('mce_editor_0','a',false);return false;"><a href="#"><img src="/s_i/ab.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Answer</a></li>
		         <li onclick = "SAWs.execInstanceCommand('mce_editor_0','c',false);return false;"><a href="#"><img src="/s_i/cb.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Choice</a></li>
		         <li onclick = "SAWs.execInstanceCommand('mce_editor_0','e',false);return false;"><a href="#"><img src="/s_i/eb.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Explanation</a></li>
		         <li onclick = "SAWs.execInstanceCommand('mce_editor_0','h',false);return false;"><a href="#"><img src="/s_i/hb.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;Hint</a></li>
                         <li><hr align="center" width="184" size="1" noshade="noshade"/></li>
		         <li onclick="SAWs.execInstanceCommand('mce_editor_0','af',false);return false;"><a href="#"><img src="/s_i/afb2.png" border ="0px" align="absmiddle">&nbsp;&nbsp;Auto Format&#8230;</a></li>
                         <li><a href="#" class="fly"><img src="/s_i/apb2.png" border ="0px" align="absmiddle">&nbsp;&nbsp;Answer Properties</a>
                                  <ul>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Anspos',false,'Answer Position 1');"><a href="#"><span style="margin-left:20px;">Answer Position 1</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Anspos',false,'Answer Position 2');"><a href="#"><span style="margin-left:20px;">Answer Position 2</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Anspos',false,'Answer Position 3');"><a href="#"><span style="margin-left:20px;">Answer Position 3</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Anspos',false,'Answer Position 4');"><a href="#"><span style="margin-left:20px;">Answer Position 4</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Anspos',false,'Answer Position 5');"><a href="#"><span style="margin-left:20px;">Answer Position 5</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Anspos',false,'Answer Position Random');"><a href="#"><span style="margin-left:20px;">Answer Position Random</span></a></li>
                                           <li><hr align="center" width="184" size="1" noshade="noshade"/></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Anspos',false,'7');"><a href="#"><span style="margin-left:20px;">Alternative Answer</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Anspos',false,'8');"><a href="#"><span style="margin-left:20px;">Alternative Question</span></a></li>
                                           <li><hr align="center" width="184" size="1" noshade="noshade"/></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Anspos',false,'Short Answer');"><a href="#"><span style="margin-left:20px;">Short Answer</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Anspos',false,'Multiple Answer');"><a href="#"><span style="margin-left:20px;">Multiple Answer</span></a></li>
                                           <li  onclick="SAWs.execInstanceCommand('mce_editor_0','Anspos',false,'Odd One Out');"><a href="#"><span style="margin-left:20px;">Odd One Out</span></a></li>
                                  </ul>
                         </li>

                         <li><a href="#" class = "fly"><img src="/s_i/hdd2.png" border ="0px" align="absmiddle">&nbsp;&nbsp;Heading</a>
                                  <ul>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Heading',false,'1');"><a href="#"><span style="margin-left:20px;">Top Heading</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Heading',false,'2');"><a href="#"><span style="margin-left:20px;">Section Heading</span></a></li>
				           <li><hr align="center" width="184" size="1" noshade="noshade"/></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Heading',false,'3');"><a href="#"><span style="margin-left:20px;">Top Details</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Heading',false,'4');"><a href="#"><span style="margin-left:20px;">Section Details</span></a></li>
                                  </ul>
                         </li>

                         <li><a href="#" class ="fly"><img src="/s_i/qsd2.png" border ="0px" align="absmiddle">&nbsp;&nbsp;Question-Set</a>
                                   <ul>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Questionset',false,'1');"><a href="#"><span style="margin-left:20px;">Forward Instruction</span></a></li>
				           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Questionset',false,'2');"><a href="#"><span style="margin-left:20px;">Reverse Instruction</span></a></li>
                                           <li><hr align="center" width="184" size="1" noshade="noshade"/></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Questionset',false,'4');"><a href="#"><span style="margin-left:20px;">Question Heading</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Questionset',false,'5');"><a href="#"><span style="margin-left:20px;">Answer Heading</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Questionset',false,'6');"><a href="#"><span style="margin-left:20px;">Explanation Heading</span></a></li>
                                           <li><hr align="center" width="184" size="1" noshade="noshade"/></li>
                                           <li  onclick="SAWs.execInstanceCommand('mce_editor_0','Questionset',false,'8');"><a href="#"><span style="margin-left:20px;">Quick Reference</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Questionset',false,'9');"><a href="#"><span style="margin-left:20px;">Info Page Subheading</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Questionset',false,'10');"><a href="#"><span style="margin-left:20px;">Custom Info Page</span></a></li>
                                  </ul>
                         <li><a href="#" class="fly"><img src="/s_i/fcd2.png" border ="0px" align="absmiddle">&nbsp;&nbsp;Fixed Choice/Passage</a>
                                  <ul>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Fixedchoice',false,'1');"><a href="#"><span style="margin-left:20px;">Set Fixed Choices</span></a></li>
                                           <li  onclick="SAWs.execInstanceCommand('mce_editor_0','Fixedchoice',false,'2');"><a href="#"><span style="margin-left:20px;">Fixed Choice 1</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Fixedchoice',false,'3');"><a href="#"><span style="margin-left:20px;">Fixed Choice 2</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Fixedchoice',false,'4');"><a href="#"><span style="margin-left:20px;">Fixed Choice 3</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Fixedchoice',false,'5');"><a href="#"><span style="margin-left:20px;">Fixed Choice 4</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Fixedchoice',false,'6');"><a href="#"><span style="margin-left:20px;">Fixed Choice 5</span></a></li>
                                           <li><hr align="center" width="184" size="1" noshade="noshade"/></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Fixedchoice',false,'True');"><a href="#"><span style="margin-left:20px;">True</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Fixedchoice',false,'False');"><a href="#"><span style="margin-left:20px;">False</span></a></li>
                                           <li><hr align="center" width="184" size="1" noshade="noshade"/></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Fixedchoice',false,'0');"><a href="#"><span style="margin-left:20px;">Fixed Passage</span></a></li>
                                  </ul>
                         </li>

                         <li><a href="#" class="fly"><img src="/s_i/tpd2.png" border ="0px" align="absmiddle">&nbsp;&nbsp;Test Paper</a>
                                  <ul>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Alter',false,'1');"><a href="#"><span style="margin-left:20px;">Keywords</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Alter',false,'2');"><a href="#"><span style="margin-left:20px;">Marks</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Alter',false,'3');"><a href="#"><span style="margin-left:20px;">Points</span></a></li>
                                  </ul>
                         </li>

                         <li><a href="#" class="fly"><img src="/s_i/tfd2.png" border ="0px" align="absmiddle">&nbsp;&nbsp;Text Features</a>
                                  <ul>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Custominfopage',false,'1');"><a href="#"><span style="margin-left:20px;">Hide/Show Text&#8230;</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Custominfopage',false,'2');"><a href="#"><span style="margin-left:20px;">Audio for Text&#8230;</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Custominfopage',false,'3');"><a href="#"><span style="margin-left:20px;">Tooltip&#8230;</span></a></li>
                                  </ul>
                         </li>

                         <li><a href="#" class="fly"><img src="/s_i/vdd2.png" border ="0px" align="absmiddle">&nbsp;&nbsp;Variable</a>
                                  <ul>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Problet',false,'1');"><a href="#"><span style="margin-left:20px;">Variable Name(s)&#8230;</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Problet',false,'2');"><a href="#"><span style="margin-left:20px;">Variable Properties&#8230;</span></a></li>
                                  </ul>
                         </li>
                         <li><a href="#" class="fly"><img src="/s_i/rdd2.png" border ="0px" align="absmiddle">&nbsp;&nbsp;Recipe</a>
                                  <ul>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Recipe',false,'1');"><a href="#"><span style="margin-left:20px;">Ingredient&#8230;</span></a></li>
                                           <li onclick="SAWs.execInstanceCommand('mce_editor_0','Recipe',false,'2');"><a href="#"><span style="margin-left:20px;">Cooking Time</span></a></li>
                                  </ul>
                         </li>
                 </ul>
	</li>
	
        <li class="top"><a href="#" class="top_link"><span class="down">Help</span></a>
                 <ul class="sub">
                          <li><a href="/saw/help/en/index.htm" target="_blank"><img src="/s_i/fm/help.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;SAW - Help Manual</a></li>
                          <li onClick="window.open('/saw/help/en/aboutSaw.htm','mywindow','width=400,height=400')"><a href="#"><span style="margin-left:22px;">About SAW</span></a></li>
                 </ul>
         </li>
</ul>

</body>

EOF

my $flag_style = 0;
my $style_info = "background:#AAE;border:1px solid #AAE;font-family:arial;font-size:80%;color:white;cursor:pointer;";
for (my $no_tabs = 1; $no_tabs <=  $tab_var; $no_tabs++)
  {
    if ($flag_style != 0)
      {
        $style_info = "background:white;border:1px solid #AAE;font-family:arial;font-size:80%;color:#AAE;cursor:pointer;";
      }
    $flag_style = 1;
print <<EOF;
<!--<span id = "syvum_span_$no_tabs" onClick = "toggleTab($no_tabs)" style = "$style_info" ondblClick = "changename(this.id);"><b>&nbsp;Tab $no_tabs&nbsp;</b></span>-->
EOF
  }
print <<EOF;
<!--</p>-->
<script>
loadtabname();
</script>
EOF
my $no_tabs;
my $flag = 0;
my $display_info = "";

for ($no_tabs = 0; $no_tabs < $tab_var; $no_tabs++)
  {
     
     my $no_tabs_elm = $no_tabs + 1;
     if ($flag != 0)
       {
          $display_info = "none";
       }
     $flag = 1; 

print <<EOF;
<div id = "syvum_$no_tabs_elm" style = "display :$display_info;">
<textarea id = "elm$no_tabs_elm" name = "elm$no_tabs_elm" rows = "24" cols = "80" style = "width: 100%"></textarea>
</div>
</div></td></tr></table>
EOF
  }
#print $stats_table;
print "<br clear=\"all\"><br /><div id=\"stats_table_afterSave\"></div>";
if ($tdffile == 1)
  {
print <<EOF;
<br /><textarea name = "tdfcontent" rows = "20" cols = "80">
$text
</textarea>
EOF
  }
$tdffile = 0;
print <<EOF;
<div id="tablestats1" style="position:absolute;top:550;" name="tablestats1"></div>
<textarea id="tdfcontent" name="tdfcontent" rows = "20" cols = "80" style="display:none">
</textarea>
<input type = "hidden" size = "30" id = "flagtxtversion" name = "indexdiv" value = "" />

<input type = "hidden" size = "40" id = "title" name = "name" style = "font-size:80%;background:lightgrey;" value="$text_box_title" onclick ="changetitle();" />
<input type = "hidden" name = "savedraft" id = "savedraft" value = "Save" style = "font-size:80%;" onclick = "wait_load();">
<input type = "button" name = "save" id = "save" value = "Save" style = "font-size:80%;display:none;" onclick = "formData2QueryString(document.forms['rte1'],'savedraft');">
<input type = "hidden" size = "2" id = "tab" name = "tab" value = "$tab_var">

<textarea rows="10" cols="100" id = "indexcontentfortxtversion" style="display:none">$cont_folder</textarea>
<textarea rows="10" cols="100" id = "setVersion" name="setVersion" style="display:none"></textarea>
<input type="button" id="setVerEdit" onclick="setVersionEditor();" style="display:none" />
<input type = "hidden" id = "checkoverwrite" name = "checkoverwrite" value = "" />
<input type = "hidden" id = "orgpath" name = "orgpath" value = "$text_box_filename" />
<input type = "hidden" name = "saveflag" id = "saveflag" />
<input type = "hidden" name = "SaveAsAgain" id = "SaveAsAgain" value='0'/>
<input type="hidden" value="" name = "ajaxopen" id = "ajaxopen">
<input type="hidden" value="" name = "ajax" id = "ajax">
<input type="hidden" value="" name = "probletflag" id = "probletflag" />
<input type="hidden" value="" name = "vieweditdeletflag" id = "vieweditdeletflag" />
<input type = "hidden" id = "indexdiv" name = "indexdiv" value = "" />
<input type = "hidden" id = "pathindex" name = "pathindex" value = "$dir" />
<input type = "hidden" id = "pathdelete" name = "pathdelete" value = "" />
<input type="hidden" value="$dir" name = "folderpathsaving" id = "folderpathsaving" />
<input type="hidden" value="" name = "userfoldername" id = "userfoldername" />
<input type="hidden" value="" name = "clientDateTime" id = "clientDateTime" />
<input type="hidden" value="0" name="noOfSaves" id="noOfSaves" />
<input type="hidden" value="0" name="noOfEdits" id="noOfEdits" />
<input type = "hidden" size = "30" id="titleDocProp" name="titleDocProp" value="" />
<input type = "hidden" size = "30" id="authorDocProp" name="authorDocProp" value="" />
<input type = "hidden" size = "30" id = "affilDocProp" name = "affilDocProp" value="" />
<textarea rows="10" cols="100" id="keysDocProp" name='keysDocProp' style="display:none"></textarea>
<textarea rows="10" cols="100" id = "descDocProp" name="descDocProp" style="display:none"></textarea>


<textarea rows="20" cols="20" id = "text1a" style="display:none"></textarea>
<input type="button" id="open" name="open" onclick="get();" style="display:none;">
<textarea rows="20" cols="20" id = "indexContent" style="display:none;"></textarea>
<textarea rows="20" cols="20" name="diff_cont" id="diff_cont" style="display:none"></textarea>
<input type="hidden" value="$table{userID}" name="userIdMainFolder" id="userIdMainFolder" />
<textarea rows="30" cols="60" id = "DirContXml" style="display:none;">$XmlContent</textarea>
<textarea rows="30" cols="60" name="currentIndexContent" id = "currentIndexContent" style="display:none"></textarea>
<textarea rows="20" cols="20" id = "SharedContent" style="display:none;"></textarea>
<textarea rows="20" cols="20" id = "XmlContShared" style="display:none;"></textarea>
<textarea rows="20" cols="20" id = "stateOfSharedMain" style="display:none;"></textarea>
<textarea rows="20" cols="20" id = "problettable" style="display:none"></textarea>
<textarea rows="20" cols="20" id = "allorgcont" style="display:none"></textarea>
<textarea rows="20" cols="20" id = "firstQP" style="display:none"></textarea>

</form>
</p>
<form target="_blank" method="post" id="rte2" name="rte2" action="/cgi/fs/publish.pl">
<input type = "hidden" name = "pub_file" id = "pub_file" />
<input type = "hidden" name = "pub_pathindex" id = "pub_pathindex" />
<input type = "hidden" name = "startpublish" id = "startpublish" value="true"/>
</form>
<form target="_blank" method="post" id="rte3" name="rte3" action="redirect.cgi">
<input type = "hidden" name = "openSimpleTextarea" id = "openSimpleTextarea" value=""/>
<input type = "hidden" name = "dirname" id = "dirname" value="OPEN"/>
</form>
<form target="_blank" method="post" id="rte4" name="rte4" action="repack.cgi">
<input type = "hidden" name = "dirSearchKeys" id = "dirSearchKeys" value=""/>
<input type = "hidden" name = "Orgpathindex" id = "Orgpathindex" value=""/>
<input type = "hidden" name = "task" id = "task" value=""/>
<input type = "hidden" name = "db_or_files" id = "db_or_files" value="$db_0r_files"/>
<input type="button" id="putContEditor" name="putContEditor" style="display:none" onclick="SetEditorCont();"/>
<textarea rows="20" cols="20" id = "test" style="display:none"></textarea>
</form>
<form target="_blank" method="post" id="rte5" name="rte5">
<input type = "hidden" name = "SelectedDir" id = "SelectedDir" value=""/>
<input type="hidden" name="OrgMovepath" id="OrgMovepath" />
<input type = "hidden" name = "taskMoveCopy" id = "taskMoveCopy" value=""/>
<textarea rows="20" cols="20" id = "FilesMovedCopied" name="FilesMovedCopied" style="display:none"></textarea>
<input type="hidden" name="titleMultFiles" id="titleMultFiles"/>
<textarea rows="20" cols="20" name="keywordsMultFiles" id="keywordsMultFiles" style="display:none"></textarea>
<textarea rows="20" cols="20" name="descriptionMultFiles" id="descriptionMultFiles" style="display:none"></textarea>
<textarea rows="20" cols="20" name="QPMultFiles" id="QPMultFiles" style="display:none"></textarea>
<input type="hidden" name="authorMultFiles" id="authorMultFiles"/>
<input type="button" id="putContEditor" name="putContEditor" style="display:none" onclick="get();"/>
</form>
</body>
</html>
EOF

  }
  
sub draft
  {
    my $alldirs = shift;
    my $allfiles = shift;
    my $cont_folder = shift;
    my $XmlContent = shift;
    my $userID = shift;
    my $currheaderr = "FILE MANAGER";
    my $fileheader = io::topHeader($currheaderr,$userID);

    my $javascript_true_path = "";
    my $hostName = $ENV{HTTP_HOST};

    if (defined $hostName && $hostName =~ /charlie|192\.168\.1\.2/)
      {
        $javascript_true_path = "/users/praful";
      }
    my $pub_flag = permInternalUsers($userID);  
    print <<EOF;
<html>
<head>
<script type="text/javascript" src="/saw/folder_tree_struct.js"></script>
<script type="text/javascript" src="/saw/highlight_folders_files.js"></script>
<script type="text/javascript" src="/saw/SatFunction_FM.js"></script>
<script type="text/javascript" src="/saw/menubar.js"></script>
<script type="text/javascript" src="/saw/tabs_new.js"></script>
<style> 
a 
{cursor : pointer}
</style>
<script type="text/javascript">
 var http_request;
function ajaxFunction(url, parameters) 
    {
      http_request = false;
      if (window.XMLHttpRequest) 
        { // Mozilla, Safari,...
          http_request = new XMLHttpRequest();
          if (http_request.overrideMimeType) 
            {
         	// set type accordingly to anticipated content type
                //http_request.overrideMimeType('text/xml');
              http_request.overrideMimeType('text/html');
           }
         } 
       else if (window.ActiveXObject) 
         { // IE
           try 
             {
               http_request = new ActiveXObject("Msxml2.XMLHTTP");
             }
           catch (e) 
             {
               try 
                 {
                    http_request = new ActiveXObject("Microsoft.XMLHTTP");
                 } 
               catch (e) {}
             }
          }
        if (!http_request) 
          {
            alert('Cannot create XMLHTTP instance');
            return false;
          }
        http_request.onreadystatechange = alertContent;
        http_request.open('POST', url, true);
        http_request.send(parameters);
}

function alertContent()
{
       if (http_request.readyState == 4) 
         {
           if (http_request.status == 200) 
             {
               result = http_request.responseText;
               result = result.replace(/\\r*\\n*/gm,"");
               //prompt("",result);
               if (result.match(/showtabpre/gm))
                 {
                   result = result.replace(/.*?<&>/,"");
                   var index_cont = new Array();
                   index_cont = result.split(/<;;&;;>/);
                   //alert (index_cont[0]);
                   if (index_cont[0] == "blank")
                     {
                       document.getElementById('tab_container1').innerHTML = '<iframe name="preview_act_ind" style="height:90%;width:100%;" FRAMEBORDER="0"></iframe>';
//                       document.getElementById('tab_container2').innerHTML = '<iframe name="edit_act_ind" style="height:90%;width:100%;" FRAMEBORDER="0" src="/cgi/editor/satdb.cgi"></iframe>';
//                       document.getElementById('tab_container3').innerHTML = 'More Actions';
                     }
                   else
                     {
                       document.getElementById('tab_container1').innerHTML = '<iframe name="preview_act_ind" style="height:90%;width:100%;" FRAMEBORDER="0" src="' + index_cont[0] + '"></iframe>';
//                       document.getElementById('tab_container2').innerHTML = '<iframe name="edit_act_ind" style="height:90%;width:100%;" FRAMEBORDER="0" src="' + index_cont[1] + '"></iframe>';
//                       document.getElementById('tab_container3').innerHTML = index_cont[2];
                     }
                 }
               else if (result.match(/alldircontindex<&>/gm))
                 {
                   result = result.replace (/alldircontindex<&>/gm,"");
                   folderUpdateTreeStruct(result); 
                 } 
               else if (result.match(/contForMainFolder<&&&>/gm))
                 {
                    result = result.replace(/contForMainFolder<&&&>/gm,"");
                    //prompt ("",result);
                    var arrContFoldTextArea = new Array();
                    arrContFoldTextArea = result.split(/<-&&;--;&&->/);
                    document.getElementById('indexcont').innerHTML = arrContFoldTextArea[0];
                    document.getElementById('DirContXml').value = arrContFoldTextArea[1];
                 }
               else if (result.match(/ConfirmDelete<&&&>/gm))
                 {
                   var FileName = result.replace(/ConfirmDelete<&&&>/gm,"");
                   FileName = FileName.replace(/\\.xml/gim,"");
                   FileName = FileName.replace(/,/gi,"\\n");
                   var confDel = confirm("Do you really want to delete the following file(s)?\\n " + FileName + "");

                   if (confDel)
                     {
                       document.getElementById("status").value = "confirmDelete";
                       creaDelRef ('deleteFile');
                     }
                   else
                     {

                     }  
                 }
               else if (result == "You--Donot--have--permission--to--delete")
                 {
                   alert ("You do not have the permission to delete this file.");
                 }  
               else if (result.match(/ConfirmFolderDelete<&&&>/gm))
                 {
                   var FileName = result.replace(/ConfirmFolderDelete<&&&>/gm,"");
                   var confDel = confirm ("Do you really want to delete '" + FileName + "' ?");
                   if (confDel)
                     {
                       document.getElementById("status").value = "confirmDeleteFolder";
                       creaDelRef ('deleteFolder');
                     }
                   else
                     {

                     }  
                 }  
               else if (result.match(/FileHasbeenDeleted<;&&&&;>/gm))
                 {
                   document.getElementById('idForRefresh').value = document.getElementById('pathForHighlight').value;
                   creaDelRef('refreshIndex');
                   document.getElementById('all_files').value = "";
                   //result = result.replace(/FileHasbeenDeleted<;&&&&;>/gm,"");
                   //folderUpdateTreeStruct(result);
                   
                   //alert (result);
                 }
               else if (result.match(/FolderDeleteFail<;&&&&;>/))  
                 {
                   var FileName = result.replace(/FolderDeleteFail<;&&&&;>/gm,"");
                   alert(FileName);
                 }
               else if (result.match(/DeletedFromMainFolder<;&&&&;>/gm))
                 {
                   result = result.replace(/DeletedFromMainFolder<;&&&&;>/gm,"");
                   newFoldCont = result.split(/<--&&&;;&&%%-->/);
                   //prompt ('',newFoldCont[0]);
                   document.getElementById('indexcont').innerHTML = newFoldCont[0];
                   var parentPath = newFoldCont[1];
                   document.getElementById('DirContXml').value = newFoldCont[2];
                   pop_tab_pre(parentPath);
                   document.getElementById('idForRefresh').value = parentPath;
                   creaDelRef('refreshIndex');
                 }  
               else if (result.match(/DeletedFolder<;&&&&;>/gm))
                 {
                   folderUpdateTreeStruct(result); 
                   var ArrParentPath = new Array();
                   ArrParentPath = result.split(/<--&&&;;&&%%-->/);
                   var parentPath = ArrParentPath[1];
                   pop_tab_pre(parentPath);
                   document.getElementById('idForRefresh').value = parentPath;
                   creaDelRef('refreshIndex');
                 }
               else if (result.match(/Shared;;=;;DirectoryList-::-::-/gm))
                 {
                   result = result.replace(/Shared;;=;;DirectoryList-::-::-/g,"");
                   var dirArray = new Array();
                   dirArray = result.split(/<&&&:::&&&>/);
                   document.getElementById('DirXmlSharedTree').value = dirArray[0];
                   //prompt ("",dirArray[1]);
                   document.getElementById('allSharedFolderList').innerHTML = dirArray[1];
                 }
               else if (result.match(/You need to <a href=\\/members\\/>log in<\\/a>, or to refresh the page in order to access this functionality\\./))
                 {
                   alert ("Your session has expired. Please sign in again to reactivate your session.");
                 }
             }
           else
             {
               alert('There was a problem with the request.');
             }
         }
}

</script>
 <title> File Manager - Syvum Authoring Wizard </title>
</head>
<body>
<form method="post" id="rte" name='rte'>
$fileheader
<table width="100%" height="100%" cellpadding="0" cellspacing="0">
<tr><td><img height="2" width="2" alt="" title=""/></td></tr>
<tr width="100%" height="100%">
<td id = "indexconts" valign="top" width="20%" height="100%" onclick='closeAnyDiv();'><div id = "DivWithBorder" style = "border:1px solid #AAE;margin:0;position:relative;left:0px;width:100%; height:270; padding:0px;float:right;overflow:auto;"><div id="mainFolder" style="background-color:#c4cfde;"><img src="/s_i/minus.jpg" id="minusImage/u/$userID/" onclick="hideIndexCont();" />&nbsp;<a id="/u/$userID/" style="cursor:pointer;color:blue;background:yellow;" onclick="pop_tab_pre(this.id);" onmouseover="createfolder(this.id,event.clientX,event.clientY);">$userID</a></div>
 <div id = "indexcont" style = "position:relative;left:0px;width:100%; height:95%; padding:0px;float:right;background-color:white;">$alldirs$allfiles
 </div></div><div class="diveditmenu" ID="diveditmenu" style="position:absolute;top:4;left:110px; top:30px;z-index:5;visibility:hidden" onmouseover="AddBackColor();" onmouseout="remBackColorDiv();"></div><div id='borderForShared' style='border:1px solid #AAE;margin:0;position:relative;left:0px;width:100%; height:230; padding:0px;float:right;overflow:auto;'><div id="sharedFolder" style="background-color:#c4cfde;"><img src="/s_i/plus.jpg" id="minusImageShare" onclick="fetchAllSharedFolds();" />&nbsp;Shared Folder(s)</div><div id='allSharedFolderList'></div></div>
</td>
<td id="all_tabs" width="80%" height="100%" valign="top" onmouseover="closePopup();">

<!--New FM menubar code-->

<link rel="stylesheet" type="text/css" href="/saw/menubar.css" />
<script type ="text/javascript"src="/saw/menubarnew.js"></script>

<body>
  <ul id="nav">
        <li class="top"><a class="top_link"><span class="down">File</span></a>
                 <ul class="sub">
                          <li onclick="loadFolderPath();"><a href="#"><img src="/s_i/fm/newfile.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;&nbsp;&nbsp;New File</a></li>
                          <li onclick="newfolder();"><a href="#"><img src="/s_i/fm/newfolder.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;&nbsp;&nbsp;New Folder&#8230;</a></li>
                          <li onclick="uploadimage();"><a href="#"><img src="/s_i/fm/uploadfile.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;&nbsp;&nbsp;Upload File(s)&#8230;</a></li>
                 </ul>
        </li>
        <li class="top"><a class="top_link"><span class="down">Edit</span></a>
                 <ul class="sub">
                          <li onclick="editquiz();"><a href="#"><img src="/s_i/fm/editfile.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;&nbsp;&nbsp;Edit File&#8230;</a></li>
                          <li onclick="editIndex();"><a href="#"><img src="/s_i/fm/editfolder.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;&nbsp;&nbsp;Edit Folder&#8230;</a></li> 
                 </ul>
        </li>
        <li class="top"><a href="#" class="top_link"><span class="down">Delete</span></a>
                 <ul class="sub">
                          <li onclick="delSelectedFiles();"><a href="#"><img src="/s_i/fm/deletefile.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;&nbsp;&nbsp;Delete File</a></li>
                          <li onclick="delSelectedFolder();"><a href="#"><img src="/s_i/fm/deletefolder.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;&nbsp;&nbsp;Delete Folder</a></li>
                 </ul>

        </li>
        <li class="top"><a href="#" class="top_link"><span class="down">More Actions</span></a>
                 <ul class="sub">
                          <li onclick="editversions();"><a href="#"><img src="/s_i/fm/versionlist.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;&nbsp;&nbsp;Version List</a></li>
                          <li onclick="UpdateXmls();"><a href="#"><img src="/s_i/fm/changeproperties.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;&nbsp;&nbsp;Change Properties&#8230;</a></li>
                          <li onclick="shareFolderCont();"><a href="#"><img src="/s_i/fm/sharefolder.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;&nbsp;&nbsp;Share Folder&#8230;</a></li>
                          <li onclick="publishfile();"><a href="#"><img src="/s_i/fm/publishfile.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;&nbsp;&nbsp;Publish File(s)&#8230;</a></li>
                          <li onclick="copyfiles_1()"><a href="#"><img src="/s_i/fm/movecopy.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;&nbsp;&nbsp;Move/Copy File(s)&#8230;</a></li>
                 </ul>
        </li>
        <li class="top"><a href="#" class="top_link"><span class="down">Help</span></a>                  
                 <ul class="sub">                           
                          <li><a href="/saw/help/en/index.htm" target="_blank"><img src="/s_i/fm/help.gif" border ="0px" align="absmiddle">&nbsp;&nbsp;SAW - Help Manual</span></a></li>                           
                          <li onClick="window.open('/saw/help/en/aboutSaw.htm','mywindow','width=400,height=400')"><a href="#"><span style="margin-left:22px;">About SAW</span></a></li>                 
                 </ul>   
        </li>


  </ul>
</body>

<div id='dropMenuFileFold' style='position:absolute;top:4;background-color:#c4cfde;margin-left:0px; top:110px;z-index:5;visibility:hidden'></div>
<div id='dropMenuEdit' style='position:absolute;top:4;background-color:#c4cfde;margin-left:55px; top:110px;z-index:5;visibility:hidden'>
</div><div id='dropMenuDelete' style='position:absolute;top:4;background-color:#c4cfde;margin-left:105px; top:110px;z-index:5;visibility:hidden'></div>
<div id='dropMenuVersion' style='position:absolute;top:4;background-color:#c4cfde;margin-left:255px; top:110px;z-index:5;visibility:hidden'></div>
</div>
<div id = "syvum_1" style="width:100%;height:525px;">
  <div id = "tab_container1" style = "border:1px solid #AAE;margin:0;position:relative;left:0px;width:100%;height:90%; padding:0px;float:right;" onclick="closeAnyDiv()";>
    <iframe name="preview_act_ind" id="preview_act_ind" style="height:90%;width:100%;position:absolute;" FRAMEBORDER="0" src="/u/$userID/?edit"></iframe>
  </div>
</div>

<!--<div id = "syvum_2" style="width:100%;height:100%;display:none;">
 <div id = "tab_container2" style = "border:1px solid #AAE;margin:0;position:relative;left:0px;width:100%; height:90%; padding:0px;float:right;">
  <iframe name="edit_act_ind" style="height:90%;width:100%;" FRAMEBORDER="0" src="/cgi/fs/tools.pl?/u/$userID/"></iframe>
 </div>
</div>
<div id = "syvum_3" style="width:100%;height:100%;display:none;">
 <div id = "tab_container3" style = "border:1px solid #AAE;margin:0;position:relative;left:0px;width:100%; height:90%; padding:0px;float:right;">
 </div>
</div>-->
</td>
</tr></table>
<div id="tablestats1" name="tablestats1"></div>
<input type="hidden" value="" name = "SaveInThisFolder" id = "SaveInThisFolder" />
<input type="hidden" value="" name = "pathindex" id = "pathindex" />
<input type="hidden" value="" name = "idForRefresh" id = "idForRefresh" />
<input type="hidden" value="" name = "FolderPathUpload" id = "FolderPathUpload" />
<input type="hidden" value="" name="userfoldername" id="userfoldername" />
<input type="hidden" value="" name="plusImageClickedFor" id="plusImageClickedFor" />
<input type="hidden" value="" name="IndexUpdate" id="IndexUpdate" />
<input type="hidden" id="pathdelete" name="pathdelete" />
<input type="hidden" id="pathForHighlight" name="pathForHighlight" value="/u/$userID/"/>
<input type="hidden" id="RemoveHighlight" name="RemoveHighlight" value="/u/$userID/"/>
<input type="hidden" id="userIDShare" name="userIDShare" value="$userID"/>
<input type="hidden" id="status" name="status" />
<textarea rows="30" cols="60" id = "DirContXml" style="display:none">$XmlContent</textarea>
<textarea rows="30" cols="60" id = "DirXmlSharedTree" style="display:none">$XmlContent</textarea>
<div style="display:none">
<textarea rows="30" cols="60" name="currentIndexContent" id = "currentIndexContent" style="display:none"></textarea>
</div>
<textarea id="all_files" style="display:none"></textarea>
<input type="button" id="putContEditor" name="putContEditor" style="display:none" onclick="SetEditorCont();"/>
<textarea rows="20" cols="20" id="addToEditorRepack" name="addToEditorRepack" style="display:none"></textarea>
<input type='button' id='refreshIndex' name='refreshIndex' onclick='hightLightRefresh(this.id)' style="display:none" />
<input type="hidden" value="/u/$userID/" name = "mainFolderPath" id = "mainFolderPath" />
</form>
<form target="_blank" method="post" id="pub_file_ind" name="pub_file_ind" action="/cgi/fs/publish.pl">
<input type = "hidden" name = "pub_file" id = "pub_file" />
<input type = "hidden" name = "pub_pathindex" id = "pub_pathindex" />
<input type = "hidden" name = "startpublish" id = "startpublish" value="true"/>
</form>
</body>
EOF
  }
 
 
  
  1;
