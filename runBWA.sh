#!/bin/bash
module load bwa
module load samtools
module load picard
module load R

GENOMEDIR="/work/GIF/arnstrm/GENOMEDB"
#GNAME="Mus_musculus.GRCm38.dna.toplevel.fa"
GNAME="$1"
REF="$GENOMEDIR/$GNAME"
THREADS="16"
READ1="$2"
READ2="$3"
SAM=$(basename ${READ1%.*} | cut -f 1-2 -d "_")
bwa mem -M -t ${THREADS} ${REF} ${READ1} ${READ2} > ${SAM}.sam
samtools view --threads 16 -b -o ${SAM}.bam ${SAM}.sam
samtools sort -m 5G -o ${SAM}_sorted.bam -T ${SAM}_temp --threads 16 ${SAM}.bam
picard CollectInsertSizeMetrics I=${SAM}_bt_sorted.bam O=${SAM}_insert_size_metrics.txt H=${SAM}_insert_size_histogram.pdf M=0.5
picard CollectAlignmentSummaryMetrics  REFERENCE_SEQUENCE=${REF}  INPUT=${SAM}_bt_sorted.bam OUTPUT=${SAM}_alignment.stats
