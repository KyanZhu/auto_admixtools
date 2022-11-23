#!/bin/bash

# coding:utf-8
# @Time : 2022/3/29 01:50
# @Author : cewinhot 
# @Version: v1.1
# @File : admixturef3_v1.1.sh


work_dir=/home/KongyangZhu/dulan/25.admixturef3/admixturef3_2
geno=../../HO/HO.geno
snp=../../HO/HO.snp
ind=../../HO/HO.ind
f3_sh=/home/KongyangZhu/sh/admixturef3/1.0
p1s=$(cat p1s)
p2s="Dulan"
target=$(cat target)
thread=20


cd ${work_dir}
# Pre-Processing : soft link, copy tools
alias rmsp='sed "s/^\s*//g" | sed "s/[[:blank:]]\+/\t/g"'
if [ ! -f f3.geno ] || [ ! -f f3.snp ] || [ ! -f f3.ind ];then ln -s ${geno} f3.geno ; ln -s ${snp} f3.snp ; ln -s ${ind} f3.ind ; fi
cp ${f3_sh}/merge_f3_result.v1.0.py ./
# check poplist
cat f3.ind | rmsp | cut -f 3 | sort -u > checklist.tmp
poplist="${p1s} ${p2s} ${target}"
for i in ${poplist};do cat checklist.tmp | grep "^${i}$" > /dev/null ; if [ ! $? -eq 0 ] ;then echo -e "Pop [ ${i} ] not exists\nEnd Processing!" ; exit 1 ; fi ; done
rm checklist.tmp ; echo -e "Check poplist Done\nStart f3-statistics!"

# extract
for i in ${poplist};do echo ${i} ; done | sort -u   > extract.poplist
echo "genotypename: f3.geno"                        > extract.par
echo "snpname:      f3.snp"                        >> extract.par
echo "indivname:    f3.ind"                        >> extract.par
echo "outputformat: PACKEDANCESTRYMAP"             >> extract.par
echo "genotypeoutname: extract.geno"               >> extract.par
echo "snpoutname:      extract.snp"                >> extract.par
echo "indivoutname:    extract.ind"                >> extract.par
echo "poplistname:     extract.poplist"            >> extract.par
convertf -p extract.par

# qp3pop
parallel echo {1} {2} {3} ::: ${p1s} ::: ${p2s} ::: ${target} > qp3pop

# qp3.par
echo "genotypename:   extract.geno"   > qp3.par
echo "snpname:        extract.snp"   >> qp3.par
echo "indivname:      extract.ind"   >> qp3.par
echo "popfilename:    qp3pop"        >> qp3.par
echo "inbreed:        YES"           >> qp3.par

# multi_admixture-f3
a=$(wc -l qp3pop | cut -d ' ' -f 1)
b=$(expr ${a} / ${thread} )
line=$(expr ${b} + 1 )
split -l ${line} qp3pop spop
li=$(ls spop*)
for i in ${li};do cat qp3.par | sed "s/qp3pop/${i}/g" > ${i}.par ; done
parallel --verbose qp3Pop -p {1}.par ">" {1}.result ::: ${li}
cat *result > result.txt
cat result.txt | grep result: | sort -nk 7 > summ.txt
mkdir p1 p2 tar
for i in ${p1s};    do cat summ.txt | awk -v tmp=${i} '{if($2==tmp)print $0}' > ./p1/${i}.result  ; done
for i in ${p2s};    do cat summ.txt | awk -v tmp=${i} '{if($3==tmp)print $0}' > ./p2/${i}.result  ; done
for i in ${target}; do cat summ.txt | awk -v tmp=${i} '{if($4==tmp)print $0}' > ./tar/${i}.result ; done
zipname=$(basename $(pwd)) ; rm spop*
cd p1 ; python ../merge_f3_result.v1.0.py ; mv result.xlsx p1.xlsx  ; cd ../
cd p2 ; python ../merge_f3_result.v1.0.py ; mv result.xlsx p2.xlsx  ; cd ../
cd tar; python ../merge_f3_result.v1.0.py ; mv result.xlsx tar.xlsx ; cd ../
zip -r ${zipname}.zip result.txt summ.result p1 p2 tar merge_f3_result.v1.0.py p1s p2s target admixturef3_v1.1.sh
