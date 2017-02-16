#!/bin/bash
module load jellyfish/2.2.5

kmer=$1
a1=Black-Ab-F_S21_L005_R1_001.fastq.gz
a2=Black-Ab-F_S21_L005_R2_001.fastq.gz
b1=Black-Ab-M_S22_L005_R1_001.fastq.gz
b2=Black-Ab-M_S22_L005_R2_001.fastq.gz

jellyfish count -C -m $kmer -s 1000000000 -t 10 <(zcat ${a1}) <(zcat ${a2}) <(zcat ${b1}) <(zcat ${b2}) -o reads_K${kmer}.jf
jellyfish histo -t 16 reads_K${kmer}.jf > reads_K${kmer}.histo


# once the histo file is created, visit http://qb.cshl.edu/genomescope/ website to upload the histo file

