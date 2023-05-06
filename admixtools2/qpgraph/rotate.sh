Kos_template="Kostenki14 Russia_Kostenki14.SG"
Hoa_tempalte="Laos_Hoabinhian.SG Malaysia_Hoabinhian.WGC"
Qih_template="Qihe Qihe3"
template=template.dot

count=1
for i in ${Kos_template};do
for j in ${Hoa_tempalte};do
for k in ${Qih_template};do
    cat ${template} | \
        sed "s/Kostemplate/${i}/g" | \
        sed "s/Qihtemplate/${k}/g" | \
        sed "s/Hoabtemplate/${j}/g" > ${count}.graph
    count=$((count+1))
done
done
done