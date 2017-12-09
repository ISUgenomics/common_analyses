#!/bin/bash
module load gsnap
GMAPDB="/work/GIF/arnstrm/GENOMEDB"
DB_NAME="$1"
R1="$2"
R2="$3"
INSERT_SIZE="300"
INSERT_SD="200"
OUTFILE=$(basename ${R1} |cut -f 1,2 -d "_")
gsnap \
   --db=${DB_NAME%.*} \
   --dir=${GMAPDB} \
   --nthreads=16 \
   --batch=5 \
   --orientation=FR \
   --gunzip \
   --pairexpect=${INSERT_SIZE} \
   --pairdev=${INSERT_SD} \
   --input-buffer-size=10000000 \
   --output-buffer-size=10000000 \
   --format=sam \
   --split-output=${OUTFILE}.split \
   --failed-input=${OUTFILE}.failed \
     ${R1} ${R2}
##### OTHE OPTIONS THAT MIGHT BE RELAVANT ######
#   --novelsplicing=1 \
#   --max-mismatches=5 \
################################################

SAMS="${OUTFILE}.split"
REF="{GMAPDB}/{DB_NAME}"
module load samtools
module load R
module load picard
module load java

for SAM in ${SAMS}*; do
SAM_to_sortedBAM.sh ${SAM};
done
samtools merge ${SAMS}_gsnap_combined.bam *_sorted.bam
unset DISPLAY
runAlignmentStats.sh ${REF} ${SAMS}_gsnap_combined.bam
