#!/bin/bash
# perfomrs mapping of reads to the indexed reference genome
# uses the options specified in "best practices"
module load picard_tools
module load java
module load bwa
module load samtools

READ1="$1"
READ2="$2"
OUTNAME=$(basename ${READ1%.*} | cut -f 1-3 -d "_")
REF="/home/arnstrm/arnstrm/20150413_Graham_SoybeanFST/01_DATA/B_REF/Gmax_275_v2.0.fa"
bwa mem -M -t 16 -p ${REF} ${READS} | samtools view -buS - > ${OUTNAME}.bam

