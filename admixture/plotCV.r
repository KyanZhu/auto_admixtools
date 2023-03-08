library(ggplot2)

fn = read.table('CV_error.table', header=FALSE, col.names = c("K", "CV"))
x = fn$K
y = fn$CV

pdf(file='CV.pdf',width=6,height=3.5)
ggplot(data = NULL, aes(x = x, y = y)) + 
  geom_line(color='#4472c4', lwd=1) + 
  geom_point(color='#4472c4', size=2, shape=16) + 
  xlab("K values") + ylab("CV Errors") +
  scale_x_continuous(breaks = seq(0, 11, 1)) + 
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.text = element_text(color='black'),
        axis.line = element_line(color='black'))
dev.off()
  


