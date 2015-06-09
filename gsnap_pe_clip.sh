#!/bin/bash
# this is optimized to run on 32 procs: spliting input to 16 peices, 2 procs per peice

## MODULES
module use /data004/software/GIF/modules
module load parallel
module load gmap

## PATHS
export GMAPDB=/home/arnstrm/arnstrm/GMAPDB
DB_NAME="GRCm38.78_musmus"

FILE1="$1"
FILE2=$(echo "$1" |sed 's/_R1_/_R2_/g')

OUTFILE=$(basename ${FILE1%%.*})

## COMMAND
# important options to consider
#==============================
# if using RNA-seq, use: --novelsplicing=1
#
# if mate pairs use: --orientation=RF
# if paired end use: --orientation=FR
# if not sure, don't include --orientation option
#
# for allowing soft-clipping of alignments, exlucde all 3 options below:
# --terminal-threshold=100
# --indel-penalty=1
# --trim-mismatch-score=0
#
# if fastq is gzipped use:
# --gunzip

parallel --jobs 4 \
  "gsnap \
--db=${DB_NAME} \
--part={}/4 \
--batch=4 \
--nthreads=8 \
--novelsplicing=1 \
--gunzip \
--expand-offsets=1 \
--max-mismatches=5.0 \
--input-buffer-size=1000000 \
--output-buffer-size=1000000 \
--format=sam \
--split-output=${DB_NAME}_AP_${OUTFILE}.{} \
--failed-input=${DB_NAME}_AP_${OUTFILE}.not_mapped.{} \
${FILE1} \
${FILE2} " \
::: {0..3}
