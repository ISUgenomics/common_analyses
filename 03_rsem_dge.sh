#!/bin/bash
# Runs the DGE once coutns table is generated
# you may have to run this on both isoforms.counts and genes.counts
# depending on your needs.
module use /data004/software/GIF/modules
module load trinity
module load rsem
module load samtools
module load R
export PERL5LIB=/home/arnstrm/perl5/lib/perl5/x86_64-linux-thread-multi
progdir="${TRINITY}/Analysis/DifferentialExpression"
input="$1"
outdir=$(basename ${input%.*})
${progdir}/run_DE_analysis.pl \
   --matrix ${input} \
   --method DESeq2 \
   --samples_file conditions.txt \
   --output ${outdir}
${progdir}/analyze_diff_expr.pl \
   --matrix ${input} \
   --samples ../conditions.txt \
   --max_genes_clust 50000 \
   -P 1e-3 \
   -C 2
