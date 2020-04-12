#!/bin/sh
# *******************************************
# Script to perform DNA seq variant calling
# part 2 of 2
# assumes the read names have a unique identifier to
# be used as readgroup and sample name.
# If not, please change the section:
# "parse info from file name"
# *******************************************

# Update with the fullpath location of your input files
destination="/ptmp/LAS/arnstrm/sention"
bam_location="/ptmp/LAS/arnstrm/sention" # should have the bam index files too
fasta="/ptmp/LAS/arnstrm/sention/TIL11_isu_pangenome_pseudomolecules.fasta" # reference fasta file (should also have samtools faidx index)
nt=$(nproc) #number of threads to use in computation, set to number of cores in the server
chunksize=10000000 #per thread how much to process at a time(<10 Mb is a good choice, for large assemblies)
workdir="$TMPDIR/${out}" # files are written to TMPRDIR by default, this will decrease runtime for jobs


# create windows for faster processing
ml bedtools2
ml bioawk
bioawk -c fastx '{print $name"\t"length($seq)}' ${fasta} > ${fasta%.*}.len.txt
bedtools makewindows -w ${chunksize} -g ${fasta%.*}.len.txt | awk '{print $1":"$2+1"-"$3}' > ${destination}/genome-chunks.txt
windows="${destination}/genome-chunks.txt"

# load the software
ml sentieon-genomics
export SENTIEON_INSTALL_DIR=$(dirname $(dirname $(which sention)))

# Setup
mkdir -p $workdir
logfile=$workdir/${out}.run.log
exec >$logfile 2>&1
cd $workdir

# write a file with inputs, assumes all deuped bams are input
for bam in ${bam_location}/*deduped.bam; do
table=$(echo $bam |sed 's/deduped.bam/recal_data.table/g');
echo -e "-i ${bam} -q ${table} "
done > .bamfiles

# generate commands to run as array job
while read line; do
vcf=$(echo $line | sed '/s:/_/g');
echo "$SENTIEON_INSTALL_DIR/bin/sentieon driver -t $(nt) -r ${fasta} --interval=${line} "$(< .bamfiles)" --algo Haplotyper $TMPDIR/${vcf}.vcf"
done<${window} > sention.cmds
arsize=$(($(cat sention.cmds | wc -l) - 1))

cat <<- "EOF" > sention.sub
#!/bin/bash
#SBATCH -N 1
#SBATCH -n 16
#SBATCH -t 96:00:00
#SBATCH -J sention
#SBATCH -o sention.o%j
#SBATCH -e sention.e%j
#SBATCH --mail-user=${USER}@iastate.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
ml sentieon-genomics
IFS=$'\n' read -d '' -r -a CMDS < sention.cmds
CMD=${CMDS[$SLURM_ARRAY_TASK_ID]}
echo "running sention on ${CMD}"
eval ${CMD};
if [ $? -eq 0 ]
then
  echo "Success: sention on ${CMD}"
  exit 0
else
  echo "Failed: sention on ${CMD}"
exit 1
fi
EOF

sbatch --array=0-${arsize} sention.sub
