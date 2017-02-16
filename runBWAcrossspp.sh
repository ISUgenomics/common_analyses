#!/bin/bash
# perfomrs mapping of reads to the indexed reference genome uses the options specified in "best practices" command genomeModule READ1 READ2
module load bwa/0.7.12
module load samtools
module load $1
REF="$GENOMEDIR/$GNAME"
# this option might be the frequetly changed, hence not it's a variable
THREADS="16"
# if the reads are paired then use -p option
if [ "$#" -eq 3 ]; then
  READ1="$2"
  READ2="$3"
  OUTNAME=$(basename ${READ1%.*} | cut -f 1-2 -d "_")
  bwa mem -M -x ont2d -t ${THREADS} ${REF} ${READ1} ${READ2} | samtools view -buS - > ${OUTNAME}.bam
# if not just use the reads as single reads
elif [ "$#" -eq 1 ]; then
  READ1="$2"
  OUTNAME=$(basename ${READ1%.*} | cut -f 1-2 -d "_")
  bwa mem -M -x ont2d -t ${THREADS} ${REF} ${READ1} | samtools view -buS - > ${OUTNAME}.bam
# if number of arguments do not match, raise error
else
  echo "ERROR: INVALID NUMBER OF ARGUMENTS"
  echo "runBWAcrossspp.sh genomeModule READ1 READ2"
fi
