#!/bin/bash

module load $1

#Grab bamfiles that will be used for input. all bam files in the folder will be selected.
#these files will be written to a temp file that will be read in later to create the input line for each command
unset -v bamfiles
bamfiles=(*.bam)
for bam in ${bamfiles[@]}; do \
echo -en "-I ${bam} "; \
done > temp

#combine the reference genome, 100k genomic intervals and the input files into gatk commands
#need to figure out how to include direct path to genomeanalysistk.jar file if that is necessary
while read line; do \
g2=$(echo $line | awk '{print $1":"$2"-"$3}'); \
g1=$(echo $line | awk '{print $1"_"$2"_"$3}'); \
CWD=$(pwd)
echo -n "java -Xmx2048m -XX:+UseParallelOldGC -XX:ParallelGCThreads=1 -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Djava.io.tmpdir=\${TMPDIR} -jar /data003/GIF/software/packages/gatk/3.3/GenomeAnalysisTK.jar -T HaplotypeCaller --pcr_indel_model NONE \
-R ${GENOMEFASTA} \
$(cat temp) \
-L "${g2}" --genotyping_mode DISCOVERY -stand_emit_conf 10 -stand_call_conf 30 -o \${TMPDIR}/"${g1}".vcf;"; \
echo "mv \${TMPDIR}/"${g1}".vcf $CWD" ; \
done<${GENOMEINTERVALS}  > gatk.cmds

cat <<-FIL > GATK04test.sub
#!/bin/bash
#PBS -q batch
#PBS -l nodes=8:ppn=16
#PBS -l walltime=48:00:00
#PBS -N GATK05
#PBS -o \${PBS_JOBNAME}.o\${PBS_JOBID} -e \${PBS_JOBNAME}.e\${PBS_JOBID}
#PBS -m ae -M andrewseverin@gmail.com
cd \$PBS_O_WORKDIR
ulimit -s unlimited
chmod g+rw \${PBS_JOBNAME}.[eo]\${PBS_JOBID}
module use /data003/GIF/software/modules
module load parallel
module load java/1.7.0_76
which java
parallel --env _ --jobs 8 --sshloginfile \$PBS_NODEFILE \
  --joblog gatk_progress_05.log --workdir \$PWD < gatk.cmds
ssh condo "qstat -f \${PBS_JOBID} |head"
FIL

#set the --env _ option in order to capture the PBS varaibles that would not be passed through otherwise to parallel on other nodes"
