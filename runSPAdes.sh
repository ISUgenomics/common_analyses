#!/bin/bash

/shared/software/GIF/programs/SPAdes/3.7.1/bin/spades.py \
--pe1-1 /data019/LAS/mhufford/zea_diplo/PE250-2/Diplo_Perennis_NoIndex_L001_R1_001.fastq.gz \
--pe1-2 /data019/LAS/mhufford/zea_diplo/PE250-2/Diplo_Perennis_NoIndex_L001_R3_001.fastq.gz \
--pe2-1 /data019/LAS/mhufford/zea_diplo/PE250-1/Diplo_Perennis_NoIndex_L001_R1_001.fastq.gz \
--pe2-2 /data019/LAS/mhufford/zea_diplo/PE250-1/Diplo_Perennis_NoIndex_L001_R4_001.fastq.gz \
--mp1-1 /data019/LAS/mhufford/zea_diplo/ZeaDipMatepair/Data/stfxbcdo6y/Unaligned/Project_JRAL_L3_Zea_dip_matepair/Zea-dip-matepair_S3_L003_R1_001.fastq.gz \
--mp1-2 /data019/LAS/mhufford/zea_diplo/ZeaDipMatepair/Data/stfxbcdo6y/Unaligned/Project_JRAL_L3_Zea_dip_matepair/Zea-dip-matepair_S3_L003_R3_001.fastq.gz \
--threads 40 \
--tmp-dir $TMPDIR \
-k 127 \
-o spades_diplo

