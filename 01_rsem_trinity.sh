#!/bin/bash
module load trinity/2.0.4
module load bowtie2
module load rsem
resdir="/home/arnstrm/arnstrm/20150508_Maier_nematode_SCN/03_TRINITY/combined/trinity_out_dir"
progdir="/data004/software/GIF/packages/trinity/2.0.4/util"
reads1=$1
reads2=$2
outdir=$(basename ${reads1%.*})
mkdir -p ${outdir}
${progdir}/align_and_estimate_abundance.pl \
  --transcripts ${resdir}/Trinity.fasta \
  --seqType fq \
  --SS_lib_type FR \
  --left  ${reads1} \
  --right ${reads2} \
  --est_method RSEM \
  --aln_method bowtie2 \
  --trinity_mode \
  --output_dir ${outdir} \
  --prep_reference  > ${outdir}/rsem_out.log

