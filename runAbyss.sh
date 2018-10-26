#!/bin/bash
module load GIF/transAbyss/prereqs
srr=$1
len=$(zcat ${srr}_1.fastq.gz | head -n 400 | sed -n '2~4p'|wc |awk '{print $3/$2}')
kmer=$(echo "scale=0;(${len}/3)*2" | bc)
transabyss --pe ${srr}_1.fastq.gz ${srr}_2.fastq.gz --outdir ${srr} --threads 16 -k $kmer
