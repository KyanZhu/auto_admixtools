#!/bin/sh
# coding:utf-8
# @Time : 2022/10/08 01:09
# @Version: v2.6
# @File : smartpca.v2.6.sh
# @Author : zky


geno_dir=/home/KongyangZhu/beizhou/5.popgen/5.merged_dataset/HO
geno_file=Wudi_Xianbei_HO  # prefix
workdir=/home/KongyangZhu/beizhou/5.popgen/6.smartpca/smartpca3
poplist=/home/KongyangZhu/beizhou/5.popgen/6.smartpca/smartpca3/poplist.txt
pcaRploter=/home/KongyangZhu/sh/smartpca/pcaRploter.v4.4.py
bc=/home/KongyangZhu/sh/smartpca/bc.py

alias rmsp='sed "s/^\s*//g" | sed "s/[[:blank:]]\+/\t/g"'
cd ${workdir}

if [ ! -f ${geno_dir}/${geno_file}.geno ] || [ ! -f ${pcaRploter} ] || [ ! -f ${poplist} ];then echo "!!! Missing files !!! " ; exit ; fi

# check extract.poplist
echo -e "=== checking popluations ! ==="
lack_pops=""
cat ${poplist} | grep -v "=" > extract.poplist
cat ${geno_dir}/${geno_file}.ind | awk '{print $3}' | sort -u > ind.tmp
pops=$(cat extract.poplist)
for pop in ${pops};do
    cat ind.tmp | grep -x ${pop} >/dev/null 2>&1
    if [ ! $? -eq 0 ];then lack_pops="${lack_pops} [${pop}]" ; flag="FALSE"; fi
done && echo -e "=== check poplist done ! ===\n\n" ; rm ind.tmp
if [[ ${flag} == "FALSE" ]];then echo ${lack_pops} not in dataset; exit; fi

# extract poplist from HO
echo "=== running convertf ! ==="
for i in "extract.par";do
    echo "genotypename: ${geno_dir}/${geno_file}.geno"
    echo "snpname: ${geno_dir}/${geno_file}.snp"
    echo "indivname: ${geno_dir}/${geno_file}.ind"
    echo "genotypeoutname: extract.geno"
    echo "snpoutname: extract.snp"
    echo "indivoutname: extract.ind"
    echo "poplistname: extract.poplist"
    echo "hashcheck: NO"
    echo "strandcheck: NO"
    echo "allowdups: YES"
done > extract.par && convertf -p extract.par

# smartpca preprocessing
row=$(cat ${poplist} -n | grep "====Ancient" | head -n 1 | rmsp | cut -f 1)
row=$[ ${row} - 1 ]
cat ${poplist} | head -n ${row} | grep -v "=" > modern.poplist

# smartpca.par
for i in "smartpca.par";do
    echo "genotypename: extract.geno"
    echo "snpname:      extract.snp"
    echo "indivname:    extract.ind"
    echo "evecoutname:  smartpca.evec"
    echo "evaloutname:  smartpca.eval"
    echo "poplistname:  modern.poplist"
    echo "lsqproject: YES"
    echo "numoutevec: 5"
    echo "altnormstyle: NO"
    echo "numoutlieriter : 0"
    echo "numthreads: 20"
done > smartpca.par

# smartpca
smartpca -p smartpca.par > smartpca.log 2>&1

# Calculate PCs
lines=$(wc -l smartpca.eval | rmsp | cut -f 1)
lines=$(expr ${lines} - 1 )
pc1=$(head -n 1 smartpca.eval)
pc2=$(tail -n+2 smartpca.eval | head -n 1)
echo -n "PC1: " >  PCs.txt ; echo "${pc1}/${lines}*100" | xargs -n 1 python ${bc} >> PCs.txt ; echo "%" >> PCs.txt
echo -n "PC2: " >> PCs.txt ; echo "${pc2}/${lines}*100" | xargs -n 1 python ${bc} >> PCs.txt ; echo "%" >> PCs.txt

# Post-Processing
tail -n+2 smartpca.evec | awk '{print $7,$1,$2,$3}' > plot.txt
cp ${pcaRploter} ./
python pcaRploter.v4.4.py
Rscript smartpca.r
zip smartpca.zip pcaRploter.v4.4.py extract.poplist modern.poplist plot.txt smartpca.r poplist.txt smartpca.eval smartpca.evec smartpca.pdf legend.pdf smartpca.sh smartpca.log PCs.txt