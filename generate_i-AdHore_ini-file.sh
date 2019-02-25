#!/bin/bash
gff="$1"
base="$2"
#table="$3"
mkdir -p $base
awk '$3=="mRNA" {print $1"\t"$7"\t"$9}' $gff |\
     sed 's/;/\t/1' | sed 's/ID=//g' |\
     awk -v x="$base" '{print x"_"$1"\t"$3""$2}' |\
     sed 's/Sobic./'$base'_/g' >  $base/${base}_full.lst
awk '$3=="mRNA" {print $9}' $gff |\
     sed -e 's/;/\t/1' -e 's/ID=//g' |\
     cut -f 1  |\
     awk '{print $1"\tfamily."$1}' |\
     sed -e 's/family.Sobic./OG_/g' -e 's/.mrna.\{1,3\}$//g' |\
     sed 's/^Sobic./'$base'_/1'  >>  blast_table.txt

awk '{print>$1"_chr.list"}'  ${base}/${base}_full.lst
#echo "blast_table=$(realpath ${base}_blast.pairs)"
echo "genome=${base}"
i=1
for list in ${base}*_chr.list; do
cut -f 2 $list > $list.temp;
mv $list.temp $base/$list;
echo "CO$i ${base}/${list}"
rm $list
((i++))
done
cat <<EOF
blast_table=blast_table.txt
table_type=family
cluster_type=colinear
tandem_gap=10
prob_cutoff=0.1
write_stats=true
multiple_hypothesis_correction=FDR
gap_size=15
cluster_gap=20
q_value=0.7
anchor_points=5
alignment_method=gg2
max_gaps_in_alignment=20
output_path=$(pwd)/iadhore_output2
number_of_threads=16
visualizeGHM=true
visualizeAlignment=true
verbose_output=true
EOF
