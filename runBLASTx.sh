#!/bin/bash
# perfomrs NR blast (blastx)
infile="$1"
outfile="$(basename "${infile%.*}").out"
database="/home/severin/GIF_1/scripts/BLAST/DB/NR/nr"
module load ncbi-blast
blastx \
 -query "${infile}" \
 -db "${database}" \
 -out "${outfile}" \
 -evalue 1e-20 \
 -num_threads 1 \
 -max_target_seqs 1 \
 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids"
