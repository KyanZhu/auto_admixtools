#!/bin/bash


geno_prefix=/home/KongyangZhu/songshan/popgen/1.dataset/1240k/Songshan_1240k
f2_output=/home/KongyangZhu/songshan/popgen/1.dataset/f2/f2_blocks
maxmiss=", maxmiss=1"  # ", maxmiss=1" 相当于all snps
cat poplist.txt | egrep -v "#|=" > poplist.tmp  # 需要提取的人群
extract_pops=$(cat poplist.tmp) ; rm poplist.tmp

for i in "extract.R";do
    echo "args <- commandArgs(trailingOnly = TRUE)"
    echo "library(admixtools)"
    echo "library(tidyverse)"
    echo "genotype_data = args[1]"
    echo "f2_dir = args[2]"
    echo "pops = args[3:length(args)]"
    echo "extract_f2(genotype_data, f2_dir, pops = pops${maxmiss})"
done > extract.R

rm -rf ${f2_output}
Rscript extract.R ${geno_prefix} ${f2_output} ${extract_pops}
rm extract.R
