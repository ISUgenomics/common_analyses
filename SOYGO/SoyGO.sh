#!/bin/bash

export SOYGO="/data005/GIF2/severin/isugif/common_analyses/SOYGO"
perl $SOYGO/GOinfoKevinupdate2.pl $1 $SOYGO/Gmv2_GODb > $1.GOIDs
perl $SOYGO/SOYGO.pl $SOYGO/Gmv2_GODb $1
R CMD BATCH "--args $1" $SOYGO/Script_Fisher.R
perl $SOYGO/combinefilesbyGO.pl $1_BP_fisher.txt $SOYGO/ATH_GO_GOSLIM.022714  $1_BP_output.txt  > $1.BP.final
perl $SOYGO/combinefilesbyGO.pl $1_MF_fisher.txt $SOYGO/ATH_GO_GOSLIM.022714  $1_MF_output.txt  > $1.MF.final
rm $1*.txt
