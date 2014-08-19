setwd("/scratch/users/vsochat/DATA/BRAINMAP/authorSynth")
load("authorBrains.Rda")
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
# (eg, the data matrix is sparse)

# self organizing map
library("kohonen")
som = som(dat, grid = somgrid(10, 10, "hexagonal"))
save(som,file="som8mm.Rda")

# We need to define a color scale that indicates the strength of the match score
library("RColorBrewer")
colorscale = brewer.pal(9,"YlOrRd")
colorscale = colorRampPalette(brewer.pal(8,"YlOrRd"))(100)

# The coordinates in so$grid$pts that we plot match the image names, so we need to order the matrix
# by the filename.  First extract the numbers
imageNames = colnames(dat)
#imageNames = as.numeric(gsub("_beststats.txt","",gsub("2mmbrainGrid","",imageNames)))
#idx = sort(imageNames,index.return=TRUE)
#data = data[,colnames(data)[idx$ix]]

# This is our color palette
rbPal <- colorRampPalette(brewer.pal(8,"YlOrRd"))

# This is match scores for one compobent to all images - the range is the max match score for all images
test = data[1,]
test = c(0,as.numeric(test),max(data))

#This adds a column of color values
# based on the y values
color = rbPal(10)[as.numeric(cut(test,breaks = 10))]
color = color[-c(1,508)]

plot(som$grid$pts,main="Which BrainTerms Maps are Similar?",xlab="Nodes",ylab="Nodes",pch=15,cex=6)
text(som$grid$pts,brainMap$labels,cex=.6)
