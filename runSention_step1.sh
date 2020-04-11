#!/bin/sh
# *******************************************
# Script to perform DNA seq variant calling
# part 1 of 2
# assumes the read names have a unique identifier to
# be used as readgroup and sample name.
# If not, please change the section:
# "parse info from file name"
# *******************************************

# function to test exit status of the commands:
function mytest {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "error with $1" >&2
    fi
    return $status
}
# ******************************************
# E D I T 
# ******************************************
# Update with the fullpath location of your sample fastq
# read 1 and read 2 are provided as first and second argument, respectively
destination="/ptmp/LAS/arnstrm/sention" # location where the results will be transferred
fastq_folder="/ptmp/LAS/arnstrm/JRIAL11" # full path for the folder containing fastq
fastq_1="$1" # assumes <unique name>_R1.fastq.gz
fastq_2="$2" # assumes <unique name>_R2.fastq.gz
fasta="/ptmp/LAS/arnstrm/sention/TIL11_isu_pangenome_pseudomolecules.fasta" # reference genome, should contain faidx index (samtools)
unqname="$(basename ${fastq_1} | cut -f 1 -d "_")" # parse info from file name (assumes <unique name>_R1.fastq.gz)
nt=$(nproc) #number of threads to use in computation, set to number of cores in the server
workdir="$TMPDIR/${out}" # files are written to TMPRDIR by default, this will decrease runtime for jobs
# addition info (optional), providing these requires editing the recal step
#dbsnp="/home/regression/references/b37/dbsnp_138.b37.vcf.gz"
#known_Mills_indels="/home/regression/references/b37/Mills_and_1000G_gold_standard.indels.b37.vcf.gz"
#known_1000G_indels="/home/regression/references/b37/1000G_phase1.indels.b37.vcf.gz"

# ******************************************
# D O   N O T   E D I T 
# ******************************************
sample="${unqname}"
group="${unqname}"
platform="ILLUMINA"
out="${unqname}"
ml sentieon-genomics
export SENTIEON_INSTALL_DIR=/opt/rit/spack-app/linux-rhel7-x86_64/gcc-4.8.5/sentieon-genomics-201808.01-opfuvzrkzgocfdrhlxyjhpl2fvmik6x5

# ******************************************
# 0. Setup
# ******************************************
mkdir -p $workdir
logfile=$workdir/${out}.run.log
exec >$logfile 2>&1
cd $workdir

# ******************************************
# 1. Mapping reads with BWA-MEM, sorting
# ******************************************
#The results of this call are dependent on the number of threads used. To have number of threads independent results, add chunk size option -K 10000000
( $SENTIEON_INSTALL_DIR/bin/sentieon bwa mem -M -R "@RG\tID:$group\tSM:$sample\tPL:$platform" -t $nt -K 10000000 $fasta $fastq_folder/$fastq_1 $fastq_folder/$fastq_2 || echo -n 'error' ) | $SENTIEON_INSTALL_DIR/bin/sentieon util sort -r $fasta -o ${out}.sorted.bam -t $nt --sam2bam -i -

# ******************************************
# 2. Metrics
# ******************************************
mytest $SENTIEON_INSTALL_DIR/bin/sentieon driver -r $fasta -t $nt -i ${out}.sorted.bam --algo MeanQualityByCycle ${out}.mq_metrics.txt --algo QualDistribution ${out}.qd_metrics.txt --algo GCBias --summary ${out}.gc_summary.txt ${out}.gc_metrics.txt --algo AlignmentStat --adapter_seq '' ${out}.aln_metrics.txt --algo InsertSizeMetricAlgo ${out}.is_metrics.txt
mytest $SENTIEON_INSTALL_DIR/bin/sentieon plot GCBias -o ${out}.gc-report.pdf ${out}.gc_metrics.txt
mytest $SENTIEON_INSTALL_DIR/bin/sentieon plot QualDistribution -o ${out}.qd-report.pdf ${out}.qd_metrics.txt
mytest $SENTIEON_INSTALL_DIR/bin/sentieon plot MeanQualityByCycle -o ${out}.mq-report.pdf ${out}.mq_metrics.txt
mytest $SENTIEON_INSTALL_DIR/bin/sentieon plot InsertSizeMetricAlgo -o ${out}.is-report.pdf ${out}.is_metrics.txt

# ******************************************
# 3. Remove Duplicate Reads. It is possible
# to mark instead of remove duplicates
# by ommiting the --rmdup option in Dedup
# ******************************************
mytest $SENTIEON_INSTALL_DIR/bin/sentieon driver -t $nt -i ${out}.sorted.bam --algo LocusCollector --fun score_info ${out}.score.txt
mytest $SENTIEON_INSTALL_DIR/bin/sentieon driver -t $nt -i ${out}.sorted.bam --algo Dedup --rmdup --score_info ${out}.score.txt --metrics ${out}.dedup_metrics.txt ${out}.deduped.bam

# ******************************************
# 5. Base recalibration
# ******************************************
mytest $SENTIEON_INSTALL_DIR/bin/sentieon driver -r $fasta -t $nt -i ${out}.deduped.bam --algo QualCal ${out}.recal_data.table
mytest $SENTIEON_INSTALL_DIR/bin/sentieon driver -r $fasta -t $nt -i ${out}.deduped.bam -q ${out}.recal_data.table --algo QualCal ${out}.recal_data.table.post
mytest $SENTIEON_INSTALL_DIR/bin/sentieon driver -t $nt --algo QualCal --plot --before ${out}.recal_data.table --after ${out}.recal_data.table.post ${out}.recal.csv
mytest $SENTIEON_INSTALL_DIR/bin/sentieon plot QualCal -o ${out}.recal_plots.pdf ${out}.recal.csv

# ******************************************
# 6. Copy files form TMPDIR to WORK
# ******************************************
RC=1
while [[ $RC -ne 0 ]]; do
rsync -rts $workdir/ $destination/
RC=$?
sleep 10
done
date
