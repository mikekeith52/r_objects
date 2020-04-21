
# D is a dataset of numeric vectors only

library(corrplot)
library(tidyverse)

# View correlations
D %>%
 cor() %>%
 corrplot()

# Run model
set.seed(123)

# Initialize total within sum of squares error: wss
wss <- 0
# For 1 to 15 cluster centers
for (i in 1:15) {
  km.out <- kmeans(scale(D), centers = i, nstart=100, iter.max=1000)
  # Save total within sum of squares to wss variable
  wss[i] <- km.out$tot.withinss
}

# Plot total within sum of squares vs. number of clusters
par(cex.sub=.7)
plot(1:10, wss, type = "b",
     xlab = "Number of Clusters", 
     ylab = "Within groups sum of squares",
     main = "Choose k (Number of Clusters) Where Elbow Bends",
     sub = "K-means Clustering")

# Choose k where the elbow bends
k<-3

########### Run this together always ##############3
# Reset seed to make the numbering consistent across trials
km.out<-kmeans(scale(D),centers=k,iter.max=1000,nstart=100)
D$cluster<-km.out$cluster