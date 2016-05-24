#!/bin/bash

# performs phasing and imputation of a VCF file
# using Beagle
# run the script as :
# sh beagle_PhaseImpute_VCF.sh input.vcf

INPUT="$1"
OUTPUT=$(basename ${INPUT%.*})

awk '(/#/ || ($4!~"," && $5!~"," && length($4)==1 && length($5)==1))' ${INPUT} > ${OUTPUT}_biAllelic.vcf
module use /data021/GIF/software/modules
module load java/1.7.0_76
module load beagle


java -Xmx100g -jar ${beagle} \
 nthreads=16 \
 window=500000 \
 phase-its=40 \
 impute-its=10 \
 ibd=true \
 gtgl=${OUTPUT}_biAllelic.vcf \
 out=${OUTPUT}_PhasedImputed.vcf

