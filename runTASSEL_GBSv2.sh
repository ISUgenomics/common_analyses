#!/bin/bash
# only 5.2.16 supports GBS V2 pipeline
module load tassel/5.2.16
###################
# C A U T I O N
###################
# all intermediary files are named genericly
# re-running this will overwrite those files
####################

# requires these 3 files, note that you need to enter the dir containing fastq file, not the file
KEY="B73xTeo_Inbred_Buckler_Doebley_key.txt"
REF="referenceSequence/new_zea.fa"
FASTQ_DIR="fastq"
# config
THREADS="32"
OUTVCF="productioHapMap_b73.vcf"

# GBSSeqToTagDBPlugin
run_pipeline.pl -fork1 -GBSSeqToTagDBPlugin \
   -e ApeKI \
   -i ${FASTQ_DIR} \
   -db ./GBSV2.db \
   -k ${KEY} \
   -kmerLength 64 -minKmerL 20 -mnQS 20 -mxKmerNum 100000000 \
   -endPlugin -runfork1 

# TagExportToFastqPlugin
run_pipeline.pl -fork1 -TagExportToFastqPlugin \
  -db ./GBSV2.db \
  -o tagsForAlign.fa.gz \
  -c 1 \
  -endPlugin -runfork1

# BWA alignment
#bwa index -a bwtsw ${REF}
bwa aln -t ${THREADS} ${REF} tagsForAlign.fa.gz > tagsForAlign.sai
bwa samse ${REF} tagsForAlign.sai tagsForAlign.fa.gz > tagsForAlign.sam

# SAMToGBSdbPlugin
run_pipeline.pl -fork1 -SAMToGBSdbPlugin \
  -i  tagsForAlign.sam \
  -db ./GBSV2.db \
  -aProp 0.0 -aLen 0 \
  -endPlugin -runfork1

# DiscoverySNPCallerPluginV2
run_pipeline.pl -fork1 -DiscoverySNPCallerPluginV2 \
  -db ./GBSV2.db \
  -mnLCov 0.1 -mnMAF 0.01 \
  -deleteOldData true \
  -endPlugin -runfork1

# SNPQualityProfilerPlugin
run_pipeline.pl -fork1 -SNPQualityProfilerPlugin \
  -db ./GBSV2.db \
  -tname "TEST" \
  -statFile "outputStats.txt" \
  -deleteOldData true \
  -endPlugin -runfork1

# GetTagSequenceFromDBPlugin
run_pipeline.pl -fork1 -GetTagSequenceFromDBPlugin \
  -db ./GBSV2.db \
  -o ./allTagFile.txt \
  -endPlugin -runfork1

# (optional) UpdateSNPPositionQualityPlugin
#run_pipeline.pl -fork1 -UpdateSNPPositionQualityPlugin \
#  -db ./GBSV2.db \
#  -qsFile myQsFile \
#  -endPlugin -runfork1

# (optional) SNPCutPosTagVerificationPlugin
#run_pipeline.pl -fork1 -SNPCutPosTagVerificationPlugin \
#  -db ./GBSV2.db \
#  -chr 9 -pos 187567 \
#  -type snp \
#  -outFile ./myOutFile \
#  -endPlugin -runfork1

# ProductionSNPCallerPluginV2
run_pipeline.pl -fork1 -ProductionSNPCallerPluginV2 \
  -db ./GBSV2.db \
  -e ApeKI \
  -i ./fastq \
  -k ${KEY} \
  -kmerLength 64 \
  -o ${OUTVCF} \
  -endPlugin -runfork1



