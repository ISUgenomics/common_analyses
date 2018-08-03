#!/bin/bash
module load samtools
module load hisat2
R1="$1"
R2=$(echo $R1 |sed 's/_1.fastq.gz/_2.fastq.gz/g')
out=$(echo $R1 |cut -f 1 -d "_")
hisat2 -p 28 -x TAIR10_chr_all --dta-cufflinks -1 $R1 -2 $R2 > ${out}.sam
samtools view -@ 28 -b -o ${out}.bam ${out}.sam
samtools sort -o ${out}_sorted.bam -T ${out}_temp --threads 28 ${out}.bam

