# dot editor: https://edotor.net/
library(admixtools)
library(tidyverse)

f2_dir = "D:/R/Anthropology/data/12.shallow_sequence/2023.03.16/popgen/8.qpgraph/graph1/f2_blocks"
my_pops = c("Mbuti.DG", "Tianyuan", "Longlin", "Laos_Hoabinhian.SG", "Qihe", "Upper_YR_LN", "Gaoshancheng_LN")
f2_blocks = f2_from_precomp(f2_dir, pops=my_pops)

constrain_cd = tribble(
  ~pop, ~min, ~max,
  "Laos_Hoabinhian.SG", NA, 0,
  "Longlin", NA, 0,
  "Tianyuan", NA, 0,
  "Gaoshancheng_LN", 1, NA,)
  
opt_results = find_graphs(f2_blocks, numadmix = 3, outpop = 'Mbuti.DG',
                          stop_gen = 50, admix_constraints = constrain_cd)

winner = opt_results %>% slice_min(score, with_ties = FALSE)
winner$score[[1]]
pdf("autograph1.pdf")
plot_graph(winner$edges[[1]])
dev.off()

# run_shiny_admixtools()
# graph <- read.table("template", stringsAsFactors = FALSE)
# 
# # 将数据处理成所需格式
# graph <- data.frame(V1 = sub('"(.*)"', '\\1', graph$V1),
#                     V2 = sub('"(.*)"', '\\1', graph$V3))
# 
# for (i in 1:nrow(graph)) {
#   for (j in 1:ncol(graph)) {
#     # 如果元素值中包含 "xxx"，则替换为 "."
#     if (grepl("xxx", graph[i,j])) {
#       graph[i,j] <- gsub("xxx", ".", graph[i,j])
#     }
#   }
# }
# 
# # qpgraph
# qpg_result = qpgraph(f2_blocks, graph, allsnps = TRUE, return_fstats = TRUE)
# # 将qpg_result$worst_residual输出到文件, 追加模式
# write.table(qpg_result$worst_residual, file = "worst_residual.txt", append = TRUE, row.names = FALSE, col.names = FALSE, quote = FALSE)
# pdf("output.pdf")
# plot_graph(qpg_result$edges)
# dev.off()
