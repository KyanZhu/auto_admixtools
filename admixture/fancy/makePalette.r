minColDist <- function(RGB, CHOSEN, CANDIDATE)
{
  min(as.matrix(dist(rbind(RGB[c(CANDIDATE,CHOSEN),]),method='manhattan'))[1,2:length(CHOSEN)])
}

RGBtoCOL <- function(X)
{
  RED <- format(as.hexmode(X[1]),width=2)
  GREEN <- format(as.hexmode(X[2]),width=2)
  BLUE <- format(as.hexmode(X[3]),width=2)
  paste('#',RED,GREEN,BLUE,sep='')
}

makePalette <- function(NCOL, RANGE=0.05, SSIZE=1000, SEED=480, RGBDIFF=50, ORIGINAL=F)
{
  RGB <- array(dim=c(SSIZE,3))
  set.seed(SEED)
  if (ORIGINAL) {
  for (i in 1:SSIZE) {
    RGB[i,] <- floor(256*(runif(3)*(1-2*RANGE)+RANGE))
    while(max(RGB[i,])-min(RGB[i,])<RGBDIFF)
      RGB[i,] <- floor(256*(runif(3)*(1-2*RANGE)+RANGE))
    print(i)
  }
  }
  else {
    PANCHROMIA <- rainbow(2*NCOL)
    for (i in 1:length(PANCHROMIA))
      RGB[i,] <- c(col2rgb(PANCHROMIA[i]))
    RGB <- RGB[1:length(PANCHROMIA),]
  }
  DIST <- as.matrix(dist(RGB))
  MINDIST <- vector(length=dim(RGB)[1])
  for (i in 1:SSIZE)
    MINDIST[i] <- min(DIST[setdiff(1:dim(RGB)[1],i),])
  CHOSEN <- which.max(MINDIST)
  NOT_CHOSEN <- setdiff(1:dim(RGB)[1],CHOSEN)
  while (length(CHOSEN)<NCOL) {
   MINDIST <- -1 
   CHOICE <- -1
   for (x in NOT_CHOSEN) {
     THIS <- minColDist(RGB, CHOSEN, x)
     if (THIS>MINDIST)
     {
       MINDIST <- THIS
       CHOICE <- x
     }
   }
   CHOSEN <- c(CHOSEN,CHOICE)
   NOT_CHOSEN <- setdiff(NOT_CHOSEN,CHOICE)
  }
  RGB <- RGB[CHOSEN,]
  PALETTE <- vector(length=NCOL)
  for (i in 1:NCOL)
    PALETTE[i] <- RGBtoCOL(RGB[i,])
  PALETTE
}
