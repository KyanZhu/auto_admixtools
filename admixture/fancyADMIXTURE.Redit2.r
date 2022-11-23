fancyADMIXTURE <- function(
  PREFIX,
  KMIN,
  KMAX,
  PADDING = 500,
  BARSEP = 10,
  POPSEP = 0,
  BARWIDTH = 3,
  BARWIDTH_SPECIAL = 5*BARWIDTH,
  BARHEIGHT = 200,
  HCLUST = F,
  COUNT_FILE = NA,
  KFONT = 2,
  LABFONT = 1,
  CUTLINE = '',
  PNG = T, 
  SINGLESLICE = '',
  OUTFILEPREFIX = ''
)

{
  RAINBOW <- c("#0099e6", "#ff994d", "#e6ff00", "#ff99e6", "#339933", "#800080", "#ff004d", "#00ff00", "#0000ff", "#ff00ff", "#ffe699", "#b24d00", "#00ffff", "#808000", "#ff9999", "#008080", "#99bf26", "#7326e6", "#26bf99", "#808080", "#0d660d", "#bfbfbf", "#ff0000", "#99e6ff", "#ff9966", "#404040", "#ffe6e6", "#993333", "#ff6600", "#33004d")

# This is the original (classic)
#  RAINBOW <- c("#ff994d", "#0099e6", "#e6ff00", "#ff99e6", "#339933", "#800080", "#ff004d", "#00ff00", "#0000ff", "#ff00ff", "#ffe699", "#b24d00", "#00ffff", "#808000", "#ff9999", "#008080", "#99bf26", "#7326e6", "#26bf99", "#808080", "#0d660d", "#bfbfbf", "#ff0000", "#99e6ff", "#ff9966", "#404040", "#ffe6e6", "#993333", "#ff6600", "#33004d")
  source('~/sh/fancy_admixture/makePalette.r')
#  RAINBOW <- makePalette(KMAX+2)
  COLOR <- array(dim=c(KMAX,KMAX))
  COLOR[KMIN,1:KMIN] <- RAINBOW[1:KMIN]
  QOLD<-read.table(paste(PREFIX,'.',KMIN,'.Q',sep=''))
  if (KMAX>KMIN) {
  for (x in (KMIN+1):KMAX) {
    FIRSTFREE <- x
    QNEW<-read.table(paste(PREFIX,'.',x,'.Q',sep=''))
    COR <- cor(QOLD,QNEW)
    RESERVED <- vector(length=x-1)
    RESERVED[1:length(RESERVED)] <- F
    TOPCOR <- vector(length=x)
    for (i in 1:x) 
      TOPCOR[i] <- max(COR[,i])
    COMPONENTORDER <- order(TOPCOR,decreasing=T)
    for (i in COMPONENTORDER) {
       BESTMATCH <- which.max(COR[,i])
       if (!RESERVED[BESTMATCH]) {
         COLOR[x,i] <- COLOR[x-1,BESTMATCH]
         RESERVED[BESTMATCH] <-T
       }
       else {
         COLOR[x,i] <-  RAINBOW[FIRSTFREE]
         FIRSTFREE <- FIRSTFREE+1
       }
    }
    RAINBOW <-c(COLOR[x,1:x],setdiff(RAINBOW,COLOR[x,1:x]))
    QOLD <- QNEW
  } 
  }
  ID_POP <- read.table(paste(PREFIX,'.fam',sep=''),colClasses='character')[,2:1]
  if (!HCLUST)
    POPS <- unique(ID_POP[,2])
  else {
       source('~/sh/fancy_admixture/averagePopsUnsorted.r')
       Q <- averagePopsUnsorted(paste(PREFIX,'.',KMIN,'.Q',sep=''),paste(PREFIX,'.fam',sep=''))[,3:(KMIN+2)]
       COUNTPOPS <- c(as.matrix(averagePopsUnsorted(paste(PREFIX,'.',KMIN,'.Q',sep=''),paste(PREFIX,'.fam',sep=''))[,1]))
       class(Q) <- "numeric"
       if (KMAX>KMIN) {
         for (K in (KMIN+1):KMAX) {
           Q1 <- averagePopsUnsorted(paste(PREFIX,'.',K,'.Q',sep=''),paste(PREFIX,'.fam',sep=''))[,3:(KMIN+2)]
           class(Q1) <- "numeric"
           Q<-cbind(Q,Q1)
         }
       }
       ORDER <- hclust(dist(Q))$order
       POPS <- COUNTPOPS[ORDER]
#      Q<-read.table(paste(PREFIX,'.',KMIN,'.Q',sep=''))
#      if (KMAX>KMIN)
#        for (K in (KMIN+1):KMAX)
#          Q<-cbind(Q,read.table(paste(PREFIX,'.',K,'.Q',sep='')))
#      C<-read.table(COUNT_FILE)
#      source('~/sh/fancy_admixture/averagePops.r')
#      Z<-averagePops(Q,C)
#      ORDER <- hclust(dist(Z))$order
#      POPS<-as.character(C[ORDER,1]) 
  }
  if (CUTLINE[1]!='') {
    FRONTOFTHELINE <- intersect(POPS,CUTLINE)
    if (SINGLESLICE=='')
      POPS <- c(FRONTOFTHELINE,setdiff(POPS,CUTLINE))
    else
      POPS <- FRONTOFTHELINE
  }
  NIND <- dim(ID_POP)[1]
  NPOP <- length(POPS)
  if (SINGLESLICE!='') {
    NPOP <- length(CUTLINE)
    NIND <- 0
    for (i in 1:NPOP)
       NIND <- NIND + sum(ID_POP[,2]==CUTLINE[i])
    NIND <- 5*NIND
    print(NPOP)
    print(NIND)
  }
  NK <- KMAX-KMIN+1
  if (SINGLESLICE!='')
    NK <- 1
  ADDENDUM<-0
  if (CUTLINE[1]!='') {
    SUMCUT <- 0
    for (i in 1:length(CUTLINE))
      SUMCUT <- sum(ID_POP[,2]==CUTLINE[i])+SUMCUT
    ADDENDUM <- (BARWIDTH_SPECIAL-BARWIDTH)*SUMCUT
  }
  if (OUTFILEPREFIX=='')
    FILEOUTPREFIX<-paste(PREFIX,'.admixture',sep='')
  else
    FILEOUTPREFIX <- OUTFILEPREFIX
  if (PNG)
     png(file=paste(FILEOUTPREFIX,'.png',sep=''), width= 2*PADDING+(NPOP-1)*POPSEP+NIND*BARWIDTH+ADDENDUM, height=2*PADDING+(NK-1)*BARSEP+NK*BARHEIGHT)
  else
     pdf(file=paste(FILEOUTPREFIX,'.pdf',sep=''), width= (2*PADDING+(NPOP-1)*POPSEP+NIND*BARWIDTH+ADDENDUM)/72, height=(2*PADDING+(NK-1)*BARSEP+NK*BARHEIGHT)/72)
  plot(rbind(c(0,0), c(2*PADDING+(NPOP-1)*POPSEP+NIND*BARWIDTH+ADDENDUM, 2*PADDING+(NK-1)*BARSEP+NK*BARHEIGHT)),type='n',axes=F,xlab=NA,ylab=NA)

  BOTTOM <- PADDING+BARHEIGHT/2
  for (K in KMIN:KMAX) {
    if (SINGLESLICE=='' | SINGLESLICE==K) {
    text(PADDING-BARSEP, BOTTOM, labels=paste('K=',K,sep=''),adj=1, cex=KFONT)
    BOTTOM <- BOTTOM+BARHEIGHT+BARSEP+1
    }
  }

  LEFT <- PADDING+1
  for (pop in POPS) {
    WHICH <- which(ID_POP[,2]==pop)
    THISBARWIDTH <- BARWIDTH
    POPSEP <- 0
    if (length(WHICH) == 1)
      THISBARWIDTH <- 12
    if (length(WHICH) == 2)
      THISBARWIDTH <- 6
    if (length(WHICH) == 3)
      THISBARWIDTH <- 4
    if (length(WHICH) < 6)
      POPSEP <- 0
    if (sum(CUTLINE==pop)==1)
      THISBARWIDTH <- BARWIDTH_SPECIAL
    text(round(LEFT+length(WHICH)*THISBARWIDTH/2),PADDING-BARSEP,labels=pop,srt=90,adj=1, cex=LABFONT)
    text(round(LEFT+length(WHICH)*THISBARWIDTH/2),PADDING+length(KMIN:KMAX)*(BARHEIGHT+BARSEP),labels=pop,srt=90,adj=0, cex=LABFONT)
    BOTTOM <-PADDING+1
    for (K in KMIN:KMAX) {
      if (SINGLESLICE=='' | SINGLESLICE==K) {
      Q<-read.table(paste(PREFIX,'.',K,'.Q',sep=''))
      HORIZON <- vector(length=length(WHICH))
      HORIZON[1:length(HORIZON)] <- BOTTOM
      for (i in 1:K) {
        NEWHORIZON <- HORIZON + c(as.matrix(Q[WHICH,i]))*BARHEIGHT
        ACTIVE <- which(Q[WHICH,i]>=0.05/BARHEIGHT)
        if (length(ACTIVE)>0) {
          if (SINGLESLICE=='')
            rect(LEFT+((1:length(WHICH)-1)*THISBARWIDTH)[ACTIVE],HORIZON[ACTIVE],(LEFT+(1:length(WHICH))*THISBARWIDTH)[ACTIVE],NEWHORIZON[ACTIVE],col=COLOR[K,i],border=COLOR[K,i])
          else if (SINGLESLICE==K)
            rect(LEFT+((1:length(WHICH)-1)*THISBARWIDTH)[ACTIVE],HORIZON[ACTIVE],(LEFT+(1:length(WHICH))*THISBARWIDTH)[ACTIVE],NEWHORIZON[ACTIVE],col=COLOR[K,i],border=COLOR[K,i])
        }
        HORIZON <- NEWHORIZON
      }
      rect(LEFT,BOTTOM,LEFT+THISBARWIDTH*length(WHICH),BOTTOM+BARHEIGHT,border='black')
      BOTTOM <- BOTTOM+BARHEIGHT+BARSEP
      }
    } 
    LEFT <- LEFT+POPSEP+THISBARWIDTH*length(WHICH)
  }

  dev.off()
}
