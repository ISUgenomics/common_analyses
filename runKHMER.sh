#!/bin/bash

TRIMMOMATIC='/data004/software/GIF/packages/trimmomatic/0.32'
KHMER='/data004/software/GIF/packages/khmer/1.01/khmerEnv/bin'
PRE=$(pwd)

input1=$1
input2=$2
output1=$(basename "${input1%%.*}")
output2=$(basename "${input2%%.*}")
output=$(basename ${input1} | sed 's/1.fastq.gz$//g')

hashsize=6.25e+10
cutoff=100
ksize=20
numHashes=4
#trimmomatic
#java -jar ${TRIMMOMATIC}/trimmomatic-0.32.jar \
#PE -phred33 \
#-threads 16 \
#${input1} \
#${input2} \
#${PRE}/${output1}_paired.fq \
#${PRE}/${output1}_unpaired.fq \
#${PRE}/${output2}_paired.fq \
#${PRE}/${output2}_unpaired.fq \
#ILLUMINACLIP:${progdir}/adapters/TruSeq3-PE.fa:2:30:10 \
#LEADING:3 \
#TRAILING:3 \
#SLIDINGWINDOW:4:15 \
#MINLEN:25

#load virtual env
source ${KHMER}/activate

#interleave
#python ${KHMER}/interleave-reads.py -o ${output}_interleaved.fq ${input1} ${input2}

#normalize
python ${KHMER}/normalize-by-median.py \
--ksize $ksize \
--n_tables $numHashes \
--cutoff $cutoff \
--out ${output}_normalized \
${output}_interleaved.fq;

#extract paired reads
python ${KHMER}/extract-paired-reads.py ${output}_normalized

#split reads
python ${KHMER}/split-paired-reads.py ${output}_normalized.pe
