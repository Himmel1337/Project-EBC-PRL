open (Read, '<', "data.txt") || die "File is not exist";

$minLengthWord = 1;
$maxLengthWord = 20;
$minFrequencyWord = 3;
$maxFrequencyWord = 1;
$typeWrite = "IDF";


# @uniqueWords;
@allDocumentWords;
@countWords;
$countDocument = 0;
@clases;


while(<Read>){
	chomp;
	my @line = split;
	push(@clases, $line[0]);
	my @string = @line[1 ... scalar @line - 1];

	# my @dokumentWords;
	my $class = $line[0];

	foreach $word (@string){

		$word =~ s|<.+?>| |g, $word;
		$word =~ s|\W||g, $word;
		$word =~ s|\d||g, $word;
		$word =~ s|\s||g, $word;
		$word = uc($word);

		if (length $word > $minLengthWord && length $word < $maxLengthWord) {

			push(@dokumentWords, $word);

			if (scalar @uniqueWords < 1) {
				push(@uniqueWords, $word);
			}

			my $count = 0;
			foreach $uniqueWord (@uniqueWords) {
				unless ($uniqueWord eq $word) {
					$count++;
				}
			}

			if ($count == scalar @uniqueWords){
				push (@uniqueWords, $word);
			}				
		}
	}

	splice @allDocumentWords, $countDocument, 0, \@dokumentWords;

	$countDocument++;

}

for ($i = 0; $i < @uniqueWords; $i++){

	my $countWord = 0;

	for ($j = 0; $j < @allDocumentWords; $j++){
		
		my @words = @{ $allDocumentWords[$j]};

		foreach $word (@words){
			if ($uniqueWords[$i] eq $word){
				$countWord++;
			}
		}
	}

	push (@countWords, $countWord);
}

@minWords;
@maxWords;

for ($i = 0; $i < @countWords; $i++){
	if ($countWords[$i] >= $minFrequencyWord){
		push (@minWords, $uniqueWords[$i]);
	}

	if ($countWords[$i] <= $maxFrequencyWord){
		push (@maxWords, $uniqueWords[$i]);
	}
}

if ($typeWrite eq "TF") {
	TFWrite();
} elsif ($typeWrite eq "TP") {
	TPWrite();
} elsif ($typeWrite eq "IDF") {
	IDFWrite();
} else {
	die "type write is not exist";
}

## TF write ##

sub TFWrite {

open (TF, '>', "TF.txt") || die "Soubor s daty neexistuje";

	foreach $word (@minWords){
			printf TF $word;
			printf TF " ";
	}

	printf TF "CLASS";
	printf TF "\n";


	for ($i = 0; $i < @allDocumentWords; $i++){

		foreach $uWord(@minWords){

			my $countWord = 0;
			my @words = @{ $allDocumentWords[$i]};

			foreach $word (@words){
				if ($uWord eq $word){
				$countWord++;
				}
			}

			printf TF $countWord;

			for (1 .. length $uWord){
				printf TF " "; 
			}
		}

		printf TF $clases[$i];
		printf TF "\n";
	}

	close TF;
}


## TF write ##


## TP write ##
sub TPWrite {
	open (TP, '>', "TP.txt") || die "Soubor s daty neexistuje";

	foreach $word (@minWords){
			printf TP $word;
			printf TP " ";
	}

	printf TP "CLASS";
	printf TP "\n";


	for ($i = 0; $i < @allDocumentWords; $i++){

		foreach $uWord(@minWords){

			my $countWord = 0;
			my @words = @{ $allDocumentWords[$i]};

			foreach $word (@words){
				if ($uWord eq $word){
				$countWord++;
				}
			}

			$countWord > 0 ? printf TP "1" : printf TP "0";

			for (1 .. length $uWord){
				printf TP " "; 
			}
		}

		printf TP $clases[$i];
		printf TP "\n";
	}
	close (TP);
}


## TP write ##

## IDF write ##

sub IDFWrite {
	open ( IDF, '>', " IDF.txt") || die "Soubor s daty neexistuje";

	foreach $word (@maxWords){
				printf IDF $word;
				printf IDF " ";
		}

		printf IDF "CLASS";
		printf IDF "\n";


	for ($i = 0; $i < @allDocumentWords; $i++){

		foreach $uWord(@maxWords){

			my $countWord = 0;
			my @words = @{ $allDocumentWords[$i]};

			foreach $word (@words){
				if ($uWord eq $word){
				$countWord++;
				}
			}

			printf IDF $countWord;

			for (1 .. length $uWord){
				printf IDF " "; 
			}
		}

		printf IDF $clases[$i];
		printf IDF "\n";
	}

	close (IDF);
}

## IDF write ##