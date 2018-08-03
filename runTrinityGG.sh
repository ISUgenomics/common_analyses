#!/bin/bash

module load gcc/5.3.0
module load perl/5.18.4-threads
module load java/jdk8u73
module load bowtie2/2.2.7
module load samtools/1.3
module load trinity/2.4.0

bam="$1"
out=$(basename ${bam%.*} |cut -f 1 -d "_") 
Trinity \
   --genome_guided_bam ${bam} \
   --max_memory 110G \
   --genome_guided_max_intron 10000 \
   --full_cleanup \
   --CPU 28
