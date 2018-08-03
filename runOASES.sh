#!/bin/bash
read1="$1"
read2=$(echo $1 |sed 's/_1.fastq.gz/_2.fastq.gz/g')
len=$(zcat ${read1} | head -n 400 | sed -n '2~4p'|wc |awk '{print $3/$2}')
start=$(echo "scale=0;(${len}/3)" | bc)
end=$(echo "scale=0;(${len}/3)*2" | bc)
velveth assembly ${start},${end},8 -shortPaired -fastq -separate ${read1} ${read2}
for folder in assembly_*; do
velvetg $folder -read_trkg yes
oases ${folder}
done
max=$(ls -d assembly_* |cut -f 2 -d "_" |sort -rn |head -n 1)
velveth mergedAssembly $max -long assembly_*/transcripts.fa
velvetg mergedAssembly -read_trkg yes -conserveLong yes
oases mergedAssembly -merge yes
