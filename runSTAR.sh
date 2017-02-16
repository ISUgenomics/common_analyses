#!/bin/bash
R1="$1"
R2=$(echo $R1 |sed 's/_R1_/_R2_/g')
OUT=$(basename ${R1%%.*})
GFF="/home/arnstrm/arnstrm/GMAPDB/Gmax_275_Wm82.a2.v1.gene.gff3"
DB="/home/arnstrm/arnstrm/GMAPDB/Gmax_275_v2.0_star"

STAR \
 --runMode alignReads \
 --runThreadN 32 \
 --genomeDir ${DB} \
 --readFilesCommand zcat \
 --outFileNamePrefix ${OUT} \
 --readFilesIn ${R1} ${R2}

# --sjdbGTFtagExonParentTranscript \
# --sjdbGTFfile ${GFF} \
# --sjdbOverhang 99 \
# --sjdbGTFfeatureExon CDS \
