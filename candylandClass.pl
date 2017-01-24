#!/usr/bin/perl

$numPlayers = 3; #or @ARGV[0]

%spaces = ();
for ($i=0;$i<25;$i++){
	$spaces{0 +$i*6}{"color"} = "red";
	$spaces{1 +$i*6}{"color"} = "purple";
	$spaces{2 +$i*6}{"color"} = "yellow";
	$spaces{3 +$i*6}{"color"} = "blue";
	$spaces{4 +$i*6}{"color"} = "orange";
	$spaces{5 +$i*6}{"color"} = "green";
}

$spaces{4}{"special"} = 60;
$spaces{14}{"special"} = 70;
$spaces{34}{"special"} = 100;

@playerSpot = ();
for ($p=0;$p<$numPlayers;$p++) {
	$playerSpot[$p]=-1;
}

$turn=0;
$gameOver=0;
while ($gameOver==0) {

	$currentPlayer =  $turn % $numPlayers;
	print "Player $currentPlayer -  it's your turn! Hit enter to draw a card.";
	$x = <>;
	
	drawCard();
	print "\tYou drew $numSquares $colorDrawn\n";
	
	$currentSpace = $playerSpot[$currentPlayer];
	$hops=1;
	while ( $spaces{$currentSpace + $hops}{"color"} ne  $colorDrawn && 	($currentSpace + $hops) <=155) {

		$hops++;
	}

	$currentSpace = $currentSpace + $hops;
	if ($numSquares == 2) {
		$currentSpace = $currentSpace+6;
	}
	$playerSpot[$currentPlayer] = $currentSpace;
	
	if ($spaces{$currentSpace}{"special"} ne "") {
		$currentSpace = $spaces{$currentSpace}{"special"};
		print "\tAwesome! A special spot!\n";
	}
	
	print "\tPlayer $currentPlayer is now in spot $currentSpace\n\n";

	if ($currentSpace>155) {
		print "PLAYER $currentPlayer WINS!!!!!!\n\n\n";
		$gameOver=1;
	}


	$turn++;
}


sub drawCard() {
	$numSquares = int(rand(2)) + 1;
	@colors = ("red","yellow","blue","purple","green","orange");

	$colorDrawn = $colors[ int(rand(6)) ];
	
	
}