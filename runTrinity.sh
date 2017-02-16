#!/bin/bash

# NOTE: RENAME YOUR OLD TRINITY RUN TO SOMETHING ELSE BEFORE RUNNING THIS SCRIPT

# need to supply input files
# eg: for paired end reads, either do

# sh runTrinity file1_r1.fq fil1_r2.fq
# (for combined r1 and r2 files) or

# sh runTrinity file1_r1.fq,file2_r1.fq fil1_r2.fq,fil2_r2.fq
# for multiple R1 and R2 files

# for single end reads just supply one file or multiple files with coma (no space)

# Runs Trinity, RSEM and calculates alignment stats

if [ "$#" -ge 1 ]; then
    echo "assuming paired-end reads"
    READS="--left ${LEFT} --right ${RIGHT}"
else
    echo "assuming single-end reads"
    READS="--single ${LEFT}"
fi

if [ "$(echo $HOSTNAME)" != 'hpc5' ]; then
    CPU=16
    MAXMEM=128G
    module use /shared/software/GIF/modules
    module load trinity
else
    CPU=32
    MAXMEM=200G
    module use /data004/software/GIF/modules
    module load trinity
fi

# Run Trinity with trimming and normalization

Trinity \
  --seqType fq \
  --CPU ${CPU} --max_memory ${MAXMEM}  ${READS} \
  --SS_lib_type RF \
  --normalize_reads \
  --trimmomatic \
  --output trinity_out_dir\
  --no_cleanup

if [ ! $* ]; then
    exit 0
fi

# run RSEM to estimate read abundance (mode RSEM)

${TRINITY}/util/align_and_estimate_abundance.pl \
   --transcripts trinity_out_dir/Trinity.fasta \
   --seqType fq \
   ${READS}
   --SS_lib_type RF \
   --est_method RSEM \
   --aln_method bowtie \
   --trinity_mode \
   --prep_reference \
   --output_dir RSEM_outdir

# run RSEM to estimate read abundance (mode eXpress)

${TRINITY}/util/align_and_estimate_abundance.pl \
   --transcripts trinity_out_dir/Trinity.fasta \
   --seqType fq \
   ${READS}
   --SS_lib_type RF \
   --est_method eXpress \
   --aln_method bowtie2 \
   --trinity_mode \
   --prep_reference \
   --output_dir eXpress_outdir


# run bowtie PE to get alignment stats

${TRINITY}/util/bowtie_PE_separate_then_join.pl  \
   --seqType fq \
   ${READS} \
   --target trinity_out_dir/Trinity.fasta \
   --aligner bowtie

${TRINITY}/util/SAM_nameSorted_to_uniq_count_stats.pl \
   bowtie_out/bowtie_out.nameSorted.bam
