#!/bin/bash
GMAPDB="/work/GIF/arnstrm/GENOMEDB"
DB_NAME="Gmax_275_v2.0_gsnap"
R1="$1"
R2="$2"
OUTFILE=$(basename ${R1} |cut -f 1 -d "_")
gsnap \
   -d ${DB_NAME} \
   -D ${GMAPDB}
   -t 16 \
   -B 5 \
   -N 1
   -m 5 \
   --gunzip \
   --fails-as-input \
   --input-buffer-size=10000000 \
   --output-buffer-size=10000000 \
   -A_gsnap.sam  ${R1} ${R2} > ${OUTFILE}_gsnap_gsnap.sam