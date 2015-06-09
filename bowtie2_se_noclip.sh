#!/bin/bash
module use /data004/software/GIF/modules
module load samtools
module load bowtie2
INPUT="$1"
OUTPUT=$(basename ${INPUT})
GENOME="/home/arnstrm/arnstrm/GMAPDB/Lvannamei_ray_scaffolds"
bowtie2 --un-gz ${OUTPUT%%.*}_unaligned.fq.gz --threads 8 -x ${GENOME} -U ${INPUT} -S ${OUTPUT%%.*}.sam
samtools view -bS ${OUTPUT%%.*}.sam > ${OUTPUT%%.*}.bam
samtools sort ${OUTPUT%%.*}.bam ${OUTPUT%%.*}_sorted
