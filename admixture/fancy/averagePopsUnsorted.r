averagePopsUnsorted <- function(QFILE, INDFILE, POPCOL=1, rounding=3, includenames=T,includesamplesizes=T )
{
  Q <- read.table(QFILE)
  POPS <- read.table(INDFILE,colClasses='character')[,POPCOL]
  UNIQUE_POPS <- unique(sort(POPS))
  Z <- array(dim=c(length(UNIQUE_POPS),dim(Q)[2]))
  N <- vector(length=dim(Z)[1])
  for (i in 1:length(UNIQUE_POPS)) {
    for (j in 1:dim(Q)[2]) {
      Z[i,j] <- mean(Q[which(POPS==UNIQUE_POPS[i]),j])
      N[i] <- sum(POPS==UNIQUE_POPS[i])
    } 
  } 
  Z<-round(Z,rounding)
  if (includesamplesizes)
    Z<-cbind(N,Z)
  if (includenames)
    Z<-cbind(UNIQUE_POPS,Z)
  Z
}
