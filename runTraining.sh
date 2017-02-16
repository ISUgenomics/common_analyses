#!/bin/bash
module use /shared/software/GIF/modules
module load hisat2
module load maker/2.31.8b
module load samtools
module load gmap-gsnap/20160404
module load assemblage

pre=$(pwd)
CHR="CHRFILE"
BASE=$(basename $(dirname $(pwd)))
TRANS="${pre}/${CHR}.all.maker.transcripts.fasta"
#process maker

gff3_merge  -d ${CHR}.maker.output/${CHR}_master_datastore_index.log
fasta_merge -d ${CHR}.maker.output/${CHR}_master_datastore_index.log


# train snap
mkdir ${CHR}_SNAP
cd ${CHR}_SNAP
maker2zff -n ${pre}/${CHR}.all.gff
fathom genome.ann genome.dna -categorize 1000
fathom -export 1000 -plus uni.ann uni.dna
forge export.ann export.dna
hmm-assembler.pl ${CHR} . > ${pre}/${CHR}.snap.hmm



# train augustus
GENOME="${pre}/${CHR}.fasta"
zff2gff3.pl genome.ann | perl -plne 's/\t(\S+)$/\t\.\t$1/' > ${CHR}.temp.gff3
autoAug.pl --genome=${GENOME} --species=${CHR}.${BASE} --cdna=${TRANS} --trainingset=${CHR}.temp.gff3


#dna="${pre}/${CHR}_SNAP/autoAug/cdna/cdna.psl"
#hints="${pre}/${CHR}_SNAP/autoAug/hints/hints.E.gff"

#autoAug.pl --genome=${GENOME} --species=${CHR}.${BASE} --useexisting --hints=${hints}  -v -v  --index=1
#autoAug.pl --genome=${GENOME} --species=${CHR}.${BASE} --useexisting --hints=${hints} --estali=${cdna} -v -v -v  --index=2

