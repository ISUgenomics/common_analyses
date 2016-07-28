#!/bin/bash
# Script to generate PBS sub files for quiver analysis
# 07/25/2016
# Andrew Severin <severin@iastate.edu>

function printUsage () {
    cat <<EOF

Synopsis

    $scriptName [-h | --help] <Genome1> <Genome2>

Description

        This bash script will align Genome1 to Genome2 using blasr. If Genome1 = Genome2 then it will align those two genomes allowing for more than the best alignment.
        -h, --help
        Brings up this help page

    <Genome1> 
        First genome to align
    <Genome2> 
        Second genome to align the first to.

Author

    Andrew Severin, Genome Informatics Facilty, Iowa State University
    severin@iastate.edu
    26 July, 2016


EOF
}
if [ $# -lt 1 ] ; then
        printUsage
        exit 0
fi

module use /shared/modulefiles 
module load blasr

if [ $1 != $2 ]; then

blasr $1 $2 --nproc 16 --nCandidates 1 -m 4 --bestn 1 --unaligned $1_$2_unaligned.fasta > $1_$2.m4 
fi

if [ $1 == $2 ]; then 
blasr $1 $2 --nproc 16 --nCandidates 20 -m 4 --bestn 50  > $1_self.m4
fi

