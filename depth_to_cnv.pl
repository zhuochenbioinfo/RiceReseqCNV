use strict;
use warnings;

my $in = shift;

die unless(defined $in);

my $stat = "$in.stat";
my $out = "$in.cnv_tag";

open(IN,"<$stat") or die $!;
my $mean;
my $stdev;
while(<IN>){
	chomp;
	if($_ =~ /^mean=(\S+)$/){
		$mean = $1;
	}elsif($_ =~ /^stdev=(\S+)$/){
		$stdev = $1;
	}
}
close IN;

if($stdev >= $mean/3){
	die "#ERROR: The standard error of depth of this sample is too big! This data may not be proper for CNV analysis.\n#ERROR: mean=$mean stdev=$stdev\n";
}

open(IN,"<$in") or die $!;
open(OUT,">$out");
while(<IN>){
	chomp;
	my($chr,$start,$end,$coverage,$depth) = split/\t/;
	my $geno = "NA";
	if($coverage >= 0.75){
		if($depth >= $mean + 3 * $stdev){
			$geno = "CNV";
		}elsif($depth > $mean * 2){
			$geno = "CNV";
		}elsif($depth <= $mean + $stdev * 2){
			$geno = "noCNV";
		}
	}
	my $depth_ratio = $depth/$mean;
	print OUT "$chr\t$start\t$end\t$coverage\t$depth\t$depth_ratio\t$geno\n";
}
close IN;
close OUT;

