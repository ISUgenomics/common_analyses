#!/bin/bash

#This script is expecting you to have all of your vcf files and vcf.idx files placed in a subfolder from where you ran GATK.  This way the files that are generated are placed in your GATK folder.
#Also update the GATK location, Raw file and the reference for your run


module load GIF/perl/5.24.1
module load vcftools
module load GIF2/gatk

vcffile=(*.vcf)
#this is just naming the vcf file that will be generated belwo.
RAW="WhiteWildCultured.vcf"
REFERENCE="/work/GIF/remkv6/Purcell/Abalone/15_WhiteWildCultured/H.rufescens.fasta"
#MAXDEPTH=19950
GATK="/shared/software/GIF/programs/gatk/3.5"

vcf-concat ${vcffile[@]} >> ../${RAW}

MAXDEPTH=$(grep -oh ";DP=.*;" ${RAW} | cut -d ";" -f 2 | cut -d "="  -f 2 | st --sd |awk '{print $0*5}')
cat ../${RAW} | vcf-sort -t $TMPDIR -p 16 -c > ${RAW%.*}_sorted.vcf

java -Xmx120g -Djava.io.tmpdir=$TMPDIR -jar ${GATK}/GenomeAnalysisTK.jar \
  -T SelectVariants \
  -R ${REFERENCE} \
  -V ${RAW%.*}_sorted.vcf \
  -selectType SNP \
  -o ${RAW%.*}_sorted_SNPs.vcf

java -Xmx120g -Djava.io.tmpdir=$TMPDIR -jar ${GATK}/GenomeAnalysisTK.jar \
  -T VariantFiltration \
  -R ${REFERENCE} \
  -V ${RAW%.*}_sorted_SNPs.vcf \
  --filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || DP > ${MAXDEPTH}" \
  --filterName "FAIL" \
  -o ${RAW%.*}_sorted_filtered_SNPs.vcf

java -Xmx120g -Djava.io.tmpdir=$TMPDIR -jar ${GATK}/GenomeAnalysisTK.jar \
  -T SelectVariants \
  -R ${REFERENCE} \
  -V ${RAW%.*}_sorted.vcf \
  -selectType INDEL \
  -o ${RAW%.*}_sorted_indels.vcf

java -Xmx120g -Djava.io.tmpdir=$TMPDIR -jar ${GATK}/GenomeAnalysisTK.jar \
  -T VariantFiltration \
  -R ${REFERENCE} \
  -V ${RAW%.*}_sorted_indels.vcf \
  --filterExpression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0" \
  --filterName "FAIL" \
  -o ${RAW%.*}_sorted_filtered_indels.vcf
