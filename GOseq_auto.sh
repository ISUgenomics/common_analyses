#!/bin/bash

module unload R
module load R/3.1.2


#define the go annotation file
export goAnnot="go_annotation.sorted.uniq.Mapped"
#define the gene lengths file
export geneLen="gene.lengths.txt"


#create a list of your genes of interest
#one per line
#geneID1
#geneID2 
#etc
#GOI = Genes of Interest
#export GOI="GOI.txt"
export GOI=$1

#create a factor label for the GOI
#export labelgoi="incOverTm"
export labelgoi=$1

#create the factor labeled file
#GOI geneID1
#GOI geneID2
#GOI etc
#awk 'BEGIN{OFS="\t"} {print "'$labelgoi'",$1}' $GOI > GOI_factorFile.txt

#create a list of all your genes
export Allgenes="Allgenes.txt"

#create a factor label for the GOI
export labelallg="Allgenes"

#create the factor labeled file
#seriola geneID1
#seriola geneID2
#seriola etc
#r awk 'BEGIN{OFS="\t"} {print "'$labelallg'",$1}' $GOI > Allgenes_factorFile.txt

#r awk '{print $1}' GOI_factorFile.txt Allgenes_factorFile.txt
cat $GOI $Allgenes | sort | uniq -c | awk 'BEGIN{OFS="\t"} ($1==1) {print "'$labelallg'",$2} ($1==2) {print "'$labelgoi'",$2}' >factor_file_$GOI 

run_GOseq.pl --factor_labeling factor_file_$GOI  --GO_assignments $goAnnot  --lengths $geneLen 

mkdir factor_file
mv factor_file_* factor_file
mkdir GO_OUT
mv *enriched GO_OUT/
mv *depleted GO_OUT/
mkdir transcriptsIDs
mv *.txt transcriptsIDs/

