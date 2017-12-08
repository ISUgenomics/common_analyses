#!/bin/bash
# arun seetharam
# arnstrm@iastate.edu
# 12/07/2017

if [ $# -lt 2 ] ; then
        echo "usage: runAlignmentStats.sh <REFERENCE_GENOME> <SORTED_BAM_ALIGNMENT>"
        echo ""
        echo "runs picard tools to obtain summary stats about alignment and insert size"
        echo ""
exit 0
fi


module load R java picard samtools
BAM=$2
REF=$1
picard CollectInsertSizeMetrics I=${BAM} O=${BAM%.*}_isize.txt H=${BAM%.*}_isize-histo.pdf M=0.5
picard CollectAlignmentSummaryMetrics REFERENCE_SEQUENCE=${REF} INPUT=$BAM OUTPUT=${BAM%.*}_align-stats.txt
