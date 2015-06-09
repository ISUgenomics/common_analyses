#!/bin/bash
# Prepares the Reference Genome for mapping as well as for using it with GATK pipeline
# You need to supply the referece genome as REF below
module load picard_tools
module load samtools
module load bwa
module load parallel
REF="$1"
parallel <<FIL
java -Xmx100G -jar /data003/GIF/software/packages/picard_tools/1.130/picard.jar CreateSequenceDictionary \
  REFERENCE=${REF} \
  OUTPUT=${REF%.*}.dict
samtools faidx ${REF}
bwa index -a bwtsw ${REF}
FIL
