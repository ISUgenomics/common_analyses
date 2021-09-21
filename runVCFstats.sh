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

# write a markdown file 

function body() {
# print the header (the first line of input)
# and then run the specified command on the body (the rest of the input)
# use it in a pipeline, e.g. ps | body grep somepattern
    IFS= read -r header
    printf '%s\n' "$header"
    "$@"
}


echo "" > stats.md
echo "## SNP count" >> stats.md
cat populations.snps.vcf.snpcount | awk '{print "SNP count = "$1}' >> stats.md
echo "" >> stats.md

echo "## Mean Depth by Sample" >> stats.md
more depth_summary.txt  | body sort -k 3rg | md >> stats.md
echo "" >> stats.md

echo "## Missing data by Sample" >> stats.md
more populations.snps.vcf.imiss | body sort -k 5rg | md >> stats.md
echo "" >> stats.md

echo "## Top 20 most related" >> stats.md
more populations.snps.vcf.relatedness | body sort -k 3rg | awk '$1!=$2' | head -n 20 | md >> stats.md
echo "" >> stats.md

