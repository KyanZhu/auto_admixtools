library(showtext)
library(reshape2)
library(ggsci)
library(ggplot2)
library(dplyr)
theme1<-theme_bw()+theme(legend.position = 'bottom',  # 图例位置
                         # panel.background=element_rect(pptbg),  # 画布背景颜色
                         # plot.background=element_rect(pptbg),  # 图形背景颜色
                         plot.title = element_text(hjust=0.5,size=16,vjust=0.5),  # 标题位置
                         panel.border=element_blank(),  # 图形边界
                         panel.grid.major=element_blank(),  # element_line(color='lightgrey',linetype="dashed"),  # 网格线
                         panel.grid.minor=element_blank(),  # 次级网格线
                         legend.title=element_text(size=10,color='black',vjust=-0.5),  # 图例标题
                         legend.text=element_text(size=10,color='black'),  # 图例文字
                         axis.text.y = element_text(hjust=1, color='black', size=10))  # angle=45, 
                         # legend.background =element_rect(pptbg),  # 图例背景
                         # axis.text=element_text(size=12,color="black"),  # 坐标轴文字
                         # strip.text=element_text(size=12,color="black"),  # 分面文字
                         # strip.background=element_blank(),  # 分面的背景
                         # axis.line = element_line(size=0.5, color = 'black'),  # 轴颜色大小
                         # panel.spacing=unit(10,'mm'))  # 画布大小


#               ANE       ANA     Steppe     BMAC      Onge       YR
source_col=c("ff8121", "bc2bff", "00eb00", "00bd00", "00b800", "dede00")
# SETTINGS
# pops_col 按照图例出现顺序定义
pops_col <- c('Upper_YR_LN'='#dede00',
              'Onge.DG'="#00b800")


df <- read.table("r_input.txt",header=TRUE,sep='\t')
df$source <- factor(df$source, levels=rev(names(pops_col)))
df <- df[order(df$source),]
# 定义群体出现的顺序
# df$target <- factor(df$target, levels=c("Dulan_o", "Kyrgyzstan_Turk", "Kazakhstan_Turkic_Karakaba"))

p1 <- ggplot(df,aes(x=target, y=percent, fill=source)) +
      geom_bar(position="stack", stat='identity', width=.7, color='black') +
      geom_errorbar(aes(ymin=sum_per-std, ymax=sum_per), width=.4) +
      scale_fill_manual(values=pops_col) +
      # 图例文字
      # guides(fill=guide_legend(reverse=TRUE)) +
      # 堆积图文字
      geom_text(aes(label=percent), position=position_stack(vjust=0.5), size=3) +
      geom_text(aes(x=target, y=.1, label=tail), size=2.5) +
      # 标题
      labs(title="", fill="", x="", y="") +
      # 主题设置
      theme1 +
      # y轴坐标
      scale_y_continuous(limits=c(0,1)) + #  + #.01),expand=c(0, 0))+
      # 90°
      coord_flip()
p1
ggsave(p1, file=paste(basename(getwd()), '.pdf', sep = ''), width=8, height=11)