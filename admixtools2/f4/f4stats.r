library(admixtools)
args <- commandArgs(trailingOnly = TRUE)

f2_dir <- args[1]
f2_blocks <- f2_from_precomp(f2_dir)

p1 <- c("Mbuti.DG")
# p2 <- c("Longlin", "Dushan", "Baojianshan", "GaoHuaHua", "Songshan", "Songshan_o1", "Songshan_o2")
p2 <- scan('p2s', what = character())
p3 <- scan('p3s', what = character())
p4 <- scan('p4s', what = character())

result <- f4(f2_blocks, p1, p2, p3, p4)
write.table(result, 'f4.result', sep = "\t", row.names = FALSE)