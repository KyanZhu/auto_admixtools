for i in $(ls ./result/*.result);do
    echo "${i} " | sed 's/.\/result\///g' | sed 's/.result//g' | sed 's/-/ /g' | awk '{printf "%s %s %s %s ",$1,$2,$3,$4}'
    cat ${i} | grep "best coefficient" | awk '{printf "%s %s %s %s %s ",$1,$2,$3,$4,$5}'
    cat ${i} | grep "std. errors" | awk '{printf "%s %s %s %s %s ",$1,$2,$3,$4,$5}'
    cat ${i} | grep "summ:" | awk '{printf "%s %s ","tail:",$4}'; cat ${i} | grep "totmean" | awk '{printf "%s %s %s %s %s \n",$1,$2,$3,$4,$5}'
done > 4.all_result.txt