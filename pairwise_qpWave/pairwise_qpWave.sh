#!/bin/bash

# coding:utf-8
# @Time : 2022/1/15 17:21
# @Author : cewinhot 
# @Version : v1.1
# @File : pairwise_qpWave.v1.sh


work_dir=/home/KongyangZhu/dulan/28.cluster/cluster7
geno_dir=/home/KongyangZhu/dulan/28.cluster
geno_file=1240k  # prefix
poplist=qpWave.poplist
outgroup=outgroup.poplist  # Mbuti.DG in first line
pairwise_dir=/home/KongyangZhu/sh/pairwise_qpWave
pairwise_root="Mbuti.DG"
thread=10
inbreed=" NO"
allsnps=" YES"

# unique
alias rmsp='sed "s/^\s*//g" | sed "s/[[:blank:]]\+/\t/g"'
rm -r result extract.{geno,snp,ind,poplist} run_script.txt
cd ${work_dir}; mkdir -p result; cp ${outgroup} ./result/outgroup
sed -i 's/\r//g' ${outgroup}
sed -i 's/\r//g' ${poplist}
cat ${poplist} | sort -u | grep -v "^$" > tmp ; cat tmp > ${poplist}
echo ${pairwise_root} > tmp
cat ${outgroup} | sort -u | grep -v "^$" | grep -v ${pairwise_root} >> tmp ; cat tmp > ${outgroup}
cat ${poplist} ${outgroup} > extract.poplist ; rm tmp

# extract population
for i in "extract.par";do
    echo "genotypename: ${geno_dir}/${geno_file}.geno"
    echo "snpname:      ${geno_dir}/${geno_file}.snp"
    echo "indivname:    ${geno_dir}/${geno_file}.ind"
    echo "genooutfilename: extract.geno"
    echo "snpoutfilename:  extract.snp"
    echo "indoutfilename:  extract.ind"
    echo "poplistname:  extract.poplist"
    echo "hashcheck:    NO"
    echo "strandcheck:  NO"
    echo "allowdups:    YES"
done > extract.par ; convertf -p extract.par

# pairwise qpWave
cp ${pairwise_dir}/gen_scripts.py ./
cp ${pairwise_dir}/pairwise_qpWave.v1.r ./
cp ${pairwise_dir}/parqpWave.template ./result
echo "inbreed: ${inbreed}" >> parqpWave.template
echo "allsnps: ${allsnps}" >> parqpWave.template
python3 gen_scripts.py ${poplist} > run_script.txt
cat run_script.txt | parallel --verbose -j ${thread}


# post-processing
alias rmsp='sed "s/^\s*//g" | sed "s/[[:blank:]]\+/\t/g"'
cd result ; li=$(ls *result) ; rm -f final_result.txt ; touch final_result.txt
for i in ${li};do
    echo ${i} | sed 's/.result//g' | sed 's/-/\t/g' >> final_result.txt
    cat ${i} | grep "f4rank: 1 dof:" | rmsp | cut -f 14 >> final_result.txt  # taildiff
    echo "" >> final_result.txt
done
mv final_result.txt ../ ; cd ../
zip_name=$(basename ${work_dir})
zip ${zip_name}.zip qpWave.poplist outgroup.poplist extract.poplist final_result.txt pairwise_qpWave.v1.r gen_scripts.py run_script.txt pairwise_qpWave.v1.sh
notify pairwise qpwave
