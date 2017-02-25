#!/bin/bash
source /work/GIF/software/programs/smrtportal/2.3.0/install/smrtanalysis_2.3.0.140936/etc/setup.sh
WORKDIR="/work/GIF/arnstrm/Purcell/20161214_redabalone/01_data/pacbio"
SMRTDIR="/work/GIF/software/programs/smrtportal/2.3.0/install/smrtanalysis_2.3.0.140936"
INPUT=${WORKDIR}/input.fofn
ConsensusTools.sh CircularConsensus \
   --minFullPasses 0  \
   --minPredictedAccuracy 80 \
   --parameters ${SMRTDIR}/analysis/etc/algorithm_parameters/2015-11 \
   --numThreads 40 \
   --fofn ${WORKDIR}/input.fofn \
   -o ${WORKDIR}/output

