library(ggplot2)
library(patchwork)
library(ggpubr)
fn=read.table("top_N.txt",col.names=c("result","PopA", "PopB", "PopC", "fst", "StdErr", "Z","SNPs"))
uni=unique(fn$PopA)
len=length(uni)

pdf("top_N.pdf",width = 11, height = 15)
for(i in 1:len){
  fn1=fn[fn$PopA==uni[i],]
  fn1$PopB=factor(fn1$PopB, levels = rev(unique(fn1$PopB)))
  assign(paste0("pp",i), ggplot(fn1,aes(y=PopB, x=fst)) +
    geom_line() + 
    geom_point(fill="#bdbdbd", color="#bdbdbd", shape=22, size=4) + 
    geom_errorbar(aes(xmin=fst - StdErr, xmax=fst + StdErr), width=0.3) + 
    labs(title=paste("P2=",uni[i])) + 
    theme_bw() +
    # geom_vline(xintercept = 0,colour = "orange",linetype="dashed")+  # 参考线
    scale_x_continuous(limits=c(0.29, 0.33)) + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),  # 底色
          panel.background = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y = element_text(color="black"),
          axis.text.x = element_text(color="black")))
}
plist <- list(pp1,pp2,pp3,pp4,pp5,pp6,pp7,pp8,pp9)  #这里不太智能，需要你自己看看你的len数，然后修改
do.call("ggarrange", c(plist, ncol=3, nrow=3)) #这里你可以自己修改一下
dev.off()




