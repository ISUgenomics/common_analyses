#!/bin/bash
progdir='/data004/software/GIF/packages/trimmomatic/0.32'
pwd=$(pwd)
input1=$1
input2=$2
output1=$(basename ${input1} | sed 's/.fastq.gz$//g')
output2=$(basename ${input2} | sed 's/.fastq.gz$//g')
java -jar ${progdir}/trimmomatic-0.32.jar PE -phred33 -threads 16 ${input1} ${input2} ${output1}_paired.fq ${output1}_unpaired.fq ${output2}_paired.fq ${output2}_unpaired.fq ILLUMINACLIP:${progdir}/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:25
