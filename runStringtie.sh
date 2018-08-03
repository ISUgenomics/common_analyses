#!/bin/bash
module load stringtie/1.3.3
bam="$1"
out=$(basename $bam |cut -f 1 -d "_")

stringtie \
   ${bam} \
   -p 28 \
   -v \
   -o ${out}_cufflinks.gtf 


