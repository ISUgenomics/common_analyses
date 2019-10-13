#!/bin/bash
module load jellyfish

if [ $# -lt 2 ] ; then
        echo ""
        echo "usage: ./runGenomescope.sh <kmer_val> *.fastq.gz"
        echo "runs the genomescope pipeline using the kmer value specified and all fastq files of a organism (shortreads only)"
        echo "Note: you can softlink all reads (MP and PE) in the directory and supply them as *.fastq.gz"
        echo ""
        exit 0
fi


kmer="$1"
shift
filear=${@};

for i in ${filear[@]}
do

if [ ! -f $i ]; then
    echo "\"$i\" file not found!"
    exit 1;
fi

if [[ $i =~ \.gz$ ]]; then
echo "files gzipped"
jellyfish count -C -m $kmer -s 1000000000 -t 10 <(zcat ${filear[@]}) -o reads_K${kmer}.jf
else
jellyfish count -C -m $kmer -s 1000000000 -t 10 <(cat ${filear[@]}) -o reads_K${kmer}.jf
fi
done
jellyfish histo -t 16 reads_K${kmer}.jf > reads_K${kmer}.histo



# once the histo file is created, visit http://qb.cshl.edu/genomescope/ website to upload the histo file

