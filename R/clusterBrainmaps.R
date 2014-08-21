setwd("/scratch/users/vsochat/DATA/BRAINMAP/authorSynth")
load("authorBrains.Rda")

# Also load the author information
meta = read.csv("/home/vsochat/SCRIPT/python/authorSynth/data/highly_cited_2014_final.csv",sep="\t")

# Match uuids with meta to get author name
uuids = gsub("_pFgA_z_FDR_0.05.nii","",rownames(authorBrains))
uuids = gsub("^r","",uuids)
idx = match(uuids,meta$uuids)
labels = c()
for (i in 1:length(idx)){
  name =  paste(meta$First_Name.Middle_Name[idx[i]],meta$Family_Name[idx[i]],sep="")
  labels = c(labels,name)
}

lookup = cbind(labels,uuids)
save(lookup,file="authorNameLookup.Rda")

# Try doing clustering
dat = authorBrains
rownames(dat) = labels
disty = dist(dat)
hc = hclust(disty)
plot(hc,main="Neuroscience Researcher Similarity")

distancematrix = as.matrix(disty)
rownames(distancematrix) = gsub(" ",".",rownames(distancematrix))
colnames(distancematrix) = gsub(" ",".",rownames(distancematrix))
hist(distancematrix,main="Distribution of Euclidean Distances for Author Similarity",col="orange")

# Let's try thresholding out low values
distancematrix[distancematrix<50] = 0
write.table(distancematrix,file="dist_euclidean.txt",quote=FALSE,sep=";")
plot(hclust(as.dist(distancematrix)))
idx = which(distancematrix == 1,arr.ind=TRUE)

# What we see in the tree is that there are small groups of researhers
# with some similarity, but likely most researchers have little similarity
# (eg, the data matrix is sparse).  This tells us that our features are not
# doing a good job because they are too detailed - two authors both with
# activation in the amygdala should be similar, even if the voxels don't
# completely overlap

# Clustering idea # 2: We instead define 157 regions (white and gray matter)
# and count voxels in author maps in each region.  We get a much nicer clustering
# because we have addressed the above.
setwd("/home/vanessa/Documents/Dropbox/Code/Python/authorSynth/data/atlas")
load("featureMatrix157Filt.Rda")
disty = dist(fmatrix)
hc = hclust(disty)
plot(hc,main="Neuroscience Author Regional Similarity")

# Clustering idea # 3: Cluster the match scores of the brainmaps to the SOM images
setwd('/scratch/users/vsochat/DATA/BRAINMAP/nsynth525pFgA/scores')
load("allScoresAuthorNames124.Rda")

disty = dist(data.euc)
hc = hclust(disty)
plot(hc,main="Clustering Neuroscience Authors Based on Euclidean Distance of Author to SOM Maps")
