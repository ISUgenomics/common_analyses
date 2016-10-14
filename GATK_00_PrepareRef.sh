#!/bin/bash
# Prepares the Reference Genome for mapping as well as for using it with GATK pipeline
# You need to supply the referece genome as REF below or as:
# ./GATK_00_PrepareRef.sh your_genome.fasta
module load picard
module load samtools
module load bwa
module load bedtools
module load parallel
module load python
REF="$1"
#index genome for (a) picard, (b) samtools and (c) bwa
parallel <<FIL
java -Xmx100G -jar $PICARD_HOME/picard.jar CreateSequenceDictionary \
  REFERENCE=${REF} \
  OUTPUT=${REF%.*}.dict
samtools faidx ${REF}
bwa index -a bwtsw ${REF}
FIL
# Create interval list (here 100 kb intervals)
python fasta_length.py ${REF} > ${REF%.*}_length.txt
bedtools makewindows -w 100000 -g ${REF%.*}_length.txt > ${REF%.*}_100kb_coords.bed
java -Xmx100G -jar $PICARD_HOME/picard.jar BedToIntervalList \
  INPUT=${REF%.*}_100kb_coords.bed \
  SEQUENCE_DICTIONARY=${REF%.*}.dict \
  OUTPUT=${REF%.*}_100kb_gatk_intervals.list
