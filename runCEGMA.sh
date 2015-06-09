#!/bin/bash
# Runs CEGMA for the genome
module use /data004/software/GIF/modules
module load cegma/2.5
export CEGMATMP="/scratch/arnstrm"
genome="$1"
cegma \
  --ext \
  --threads 32 \
  --verbose \
  --genome ${genome} \
  --output ${genome%.*}
