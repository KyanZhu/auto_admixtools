#!/bin/sh
# dates.sh
# 2022.10.05
# zky


p1s="DevilsCave_N.SG ARpost9K Boisman_MN Russia_Shamanka_Eneolithic.SG Mongolia_N_North Mongolia_N_East"
p2s="Upper_YR_IA YR_LBIA"
targets="Xianbei_Wudi"
geno="2.2M_mini.geno"
snp="2.2M_mini.snp"
ind="2.2M_mini.ind"
thread=5

# generate admix list
for p1 in ${p1s};do
    for p2 in ${p2s};do
        for target in ${targets};do
            for i in "dates.par";do
                echo "genotypename:   ${geno}"
                echo "snpname:        ${snp}"
                echo "indivname:      ${ind}"
                echo "admixlist:      ${p1}_${p2}_${target}.list"
                echo "binsize:        0.001"
                echo "maxdis:         1.0"
                echo "seed:           12"
                echo "jackknife:      YES"
                echo "qbin:           10"
                echo "runfit:         YES"
                echo "afffit:         YES"
                echo "lovalfit:       0.45"
                echo "checkmap:       NO"
                echo "# chithresh:    0.0"
                echo "# mincount:     1"
                echo "# zdipcorrmode: YES"
            done > ${p1}_${p2}_${target}.par
            echo "${p1} ${p2} ${target} ${p1}_${p2}_${target}" > ${p1}_${p2}_${target}.list
            echo "dates -p ${p1}_${p2}_${target}.par"
        done
    done
done > dates.parl

# dates
cat dates.parl | parallel -j ${thread}

# post-processing
alias rmsp='sed "s/^\s*//g" | sed "s/[[:blank:]]\+/\t/g"'
echo "target source1 source2 mean: mean std error std_error Z: Z" > tmp
for p1 in ${p1s};do
    for p2 in ${p2s};do
        for target in ${targets};do
            ls ${p1}_${p2}_${target}/${target}.jout 1>/dev/null 2>&1
            if [ $? == 0 ];then
                echo -n "${target} ${p1} ${p2} "
                cat ${p1}_${p2}_${target}/${target}.jout | grep mean:
            fi
        done
    done
done >> tmp
cat tmp | rmsp | cut -f 1,2,3,5,8,10 > dates.result ; rm tmp

