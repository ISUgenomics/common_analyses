#!/bin/bash
module load hisat2
module load samtools
DBDIR="/work/GIF/arnstrm/GENOMEDB"
GENOME="$1"
#GENOME="TAIR10"
p=16
R1_FQ="$2"
R2_FQ="$3"
OUTPUT=$(basename ${R1_FQ} |cut -f 1 -d "_");
hisat2 \
  -p ${p} \
  -x ${DBDIR}/${GENOME} \
  -1 ${R1_FQ} \
  -2 ${R2_FQ} \
  -S  ${OUTPUT}.sam &> ${OUTPUT}.log || {
echo >&2 "hisat2 alignment failed for ${OUTPUT}"
exit 1
}
samtools view --threads 16 -b -o ${OUTPUT}.bam ${OUTPUT}.sam  || {
echo >&2 "sam to bam conversion failed for ${OUTPUT}"
exit 1
}
samtools sort -m 4G -o ${OUTPUT}_sorted.bam -T ${OUTPUT}_temp --threads 16 ${OUTPUT}.bam || {
echo >&2 "sorting bam failed for ${OUTPUT}"
exit 1
}

