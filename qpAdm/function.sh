dst=ccwang@hpc.xmu.edu.cn:/data/gpfs01/ccwang/kongyangzhu/beizhou/qpAdm
genofile=/data/gpfs01/ccwang/kongyangzhu/beizhou/qpAdm/dataset/2.2M/2.2M_mini*  # PREFIX of geno/snp/ind
#  use alias python='python3' if your default python is python 2.0

function scpfile() {
    if [ ! -f *_pops.xlsx ];then
        python tools/0.rotate_pops.py
    else
        python tools/0.rotate_pops.py
        echo "Please check destination : ${dst}"
        echo "Please check genofile : ${genofile}"
        echo "Press Eneter to scp files:" && read
        file_name=$(basename $(pwd)) ; zip -r ${file_name}.zip *
        mkdir -p ${file_name} ; scp -r $(pwd)/${file_name} ${dst} ; rmdir ${file_name}
        scp -r ${file_name}.zip tools/function.sh ${dst}/${file_name}
    fi
}

function submit() {
    file_name=$(basename $(pwd)) ; unzip ${file_name}.zip
    chmod 755 *
    ls ${genofile} | xargs -n 1 ln -s 
    ls *ind  | xargs -I% mv % extract.ind
    ls *snp  | xargs -I% mv % extract.snp
    ls *geno | xargs -I% mv % extract.geno
    # 检查geno文件是否存在
    if [ ! -f extract.ind ] || [ ! -f extract.snp ] || [ ! -f extract.geno ];then echo "!!! Missing files !!! " ; return 1 ; fi
    # 检查人群是否存在
    echo -e "=== checking popluations ! ==="
    lack_pops=""
    cat extract.ind | awk '{print $3}' | sort -u > ind.tmp ; pops=$(cat check.poplist)
    for pop in ${pops};do
        cat ind.tmp | grep -x ${pop} >/dev/null 2>&1
        if [ ! $? -eq 0 ];then lack_pops="${lack_pops} [${pop}]" ; flag="FALSE"; fi
    done && echo -e "=== check poplist done ! ===\n\n" ; rm ind.tmp
    if [[ ${flag} == "FALSE" ]];then echo ${lack_pops} not in dataset; exit; fi
    # Submit Tasks
    ls -d src* | parallel -I% "echo \"   submit %\"; cd %; python 1.rotate_prepare.py; sh 2.bsub_qpAdm.sh"
    ti=$(date | awk '{print $4}' | sed "s/:/ /g" | awk '{print $1":"$2}')
    while [ 1 ];do jobs=$(bjobs | grep ${ti} | wc -l); if [ ${jobs} -eq 0 ];then echo "===qpAdm done==="; break; fi; echo "  remain ${jobs} jobs."; sleep 5; done
    result
}

function result() {
    alias rmsp='sed "s/^\s*//g" | sed "s/[[:blank:]]\+/\t/g"'
    file_name=$(basename $(pwd))
    ls -d src* | parallel -I% "echo \"   grep_result %\"; cd %; sh 3.grep_result.sh"
    cat src*/*/*result | grep "coverage" | sort -u | rmsp | cut -f 2,3 | sort -nk2 > tmp.coverage
    li=$(cat tmp.coverage | cut -f 1)
    cat tmp.coverage | cut -f 2 > tmp1
    cat extract.ind | rmsp | cut -f 3 > tmp2
    for i in ${li};do
        num=$(grep -x ${i} tmp2 | wc -l)
        echo "${i} (n=${num})"
    done > tmp3
    paste tmp3 tmp1 > poplist.coverage
    rm -rf src*/*{py,sh,template,parfile} tmp1 tmp2 tmp3 tmp.coverage
    rm -r ${file_name}.zip ; zip -r -q -y ${file_name}.zip *
}

function scpback() {
    file_name=$(basename $(pwd))
    ls -d src* | parallel -I% "echo \"   scpback %\"; scp ${dst}/${file_name}/%/4.all_result.txt %"
    rm -r ${file_name}.zip
    scp ${dst}/${file_name}/poplist.coverage ${dst}/${file_name}/${file_name}.zip ./
    summary
    rm -r src* ; zip -r ${file_name}.zip *
}

function summary() {
    # ls -d src* | parallel -I% "echo \"   result -> excel %\"; cd %; python 5.result2excel.py"
    # 汇总文件
    count=$(ls src* -d | wc -l | cut -f 1)
    cp ./tools/5.result2excel.py ./
    for i in $(seq 1 $count);do
        cat src${i}/4.all_result.txt
    done > 4.all_result.txt
    python 5.result2excel.py ; rm 5.result2excel.py
}

function resubmit() {
    ls -d src* | parallel -I% "echo \"   submit %\"; cd %; python 1.rotate_prepare.py; sh 2.bsub_qpAdm.sh"
    ti=$(date | awk '{print $4}' | sed "s/:/ /g" | awk '{print $1":"$2}')
    while [ 1 ];do jobs=$(bjobs | grep ${ti} | wc -l); if [ ${jobs} -eq 0 ];then echo "===qpAdm done==="; break; fi; echo "  remain ${jobs} jobs."; sleep 5; done
}

alias fun1='scpfile'
alias fun2='submit'
alias fun3='result'
alias fun4='scpback'
alias fun5='summary'
alias refun2='resubmit'
