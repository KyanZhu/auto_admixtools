#!/bin/sh


li="Han_Wangmo Han_Ceheng Maonan_Pingtang Bouyei_Wangmo Bouyei_Ceheng Miao_Wangmo Miao_Ceheng She_Majiang Yao_Wangmo"
top_N=20
for i in ${li};do
	cat pairs.txt | awk -v pop=${i} '{if ($2==pop) print}' | head -n ${top_N}
done > top_N.txt
