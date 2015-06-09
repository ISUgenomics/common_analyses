#!/bin/bash
module use /data004/software/GIF/modules
module load bayescan
module load parallel
FILE=$(basename $1);
pre=$(pwd)
progdir="${pre}/prog"

awk 'NR > 1309' $FILE | cut -f 1-9,15-18,20-21,25-27,31,34,38,40-42,48-49,52-53,55-56,58-62,64,68,70,73,77-79,81-84,86 > temp.vcf
head -n 1309 $FILE > header.vcf
cat header.vcf temp.vcf >> ${FILE%%.*}_grp.vcf
cat header.vcf temp.vcf >> ${FILE%%.*}_gen.vcf

java -Xmx200g -Xms10g -jar ${progdir}/PGDSpider2-cli.jar -inputfile ${pre}/${FILE%%.*}_grp.vcf -inputformat VCF -outputfile ${pre}/${FILE%%.*}_grp.bayes -outputformat GESTE_BAYE_SCAN -spid ${pre}/vcf_bayescan_group.spid
java -Xmx200g -Xms10g -jar ${progdir}/PGDSpider2-cli.jar -inputfile ${pre}/${FILE%%.*}_gen.vcf -inputformat VCF -outputfile ${pre}/${FILE%%.*}_gen.bayes -outputformat GESTE_BAYE_SCAN -spid ${pre}/vcf_bayescan_gen.spid
java -Xmx200g -Xms10g -jar ${progdir}/PGDSpider2-cli.jar -inputfile ${pre}/${FILE} -inputformat VCF -outputfile ${pre}/${FILE%%.*}_yer.bayes -outputformat GESTE_BAYE_SCAN -spid ${pre}/vcf_bayescan_year.spid

mkdir -p ${FILE%%.*}_group ${FILE%%.*}_generations ${FILE%%.*}_year

parallel <<CMDS
bayescan ${pre}/${FILE%%.*}_grp.bayes -od ${pre}/${FILE%%.*}_group -threads 10 -n 1000000 -pr_odds 10000
bayescan ${pre}/${FILE%%.*}_gen.bayes -od ${pre}/${FILE%%.*}_generations -threads 10 -n 1000000 -pr_odds 10000
bayescan ${pre}/${FILE%%.*}_yer.bayes -od ${pre}/${FILE%%.*}_year -threads 12 -n 1000000 -pr_odds 10000
CMDS
