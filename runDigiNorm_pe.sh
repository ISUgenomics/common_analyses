#!/bin/bash
# runs digital normalization for the reads using khmer
# configured to run only on paied-end data
# run it as:
# runDigiNorm_pe.sh <read1.fq> <read2.fq>

if [ $# -lt 1 ] ; then
        echo "usage: runDigiNorm_pe.sh <read1.fq> <read2.fq>"
        echo ""
        echo "runs digital normalization for the paired-end reads"
        echo "paired-end reads can either be gzipped or uncompressed"
        echo ""
exit 0
fi
################################
##### CHANGE SETTINGS HERE #####
################################
ksize=32 #max kmer is 32
numHashes=4
cutoff=20
memory=100e9 #for using 100G
###############################
##### SETTINGS END HERE #######
###############################


module load trimmomatic
module load python
module load fastx-toolkit/0.0.14

KHMER=$(dirname $(which normalize-by-median.py))

R1="$1"
R2="$2"

name=$(basename ${R1} |cut -f 1-3 -d "_")


#trim
echo "running trimmomatic on  ${name}";

java -jar $TRIMMOMATIC_HOME/trimmomatic.jar PE \
   ${R1} ${R2} \
   ${name}_s1_pe ${name}_s1_se ${name}_s2_pe ${name}_s2_se \
    ILLUMINACLIP:${TRIMMOMATIC_HOME}/adapters/TruSeq3-PE.fa:2:30:10 \
    LEADING:3 \
    TRAILING:3 \
    SLIDINGWINDOW:4:15 \
    MINLEN:36 || {
  echo >&2 trimming failed for $FILE
exit 1
}
cat ${name}_s1_se ${name}_s2_se  | gzip -9c > ${name}.se.fq.gz

#interleave
echo "interleaving reads for ${name}";
python ${KHMER}/interleave-reads.py \
  --output ${name}_interleaved.fq \
    ${name}_s1_pe ${name}_s2_pe || {
  echo >&2 interleaving failed for $FILE
exit 1
}

#quality filter
echo "running quality filtering for ${name}";
fastq_quality_filter \
  -Q33 \
  -q 30 \
  -p 50 \
  -i ${name}_interleaved.fq \
  -o ${name}_interleaved_qc.fq || {
  echo >&2 filtering failed for $FILE
exit 1
}

#normalize
echo "normalizing reads for ${name}";
python ${KHMER}/normalize-by-median.py \
  --ksize $ksize \
  --n_tables $numHashes \
  --cutoff $cutoff \
  --max-memory-usage $memory \
  --report ${name}.report \
  --out ${name}_C${cutoff}_normalized.fq \
    ${name}_interleaved_qc.fq || {
  echo >&2 normalizing failed for $FILE
exit 1
}

#extract paired reads
echo "extracting paired reads for ${name}";
python ${KHMER}/extract-paired-reads.py \
  --output-paired ${name}_C${cutoff}_normalized.fq.pe \
  --output-single ${name}_C${cutoff}_normalized.fq.se \
    ${name}_C${cutoff}_normalized.fq || {
  echo >&2 extaction failed for $FILE
exit 1
}

#split reads
echo "splitting paired reads for  ${name}";
python ${KHMER}/split-paired-reads.py \
  --output-first  ${name}_normalized_C${cutoff}_R1.fq \
  --output-second ${name}_normalized_C${cutoff}_R2.fq \
${name}_C${cutoff}_normalized.fq.pe || {
  echo >&2 splitting failed for $FILE
exit 1
}
#cleanup

mkdir -p normalized_C${cutoff};
mv ${name}_normalized_C${cutoff}_R[12].fq normalized__C${cutoff}/
mkdir -p khmer_intermediary_files/{report_files,fastq_files,se_files}
mv ${name}.report khmer_intermediary_files/report_files/
mv ${name}_s[12]_[ps]e khmer_intermediary_files/fastq_files/
mv ${name}_C20_normalized.fq* khmer_intermediary_files/fastq_files/
mv ${name}.se.fq.gz khmer_intermediary_files/se_files/
mv ${name}_interleaved_qc.fq ${name}_interleaved.fq khmer_intermediary_files/fastq_files/

echo "all done!";
