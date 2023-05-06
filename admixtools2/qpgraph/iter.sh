addpop=Gaoshancheng_LN
template=template  # graph template

cat ${template} | awk '{print $3}' | sort -u > var3
cat ${template} | awk '{print $3}' | sort | uniq -c | awk '{if ($1==2) print $2}' > rmind
li=$(cat var3 | grep -v -f rmind) ; rm var3 rmind  # 对所有节点进行遍历
# li="Laos_Hoabinhian.SG Longlin Upper_YR_LN"  # 自定义增加的节点
count=1
while read i j k;do
    while read x y z;do
        if [[ "$k" != "$z" && "$k" < "$z" && "${li[*]}" =~ "$k" && "${li[*]}" =~ "$z" ]]; then
            cat ${template} | \
            sed -E "s/$k$/add3\nadd3 -- add4\nadd3 -- $k/g" | \
            sed -E "s/$z$/add1\nadd1 -- add2\nadd1 -- $z/g" \
            > ${count}.graph
            echo -e "add2 -- pp\nadd4 -- pp\npp -- ${addpop}" >> ${count}.graph
            count=$((count+1))
        fi
    done < ${template}
done < ${template}
Rscript iter.R