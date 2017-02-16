#!/bin/bash
GENOME=$1
TARGET=$2
module load pyscaf
module load last/770

mkdir -p pyscaf_synteny

python /shared/software/GIF/programs/pyscaf/2016-04-08/pyScaf.py \
    --fasta $GENOME \
    --reference $TARGET \
    --norearrangements \
    --threads 16 \
    --dotplot pdf \
    --log ${GENOME%.*}_pynast.log
