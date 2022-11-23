# export LD_LIBRARY_PATH=/data/gpfs01/ccwang/bin/lib:$LD_LIBRARY_PATH
mkdir -p result; cd parfile
combs=$(ls *par)
for comb in ${combs};do
    name=$(basename ${comb} .par)
    cat ../0.qpAdm_bsub.template | sed "s/replace/${name}/g" > temp
    rand=$(( $RANDOM % 3 ))
    if [ ${rand} -eq 0 ];then process="normal_1week"    ; fi
    if [ ${rand} -eq 1 ];then process="normal_1day"    ; fi
    if [ ${rand} -eq 2 ];then process="normal_1day"    ; fi
    process="normal_1day"
    ls ../result/${name}.result > /dev/null 2>&1  # 存在文件 $?=0
    if [ ! $? -eq 0 ];then bsub -q ${process} < temp ; fi
done && rm temp