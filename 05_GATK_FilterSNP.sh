#!/bin/bash
vcffile=(*.vcf)
RAW="combined_variants.vcf"
REFERENCE="/data003/GIF/arnstrm/20150413_Graham_SoybeanFST/01_DATA/B_REF/Gmax_275_v2.0.fa"
MAXDEPTH=19950
GATK="/data003/GIF/software/packages/gatk/3.3"

vcf-concat ${vcffile[@]} >> ../${RAW}

cat ../${RAW} | vcf-sort -t $TMPDIR -p 16 -c > ${RAW}_sorted.vcf

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
