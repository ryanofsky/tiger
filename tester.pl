#!/usr/bin/perl


$fileName = $ARGV[0];

$results = `spim -file $fileName 2> results.out`; 



open(RESFILE, "<results.out");
@theLines = <RESFILE>;
close(RESFILE);

$totalOutput = "";

foreach $line (@theLines)
{$totalOutput .= $line;}

$totalOutput =~ s|.*/sw/share/spim//trap\.handler||i;
print "$totalOutput\n\n";











