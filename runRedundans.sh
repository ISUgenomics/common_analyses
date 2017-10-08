#!/bin/bash
if [ $# -lt 2 ] ; then
        echo ""
        echo "usage: ./runRedundans.sh genome.fasta *.fastq.gz"
        echo "runs the redundans pipeline using the genome and all fastq files used for the genome assembly"
        echo "Note: you can softlink all reads (MP and PE) in the directory and supply them as *.fastq.gz for redundans"
        echo "needs reconfiguration if running using the long reads (pacbio or nanopore)"
        echo ""
        exit 0
fi

module load GIF/redundans
genome="$1"
shift
fastq="$@"
out="${genome%.*}_redundans_output"
#mkdir -p ${out}
# doesn't like if you already make a output folder

redundans.py \
     -v \
     -i ${fastq} \
     -f ${genome} \
     -o ${out} \
     -t 16 \
     --log redundans_out.log
