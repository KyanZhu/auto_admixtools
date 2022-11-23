# Getting the path of your current open file
library(rstudioapi)
current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))

# while read a b;do a=`echo $a | tr -d "\r"`;b=`echo $b | tr -d "\r"`;sed -i "s/${a}/${b}"_"${a}/g" qpWave_homogeny_final.txt;done < qpWave_pop_class.txt
fileprefix <- "final_result"
fn <- readLines(paste(fileprefix,"txt",sep="."))  # 一行一行读，fn[1]就是第一行
b=c()
for(linenum in seq(1,length(fn),by=3)){
  b=c(b,unlist(strsplit(fn[linenum],"\t")))}
# strsplit将字串按照第二个参数分割存储在列表中 unlist(strsplit(待分割的字串，分隔符))
# 需要使用unlist将列表转化为向量
# Pop <- c("Tibetan_Xinlong", "Yi", "Naxi", "Upper_YR_IA", "Miaozigou_MN", "Bianbian", "Upper_YR_LN", "lateXiongnu", "earlyXiongnu_rest", "Mongolia_Medieval", "Afanasievo_Mongolia", "Mongolia_Chalcolithic_1_Afanasievo", "Qiang_Danba", "YR_MN", "Kazakhstan_Nomad_Hun_Sarmatian", "Mongolia_IA_Xianbei", "Kazakhstan_Turk", "earlyMed_Uigur", "Turkmen", "AR_Xianbei_IA", "AR_EN", "lateMed_Khitan", "Chokhopani", "Nepal_Samdzong_1500BP", "Kazakhstan_Turkic_Karakaba", "Uyghur", "Qiang_Daofu", "Tibetan_Yunnan", "Shimao_LN", "Tibetan_Gannan", "Tibetan_Xunhua", "Tibetan_Yajiang", "YR_LBIA", "YR_LN", "Daur", "Hezhen", "earlyXiongnu_SKT007", "Gurung", "Xiaojingshan", "Ulchi", "Tajikistan_C_Sarazm", "Tajikistan_Ksirov_Kushan", "earlyMed_Turk", "Kazakh", "Mongolia_N_East", "Mongolia_N_North", "Japanese", "Korean", "Buryat", "Mongolia_EIA_5", "Tibetan_Gangcha", "Mongolia_Mongol", "Tajik", "Oroqen", "earlyXiongnu_west", "lateMed_Mongol", "lateXiongnu_han", "Turkish", "Mongola", "Newar", "Tamang", "China_Lahu", "Tujia", "Kazakhstan_Wusun_2", "lateXiongnu_sarmatian", "Dulan_o", "Kyrgyzstan_Turk", "Karakalpak", "Kazakhstan_Kipchak2", "Kazakhstan_Medieval_Nomad", "Rai", "Tibetan_Chamdo", "Tibetan_Shannan", "Tibetan_Shigatse", "Tibetan_Lhasa", "Tibetan_Nagqu", "Sherpa", "Dulan", "Nepal_Mebrak_2125BP", "Kyang", "Rhirhi", "Lubrak", "Nepal_Chokhopani_2700BP", "Samdzong", "Mebrak", "Suila")
Pop <- unique(b)
resultmatrix <- matrix(NA,nrow=length(Pop),ncol=length(Pop))
rownames(resultmatrix) <- Pop
colnames(resultmatrix) <- Pop
for(i in 1:length(fn)){
  if(i%%3==1){
    Pop1<-strsplit(fn[i],"\t", fixed=TRUE)[[1]][1]  
    Pop2<-strsplit(fn[i],"\t", fixed=TRUE)[[1]][2]}
  if(i%%3==2){
    options(scipen=-300)  # 设置科学计数法，因为我们的结果里面含有的是e^-n,所以设置为负值，如果是e^n,就需要设置为正值
    # 不要随便设置 最好重启R 在跑其他脚本的时候
    ttail <- strsplit(fn[i],"\t", fixed=TRUE)[[1]][1]
    print(ttail)
    Pop1_pos=match(Pop1,Pop)  # 某字符串在某向量中的位置
    Pop2_pos=match(Pop2,Pop)
    resultmatrix[Pop1_pos,Pop2_pos] <- as.numeric(ttail)
    resultmatrix[Pop2_pos,Pop1_pos] <- as.numeric(ttail)}
}
write.table(resultmatrix,file=paste(fileprefix,"matrix.txt",sep="_"),row.names =TRUE, col.names =TRUE, quote =FALSE)

library(pheatmap)
pdf(file=paste(fileprefix,"pdf",sep="."),width=70,height=70)
#png(file=paste(fileprefix,"png",sep="."),width=1200,height=1300)

# 如果你想在图里展示NA
significance=matrix(ifelse(resultmatrix>0.05, "++",ifelse(resultmatrix>0.01 & resultmatrix<0.05,"+"," ")),nrow(resultmatrix))
# 如果你不想在图里展示NA
# significance=matrix(ifelse(is.na(resultmatrix),"",ifelse(resultmatrix>0.05, "+","p<0.05")),nrow(resultmatrix))


# 生成annotation文件 格式：popnames\tclass
# option1：因为我藏族内部还可以按地理排 所以我第一次要手动搞 之后可以用现成的
# 用法：
# anno=read.table("qpWave_pop_class.txt",header=FALSE,row.names= 1,sep="\t")
#write.table(Pop,file="qpWave_pop_class.txt",row.names=FALSE,col.names=FALSE,quote=FALSE) 
# 在qpWave_pop_class.txt里面增添class 以\t分割
# quote:如果是FALSE则字符型变量和因子不写在双引号""中

# option2：PCA的语系class分类
# 用法：
#c=file.create("qpWave_pop_class.txt")
# 在qpWave_pop_class.txt里面增添class 以\t分割
# annotation_col =anno,annotation_row =anno,
pheatmap(resultmatrix,  border_color = "black",
         cluster_row = FALSE, cluster_col = FALSE, cutree_rows=8, cutree_cols=8,
         fontsize_row = 30, fontsize_col = 30,fontsize_number=20,color=rev(colorRampPalette(c("royalblue","white"))(10)),display_numbers=significance,main="qpWave rank=0",cellwidth = 50, cellheight = 50)
dev.off()

