#!/bin/sh
# coding:utf-8
# @Time : 2023/03/08 01:09
# @Version: v2.7
# @File : smartpca.sh
# @Author : zky


geno_dir=/home/KongyangZhu/data/12.shallow/2023.03.02/pops/dataset/HO
geno_file=DSQM_HO  # prefix
workdir=./
poplist=poplist.txt  # default

alias rmsp='sed "s/^\s*//g" | sed "s/[[:blank:]]\+/\t/g"'
cd ${workdir}

# check files
missing=0
if [ ! -f ${geno_dir}/${geno_file}.geno ];then echo "!!! Missing geno file !!! " ; missing=1 ; fi
if [ ! -f ${poplist} ];then echo "!!! Missing poplist !!! " ; missing=1 ; fi    
if [ ! -f pcaRploter.py ];then echo "!!! Missing pcaRploter.py !!! " ; missing=1 ; fi
if [ ! -f bc.py ];then echo "!!! Missing bc.py !!! " ; missing=1 ; fi
if [ ${missing} -eq 1 ];then exit; fi

# check extract.poplist
echo -e "=== checking popluations ! ==="
lack_pops=""
cat ${poplist} | egrep -v "#|=" > extract.poplist
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
echo -n "PC1 (" >  PCs.txt ; echo "${pc1}/${lines}*100" | xargs -n 1 python bc.py >> PCs.txt ; echo "%)" >> PCs.txt
echo -n "PC2 (" >> PCs.txt ; echo "${pc2}/${lines}*100" | xargs -n 1 python bc.py >> PCs.txt ; echo "%)" >> PCs.txt

# Post-Processing
prefix=$(basename ${workdir})
tail -n+2 smartpca.evec | awk '{print $7,$1,$2,$3}' > plot.txt
python pcaRploter.py; mv smartpca.r ${prefix}.r
Rscript ${prefix}.r
zip ${prefix}.zip *.{py,pdf,r,sh,txt} smartpca.* *poplist*