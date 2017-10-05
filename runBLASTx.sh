#!/bin/bash
# perfomrs NR blast (blastx)
infile="$1"
outfile="$(basename "${infile%.*}").out"
database="/work/GIF/databases/ncbi_nr/nr"
module load ncbi-blast
blastx \
 -query "${infile}" \
 -db "${database}" \
 -out "${outfile}" \
 -evalue 1e-20 \
 -num_threads 1 \
 -max_target_seqs 1 \
 -outfmt 6
# -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids salltitles"
