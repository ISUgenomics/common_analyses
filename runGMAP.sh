#!/bin/bash
module load gmap-gsnap
db="$1"
fasta="$2"
threads=36
out="${db%.*}_${fasta%.*}"
for type in match_est match_cdna gene; do
if [ ! -f "${out}_${type}.gff3.done" ]; then
gmap -D /work/LAS/mhufford-lab/arnstrm/NAM/genomes -d ${db} -B 4 -t $threads -f gff3_${type} ${fasta} > ${out}_${type}.gff3 2> ${out}_${type}.err
if [ $? -eq 0 ]; then
    touch "${out}_${type}.gff3.done"
fi
fi
done
