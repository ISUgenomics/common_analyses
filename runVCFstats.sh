#!/bin/bash

module use /shared/software/GIF/modules/
module use  /shared/modulefiles
module load vcftools
module load compilers/gcc-4.8.2 

out=`basename $1`
#filter out undesirable lines create new vcf file
#vcftools --vcf $1 --remove-indv 6497 --remove-indv 7074 --non-ref-ac-any 1 --recode


#snp count
grep -v "#" $1 | wc -l > ${out}.snpcount

#determine the depth of coverage by individual
vcftools --vcf $1  --depth --out ${out}

#determine Transitions and transversion ratio Ts/Tv
vcftools --temp ./temp  --vcf $1  --TsTv 1000
#explore potential bins of interest
#awk '$NF<1 && $NF>0' out.TsTv | awk '{print $1,$2}' | intervalBins.awk 10000 | awk '$3>3'
#awk '$NF>4' out.TsTv | awk '{print $1,$2}' | intervalBins.awk 10000 | awk '$3>2'

#determine windowed pi values
vcftools --temp ./temp  --vcf $1  --window-pi 1000 --window-pi-step 1000 --out ${out}_1000
vcftools --temp ./temp  --vcf $1  --window-pi 10000 --window-pi-step 1000 --out ${out}_10000

#singleton enrichment in bins could indicate regions of interest.
vcftools --temp ./temp  --vcf $1  --singletons --out ${out}

#look at relatedness
vcftools --vcf $1  --relatedness --out ${out}

#missing site frequency for potential filtering purposes on a per site and overall individual basis
vcftools --vcf $1   --missing-site --out ${out}
vcftools --vcf $1  --missing-indv --out ${out}

#SNP density
vcftools --vcf $1  --SNPdensity 1000 --out ${out}_1000
vcftools --vcf $1  --SNPdensity 10000 --out ${out}_10000

#Tajima's D 
vcftools --vcf $1  --TajimaD 1000 --out ${out}_1000
vcftools --vcf $1  --TajimaD 10000 --out ${out}_10000

#inbreeding coefficient
vcftools --vcf $1  --het --out ${out}

