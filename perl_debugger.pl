#!/usr/bin/perl -w

# Script to list out the filenames (in the pwd) that contains specific pattern.

#Enabling slurp mode
$/=undef;

# Function : get_pattern
# Description : to get the pattern to be matched in files.
sub get_pattern
{
    my $pattern;
    print "Enter search string: ";
    chomp ($pattern = <STDIN> );
    return $pattern;
}

# Function : find_files
# Description : to get list of filenames that contains the input pattern.
sub find_files
{
    my $pattern = shift;
    my (@files,@list,$file);
    
    # using glob, obtaining the filenames,
    @files = <./*>;
    
    # taking out the filenames that contains pattern.
    @list = grep {
        $file = $_;
        open $FH,"$file";
        @lines = <$FH>;
        $count = grep { /$pattern/ } @lines;
        $file if($count);
    } @files;
    return @list;
}
# to obtain the pattern from STDIN
$pattern = get_pattern();

# to find-out the list of filenames which has the input pattern.
@list = find_files($pattern);

print join "\n",@list;