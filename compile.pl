#! /usr/bin/perl


print "Compiling.";

$messages = `java -classpath ../antlr:./ antlr/Tool TigerSemant.g`;

if($messages ne "")
{print "$messages";}
else
{
$messages = `javac TigerSemant.java`;


if($messages ne "")
{print "$messages";}

}

1;
