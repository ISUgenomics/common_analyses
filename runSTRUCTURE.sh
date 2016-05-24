#!/bin/bash


#convert vcf file to structure format
#create spid file using the gui and webstart from website
#http://heidi.chnebu.ch/doku.php?id=pgd_spider_-_manual
module use /shared/software/GIF/modules/
module load PGDspider
INFILE=$1
OUTFILE=$(echo ${INFILE%.*}).recode.str
$PGDspider -inputfile  $INFILE  -inputformat VCF -outputfile $OUTFILE  -outputformat STRUCTURE -spid $spidvcf2structure 


UNIQ=""
COUNTER=1
UNIQ="structure"
((COUNTER++))
UC="_$UNIQ$COUNTER"

rm structure.commands_$UNIQ
for i in $(seq 1 1 16); do 

module load fastSTRUCTURE/e47212f 
INFILE_structure=$(echo ${INFILE%.*}).recode
((COUNTER++))
UC="_$UNIQ"
echo "python $structure --input=$INFILE_structure --output structOut$UC --seed=100 -K $i --format=str" >> structure.commands$UC
done

module load parallel
parallel --jobs 16 <structure.commands$UC

awk '{print $1}' $(echo ${INFILE%.*}).recode.str | uniq > lines$UC.txt

python `which chooseK.py` --input=structOut_$UNIQ*

KVAL=$(python `which chooseK.py` --input=structOut_$UNIQ* | awk '(NR==1){print $NF}')
echo "<Covariate>" > STRUCTURE_K$KVAL$UC.Qmatrix
QHEADER=$(seq 1 1 $KVAL | awk '{print "Q"$1}' | tr '\n' '\t')
echo -e "<Trait>\t$QHEADER" >> STRUCTURE_K$KVAL$UC.Qmatrix
paste lines_$UNIQ.txt structOut_$UNIQ.$KVAL.meanQ  >> STRUCTURE_K$KVAL$UC.Qmatrix
