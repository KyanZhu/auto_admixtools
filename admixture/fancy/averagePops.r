averagePops <- function(Q, C, rounding=3)
{
   NI <- dim(Q)[1];
   NP <- dim(C)[1];
   K <- dim(Q)[2];
   A <- array(dim=c(NP,K));
   
   first <- 1;
   for (i in 1:NP) {
      for (j in 1:K) {
         A[i,j] <- mean(Q[first:(first+as.numeric(C[i,2])-1),j]);
      }
      first <- first+as.numeric(C[i,2]);
   }
   round(A,rounding)
}

