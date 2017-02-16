#!/bin/bash

module load augusuts
module load maker

species="genus_spp"
genome="yourgenomefile.fasta"
cdna="yourtrinityfile.fasta"
maker="maker.gff"
cwd=$(pwd)

# convert gff to gff3
maker2zff -n ${maker}
zff2gff3.pl genome.ann | perl -plne 's/\t(\S+)$/\t\.\t$1/' > ${maker%.*}.gff3

autoAug.pl --species=${species} --genome=${genome} --cdna=${cdna} --trainingset=${maker%.*}.gff3
cd ./autoAug/autoAugPred_abinitio/shells
parallel --joblog progress.log --workdir $PWD  "./{}" ::: aug* || {
echo >&2 step 2 failed for $FILE
exit 1
}
cd $cwd
autoAug.pl --species=${species} --genome=${genome} --useexisting --hints=${cwd}/autoAug/hints/hints.E.gff  -v -v  --index=1
cd autoAug/autoAugPred_hints/shells
parallel --joblog progress.log --workdir $PWD  "./{}" ::: aug* || {
echo >&2 step 4 failed for $FILE
exit 1
}
autoAug.pl --species=${species} --genome=${genome} --useexisting --hints=${cwd}/autoAug/hints/hints.E.gff --estali=${cwd}/autoAug/cdna/cdna.psl -v -v -v  --index=2


