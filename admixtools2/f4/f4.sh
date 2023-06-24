#!/bin/bash


alias rmsp='sed "s/^\s*//g" | sed "s/[[:blank:]]\+/\t/g"'

f2_prefix="/home/KongyangZhu/songshan/popgen/1.dataset/f2/f2_blocks"
Rscript f4stats.r ${f2_prefix}
head -n 1 f4.result > result.xls
tail -n+2 f4.result | awk '{if (($2==$3) || ($2==$4) || ($3==$4)) $7="NA" ; print $0 }' | grep -v "NA" | rmsp | sort -nk7 >> result.xls