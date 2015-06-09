#!/bin/bash

PATH=$PATH:~/.local/bin
GFF="/home/arnstrm/arnstrm/20140324_Bhattacharyya_fusarium_RNAseq/01_DATA/C_GFF/Fusvul.gff3"
INFILE="$1"
OUTFILE=$(echo $INFILE | sed 's/unpaired/count/g')

htseq-count -s no -m intersection-nonempty -t gene -i ID $INFILE $GFF > $OUTFILE
