#!/bin/bash
# this script runs the counts matrix generation script once the mapping is done
# rename the directories accordingly and move the ones that aren't needed.
module load trinity
module load rsem
module load samtools
module load R
module load parallel

UTIL=${TRINITY_HOME}/util"
isofiles=(*/RSEM.isoforms.results)
genfiles=(*/RSEM.genes.results)
${UTIL}/abundance_estimates_to_matrix.pl \
  --est_method RSEM \
  --name_sample_by_basedir \
  --out_prefix isoforms \
  "${isofiles[@]}" > isoforms.matrix.log
${UTIL}/abundance_estimates_to_matrix.pl \
  --est_method RSEM \
  --name_sample_by_basedir \
  --out_prefix genes \
  "${genfiles[@]}" > genes.matrix.log
