#!/bin/bash
# Script to generate PBS sub files for quiver analysis
# 07/25/2016
# Andrew Severin <severin@iastate.edu>

function printUsage () {
    cat <<EOF

Synopsis

    $scriptName [-h | --help] <Number of commands per file> <commands_file>

Description

    This is a bash script that generates the sub file for each line/lines reading the command file
    The submission file is formatted to run on condo with 48 hours walltime on default queue.
	The output will be named with the commands_file name along with the number suffix.

        -h, --help
        Brings up this help page

    <commands_file>
    File with commands. Each line should be a independent job that should not have any variables.
    Eg., "sh bash_script.sh file1;" as first line, "sh bash_script.sh file2;" as second line and so on
	makes a good commands file. Note that the lines should end with colon (;). 

#example input file creation
#ls *h5 | xargs -I xx echo "pbalign --forQuiver xx genome245.fasta aligned_reads.xx.cmp.h5" > pbalign.commands

Author

    Andrew Severin, Genome Informatics Facilty, Iowa State University
    severin@iastate.edu
    25 July, 2016


EOF
}
if [ $# -lt 1 ] ; then
        printUsage
        exit 0
fi


INFILE="$1"



function readlines () {
    local N=1
    local line
    local rc="1"
    for i in $(seq 1 $N); do
        read line
        if [ $? -eq 0 ]; then
            echo "$line"
            rc="0"
        else
            break
        fi
    done
    return $rc
}
netid=$(whoami)
num=1
while chunk=$(readlines ${LINES}); do
cat <<JOBHEAD > ${INFILE%%.*}_${num}.sub
#!/bin/bash
#PBS -l nodes=1:ppn=16
#PBS -l walltime=48:00:00
#PBS -N ${INFILE%%.*}_${num}
#PBS -o \${PBS_JOBNAME}.o\${PBS_JOBID} -e \${PBS_JOBNAME}.e\${PBS_JOBID}
#PBS -m ae -M $netid@iastate.edu
cd \$PBS_O_WORKDIR
ulimit -s unlimited
chmod g+rw \${PBS_JOBNAME}.[eo]\${PBS_JOBID}
module use /shared/modulefiles 
module load LAS/parallel/20150922 
module load python/2.7.10
module load SMRTAnalysis/2.3.0
JOBHEAD
echo -e "${chunk}" >> ${INFILE%%.*}_${num}.sub
echo -e "qstat -f \"\$PBS_JOBID\" | head" >> ${INFILE%%.*}_${num}.sub
echo -e "\nwalltime" >> ${INFILE%%.*}_${num}.sub
((num++))
done<"${INFILE}"
sed -i '/^$/d' ${INFILE}
