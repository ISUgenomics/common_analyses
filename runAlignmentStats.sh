#!/bin/bash
# Arun Seetharam
# arnstrm@iastate.edu
# 12/07/2017

if [ $# -lt 2 ] ; then
        echo ""
        echo ""
        echo "usage: runAlignmentStats.sh <REFERENCE_GENOME> <SORTED_BAM_ALIGNMENT>"
        echo ""
        echo "Runs Picard tools to obtain summary stats about alignment and insert size"
        echo "Also runs Qualimap to get more detailed statistics about various aspects of alignment"
        echo "you can either supply a single bam file or regex matching a bunch of them"
        echo "bam file MUST be co-ordiante sorted"
        echo ""
        echo ""
exit 0
fi


module load R
module load java
module load picard/2.9.0
module load samtools
module load GIF/qualimap

REF="$1"
shift
BAMS=${@};

for BAM in ${BAMS[@]}
do

if [ ! -f $BAM ]; then
    echo "\"$BAM\" file not found!"
    exit 1;
fi

if [ ${BAM##*.} != "bam" ]; then
  echo "File $BAM is not a bam file!"
  exit 1;
fi

picard CollectInsertSizeMetrics I=${BAM} O=${BAM%.*}_isize.txt H=${BAM%.*}_isize-histo.pdf M=0.5
picard CollectAlignmentSummaryMetrics REFERENCE_SEQUENCE=${REF} INPUT=$BAM OUTPUT=${BAM%.*}_align-stats.txt
unset DISPLAY
qualimap bamqc -bam ${BAM} --java-mem-size=80G -outdir ${BAM%.*}
done
