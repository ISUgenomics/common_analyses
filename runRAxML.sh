#!/bin/bash
module load raxml

if [ $# -lt 2 ] ; then
        echo "usage: runRAxML.sh <alignment_file> <AA|NT>"
        echo ""
        echo "run rapid Bootstrap analysis and find the best scoring ML tree from alignment file"
        echo "if alignment is protein, use AA; if nucleotide use NT"
        echo "for AA it uses use Automatic protein model assignment, and for NT it is GTRGAMMA model"
        echo ""
exit 0
fi

if [ "$2" -eq "AA" ] then
MOD="PROTGAMMAAUTO"
elif ["$2" -eq "NT" ] then
MOD="GTRGAMMA"
fi
fi


ALN="$1"
SUF=$(basename ${ALN} |cut -f 1 -d "_")

raxmlHPC-PTHREADS \
          -T 16 \
          -f a \
          -m ${MOD} \
          -p 12345 \
          -x 12345 \
          -# 100 \
          -s ${ALN} \
          -n ${SUF}

# -T 16 : number of threads set to 16 (condo)
# -f a : rapid Bootstrap analysis and search for best-scoring ML tree in one program run
# -m PROTGAMMAAUTO : use Automatic protein model assignment algorithm based on ML scores
# -p 12345 : random number seed for the parsimony inferences
# -x 12345 : random seed for rapid bootstrap
# -# 100 : number of bootstraps set to 100
# -s ${ALN}: alignment file in fasta or phylip format
# -n ${SUF}: naming suffix for files generated for a individual run
