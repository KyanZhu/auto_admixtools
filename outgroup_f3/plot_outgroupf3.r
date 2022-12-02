#需要两个输入文件
library(pheatmap)
INFILE='plot.txt' #outgroup_f3结果文件
PREFIX=as.character(unlist(strsplit(INFILE, split = ".txt")))
X<-as.matrix(read.table(INFILE))
COL_POPX=1
COL_POPY=2
VALUE_COL=4
Z_col=6
cut_num=18
POPS <- unique(sort(c((X[,COL_POPX:COL_POPY]))))
NPOPS <- length(POPS)
print(NPOPS)
Z <- array(dim=c(NPOPS,NPOPS))
print(dim(Z))
Z[1:NPOPS,1:NPOPS] <- NA
colnames(Z)<-POPS
rownames(Z)<-POPS
NPAIRS <- dim(X)[1]
for (i in 1:NPAIRS) {
  Z[as.character(X[i,COL_POPX]),as.character(X[i,COL_POPY])] <- as.numeric(X[i,VALUE_COL])
  Z[as.character(X[i,COL_POPY]),as.character(X[i,COL_POPX])] <- as.numeric(X[i,VALUE_COL])
  Z[as.character(X[i,COL_POPX]),as.character(X[i,COL_POPX])] <- NA
  # Z[as.character(X[i,COL_POPY]),as.character(X[i,COL_POPY])] <- NA
}
Z<-apply(Z,c(1,2),as.numeric)

#加分组(按语系+按target）
popGroups_modern=c()
popGroups_modern <- read.table('pop.txt',col.names=c("Pop", "color", "PopGroup","colcew"),sep = '\t') #1记录群体；2分组颜色；3所属语系名；4target群体（红色），其他黑色
#pheatmap
OUTPUT3=paste(PREFIX,"_pheatmap.pdf",sep="")
pdf(file=OUTPUT3,width=22,height=22)
aa=data.frame(POPS)
colnames(aa)="Pop"
bb=merge(data.frame(aa),popGroups_modern,by="Pop")
cc=subset(bb,select=c(PopGroup))
rownames(cc)=bb$Pop
color=c("#42a5f5","#4dd0e1","#fff176","#ffd54f","#ffb74d","#ff8a65")
pheatmap(Z, anotation_col=cc, annotation_row =cc,
         # color=color, breaks = c(0.25,0.27,0.29,0.31,0.33,0.35,0.37),legend_breaks=c(0.25,0.27,0.29,0.31,0.33,0.35,0.37),
         main="outgroup-f3(X,Y;Mbuti)",cutree_rows=cut_num,cutree_cols=cut_num,cellwidth = 8, cellheight = 8)  # distances 0 to 3 are red, 3 to 9 black
dev.off()
