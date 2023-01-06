use strict;
use warnings;

my $ref_bed = shift;
my $in_bed = shift;

my $usage = "UASGE:\nperl $0 <ref bed> <out bed>\n";
die $usage unless(defined $in_bed);

open(IN,"<$ref_bed") or die $!;
my %hash_bed;
while(<IN>){
	chomp;
	my($chr,$start,$end) = split/\t/;
	$hash_bed{$chr}{$start}{$end}{pick} = 0;
}
close IN;

open(IN,"<$in_bed") or die $!;
while(<IN>){
	chomp;
	my($chr,$start,$end) = split/\t/;
	next unless(exists $hash_bed{$chr});
	next unless(exists $hash_bed{$chr}{$start});
	next unless(exists $hash_bed{$chr}{$start}{$end});
	print $_."\n";
}
close IN;
