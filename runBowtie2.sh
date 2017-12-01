#!/bin/bash
module load bowtie2
module load samtools
GENOMEDIR="/work/GIF/arnstrm/GENOMEDB"
GNAME="$1"
REF="$GENOMEDIR/$GNAME"
THREADS="16"
READ1="$2"
READ2="$3"
SAM=$(basename ${READ1%.*} | cut -f 1-2 -d "_")
bowtie2 --end-to-end --threads ${THREADS} -x ${REF} -1 ${READ1} -2 ${READ2} -S ${SAM}_bt.sam
samtools view --threads 16 -b -o ${SAM}_bt.bam ${SAM}_bt.sam
samtools sort -m 5G -o ${SAM}_bt_sorted.bam -T ${SAM}_bt_temp --threads 16 ${SAM}_bt.bam
