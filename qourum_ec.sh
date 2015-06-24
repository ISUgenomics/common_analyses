#!/bin/bash
module load quorum

read1="$1"
#read2=$(echo ${read1} | sed 's/_R1_/_R2_/g')
read2="$2"

quorum \
  -s 200000000000 \
  -t 32 \
  -p QC \
  -m 5 \
  -q 33 \
  ${read1} ${read2}
