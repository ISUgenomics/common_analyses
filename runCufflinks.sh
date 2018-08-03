#!/bin/bash
module load boost/1.50.0
module load gcc/4.8.4
module load eigen/3.2.8
module load samtools/0.1.19
module load python/2.7.11_gcc
module load cufflinks/2.2.1
bam="$1"
out=$(basname $bam |cut -f 1 -d "_")
cufflinks \
   --output-dir $out \
   --num-threads 28 \
   --verbose \
   --no-update-check \
   $bam

