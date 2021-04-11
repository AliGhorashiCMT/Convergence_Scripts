#!/bin/bash 
export wfncutoff=30
export densitycutoff=150
for mult in  2 3 4 5; do
export mult
export ext=BC
export charge=-0.5
export nk=6
for i in {0..3} do
jdftx_gpu SCF_MAIN.in | tee BN"$mult""$mult""$ext".out
done
createXSF BN"$mult""$mult""$ext".out BN"$mult""$mult".xsf 
export ext=NC
export charge=0.5
export nk=8
for i in {0..3} do
jdftx_gpu SCF_MAIN.in | tee BN"$mult""$mult""$ext".out
done
createXSF BN"$mult""$mult""$ext".out BN"$mult""$mult".xsf 
done
