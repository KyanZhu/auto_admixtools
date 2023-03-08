#!/bin/sh
# @Time : 2022/10/08 12:49
# @Author : KyanZhu
# @Version：1.4
# @File : multi_f4

# SETTINGS
thread=10
geno=/home/KongyangZhu/beizhou/5.popgen/5.merged_dataset/1240k/Wudi_Xianbei_1240k.geno
snp=/home/KongyangZhu/beizhou/5.popgen/5.merged_dataset/1240k/Wudi_Xianbei_1240k.snp
ind=/home/KongyangZhu/beizhou/5.popgen/5.merged_dataset/1240k/Wudi_Xianbei_1240k.ind
f4_tools=/home/KongyangZhu/sh/f4_tools/v1.4
p1s="Mbuti.DG"  # 读文件或直接写列表
p2s=$(cat p2s)
p3s=$(cat p3s)
p4s="Xianbei_Wudi"

# optional
parfile=0.pars  # 默认不需要修改
popfile=0.pop  # 生成的f4组合存放位置, 默认不需要修改

# f4 combinations
parallel echo "{1} {2} {3} {4}" ::: ${p1s} ::: ${p2s} ::: ${p3s} ::: ${p4s} > ${popfile}

# Pre-Processing : softlink, tools
alias rmsp='sed "s/^\s*//g" | sed "s/[[:blank:]]\+/\t/g"'
if [ ! -f f4.geno ] || [ ! -f f4.snp ] || [ ! -f f4.ind ];then ln -s ${geno} f4.geno ; ln -s ${snp} f4.snp ; ln -s ${ind} f4.ind ; fi
cp ${f4_tools}/{0.pars,4.merge_f4_result.v2.py,8.adjust_excel.py,plot.r} ./

# Check if pops are exist
cat f4.ind | rmsp | cut -f 3 | sort -u > checklist.tmp
li="${p1s} ${p2s} ${p3s} ${p4s}"
for i in ${li};do cat checklist.tmp | grep "^${i}$" > /dev/null ; if [ ! $? -eq 0 ] ;then echo -e "Pop [ ${i} ] not exists\nEnd Processing!" ; exit 1 ; fi ; done
rm checklist.tmp ; echo -e "Check poplist Done\nStart f4-statistics!"

# split tasks by $thread
a=$(wc -l ${popfile} | cut -d ' ' -f 1)
b=$(expr $a / ${thread} )
line=$(expr $b + 1 )
split -l ${line} ${popfile} spop

# merge all results
li=$(ls spop*) ; rm -f run_script.txt ; touch run_script.txt
for i in ${li};do echo "cat ${parfile} | sed \"s/replacepop/${i}/g\" > ${i}.par ; qpDstat -p ${i}.par > ${i}.result" >> run_script.txt ; done
cat run_script.txt | parallel --verbose -j ${thread}
cat spop*result > result.txt ; cat result.txt | grep result: | sort -nk 8 > summ.txt ; rm spop*

# Post-Processing generate xlsx
function post_processing() {
    rm -rf plot.txt ； touch plot.txt
    cat ${ind} | rmsp | cut -f 3 > pop.tmp
    for i in $(ls *.result);do
        # fst
        cat ${i} | sort -nk6 | rmsp | cut -f 6 > ${i}.fstsort.tmp
        fstmin=$(head -n 1 ${i}.fstsort.tmp)
        fstmax=$(tail -n 1 ${i}.fstsort.tmp)
        rm ${i}.fstsort.tmp
        # popnums
        name=$(basename ${i} .result)
        popn=$(cat pop.tmp | grep -x ${name} | wc -l)
        # z-score
        min=$(cat ${i} | rmsp | cut -f 8 | head -n 1)
        max=$(cat ${i} | rmsp | cut -f 8 | tail -n 1)
        sum=$(echo "${min#-} + ${max#-}" | bc)
        echo -e "${name} ( n=${popn} )\t${min}\t${max}\t${fstmin}\t${fstmax}\t${sum}"
        # plot.txt
        cat ${i} | awk -v name=${name} -v popn=${popn} -v ord=${sum} '{print name" ( n="popn" )\t"$6"\t"$8"\t"ord'} >> plot.tmp
    done | sort -nk9 | cat -n > summ.table ; rm pop.tmp
    while read a b c;do mv ${b}.result ${a}.result ; done < summ.table
    cat plot.tmp | sort -nk7 > plot.txt ; rm plot.tmp
}

mkdir -p p2 p3 p4
for i in ${p2s};do cat summ.txt | awk -v tmp=${i} '{if($3==tmp)print $0}' > ./p2/${i}.result ; done
for i in ${p3s};do cat summ.txt | awk -v tmp=${i} '{if($4==tmp)print $0}' > ./p3/${i}.result ; done
for i in ${p4s};do cat summ.txt | awk -v tmp=${i} '{if($5==tmp)print $0}' > ./p4/${i}.result ; done
cd p2 ; post_processing ; python ../4.merge_f4_result.v2.py ; python ../8.adjust_excel.py --head ; mv result.xlsx p2.xlsx ; cp ../plot.r ./ ; Rscript plot.r ; mv plot.pdf p2.pdf ; cd ../
cd p3 ; post_processing ; python ../4.merge_f4_result.v2.py ; python ../8.adjust_excel.py --head ; mv result.xlsx p3.xlsx ; cp ../plot.r ./ ; Rscript plot.r ; mv plot.pdf p3.pdf ; cd ../
cd p4 ; post_processing ; python ../4.merge_f4_result.v2.py ; python ../8.adjust_excel.py --head ; mv result.xlsx p4.xlsx ; cp ../plot.r ./ ; Rscript plot.r ; mv plot.pdf p4.pdf ; cd ../

# zipfile
zipname=$(basename $(pwd)) ; rm spop*
zip -r ${zipname}.zip 0.pars 0.pop result.txt summ.txt 3.grep_pop.sh 4.merge_f4_result.v2.py 8.adjust_excel.py *.result result.xlsx p2 p3 p4
notify multi f4-statistics