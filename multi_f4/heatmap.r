#需要两个输入文件
library(pheatmap)
INFILE='summ.txt'
DF <- as.matrix(read.table(INFILE))
TARGET_COL = 4
COL_POPX = 5
COL_POPY = 3
CUT_ROW = 2
CUT_COL = 5
VALUE_COL = 8
TARGETS <- unique(DF[, TARGET_COL])
for (i in 1:length(TARGETS)) {
  heatmap_title=paste0("f4_heatmap(Mbuti, Refs; ", TARGETS[i], ", Songshan_Other)")
  X <- DF[DF[,TARGET_COL] == TARGETS[i],]
  NAME_POPX <- unique(X[,COL_POPX])
  NAME_POPY <- unique(X[,COL_POPY])
  N_POPX <- length(NAME_POPX)
  N_POPY <- length(NAME_POPY)
  Z <- array(dim=c(N_POPX,N_POPY))
  Z[1:N_POPX,1:N_POPY] <- NA
  colnames(Z)<-NAME_POPY
  rownames(Z)<-NAME_POPX
  NPAIRS <- dim(X)[1]
  for (j in 1:NPAIRS) {
    Z[as.character(X[j,COL_POPX]),as.character(X[j,COL_POPY])] <- as.numeric(X[j,VALUE_COL])
  }
  Z<-apply(Z,c(1,2),as.numeric)
  pdf(file=paste0(TARGETS[i], '.pdf'),width=23,height=23)
  bk <- c(seq(-5,-0.1,by=0.01),seq(0,5,by=0.01))
  pheatmap(Z,main=heatmap_title, 
           scale = "none", breaks=bk, legend_breaks=seq(-5,5,2),
           color = c(colorRampPalette(colors = c("red","white"))(length(bk)/2),colorRampPalette(colors = c("white","blue"))(length(bk)/2)),
           cutree_rows=CUT_ROW, cutree_cols=CUT_COL, 
           cellwidth = 10, cellheight = 10)
  dev.off()
}