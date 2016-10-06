#!/bin/bash
# Runs CEGMA for the genome
module load cegma/2.5
export CEGMATMP="/local/scratch/${USER}/${PBS_JOBID}"
genome="$1"
cegma \
  --ext \
  --threads 16 \
  --verbose \
  --genome ${genome} \
  --output ${genome%.*}
