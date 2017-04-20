#!/bin/bash

# sh runTrinity file1_r1.fq.gz
# for single end reads just supply one file or multiple files with coma (no space)
# Runs Trinity, RSEM and calculates alignment stats

READS="--single ${LEFT}"
CPU=16
MAXMEM=60G

module load trinityrnaseq/2.1.1
# Run Trinity with trimming and normalization
Trinity \
  --seqType fq \
  --CPU ${CPU} --max_memory ${MAXMEM} --single "$1" \
  --normalize_reads \
  --trimmomatic \
  --output trinity_out_dir\
  --no_cleanup

# estimate read abundance (mode RSEM)

${TRINITY_HOME}/util/align_and_estimate_abundance.pl \
   --transcripts trinity_out_dir/Trinity.fasta \
   --seqType fq \
   --single "$1" \
   --est_method RSEM \
   --aln_method bowtie2 \
   --trinity_mode \
   --prep_reference \
   --output_dir RSEM_outdir

# estimate read abundance (mode eXpress)

${TRINITY_HOME}/util/align_and_estimate_abundance.pl \
   --transcripts trinity_out_dir/Trinity.fasta \
   --seqType fq \
   --single "$1" \
   --est_method eXpress \
   --aln_method bowtie2 \
   --trinity_mode \
   --prep_reference \
   --output_dir eXpress_outdir


# run bowtie PE to get alignment stats

${TRINITY_HOME}/util/bowtie_PE_separate_then_join.pl  \
   --seqType fq \
   --single "$1" \
   --target trinity_out_dir/Trinity.fasta \
   --aligner bowtie2

${TRINITY_HOME}/util/SAM_nameSorted_to_uniq_count_stats.pl \
   bowtie_out/bowtie_out.nameSorted.bam
