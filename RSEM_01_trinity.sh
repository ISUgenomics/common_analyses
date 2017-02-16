#!/bin/bash
module load trinity
module load bowtie2
module load rsem
LEFT=$1
RIGHT=$2

${TRINITY_HOME}/Trinity \
  --seqType fq \
  --CPU ${CPU} \
  --max_memory ${MAXMEM}  \
  --left ${LEFT} --right ${RIGHT} \
  --SS_lib_type RF \
  --normalize_reads \
  --trimmomatic \
  --output trinity_out_dir\
  --no_cleanup > trinity_out_dir/trinity_out.log

${TRINITY_HOME}/util/align_and_estimate_abundance.pl \
  --transcripts trinity_out_dir/Trinity.fasta \
  --seqType fq \
  --SS_lib_type FR \
  --left  ${LEFT} \
  --right ${RIGHT} \
  --est_method RSEM \
  --aln_method bowtie2 \
  --trinity_mode \
  --output_dir rsem_out_dir \
  --prep_reference  > rsem_out_dir/rsem_out.log

