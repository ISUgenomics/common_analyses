#!/bin/bash

perl GOinfoKevinupdate2.pl $1 Gmv2_GODb > $1.GOIDs
perl SOYGO.pl Gmv2_GODb $1
R CMD BATCH "--args $1" Script_Fisher.R
perl combinefilesbyGO.pl $1_BP_fisher.txt ATH_GO_GOSLIM.022714  $1_BP_output.txt  > $1.BP.final
perl combinefilesbyGO.pl $1_MF_fisher.txt ATH_GO_GOSLIM.022714  $1_MF_output.txt  > $1.MF.final
