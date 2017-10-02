#!/bin/bash
# Prepares the Reference Genome for mapping as well as for using it with GATK pipeline
# You need to supply the referece genome as REF below or as:
# ./GATK_00_PrepareRef.sh your_genome.fasta
module load GIF2/picard
module load samtools
module load bwa
module load bedtools2
module load parallel
module load python
module load bioawk
REF="$1"
#index genome for (a) picard, (b) samtools and (c) bwa
bioawk -c fastx '{print}' $REF | sort -k1,1V | awk '{print ">"$1;print $2}' >Genome_sorted.fa
parallel <<FIL
java -Xmx100G -jar $PICARD_HOME/picard.jar CreateSequenceDictionary \
  REFERENCE=Genome_sorted.fa \
  OUTPUT=Genome_sorted.dict
samtools faidx Genome_sorted.fa
bwa index -a bwtsw Genome_sorted.fa
FIL
# Create interval list (here 100 kb intervals)
fasta_length.py Genome_sorted.fa > Genome_sorted_length.txt
bedtools makewindows -w 100000 -g Genome_sorted_length.txt > Genome_sorted_100kb_coords.bed
java -Xmx100G -jar $PICARD_HOME/picard.jar BedToIntervalList \
  INPUT= Genome_sorted_100kb_coords.bed \
  SEQUENCE_DICTIONARY=Genome_sorted.dict \
  OUTPUT=Genome_sorted_100kb_gatk_intervals.list
