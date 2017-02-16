#!/bin/bash
module load tassel
VCF="$1"
TRAITS="/data013/GIF/arnstrm/Purcell/albacore/2_gatk/d_tassel/pheno_traits.txt"
# traits file should be numerical
# else the file will be empty

#sort
${TASSEL_HOME}/run_pipeline.pl -SortGenotypeFilePlugin -inputFile ${VCF} -outputFile ${VCF%.*}_sorted.vcf
#impute
${TASSEL_HOME}/run_pipeline.pl -fork1 -importGuess ${VCF%.*}_sorted.vcf -ImputationPlugin -ByMean true -nearestNeighbors 5 -distance Euclidean -endPlugin -export ${VCF%.*}_imputed -exportType VCF
# generate kinship matrix
${TASSEL_HOME}/run_pipeline.pl -fork2 -importGuess ${VCF%.*}_imputed.vcf -KinshipPlugin -method Centered_IBS -endPlugin -export ${VCF%.*}_kinship.txt -exportType SqrMatrix
# GLM
${TASSEL_HOME}/run_pipeline.pl \
     -fork1 \
         -importGuess ${VCF%.*}_imputed.vcf \
     -fork2 \
         -importGuess ${TRAITS} \
     -fork3 \
         -importGuess ${VCF%.*}_kinship.txt \
     -combine4 \
         -input1 \
         -input2 \
         -input3 \
         -intersect \
         -FixedEffectLMPlugin \
         -maxP 1e-3 -permute true -nperm 1000 -biallelicOnly true \
         -endPlugin -export ${VCF%.*}_glm_output
