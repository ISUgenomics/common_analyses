#!/bin/bash
module load ncbi-blast
FASTA="$1"
blastn \
-task megablast \
-query ${FASTA} \
-db /data021/GIF/arnstrm/Baum/GenePrediction_Hg_20160115/05_databases/nt/nt \
-outfmt '6 qseqid staxids bitscore std sscinames sskingdoms stitle' \
-culling_limit 5 \
-num_threads 16 \
-evalue 1e-25 \
-out ${FASTA%.**}.vs.nt.cul5.1e25.megablast.out
