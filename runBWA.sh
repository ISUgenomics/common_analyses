#!/bin/bash
module load bwa
module load samtools
GENOMEDIR="/work/GIF/arnstrm/GENOMEDB"
#GNAME="Btau_4.6.1_chromosomes.fa"
GNAME="$1"
REF="$GENOMEDIR/$GNAME"
THREADS="16"
READ1="$2"
READ2="$3"
SAM=$(basename ${READ1%.*} | cut -f 1-2 -d "_")
bwa mem -M -t ${THREADS} ${REF} ${READ1} ${READ2} > ${SAM}.sam
samtools view --threads 16 -b -o ${SAM}.bam ${SAM}.sam
samtools sort -m 8G -o ${SAM}_sorted.bam -T ${SAM}_temp --threads 16 ${SAM}.bam
