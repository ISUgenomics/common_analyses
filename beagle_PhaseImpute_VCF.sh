#!/bin/bash

# performs phasing and imputation of a VCF file
# using Beagle
# run the script as :
# sh beagle_PhaseImpute_VCF.sh input.vcf

INPUT="$1"
OUTPUT=$(basename ${INPUT%.*})

awk '(/#/ || ($4!~"," && $5!~","))' ${INPUT} > ${OUTPUT}_biAllelic.vcf
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

