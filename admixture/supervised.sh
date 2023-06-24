#!/bin/sh
# coding:utf-8
# @Time : 2023/03/08 16:30
# @Version: 2.7
# @File : admixture.sh
# @Author : KyanZhu


# SETTINGS
geno_dir=/home/KongyangZhu/beizhou/5.popgen/5.merged_dataset/HO
work_dir=$(pwd)
geno_file=Wudi_Xianbei_HO  # prefix
poplist=poplist.txt
thread=30
bootstrap="-B100"  # "-B100" 或 ""
source="Ami Russia_Afanasievo AR_EN"

mkdir -p ${work_dir} ; cd ${work_dir}
# 0. check files
missing=0
if [ ! -f ${geno_dir}/${geno_file}.geno ];then echo "!!! Missing geno file !!! " ; missing=1 ; fi
if [ ! -f ${poplist} ];then echo "!!! Missing poplist !!! " ; missing=1 ; fi    
if [ ! -f remove_excess.py ];then echo "!!! Missing remove_excess.py !!! " ; missing=1 ; fi
if [ ${missing} -eq 1 ];then exit; fi

# 0. check extract.poplist
echo -e "=== checking popluations ! ==="
lack_pops=""
cat ${poplist} | egrep -v "#|=" | sort -u > extract.poplist
cat ${geno_dir}/${geno_file}.ind | awk '{print $3}' | sort -u > ind.tmp
pops=$(cat extract.poplist)
for pop in ${pops};do
    cat ind.tmp | grep -x ${pop} >/dev/null 2>&1
    if [ ! $? -eq 0 ];then lack_pops="${lack_pops} [${pop}]" ; flag="FALSE"; fi
done && echo -e "=== check poplist done ! ===\n\n" ; rm ind.tmp
if [[ ${flag} == "FALSE" ]];then echo ${lack_pops} not in dataset; exit; fi

# 1. extract poplist
for i in "extract.par";do
    echo "genotypename: ${geno_dir}/${geno_file}.geno"
    echo "snpname: ${geno_dir}/${geno_file}.snp"
    echo "indivname: ${geno_dir}/${geno_file}.ind"
    echo "outputformat: PACKEDANCESTRYMAP"
    echo "genotypeoutname: tmp.geno"
    echo "snpoutname: tmp.snp"
    echo "indivoutname: tmp.ind"
    echo "poplistname: extract.poplist"
    echo "hashcheck: NO"
done > extract.par ; convertf -p extract.par ; echo ""

# 2. remove individual larger than MAX
MAX=15
while read a;do grep -w ${a} tmp.ind | wc -l | awk -v pop=${a} -v max=${MAX} '{if($1 > max)print pop" "$1-max}'; done < extract.poplist > remove.counts
python remove_excess.py > tmp.edit.ind
for i in "extract.par";do
    echo "genotypename: tmp.geno"
    echo "snpname: tmp.snp"
    echo "indivname: tmp.edit.ind"
    echo "outputformat: PACKEDANCESTRYMAP"
    echo "genotypeoutname: extract.geno"
    echo "snpoutname: extract.snp"
    echo "indivoutname: extract.ind"
    echo "poplistname: extract.poplist"
done > extract.par ; convertf -p extract.par ; echo "" ; rm tmp.*

# 3. convert to bed,bim,fam
for i in "eig2bed.par";do
    echo "genotypename: extract.geno"
    echo "snpname: extract.snp"
    echo "indivname: extract.ind"
    echo "outputformat: PACKEDPED"
    echo "genotypeoutname: extract.bed"
    echo "snpoutname: extract.bim"
    echo "indivoutname: extract.fam"
done > eig2bed.par ; convertf -p eig2bed.par ; echo ""  # extract.ind/genp/snp -> extract.bed/bim/fam

# 4. generate bed,bim,fam
plink --bfile extract --indep-pairwise 200 25 0.4 --out plink --allow-no-sex
plink --bfile extract --extract plink.prune.in  --make-bed --out prune  --allow-no-sex
cat extract.ind | awk '{print $3,$1,$2}' > prune.fam  # change prune.fam file to admixture format

# 5. if source in prune.fam $1, then print $1, else print "-"
cat prune.fam | awk -v source="${source}" '{if(source ~ $1)print $1;else print "-"}' > prune.pop

# 6. Admixture
bed_file=prune.bed
K=$(echo ${source} | awk '{print NF}')  # number of source
admixture ${bed_file} ${K} --supervised -s time ${bootstrap} -j${thread} --cv | tee result.out
# 7. grep result
cat result.out | grep "CV error" > CV_error.txt

# 8. plot
cat ./fancy/fancyAdmixture_plot.R.template | sed "s/replaceversion/2/g" | sed "s/replacest/${K}/g" | sed "s/replaceen/${K}/g" | sed "s/replaceprefix/${K}/g" > ${K}.R ; Rscript ${K}.R

prefix=$(basename ${work_dir})
zip -r ${prefix}.zip ${K}.pdf *.{py,sh,txt} result.out CV_error.txt