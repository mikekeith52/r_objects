# D is a dataset of numeric vectors only

library(corrplot)
library(tidyverse)

# View correlations
D %>%
 cor() %>%
 corrplot()

# PCA model to reduce dimensionality
pca.out<-prcomp(D,center=T,scale=T)
# Cumulative variance
pcs.var<-pca.out$sd^2
pve<-pcs.var/sum(pcs.var)
# Two PCs ~ 21% of the variance (1/5)
cumsum(pve)

# See Rotation
df.pca<-data.frame(pc1=pca.out$rotation[,1],pc2=pca.out$rotation[,2])
df.pca

# Take first two PCs
pcs<-predict(pca.out,D)
pc1<-pcs[,1]
pc2<-pcs[,2]
PCS<-pcs[,c(1,2)]
