#!/bin/bash
progdir='/data004/software/GIF/GIF/programs/trimmomatic/Trimmomatic-0.32'
pwd=$(pwd)
input1=$1
output1=$(echo ${input1} | sed 's/.fastq$//g')
java -jar ${progdir}/trimmomatic-0.32.jar SE -phred33 -threads 6 ${input1} ${output1}_trimmed.fq ILLUMINACLIP:${progdir}/adapters/TruSeq3-SE:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
