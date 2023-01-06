use strict;
use warnings;

my($out_prefix, @bams) = @ARGV;

my $usage = "USAGE:\nperl $0 <output prefix> <bam1> <bam2> ...\n";

die $usage unless(@bams > 0 and defined $out_prefix);

# softwares and scripts
my $bedtools = "bedtools";
my $bam2depth = "window_cov_depth.step.pl";
my $filter_bed = "filter_bed.pl";
my $Rscript = "Rscript";
my $depth_stat = "window_depth_stat.noheader.r";
my $depth2cnv = "depth_to_cnv.pl";

# parameters
my $window = 1000;
my $step = 100;
my $cover = 0.75;
# This is a BED file containing regions that need to be filtered in CNV analysis, such as regions with abnormal coverage in reference sequencing data
my $ref_bed = "Nipponbare.win1000.step100.windowed.depth.thin";
# This is a file for gene information
my $gene_bed = "MSU.genes.bed.funricegene.txt";

# run pipe
my $bams_join = "";
foreach my $bam(@bams){
	chomp($bam);
	$bams_join .= " --bam $bam";
}

system("perl $bam2depth $bams_join --out $out_prefix.windowed.depth --window $window --step $step");
system("perl $filter_bed $ref_bed $out_prefix.windowed.depth > $out_prefix.windowed.depth.filtered");
system("$Rscript scripts/window_depth_stat.noheader.r $out_prefix.windowed.depth.filtered > $out_prefix.windowed.depth.filtered.stat");
system("perl $depth2cnv $out_prefix.windowed.depth.filtered");
system("cat $out_prefix.windowed.depth.filtered.cnv_tag |awk '{if(\$7 == \"CNV\")print \$0}' > $out_prefix.windowed.depth.filtered.cnv");
system("$bedtools intersect -a $out_prefix.windowed.depth.filtered.cnv -b $gene_bed -wao|awk '{if(\$7 != \".\" && \$11 != \"-\")print}' > $out_prefix.windowed.depth.filtered.cnv.known");


