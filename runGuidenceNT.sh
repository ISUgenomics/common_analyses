#!/bin/bash
module load guidance/2.02
# nucleotide using PRANK
perl /shared/software/GIF/programs/guidance/2.02/www/Guidance/guidance.pl \
        --seqFile "$1"     \
        --msaProgram PRANK \
        --seqType codon    \
        --outDir $(pwd)/${1%.*} \
        --proc_num 16

