library(ggplot2)
library(patchwork)
library(ggpubr)
fn=read.table("top_20.txt",col.names=c("result","Target", "PopB", "PopC", "Fst", "StdErr", "Z", "SNPs"))
uni=unique(fn$Target)  # cluster by Target
len=length(uni)
top_N=20
fst_min = 0.28
fst_max = 0.30
WIDTH = 3.5
HEIGHT = 5


pdf(paste0("top_",top_N,".pdf"),width = WIDTH, height = HEIGHT)
for(i in 1:len){
  # subset
  fn1 <- subset(fn, Target==uni[i])
  fn1$PopB <- factor(fn1$PopB, levels = rev(unique(fn1$PopB)))
  fn1 <- fn1[1:top_N,]
  # Color
  Zcolor <- c()
  Zsigh <- c()
  for(k in seq(1,nrow(fn1))){
    if(fn1$Z[k] <= -3){
      Zcolor <- c(Zcolor,"#ff8a80")
      Zsigh <- c(Zsigh, "|Z|<=-3")}
    else if(fn1$Z[k] < -2){
      Zcolor <- c(Zcolor,"#ffcc80")
      Zsigh <- c(Zsigh, "-3<|Z|<-2")}
    else if(fn1$Z[k] <= 2){
      Zcolor <- c(Zcolor,"#bdbdbd")
      Zsigh <- c(Zsigh, "-2<=|Z|<=2")}
    else if(fn1$Z[k] < 3){
      Zcolor <- c(Zcolor,"#81d4fa")
      Zsigh <- c(Zsigh, "2<|Z|<3")}
    else if(fn1$Z[k] >= 3){
      Zcolor <- c(Zcolor,"#82b1ff")
      Zsigh <- c(Zsigh, "|Z|>=3")}
  }
  fn1$Zscore <- Zsigh
  # plot
  p <- ggplot(fn1,aes(y=PopB, x=Fst)) + # y axis
    geom_line() + 
    geom_point(fill=Zcolor, color=Zcolor, shape=22, size=4) + 
    geom_errorbar(aes(xmin=Fst - StdErr, xmax=Fst + StdErr), width=0.3) + 
    labs(title=paste("P2=",uni[i])) + 
    theme_bw() +
    # geom_vline(xintercept = 0,colour = "orange",linetype="dashed")+  # 参考线
    # scale_colour_manual(values = c("#0000ff","#82b1ff","#bdbdbd","#ff8a80","#ff0000")) +
    # scale_fill_manual(values = c("#0000ff","#82b1ff","#bdbdbd","#ff8a80","#ff0000")) +
    scale_x_continuous(limits=c(fst_min, fst_max)) + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),  # 底色
          panel.background = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y = element_text(color="black"),
          axis.text.x = element_text(color="black"))
  assign(paste0("p",i), p)
}
plist <- list(p1)  #这里不太智能，需要你自己看看你的len数，然后修改
do.call("ggarrange", c(plist, ncol=1, nrow=1)) #这里你可以自己修改一下
dev.off()