#!/bin/bash


scriptName="runFASTQC"
function printUsage () {
    cat <<EOF

Synopsis

    $scriptName [-h | --help] Directory 

        Directory:  directory location of raw fastq files that need to be processed 
	
Output directory is fastqc and will be created upon running of script in the current folder.

Author

    Andrew Severin, Genome Informatics Facilty, Iowa State University
    severin@iastate.edu
    15 December, 2015


EOF
}


if [ $# -lt 1 ] ; then
        printUsage
        exit 0
fi

dir=$1

ls $dir/*.fastq | xargs -I xx echo "fastqc -o fastqc xx" > fastqc.commands
mkdir fastqc

