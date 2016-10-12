#!/bin/bash
#PBS -l nodes=1:ppn=16
#PBS -l walltime=48:00:00
#PBS -N quiver 
#PBS -o ${PBS_JOBNAME}.o${PBS_JOBID} -e ${PBS_JOBNAME}.e${PBS_JOBID}
#PBS -m ae -M $netid@iastate.edu
cd $PBS_O_WORKDIR
ulimit -s unlimited
chmod g+rw ${PBS_JOBNAME}.[eo]${PBS_JOBID}

function printUsage () {
    cat <<EOF

Synopsis

    $scriptName [-h | --help] GenomeFastafile 

        GenomeFastafile: Genome file from PacBio Assembly that you wish to polish with Quiver 

Author

    Andrew Severin, Genome Informatics Facilty, Iowa State University
    severin@iastate.edu
    16 December, 2016


EOF
}

if [ $# -lt 1 ] ; then
        printUsage
        exit 0
fi

module use /shared/modulefiles 
module load LAS/parallel/20150922 
module load python/2.7.10
module load SMRTAnalysis/2.3.0
module load samtools

cmph5tools.py merge --outFile out_all.cmp.h5 aligned_reads*
cmph5tools.py sort --inPlace --deep out_all.cmp.h5
samtools faidx $1 
quiver out_all.cmp.h5 -j 16 -r $1 -o $1_polished.fasta
rm align_reads*
