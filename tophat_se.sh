#!/bin/bash
module use /data004/software/GIF/modules
module load parallel
module load tophat

INDEXDB="/home/arnstrm/arnstrm/GMAPDB"
DB_NAME="Gmax_275_v2.0"
GFF="/home/arnstrm/arnstrm/20141114_Bhattacharyya_Psojae_RNAseq/05_BOWTIE_SB/Gmax_275_Wm82.a2.v1.gene_exons.gff3"
FILE1="$1"
#FILE2=$(echo "$1" |sed 's/.fastq.gz$/2.fastq.gz/g')

OUTFILE=$(basename ${FILE1} | sed 's/.fastq$//g')

echo "$OUTFILE now processing"
tophat -o "${OUTFILE}" -p8 -G "${GFF}" -M "${INDEXDB}/${DB_NAME}" "${FILE1}"

