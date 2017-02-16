#!/bin/bash
# works on L3
# change this to condo is you need to run it there
# needs rnaseq reads as well as the genome to be annotated
# if you have multiple RNA seq libraries merge them together (all R1's and all R2's seperately)
if [ $# -lt 3 ] ; then
	echo "usage: runBraker.sh <RNAseq_R1> <RNAseq_R2> <genome.fasta>"
	echo ""
	echo "To align RNAseq reads to genome and run Braker gene prediction program"
	echo ""
exit 0
fi
module use /shared/software/GIF/modules
module load hisat2
module load braker/1.9

cp $GENEMARK_PATH/gm_key ~/.gm_key

R1="$1"
R2="$2"
GENOME="$3"
BASE=$(basename ${GENOME%.*})

hisat2-build ${GENOME} ${GENOME%.*}
hisat2 -p 31 -x ${GENOME%.*} -1 ${R1} -2 ${R2} | samtools view -bS - > ${BASE}_rnaseq.bam
samtools sort -m 5G ${BASE}_rnaseq.bam > ${BASE}_sorted_rnaseq.bam
braker.pl --cores=32 --overwrite --species=${BASE} --genome=${GENOME} --bam=${BASE}_sorted_rnaseq.bam --gff3
