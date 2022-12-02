#!/bin/bash

# coding:utf-8
# @Time : 2022/12/03 01:50
# @Author : cewinhot 
# @Version : 2.2
# @File : outgroup_f3.sh


geno_dir=/home/KongyangZhu/beizhou/5.popgen/5.merged_dataset/1240k
work_dir=/home/KongyangZhu/beizhou/5.popgen/9.outgroupf3/outgroupf3_1
geno_file=Wudi_Xianbei_1240k  # prefix
poplist=poplist.txt
qp3Pop_sh=/home/KongyangZhu/sh/qp3Pop
# qp3Pop parameters
outgroup=Mbuti.DG
thread=10

cd ${work_dir}

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

# extract
for i in "extract.par";do
    cat ${poplist} | grep -v ${outgroup} | grep -v "=" > extract.poplist
    echo ${outgroup} >> extract.poplist
    echo "genotypename: ${geno_dir}/${geno_file}.geno"
    echo "snpname: ${geno_dir}/${geno_file}.snp"
    echo "indivname: ${geno_dir}/${geno_file}.ind"
    echo "outputformat: PACKEDANCESTRYMAP"
    echo "genotypeoutname: extract.geno"
    echo "snpoutname: extract.snp"
    echo "indivoutname: extract.ind"
    echo "poplistname: extract.poplist"
done > extract.par ; convertf -p extract.par

# qp3pop par
cat ${poplist} | grep -v ${outgroup} | grep -v "=" > tmp
cp ${qp3Pop_sh}/gen3Pop.py ${qp3Pop_sh}/gen3txt.py ${qp3Pop_sh}/plot_outgroupf3.r ./
python gen3Pop.py tmp ${outgroup} > qp3pop
rm tmp gen3Pop.py

# qp3.par
for i in "qp3.par";do
    echo "genotypename:   extract.geno"
    echo "snpname:        extract.snp"
    echo "indivname:      extract.ind"
    echo "popfilename:    qp3pop"
    echo "inbreed: YES"
done > qp3.par

# multi qp3Pop
a=$(wc -l qp3pop | cut -d ' ' -f 1)
b=$(expr ${a} / ${thread} )
line=$(expr ${b} + 1 )
split -l ${line} qp3pop spop
li=$(ls spop*)
for i in ${li};do cat qp3.par | sed "s/qp3pop/${i}/g" > ${i}.par ; done
parallel --verbose qp3Pop -p {1}.par ">" {1}.result ::: ${li}
cat *result > qp3.result
cat qp3.result | grep result: | awk '{print $2,$3,$4,$5,$6,$7,$8}' > plot.txt
rm spop*

python gen3txt.py ${poplist} > pop.txt
Rscript plot_outgroupf3.r

zip qp3result.zip qp3.result plot.txt pop.txt plot_outgroupf3.r *pdf *sh
notify qp3pop