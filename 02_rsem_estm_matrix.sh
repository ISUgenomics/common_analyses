#!/bin/bash
# this script runs the counts matrix generation script once the mapping is done
# rename the directories accordingly and move the ones that aren't needed.
module use /data004/software/GIF/modules
module load trinity/r20140717
module load rsem
module load samtools
module load R
module load parallel
export PERL5LIB=/home/arnstrm/perl5/lib/perl5/x86_64-linux-thread-multi
progdir="/data004/software/GIF/packages/trinity/r20140717/util"
isofiles=(*/RSEM.isoforms.results)
genfiles=(*/RSEM.genes.results)
${progdir}/abundance_estimates_to_matrix.pl \
  --est_method RSEM \
  --name_sample_by_basedir \
  --out_prefix isoforms \
  "${isofiles[@]}" > isoforms.matrix.log
${progdir}/abundance_estimates_to_matrix.pl \
  --est_method RSEM \
  --name_sample_by_basedir \
  --out_prefix genes \
  "${genfiles[@]}" > genes.matrix.log
