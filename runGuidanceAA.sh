#!/bin/bash
module load GIF/guidance/2.02
# proteins using MAFFT
perl perl  /work/GIF/software/programs/guidence/2.02/www/Guidance/guidance.pl \
        --seqFile "$1"     \
        --msaProgram MAFFT \
        --seqType aa    \
        --outDir $(pwd)/${1%.*} \
        --proc_num 16

