#!/bin/bash
# perfomrs mapping of reads to the indexed reference genome
# uses the options specified in "best practices"
module load picard_tools
module load java
module load bwa
module load samtools

REF="/data003/GIF/genomes/sequences/TIL01/TIL01_MaSuRCA_scaffolds.fasta"
THREADS="8"

if [ "$#" -eq 2 ]; then
  READ1="$1"
  READ2="$2"
  OUTNAME=$(basename ${READ1%.*} | cut -f 1-2 -d "_")
  bwa mem -M -t ${THREADS} ${REF} -p ${READ1} ${READ2} | samtools view -buS - > ${OUTNAME}.bam
elif [ "$#" -eq 1 ]; then
  READ1="$1"
  OUTNAME=$(basename ${READ1%.*} | cut -f 1-2 -d "_")
  bwa mem -M -t ${THREADS} ${REF} ${READ1} | samtools view -buS - > ${OUTNAME}.bam
else
  echo "ERROR: INVALID NUMBER OF ARGUMENTS"
fi
