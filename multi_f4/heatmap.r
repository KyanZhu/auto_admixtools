#需要两个输入文件
library(pheatmap)
heatmap_title="f4_heatmap(Mbuti, ref; DSQM, WLR/YR)"
INFILE='summ.txt'
X<-as.matrix(read.table(INFILE))
CUT_ROW = 2
CUT_COL = 5
COL_POPX = 5
COL_POPY = 3
VALUE_COL = 8
NAME_POPX <- unique(X[,COL_POPX])
NAME_POPY <- unique(X[,COL_POPY])
N_POPX <- length(NAME_POPX)
N_POPY <- length(NAME_POPY)
Z <- array(dim=c(N_POPX,N_POPY))
Z[1:N_POPX,1:N_POPY] <- NA
colnames(Z)<-NAME_POPY
rownames(Z)<-NAME_POPX
NPAIRS <- dim(X)[1]
for (i in 1:NPAIRS) {
  Z[as.character(X[i,COL_POPX]),as.character(X[i,COL_POPY])] <- as.numeric(X[i,VALUE_COL])
}
Z<-apply(Z,c(1,2),as.numeric)
pdf(file='summ.pdf',width=23,height=23)
bk <- c(seq(-5,-0.1,by=0.01),seq(0,5,by=0.01))
pheatmap(Z,main=heatmap_title, 
         scale = "none", breaks=bk, legend_breaks=seq(-5,5,2),
         color = c(colorRampPalette(colors = c("blue","white"))(length(bk)/2),colorRampPalette(colors = c("white","red"))(length(bk)/2)),
         cutree_rows=CUT_ROW, cutree_cols=CUT_COL, 
         cellwidth = 10, cellheight = 10)
dev.off()
