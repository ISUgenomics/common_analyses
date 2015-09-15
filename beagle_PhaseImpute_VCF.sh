#!/bin/bash
# performs phasing and imputation of a VCF file
# using Beagle
# run the script as :
# sh beagle_PhaseImpute_VCF.sh input.vcf

INPUT="$1"
OUTPUT=$(basename ${INPUT%.*})

awk '(/#/ || ($4!~"," && $5!~","))' ${INPUT} > ${OUTPUT}_diAllelic.vcf
module load java/1.7.0_76
module load beagle

#put this in the module above
#beagle="/data003/GIF/software/packages/beagle/r1399/beagle.jar"

java -Xmx100g -jar ${beagle} \
 nthreads=16 \
 window=500000 \
 phase-its=40 \
 impute-its=10 \
 ibd=true \
 gtgl=${OUTPUT}_diAllelic.vcf \
 out=${OUTPUT}_PhasedImputed.vcf
