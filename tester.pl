#!/usr/bin/perl


$fileName = $ARGV[0];

$results = `spim -file $fileName`; 

$results =~ s/\n//gi;
$results =~ s|.*/sw/share/spim//trap\.handler||i;
print "$results\n";











