setwd("/home/vanessa/Documents/Dropbox/Code/Python/authorSynth")
#setwd("C:\\Users\\Vanessa\\Documents\\Dropbox\\Code\\Python\\authorSynth\\data\\atlas")

# AUTHOR 17K WORK -------------------------------------------------------------
load("regionalFeaturesFilter17931.Rda")


# AUTHOR 124 WORK -------------------------------------------------------------
load("authorBrains.Rda")
library(reshape2)
library(ade4)

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

# NETWORK GENERATION

setwd("C:\\Users\\Vanessa\\Documents\\Dropbox\\Code\\Python\\authorSynth\\data\\atlas")
load("featureMatrix157Filt.Rda")
disty = dist(fmatrix)
hc = hclust(disty)
plot(hc)



library(qgraph)
# We need to know author names for labels
load("authorLookup125.Rda")
lookup = as.data.frame(lookup)
idx = match(lookup$uuids,rownames(fmatrix))
labels = lookup$labels[idx]


# change feature matrix to boolean
dat = cmatrix
dat[dat>=1] = 1
# Adjacency matrix
dat = dat %*% t(dat)
rownames(dat) = labels
colnames(dat) = labels

holder = dat
holder[holder<20] = 0
qg = qgraph(holder, layout="spring",
            label.cex=0.5, labels=colnames(holder), 
            label.scale=FALSE,
            title="Neuroscience Author Literature Brain Map Similarity",
            posCol="green",negCol="red",
            color = "purple")



# TANIMOTO SCORES --------------------------------------------------------
# Try doing a tanimoto score for region names
tanimotos = array(dim=c(nrow(fmatrix),nrow(fmatrix)))
for (r in 1:nrow(fmatrix)){
  for (rr in 1:nrow(fmatrix)){
    author1= fmatrix[r,]
    author2 = fmatrix[rr,]
    author1 = names(author1[author1 != 0])
    author2 = names(author2[author2 != 0])
    tanimotos[r,rr] = length(intersect(author1,author2)) / length(union(author1,author2))
  }  
}
rownames(tanimotos) = labels
colnames(tanimotos) = labels
save(tanimotos,file="authorTanimotos125.Rda")

# COSINE DISTANCES --------------------------------------------------------
# Try cosine distance of featureMatrix
cmatrix = array(dim=c(nrow(fmatrix),nrow(fmatrix)))
rownames(cmatrix) = rownames(fmatrix)
colnames(cmatrix) = rownames(fmatrix)
idx = match(rownames(cmatrix),lookup$uuids)
labels = lookup$labels[idx]
cos.dist = function(x1,x2) {crossprod(x1, x2)/sqrt(crossprod(x1) * crossprod(x2))}
for (i in 1:nrow(fmatrix)){
  for (j in 1:nrow(fmatrix)){
    cmatrix[i,j] = cos.dist(fmatrix[i,],fmatrix[j,])
  }  
}
# We have an errored image "aaa" in here!
cmatrix = cmatrix[-88,]
cmatrix = cmatrix[,-88]
labels = labels[-88]


# Also try binary cosine distance of featureMatrix
cmatrixbin = array(dim=c(nrow(fmatrix),nrow(fmatrix)))
rownames(cmatrixbin) = rownames(fmatrix)
colnames(cmatrixbin) = rownames(fmatrix)
idx = match(rownames(cmatrixbin),lookup$uuids)
labels = lookup$labels[idx]
cos.dist = function(x1,x2) {crossprod(x1, x2)/sqrt(crossprod(x1) * crossprod(x2))}
for (i in 1:nrow(fmatrix)){
  for (j in 1:nrow(fmatrix)){
    author1 = fmatrix[i,]
    author2 = fmatrix[j,]
    author1[author1 != 0] = 1
    author2[author2 != 0] = 1
    cmatrixbin[i,j] = cos.dist(author1,author2)
  }  
}
# We have an errored image "aaa" in here!
cmatrixbin = cmatrixbin[-88,]
cmatrixbin = cmatrixbin[,-88]
labels = labels[-88]

# This one works best
# dat = somAuthorMatch$cos
dat=cmatrix
rownames(dat) = labels
colnames(dat) = labels
dat = cor(t(dat), method="spearman")
dat[abs(dat) < .5] = 0

# We will color by institution
meta = read.csv("C:\\Users\\Vanessa\\Documents\\Dropbox\\Code\\Python\\authorSynth\\data\\highly_cited_2014_final.tab",sep="\t")
idx = match(as.character(rownames(fmatrix)),as.character(meta$uuids))
institution = as.character(meta$Primary.Affiliation[idx])
colors = rainbow(length(unique(institution)))
col = array(dim=length(institution))
for (c in 1:length(unique(institution))){
  ins = unique(institution)[c]
  col[which(institution == ins)] = colors[c]
}

# Try coloring by county
meta = read.csv("C:\\Users\\Vanessa\\Documents\\Dropbox\\Code\\Python\\authorSynth\\data\\highly_cited_2014_final.tab",sep="\t")
idx = match(as.character(rownames(fmatrix)),as.character(meta$uuids))
institution = as.character(meta$Primary.Affiliation[idx])
countries = c()
for (i in institution){
  countries = c(countries,gsub(" ","",strsplit(i,",")[[1]][2]))  
}
countries[c(114,115,101,96,86,88,78,75,70,63,16,3,1)] = "USA"
colors = rainbow(length(unique(countries)))
col = array(dim=length(countries))
for (c in 1:length(unique(countries))){
  con = unique(countries)[c]
  col[which(countries == con)] = colors[c]
}

qg = qgraph(dat, layout="spring",
       label.cex=0.5, labels=colnames(dat), 
       label.scale=FALSE,
       title="Neuroscience Author Literature Brain Map Similarity",
       posCol="green",negCol="red",
       color = "purple")


# Save stuff so we can do more later!
network = list(graph=qg,institution=institution,countries=countries,distData = cmatrix,corr=dat,thresh=0.5,uuids=rownames(cmatrix))
save(network,file="../authorNetworkRegionSim125.Rda")

# Now let's extract stuff from this matrix so that we can make d3!
