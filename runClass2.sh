#!/bin/bash
PATH=$PATH:/home/aseethar/CLASS-2.1.7
bam="$1"
out=$(basename $bam |cut -f 1 -d "_")
perl /home/aseethar/CLASS-2.1.7/run_class.pl \
   -a $bam \
   -o ${out}_class.gtf \
   -p 28 \
   --verbose \
   --clean  
