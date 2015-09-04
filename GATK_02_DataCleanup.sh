#!/bin/bash
# runs the complete Data Cleanup part of the GATK best practices pipeline
# Sort, Clean, MarkDuplicates, Add ReadGroups and IndelRealigner
# You'll need:
# 1. Alignment files in BAM format (for each line separately) with names formated as uniquename_otherinfo.bam
#    unique name shouldn't have any underscores in them, otherinfo added will be used for the readgroup [REQUIRED]
# 2. Reference genome in FASTA format (should be the same that was used for mapping) [REQUIRED]
# GATK variable needs to be set to GATK directory

######################################
### Format file names as:
###
### <UNIQIE_FILE_IDENTIFIER>_<REFERENCEGENOME>_<EXPTTITLE>.bam
###
### This will ensure that the Read Group will be properly parsed
### Else you need to manually add them below (SAMPLE, UNIT, RGLB)
###
######################################

module load picard_tools
module load java
module load samtools
module load gatk

FILE="$1"
REF="$2"

# for adding read group info
# if filenames don't have 3 fields, manually add them below
SAMPLE=$(echo ${FILE} |cut -d "_" -f 1)
UNIT=$(echo ${FILE} |cut -d "_" -f 2)
RGLB=$(echo ${FILE} |cut -d "_" -f 3)
TMPDIR=/local/scratch/${USER}/${PBS_JOBID}

## Sorting BAM file
echo ${TMPDIR};
java -Xmx100G -jar $PICARD/picard.jar SortSam \
  TMP_DIR=${TMPDIR}\
  INPUT=${FILE} \
  OUTPUT=${TMPDIR}/${FILE%.*}_picsort.bam \
  SORT_ORDER=coordinate \
  MAX_RECORDS_IN_RAM=5000000 || {
  echo >&2 sorting failed for $FILE
  exit 1
}
cp ${TMPDIR}/${FILE%.*}_picsort.bam $PBS_O_WORKDIR/
## Cleaning Alignment file
java -Xmx100G -jar $PICARD/picard.jar CleanSam \
  TMP_DIR=${TMPDIR} \
  INPUT=${TMPDIR}/${FILE%.*}_picsort.bam \
  OUTPUT=${TMPDIR}/${FILE%.*}_picsort_cleaned.bam \
  MAX_RECORDS_IN_RAM=5000000 || {
  echo >&2 cleaning failed for $FILE
  exit 1
}
cp ${TMPDIR}/${FILE%.*}_picsort_cleaned.bam $PBS_O_WORKDIR/
## Marking Duplicates
java -Xmx100G -jar $PICARD/picard.jar MarkDuplicates \
  TMP_DIR=${TMPDIR} \
  INPUT=${TMPDIR}/${FILE%.*}_picsort_cleaned.bam \
  OUTPUT=${TMPDIR}/${FILE%.*}_dedup.bam \
  METRICS_FILE=${TMPDIR}/${FILE%.*}_metrics.txt \
  ASSUME_SORTED=true \
  REMOVE_DUPLICATES=true \
  MAX_RECORDS_IN_RAM=5000000 || {
  echo >&2 deduplicating failed for $FILE
  exit 1
}
cp ${TMPDIR}/${FILE%.*}_metrics.txt $PBS_O_WORKDIR/
cp ${TMPDIR}/${FILE%.*}_dedup.bam $PBS_O_WORKDIR/
## Adding RG info
java -Xmx100G -jar $PICARD/picard.jar AddOrReplaceReadGroups \
  TMP_DIR=${TMPDIR} \
  INPUT=${TMPDIR}/${FILE%.*}_dedup.bam \
  OUTPUT=${TMPDIR}/${FILE%.*}_dedup_RG.bam \
  RGID=${SAMPLE} RGLB=${RGLB} \
  RGPL=illumina \
  RGPU=${UNIT} \
  RGSM=${SAMPLE} \
  MAX_RECORDS_IN_RAM=5000000 \
  CREATE_INDEX=true || {
  echo >&2 RG adding failed for $FILE
  exit 1
}
cp ${TMPDIR}/${FILE%.*}_dedup_RG.bam* $PBS_O_WORKDIR/
## Indel Realigner: create intervals
java -Xmx60G -jar $GATK \
  -T RealignerTargetCreator \
  -R ${REF} \
  -I ${TMPDIR}/${FILE%.*}_dedup_RG.bam \
  -o ${TMPDIR}/${FILE%.*}_target_intervals.list || {
echo >&2 Target intervels list generation failed for $FILE
exit 1
}
cp ${TMPDIR}/${FILE%.*}_target_intervals.list $PBS_O_WORKDIR/
## Indel Realigner: write realignments
java -Xmx60G -jar $GATK \
  -T IndelRealigner \
  -R ${REF} \
  -I ${TMPDIR}/${FILE%.*}_dedup_RG.bam \
  -targetIntervals ${TMPDIR}/${FILE%.*}_target_intervals.list \
  -o ${TMPDIR}/${FILE%.*}_realigned.bam || {
echo >&2 Indel realignment failed for $FILE
exit 1
}
cp ${TMPDIR}/${FILE%.*}_realigned.bam $PBS_O_WORKDIR/
echo "All done!"
