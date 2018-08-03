#!/bin/bash
#module load soapdenovo-trans/1.0.4-kfl7rhm
srr=$1
len=$(zcat ${srr}_1.fastq.gz | head -n 400 | sed -n '2~4p'|wc |awk '{print $3/$2}')
start=$(echo "scale=0;(${len}/3)" | bc)
end=$(echo "scale=0;(${len}/3)*2" | bc)
for kmer in $(seq $start 8 $end); do
SOAPdenovo-Trans-127mer all -s config.txt -o ${srr}_${kmer} -K ${kmer} -p 16
done

