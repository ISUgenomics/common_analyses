#!/bin/bash
GMAPDB="/work/GIF/arnstrm/GENOMEDB"
DB_NAME="$1"
R1="$2"
R2="$3"
OUTFILE=$(basename ${R1} |cut -f 1 -d "_")
gsnap \
   --db=${DB_NAME%.*} \
   --dir=${GMAPDB} \
   --nthreads=16 \
   --batch=5 \
   --orientation=FR \
   --gunzip \
   --pairexpect=600 \
   --pairdev=500 \
   --input-buffer-size=10000000 \
   --output-buffer-size=10000000 \
   --format=sam \
   --split-output=${OUTFILE}.split \
   --failed-input=${OUTFILE}.failed \
     ${R1} ${R2}


#   --novelsplicing=1 \
#   --max-mismatches=5 \
