#!/bin/bash
# coding:utf-8
# @Time : 2022/3/19 01:50
# @Author : cewinhot
# @Version：v0.1
# @File : f4ratio.sh

# SETTINGS
dataset_prefix=../../1240k/1240k
prefix=Dulan
py_path=~/sh/f4ratio/f4ratio2xlsx.py

# Main
for i in "f4ratio.par";do
    echo "indivname:      ${dataset_prefix}.ind"
    echo "snpname:        ${dataset_prefix}.snp"
    echo "genotypename:   ${dataset_prefix}.geno"
    echo "popfilename:    ${prefix}.pop"
    echo "inbreed:        YES"
done > ${prefix}.par

# alpha = f4(A,O; X,C)/ f4(A,O; B, C) 
a="DevilsCave_N.SG Mongolia_N_East"
b="Upper_YR_LN"
x="Dulan Tibetan_Lhasa Tibetan_Nagqu Lubrak Sherpa Nepal_Chokhopani_2700BP.SG Nepal_Mebrak_2125BP.SG Nepal_Samdzong_1500BP.SG"
c="Onge.DG"
o="Mbuti.DG"
parallel echo {1} {2} : {3} {4} :: {1} {2} : {5} {4} ::: ${a} ::: ${o} ::: ${x} ::: ${c} ::: ${b} > ${prefix}.pop

qpF4ratio -p ${prefix}.par > ${prefix}.txt
cat ${prefix}.txt | grep result: | awk '{print $2,$9,$4,$5,$3,$11,$12,$13,$14}' > ${prefix}.result
cp ${py_path} ./f4ratio2xlsx.py
python f4ratio2xlsx.py ${prefix}.result
notify qpF4ratio
