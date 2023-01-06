# RiceReseqCNV
Mining CNV based on rice Nipponbare genome using resequencing data.
If you have any questions, suggestions or interests about this project, please feel free to contact: chenomics@163.com or zhuochen@genetics.ac.cn.

## 1. Description
Accessions with high depth (> 20 × ) short-read resequencing data were used to detect copy number variations based on the Nipponbare genome (IRGSP1.0). We first aligned the short-read resequencing data of NIP (SRA accession: SRX734432) to the Nipponbare genome (IRGSP1.0) and filtered out the reads with mapping quality less than 30. The coverage depth of each base was calculated using the SAMtools depth function. The coverage ratio and mean depth values were then calculated using a non-overlapping 1-Kbp window. For NIP, windows with a coverage ratio over 0.75 and a mean depth within one standard deviation (STDEV) from the mean depth of the whole genome were kept for further CNV detection. For a query accession, the coverage ratio and mean depth of each 1-Kbp window were calculated, and samples with a STDEV over 1/3 of the mean depth of whole genome were abandoned due to severe sequencing bias. Finally, windows with coverage ratio over 0.75 and mean depth over three STDEV from or two-fold of the mean depth of whole genome were defined as CNVs.

## 2. Usage:
Check pipe_cnv.w1000s100.sh

## Reference
https://doi.org/10.1016/j.cell.2021.04.046
