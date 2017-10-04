#!/bin/bash
module load jellyfish/2.2.5
kmer=21
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

jellyfish histo -t 16 reads_K${kmer}.jf > reads_K${kmer}.histo


# once the histo file is created, visit http://qb.cshl.edu/genomescope/ website to upload the histo file

