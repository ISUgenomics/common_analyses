#!/bin/bash
#create files list as follows
#SRR943126_1.fastq
#SRR943126_2.fastq
#SRR943127_1.fastq
#SRR943127_2.fastq
#SRR943130_1.fastq
#SRR943130_2.fastq
#SRR943129_1.fastq
#SRR943129_2.fastq
#SRR943128_1.fastq
#SRR943128_2.fastq
#single field with just the filename followed by its mate

platanus_trim -i paired_end_files_list -t 16
platanus_internal_trim -i mate_pair_files_list -t 16

platanus assemble \
    -o plat_assembly \
    -f read_250_[AB]_R[12].fq.trimmed \
    -t 40 \
    -m 500

platanus scaffold \
    -o plat_scaf \
    -c plat_assembly_contig.fa \
    -b  plat_assembly_contigBubble.fa \
    -IP1 read_250_[AB]_R[12].fq.trimmed \
    -OP2 matepair_R[12].fq.int_trimmed \
    -n2 7000 \
    -a2 8000 \
    -d2 500 \
    -t 40 \
    -tmp $TMPDIR

platanus gap_close \
    -o plat_gapclose \
    -c plat_scaf_scaffold.fa \
    -IP1 matepair_R[12].fq.int_trimmed \
    -OP2 read_250_[AB]_R[12].fq.trimmed \
    -t 40 \
    -tmp $TMPDIR

