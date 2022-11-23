#!/bin/sh


# coding:utf-8
# @Time : 2022/9/28 16:30
# @Version: 2.6
# @File : admixture.2.6.sh
# @Author : zky


# SETTINGS
geno_dir=/home/KongyangZhu/beizhou/5.popgen/5.merged_dataset/HO
geno_file=Wudi_Xianbei_HO  # prefix
workdir=/home/KongyangZhu/beizhou/5.popgen/7.admixture
extract_poplist=poplist.txt
fancy=/home/KongyangZhu/sh/fancy_admixture
remove_excess=/home/KongyangZhu/sh/admixture/remove_excess.py
thread=5
K_st=1
K_en=10
bootstrap="-B100"  # 不需要bootstrap放空""

cd ${workdir}

# 1. extract poplist
cat ${extract_poplist} | grep -v "=" > extract.poplist
for i in "extract.par";do
    echo "genotypename: ${geno_dir}/${geno_file}.geno"
    echo "snpname: ${geno_dir}/${geno_file}.snp"
    echo "indivname: ${geno_dir}/${geno_file}.ind"
    echo "outputformat: PACKEDANCESTRYMAP"
    echo "genotypeoutname: tmp.geno"
    echo "snpoutname: tmp.snp"
    echo "indivoutname: tmp.ind"
    echo "poplistname: extract.poplist"
done > extract.par ; convertf -p extract.par ; echo ""

# 2. remove individual larger than MAX
MAX=15
cp ${remove_excess} ./
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

# 5. Admixture
bed_file=prune.bed
parallel -j ${thread} --verbose admixture -s time ${bootstrap} -j10 --cv ${bed_file} {} "|" tee -a result.out ::: $(seq ${K_st} ${K_en})
# grep result
cat result.out | grep "CV error" | sort -k 4 -n > CV_error.txt
min=$(cat CV_error.txt  | sort -k 4 -n | head -n 1 | awk '{print $3}' | egrep -o '[0-9]{1,2}')

# plot
for version in 1 2;do
    cat ${fancy}/fancyAdmixture_plot.R.template | sed "s/replaceversion/${version}/g" | sed "s/replacest/2/g" | sed "s/replaceen/${K_en}/g" | sed "s/replaceprefix/full/g" > full.R ; Rscript full.R
    for i in $(seq ${K_st} ${K_en});do
        cat ${fancy}/fancyAdmixture_plot.R.template | sed "s/replaceversion/${version}/g" | sed "s/replacest/${i}/g" | sed "s/replaceen/${i}/g" | sed "s/replaceprefix/${i}/g" > ${i}.R ; Rscript ${i}.R
    done
    mkdir pdf${version} ; mv *.pdf pdf${version}
done

zip -r admixture.zip pdf1 pdf2 *sh *py CV_error.txt result.out poplist.txt
notify ADMIXTURE