#!/bin/bash
# runs the busco pipeline on the genome assesment mode
# if your genome is not plan change the select the suitable option below

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

module use /data003/GIF/software/modules/
module load busco/2.0
genome="$1"
outname=$(basename ${genome%.*})
python ${BUSCO}/busco.py \
  -o ${outname} \
  -in ${genome} \
  -l ${PROFILES}/${ORG} \
  -m genome
  -c 16
