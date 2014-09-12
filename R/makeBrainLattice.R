# This script will create an "empty" brain lattice, with a list of highly matched
# authors at each node.

setwd("/home/vanessa/Documents/Dropbox/Code/Python/authorSynth/data")

# Here is out directory for brainlattice image data file
latticeoutdir = "/var/www/authorSynth/data"

# Here is author and coauthor data
authors = read.csv("authors.txt",sep="\t",head=TRUE)
authors = authors[authors$PI ==1,]

# Here are the match scores to the SOM map, for pAgF
load("/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/scoresNeuroSynth/allScoresPIAuthors3383.Rda")
rownames(somMatch$cos) = gsub("_pAgF_z_FDR_0.05_score.Rda","",rownames(somMatch$cos))

# BRAIN LATTICE ---------------------------------------------------------------------------
# For each node, print file to plot the node, and save top matches to it

# We want to convert ALL the scores to Z scores so that 1) they are comparable, and 2)
# we can get the scores in the tail of the distribution for each node, and also
# make an assessment of which nodes don't have many matches (eg, missing results for
# some set of brain regions in the literature)
# These will be Z scores
dataZ = (somMatch$cos - mean(somMatch$cos)) / sd(somMatch$cos)
# These are raw scores
data = somMatch$cos

# Here is the XY coordinates and terms for each node to make the D3 - length 506
test = load("som_pAgF_d3.Rda")

# Here is the som itself
load("/home/vanessa/Documents/Dropbox/Code/Python/authorSynth/app/som_pAgF.Rda")

matchedAuthors = c()
# For each node, get list of matched authors
for (col in 1:ncol(data)){
  # These are Z scores
  scoresZ = sort(dataZ[,col],decreasing=TRUE)
  # These are regular scores
  scores = sort(data[,col],decreasing=TRUE)
  # Get the ones above Z = 1.96
  idx = which(scoresZ>1.96)
  Z = scoresZ[idx]
  raw = scores[idx]
  # Now create data frame to save to file
  uid = paste(names(Z),collapse=",")
  Z = paste(round(Z,3),collapse=",")
  raw = paste(round(raw,3),collapse=",")
  res = data.frame(Z=Z,raw=raw,uid=uid)
  matchedAuthors = rbind(matchedAuthors,res)
}
 
# Now we want to make a color for each node that shows similarity between actual node images

# Here is the directory with our som images
somdir = "/home/vanessa/Documents/Work/BRAINSPAN/dim_reduction/som506"
pattern = "*.nii$"

# Get list of SOM images to match to
soMR = list.files(somdir,pattern=pattern)
idx = grep("brainGrid*",soMR)
soMR = soMR[idx]

# Get image numbers
order = as.numeric(gsub(".nii","",gsub("brainGrid","",soMR)))
sorting = order(order)
soMR = soMR[sorting]

# Create a matrix of similarity scores
matrix = array(dim=c(length(soMR),length(soMR)))
rownames(matrix) = soMR
colnames(matrix) = soMR

# Define distance functions
euc.dist = function(x1,x2) {sqrt(sum((x1 - x2) ^ 2))}
cos.dist = function(x1,x2) {crossprod(x1, x2)/sqrt(crossprod(x1) * crossprod(x2))}

library(Rniftilib)

for (i in 1:length(soMR)){
  # Read in image
  img1 = paste(somdir,"/",soMR[i],sep="")
  img1 = nifti.image.read(img1,read_data=1)
  img1 = as.vector(img1[,,,1])
  for (j in 1:length(soMR)){
    img2 = paste(somdir,"/",soMR[j],sep="")
    img2 = nifti.image.read(img2,read_data=1)
    img2 = as.vector(img2[,,,1])
    # Calculate correlation between 1 and 2
    matrix[i,j] = cor(img1,img2)
  }
}

save(matrix,file="somCorrelationMatrix506.Rda")

disty = dist(matrix)
hc = hclust(disty)
hc$labels = seq(1,506)
plot(hc)
groups = cutree(hc,15)
colors = c("#B8002E","#F5003D","#6633FF","#CC33FF","#FF33CC","#33CCFF","#003DF5","#FF3366","#6600FF","#F5B800","#FF6633","#33FF66","#66FF33","#CCFF33","#FFCC33")
names(colors) = seq(1,15)
col = c()
for (i in 1:length(groups)){
  col = c(col,colors[groups[i]])  
}

# Now plot the som!
# plot(brainMap$som$grid$pts,main="Braingrid Similarity",col=col,xlab="Meta Brain Map Nodes",ylab="Meta Brain Map Nodes",pch=15,cex=8)
# text(brainMap$som$grid$pts,brainMap$labels,cex=.5)   

# Now add a color value to each of our som nodes
brainLattice = cbind(matchedAuthors,col,d3)
colnames(brainLattice) = c("ZSCORE","RAW","UIDS","COLOR","X","Y","TERMS")
save(brainLattice,file="brainLattice506MatchedAuthorsColors.Rda")

# Now write to text file to plot the SOM!
write.table(brainLattice,paste(latticeoutdir,"/brainLattice506MatchedAuthorsColors15.tsv",sep=""),row.names=FALSE,quote=FALSE,sep="\t")
