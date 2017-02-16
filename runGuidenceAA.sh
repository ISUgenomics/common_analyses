#!/bin/bash
module load guidance/2.02
# proteins using MAFFT
perl /shared/software/GIF/programs/guidance/2.02/www/Guidance/guidance.pl \
        --seqFile "$1"     \
        --msaProgram MAFFT \
        --seqType aa    \
        --outDir $(pwd)/${1%.*} \
        --proc_num 16

