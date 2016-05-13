#!/bin/bash
# runs the busco pipeline on the genome assesment mode
# if your genome is not plan change the select the suitable option below
# run it as:
# sh runBUSCO_genome.sh genome.fasta
# Arun Seetharam
# 2015/10/09 <arnstrm@iastate.edu>

#+++++++++++++++++++++
ORG=plantae
#ORG=arthropoda
#ORG=bacteria
#ORG=eukaryota
#ORG=fungi
#ORG=metazoa
#ORG=vertebrata
#++++++++++++++++++++

# (select one of the aboove)
# results will be stored in the new directroy with the genome suffix
module use /shared/software/GIF/modules
module load busco/2.0
genome="$1"
outname=$(basename ${genome%.*})
python3 ${BUSCO}/busco.py \
  -o ${outname} \
  -in ${genome} \
  -l ${PROFILES}/${ORG} \
  -m genome \
  -c 16 \
  -f
