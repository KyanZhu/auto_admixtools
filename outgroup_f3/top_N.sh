#!/bin/sh


li="Songshan"
top_N=40
for i in ${li};do
	cat pairs.txt | awk -v pop=${i} '{if ($2==pop) print}' | head -n ${top_N}
done > top_${top_N}.txt
