setwd("/scratch/users/vsochat/DATA/BRAINMAP/authorSynth")
load("authorBrains.Rda")

# Try doing clustering
disty = dist(authorBrains)
hc = hclust(disty)
plot(hc)

# self organizing map
library("kohonen")
som = som(authorBrains, grid = somgrid(10, 10, "hexagonal"))
