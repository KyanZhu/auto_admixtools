#需要两个输入文件
library(pheatmap)
INFILE='plot.txt' #outgroup_f3结果文件
POP_FILE='pop.txt'
PREFIX=as.character(unlist(strsplit(INFILE, split = ".txt")))
X<-as.matrix(read.table(INFILE))
COL_POPX=1 ; COL_POPY=2 ; VALUE_COL=4 ; Z_col=6

# HEATMAP PARAMETERS
heatmap_title = "outgroup-f3(X,Y;Mbuti)"
cut_row=8
cut_col=8
cell_width=10
cell_height=10
fst_min=0.23
fst_max=0.31

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
popGroups_modern <- read.table(POP_FILE,col.names=c("Pop", "color", "PopGroup","colcew"),sep = '\t') #1记录群体；2分组颜色；3所属语系名；4target群体（红色），其他黑色
#pheatmap
OUTPUT3=paste("heatmap.pdf",sep="")
pdf(file=OUTPUT3,width=23,height=23)
aa=data.frame(POPS)
colnames(aa)="Pop"
bb=merge(data.frame(aa),popGroups_modern,by="Pop")
cc=subset(bb,select=c(PopGroup))
rownames(cc)=bb$Pop
bk <- c(seq(fst_min,fst_max,by=0.0005))
pheatmap(Z, main=heatmap_title,
         anotation_col=cc, annotation_row =cc,
         scale = "none", breaks=bk, legend_breaks=seq(fst_min,fst_max,0.03),
         color = c(colorRampPalette(colors = c("blue","white"))(length(bk)/2),colorRampPalette(colors = c("white","red"))(length(bk)/2)),
         cutree_rows=cut_row, cutree_cols=cut_col,
         cellwidth = cell_width, cellheight = cell_height)  # distances 0 to 3 are red, 3 to 9 black
dev.off()
