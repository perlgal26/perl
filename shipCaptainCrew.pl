#!/usr/bin/perl

$roll = 1;

$die1="";
$die2="";
$die3="";
$die4="";
$die5="";

$keep1=0;
$keep2=0;
$keep3=0;
$keep4=0;
$keep5=0;

$found6 = 0;
$found5=0;
$found4=0;


print qq+

                                                                           
,---.|    o         ,---.          |         o         ,---.               
`---.|---..,---.    |    ,---.,---.|--- ,---..,---.    |    ,---.,---.. . .
    ||   |||   |    |    ,---||   ||    ,---|||   |    |    |    |---'| | |
`---'`   '`|---'    `---'`---^|---'`---'`---^``   '    `---'`    `---'`-'-'
           |                  |                                            
   
          +;

for ($i=1;$i<=3;$i++) {
	
	print "\n\nThis is roll number $i. Hit any key to roll. ";
	$in = <>;

	$die1=int(rand(6)) + 1;
	$die2=int(rand(6)) + 1;
	$die3=int(rand(6)) + 1;
	$die4=int(rand(6)) + 1;
	$die5=int(rand(6)) + 1;


	if ($found6==0) {
		print "Your roll is $die1 $die2 $die3 $die4 $die5\n\n";
		if ($die1==6 || $die2==6 || $die3==6 || $die4==6 || $die5==6) {
			$found6=1;
			print "Congratulations! You rolled a 6!\n";
	
			if ($die1==5 || $die2==5 || $die3==5 || $die4==5 || $die5==5) {
				$found5=1;
				print "Congratulations! You rolled a 5!\n";
					if ($die1==4 || $die2==4 || $die3==4 || $die4==4 || $die5==4) {
						$found4=1;
						print "Congratulations! You rolled a 4!\n";
					
						print "Your score is " ;
						print (($die1 + $die2 + $die3 + $die4+$die5) -6 - 5-4 );
						print ".\n";
						if ($i<3) {
							print "Would you like to roll again?  (y/n)  ";
							$in=<>; chomp $in;
							if ($in eq "n") {
								print "Ok! That's your final score!\n";
								exit(1);
							} else {
								print  "Good luck!\n";
							}
						}
					} else {
						print "You still need a 4. \n";
					}
			} else {
				print "You still need a 5. \n";
			}
		} else {
			print "You still need a 6. ";
		}
	} elsif ($found5==0) {
	print "Your roll is $die1 $die2 $die3 $die4\n\n";

		if ($die1==5 || $die2==5 || $die3==5 || $die4==5 ) {
				$found5=1;
				print "Congratulations! You rolled a 5!\n";
					if ($die1==4 || $die2==4 || $die3==4 || $die4==4 ) {
						$found4=1;
						print "Congratulations! You rolled a 4!\n";
						print "Your score is " ;
						print (($die1 + $die2 + $die3 + $die4)  - 5-4 );
						print ".\n";
						if ($i<3) {
							print "Would you like to roll again?  (y/n) ";
							$in=<>; chomp $in;
							if ($in eq "n") {
								print "Ok! That's your final score!\n";
								exit(1);
							} else {
								print  "Good luck!\n";
							}
						}
					} else {
						print "You still need a 4. \n";
					}
			} else {
				print "You still need a 5. ";
			}
	} elsif ($found4==0) {
	print "Your roll is $die1 $die2 $die3 \n\n";
	
		if ($die1==4 || $die2==4 || $die3==4 ) {
						$found4=1;
						print "Congratulations! You rolled a 4!\n";
						print "Your score is ";
						print (($die1 + $die2 + $die3 )  -4 );
						print ".\n";
						if ($i<3) {
							print "Would you like to roll again?  (y/n)  ";
							$in=<>; chomp $in;
							
							if ($in eq "n") {
								print "Ok! That's your final score!\n";
								exit(1);
							} else {
								print  "Good luck!\n";
							}
						}
					} else {
						print "You still need a 4. \n";
					}
	} else {
		print "Your roll is $die1 $die2\n\n";
		print "Your new score is ";
		print $die1 + $die2;
		print ".\n";
		if ($i<3) {
			print "Would you like to roll again?  (y/n)  ";
			$in=<>; chomp $in;
			if ($in eq "n") {
				print "Ok! That's your final score!\n";
				exit(1);
			} else {
				print  "Good luck!\n";
			}
		}
	}

}
if ($found4==0) {
	print "\nSorry! Since you didn't get the 3 required numbers, you lose!\n\n";
}	
print "\n";