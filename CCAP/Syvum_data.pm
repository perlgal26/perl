package Syvum_data;

use Syvum::Common::DBInit;
use strict;

my $dbh = "";


sub saveQuiz
  {
    my $FilePath = shift;
    my $FileData = shift;
    my $TxtData = shift;
    my $TxtVersion = shift;
    
    my $ret = 0;
    
    $dbh = Syvum::Common::DBInit::getHandler();
    my $InsSql = "";
    my $QFilePath = $dbh->quote($FilePath);
    my $QFileData = $dbh->quote($FileData);
    my $QTxtData = $dbh->quote($TxtData);
    my $QTxtVersion = $dbh->quote($TxtVersion);
    $InsSql = "Insert into syvum_data (FilePath, FileData, FileTxt, TxtVersions) values (".$QFilePath.", ".$QFileData.", ".$QTxtData.", ".$QTxtVersion.")";
    my $InsSth = $dbh->prepare($InsSql);
    $ret = $InsSth->execute;
    
    return ($ret);
  }

sub updateSyvum_data
  {
    my $FilePath = shift;
    my $FileData = shift;
    my $TxtData = shift;
    my $diff = shift;
    
    my $ret = 0;
    
    $dbh = Syvum::Common::DBInit::getHandler();
    my $InsSql = "";
    my $QFilePath = $dbh->quote($FilePath);
    my $QFileData = $dbh->quote($FileData);
    my $QTxtData = $dbh->quote($TxtData);
    my $Qdiff = $dbh->quote($diff);
    
    my $sql = "";
    $sql = "update syvum_data set FileData=".$QFileData.", FileTxt=".$QTxtData.", TxtVersions=".$Qdiff." where FilePath=".$QFilePath;
    my $sth = $dbh->prepare($sql);
    my $result = $sth->execute;
    
  }

sub doesFileExistSyvum_data
  {
    my $FilePath = shift;
    
    my $ret = 0;
    $dbh = Syvum::Common::DBInit::getHandler();
    my $QFilePath = $dbh->quote($FilePath);
    my $sql = "select FilePath from syvum_data where FilePath = $QFilePath";
    my $sth = $dbh->prepare($sql);
    $sth->execute;
    my @array = $sth->fetchrow_array();
    if (scalar @array > 0)
      {
        $ret = 1;
      }
    return ($ret);
  }

sub getAllDataSyvum_data
  {
    my $FilePath = shift;
    my $userID = shift;
    
#    my $perm = Syvum::Fs::Dirs::checkPermissions($userID, $FilePath, Syvum::Fs::Dirs::getViewAction());
#    if ($perm < 1)
#      {
#        print "Content-type: text/html\n\n";
#        print "Not allowed";
#        die;
#      }
    $dbh = Syvum::Common::DBInit::getHandler();
    my $QFilePath = $dbh->quote($FilePath);
    my $tab_cont = "select FilePath,FileData,FileTxt,TxtVersions from syvum_data where FilePath = ".$QFilePath;
    my $tab_cont1 = $dbh->prepare($tab_cont);
    $tab_cont1->execute();
    my @temp = $tab_cont1->fetchrow_array;
    return (\@temp);
  }


sub getSelectedFieldData
  {
    my $Path = shift;
    my $fieldName = shift;
    my $userID = shift;
    
    my $perm = Syvum::Fs::Dirs::checkPermissions($userID, $Path, Syvum::Fs::Dirs::getEditAction());
    if ($perm < 1)
      {
        print "Content-type: text/html\n\n";
        print "Not allowed";
        die;
      }
    if (!$fieldName || length ($fieldName) == 0)
      {
        $fieldName = "FilePath";
      }
    my $dbh = Syvum::Common::DBInit::getHandler();
    my $QFilePath = $dbh->quote($Path);
    my $tab_cont = "select ".$fieldName." from syvum_data where filepath = ".$QFilePath;
    my $tab_cont1 = $dbh->prepare($tab_cont);
    my @files;    
    $tab_cont1->execute();
    my $row;
    while ($row = $tab_cont1->fetchrow_array()) 
      {
        push (@files, $row);
      }
    return (\@files);
  }
  
sub searchEquationsSyvum_data
  {
    my $keywords = shift;
    my $pathforsearch = shift;
    
    my $dbh = Syvum::Common::DBInit::getHandler();
    $keywords = "%".$keywords."%";
    my $encTag = "%<enc%";
    $pathforsearch = $pathforsearch."%";
    
    my $quotedKey = $dbh->quote($keywords);
    my $quotedpath = $dbh->quote($pathforsearch);
    my $quoteEncTag = $dbh->quote($encTag);
    my $query = "select FilePath from syvum_data where FileData like ".$quotedKey." and FileData like ".$quoteEncTag." and FilePath like ".$quotedpath;
    my $prepQuery = $dbh->prepare($query);
    $prepQuery->execute;
    my @filepaths;
    my $row;
    while ($row = $prepQuery->fetchrow_array)
      {
        push (@filepaths,$row);
      }
    return (\@filepaths); 
  }
  
sub permDelSyvum_data
  {
    my $pathForSyvumData = shift;
    my $userID = shift;
    
    (my $path = $pathForSyvumData) =~ s/\.xml$/\.tdf/;
    my $perm = Syvum::Fs::Dirs::checkPermissions($userID, $path, Syvum::Fs::Dirs::getDeleteAction());
    if ($perm < 1)
      {
        print "Content-type: text/html\n\n";
        print "Not allowed";
        die;
      }
    my $dbh = Syvum::Common::DBInit::getHandler(); 
    
    my $qpathForSyvumData = $dbh->quote($pathForSyvumData);
    my $query = "delete from syvum_data where filepath = ".$qpathForSyvumData;  

    my $prepQuery = $dbh->prepare($query);
    $prepQuery->execute();
  }

sub getAllFilepathsSyvum_data
  {
    my @files;
    my $tab_cont = "select filepath from syvum_data";
    my $tab_cont1 = $dbh->prepare($tab_cont);
        
    $tab_cont1->execute();
    my $row;
    while ($row = $tab_cont1->fetchrow_array()) 
      {
        push (@files, $row);
      }
    return (\@files);  
  }

  
1;
