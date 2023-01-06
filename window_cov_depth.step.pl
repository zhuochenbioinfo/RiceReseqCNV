use strict;
use warnings;
use Getopt::Long;

my $samtools = "samtools";

my($mapq,$output,$window,$step);
my @bams = ();

my $usage = "USAGE:\nperl $0 --bam <bam1> --bam <bam2> --out <output file>\n";
$usage .= "Optional parameters:\n";
$usage .= "--mapq <map quality score threshold>, Default=10\n";
$usage .= "--window <window>, Default=100\n";
$usage .= "--step <step>, Default=<window>\n";

GetOptions(
	"bam=s" => \@bams,
	"out=s" => \$output,
	"mapq=s" => \$mapq,
	"window=s" => \$window,
	"step=s" => \$step,
) or die $usage;

die $usage unless(@bams > 0 and defined $output);

unless(defined $window){
	$window = 100;
}
unless(defined $step){
	$step = $window;
}

unless(defined $mapq){
	$mapq = 10;
}

my $bams_join = "";
foreach my $bam(@bams){
	chomp($bam);
	$bams_join .= " $bam";
}

open(IN,"$samtools depth -q $mapq -a $bams_join|") or die $!;

my $cov_global = 0; # global cover count
my $len_global = 0; # global base count
my $sum_global = 0; # global depth sum

my %hash_window;

while(<IN>){
	chomp;
	my($chr,$pos,@depths) = split/\t/;
	my $depth = 0;
	foreach my $subdepth(@depths){
		$depth += $subdepth;
	}
	my $rank = int($pos/$step);
	for(my $i = $rank; $i >= 0; $i--){
		last if($i * $step + $window <= $pos);
		$hash_window{$chr}{$i}{len} ++;
		$len_global ++;
		$hash_window{$chr}{$i}{cov} += 0;
		$hash_window{$chr}{$i}{sum} += 0;
		if($depth > 0){
			$cov_global ++;
			$sum_global += $depth;
			$hash_window{$chr}{$i}{cov} ++;
			$hash_window{$chr}{$i}{sum} += $depth;
		}
	}
}
close IN;

open(OUT,">$output");
open(STAT,">$output.raw_stat");

my $mean_depth_global = $sum_global/$cov_global;
my $cover_rate_global = $cov_global/$len_global;

print STAT "len_global=$len_global\n";
print STAT "cov_global=$cov_global\n";
print STAT "sum_global=$sum_global\n";
print STAT "cover_rate_global=$cover_rate_global\n";
print STAT "mean_depth_global=$mean_depth_global\n";
print STAT "window=$window\n";
print STAT "step=$step\n";

print OUT "#chr\tstart\tend\tcov\tdepth\n";

foreach my $chr(sort keys %hash_window){
	foreach my $rank(sort {$a <=> $b} keys %{$hash_window{$chr}}){
		my $start = $step * $rank + 1;
		my $end = $step * $rank + $window;
		my $cov = $hash_window{$chr}{$rank}{cov};
		my $sum = $hash_window{$chr}{$rank}{sum};
		my $len = $hash_window{$chr}{$rank}{len};
		my $mean_depth = 0;
		my $cov_rate = 0;
		if($cov > 0){
			$cov_rate = $cov/$len;
			$mean_depth = $sum/$cov;
		}
		print OUT "$chr\t$start\t$end\t$cov_rate\t$mean_depth\n";
	}
}
close OUT;
close STAT;

