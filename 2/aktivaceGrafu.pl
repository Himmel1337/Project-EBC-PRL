open (Read, '<', "sit+parametry.txt") || die "File is not exist";

my @nodeTypes;

my %linkTypes;
my %initialA; 
my %nodes;
my %links;
my %linkWeights;

my $beta;
my $iterationsNo;
my $calibration;
my $a;
my $b;
my $c;
my $t;
my $sumIn = 0;

while(<Read>){
	chomp;
	my @line = split(/\s+/);

	if ($line[0] eq "nt")  {
		push(@nodeTypes, $line[1]);
	} 
	elsif ($line[0] eq "ltra") {
		$linkTypes{$line[1]} = [$line[2]];
	}
	elsif ($line[0] eq "n") {
		addNode($line[1], $line[2], $line[3]);
	}
	elsif ($line[0] eq "l") {
		addLink($line[1], $line[2], $line[3]);
	}
	elsif ($line[0] eq "ia") {
		$nodes{$line[1]} = {activationLevel => $line[2], startEdge => 1};
	}
	elsif ($line[0] eq "lw") {
		$linkWeights{$line[1]} = {weight => $line[2]};
	}
	elsif ($line[0] eq "Beta") {
		$beta = $line[1];
	}
	elsif ($line[0] eq "IterationsNo") {
		$iterationsNo = $line[1];
	}
	elsif ($line[0] eq "Calibration") {
		$calibration = $line[1];
	}
	elsif ($line[0] eq "a") {
		$a = $line[1];
	}
	elsif ($line[0] eq "b") {
		$b = $line[1];
	}
	elsif ($line[0] eq "c") {
		$c = $line[1];
	}
	elsif ($line[0] eq "t") {
		$t = $line[1];
	}
}
close(Read);

print "I", "\t";
foreach $key (sort keys %nodes) {
   print "$key\t";
}

print "\n";

setWeight();



for(my $i = 0; $i <= $iterationsNo; $i++){
	print "$i\t";

	if ($i > 0){
		iteration();
	}

	foreach $key (sort keys %nodes) {
	   printf "%.2f ", $nodes{$key}{activationLevel};
	   print "\t";
	}

	print "\n";
}

sub addNode{
	my ($nodeId, $nodeType, $importance) = @_;
	$nodes{$nodeId} = {nodeType => $nodeType, importance => $importance, activationLevel => 0, changeValue => 0, startEdge => 0};
}

sub addLink{
	my ($initialNode, $terminalNode, $linkType) = @_;
	$links{$initialNode.$terminalNode} = {initialNode => $initialNode, terminalNode => $terminalNode, linkType => $linkType, weight => 0};
}

sub setWeight{

	foreach $key (sort keys %links){
		$links{$key}{weight} = $linkWeights{$links{$key}{linkType}}{weight};
	}
}

sub iteration{

	foreach $key (sort keys %nodes) {
		$nodes{$key}{changeValue} = 0;
	}

	foreach $key (sort keys %nodes) {

		if ($nodes{$key}{activationLevel} > $t){

			my $xi = $nodes{$key}{activationLevel};
			my $outdegree = 0;
			my @keyLinks;
			my %keyNodes;

			foreach $keyLink (sort keys %links){
				if ($links{$keyLink}{initialNode} eq $key){
					$outdegree++;
					push (@keyLinks, $keyLink);
					$keyNodes{$links{$keyLink}{terminalNode}} = {weight => $links{$keyLink}{weight}};
				} elsif ($links{$keyLink}{terminalNode} eq $key){
					$outdegree++;
					push (@keyLinks, $keyLink);
					$keyNodes{$links{$keyLink}{initialNode}} = {weight => $links{$keyLink}{weight}};
				}
			}

			$outValue = $xi * 1 / $outdegree ** $beta;

			foreach $keyNode (sort keys %keyNodes){	
				$nodes{$keyNode}{changeValue} += $outValue * $keyNodes{$keyNode}{weight};
			}
		}
	}


	my $sum = 0;
	foreach $key (sort keys %nodes) {
		my $outdegree = 0;
		foreach $keyLink (sort keys %links){
				if ($links{$keyLink}{initialNode} eq $key || $links{$keyLink}{terminalNode} eq $key){
					$outdegree++;
				}
		}

		$nodes{$key}{changeValue} = ($a * $nodes{$key}{activationLevel}) + 
						($b * $nodes{$key}{changeValue}) + 
						($c * ($nodes{$key}{activationLevel} * $outdegree));
		$sum += $nodes{$key}{changeValue};
		$sumIn += $nodes{$key}{changeValue};
	}

	foreach $key (sort keys %nodes) {
		if ($calibration eq "None") {
			$nodes{$key}{activationLevel} = $nodes{$key}{changeValue};
		} elsif($calibration eq "ConservationOfTotalActivation") {
			$nodes{$key}{activationLevel} = $nodes{$key}{changeValue} / $sum;
		} elsif($calibration eq "ConservationOfInitialActivation") {
			if ($nodes{$key}{startEdge} != 1){
				$nodes{$key}{activationLevel} = $nodes{$key}{changeValue} / $sumIn;
			}
		} else {
			die "Calibration is not exist";
		}
	}
}
