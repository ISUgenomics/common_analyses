#!/bin/bash

module load hisat2
module load samtools
DBDIR="/data013/GIF/arnstrm/GENOMEDB"
GENOME="Mus_musculus.GRCm38.dna.toplevel_hisat2"

p=16
R1_FQ="$1"
R2_FQ="$2"

OUTPUT=$(basename ${R1_FQ} |cut -f 1 -d "_");

hisat2 \
  -p ${p} \
  -x ${DBDIR}/${GENOME} \
  -1 ${R1_FQ} \
  -2 ${R2_FQ} | \
  -S  ${OUTPUT}.sam &> ${OUTPUT}.log
samtools view --threads 16 -b -o ${OUTPUT}.bam ${OUTPUT}.sam
samtools sort -m 7G -o ${OUTPUT}_sorted.bam -T ${OUTPUT}_temp --threads 16 ${OUTPUT}.bam
