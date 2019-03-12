#!/bin/bash
vcf="vcffile"
indels="indelfile"
module load gatk
module load vcftools
module load GIF/perl/5.24.1
grep -v "^#" $indels | cut -f 8 | grep -oe ";DP=.*" |cut -f 2 -d ";" |cut -f 2 -d "=" > dp_indel.txt
grep -v "^#" $vcf | cut -f 8 | grep -oe ";DP=.*" |cut -f 2 -d ";" |cut -f 2 -d "=" > dp_snps.txt
echo "dp stats for VCF"
cat dp_snps.txt | st
echo "dp stats for INDEL"
cat dp_indel.txt | st
java -Xmx120g -Djava.io.tmpdir=$TMPDIR  -jar $GATK VariantsToTable -R $ref -V $vcf  -F CHROM -F POS -F QUAL -F QD -F DP -F MQ -F MQRankSum -F FS -F ReadPosRankSum -F SOR  -O SNPs.table
java -Xmx120g -Djava.io.tmpdir=$TMPDIR  -jar $GATK VariantsToTable -R $ref -V $indels  -F CHROM -F POS -F QUAL -F QD -F DP -F MQ -F MQRankSum -F FS -F ReadPosRankSum -F SOR  -O INDELs.table
