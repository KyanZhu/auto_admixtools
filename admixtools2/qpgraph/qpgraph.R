# dot editor: https://edotor.net/
library(admixtools)
library(tidyverse)

f2_dir <- "D:/R/Anthropology/data/12.shallow_sequence/2023.03.16/popgen/8.qpgraph/graph1/f2_blocks"
my_pops <- c("Mbuti.DG", "Kostenki14", "Tianyuan", "Longlin", "Malaysia_Hoabinhian.WGC", "Qihe", "Dushan", "Baojianshan", "Boshan", "Upper_YR_LN", "Gaoshancheng_LN", "Haimenkou_LN")
f2_blocks <- f2_from_precomp(f2_dir)

# define a function that takes a file name as input and returns the result of qpgraph on that file
run_qpgraph <- function(filename) {
  
  # read the graph file
  graph <- read.table(filename, stringsAsFactors = FALSE)
  
  # process the graph data
  graph <- data.frame(V1 = sub('"(.*)"', '\\1', graph$V1),
                      V2 = sub('"(.*)"', '\\1', graph$V3))
  for (i in 1:nrow(graph)) {
    for (j in 1:ncol(graph)) {
      if (grepl("xxx", graph[i,j])) {
        graph[i,j] <- gsub("xxx", ".", graph[i,j])
      }
    }
  }
  
  # run qpgraph on the f2_blocks and the processed graph
  qpg_result <- qpgraph(f2_blocks, graph, allsnps = TRUE, return_fstats = TRUE)
  
  # plot and worst residual
  write.table(filename, file = "worst_residual.txt", append = TRUE, row.names = FALSE, col.names = FALSE, quote = FALSE, eol = '\t')
  write.table(qpg_result$worst_residual, file = "worst_residual.txt", append = TRUE, row.names = FALSE, col.names = FALSE, quote = FALSE)
  
  pdf(paste0(gsub("\\.graph$", "", filename), ".pdf"))
  print(plot_graph(qpg_result$edges))
  dev.off()
}

# get a list of all graph files in the root directory
graph_files <- list.files(pattern = "\\.graph$", recursive = TRUE)

# run qpgraph on each graph file and save the result to a list
lapply(graph_files, run_qpgraph)