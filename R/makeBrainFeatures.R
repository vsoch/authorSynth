# This script will create regional atlas features based on a set
# of white and gray matter brain atlas, and subcortical structure
# atlases.  We will

# 1) create feature matrix
# 2) count number of voxels in author maps for each feature
# 3) and then cluster to find simila researchers

library(XML)

setwd("/home/vanessa/Documents/Dropbox/Code/Python/authorSynth/data/atlas")
atlas = list.files(pattern="*.nii")
xml = list.files(pattern="*.xml")

# First create long list of labels and image indices for each
# image   region-name   label
image = c()
regionName = c()
label = c()

for (x in 1:length(xml)){
  im = atlas[x]
  data = xmlParse(xml[x])
  data = xmlToList(data) 
  for (d in 1:length(data$data)){
    dat = data$data[d]
    r = dat$label$text
    idx = as.numeric(dat$label$.attrs[1])
    image = c(image,im)
    regionName = c(regionName,r)
    label = c(label,idx)
  }
}

features = as.data.frame(cbind(image,regionName,label))
save(features,file="atlasFeatues.Rda")
write.table(features,file="atlasFeatures.tab",sep="/t",row.names=FALSE,quote=FALSE,col.names=TRUE)

# Make sure we don't have duplicates
any(duplicated(as.character(features$regionName)))

# Now let's read in all of our atlas images, to prepare for feature extraction
library(Rniftilib)
library("R.utils")

mrs = list()

for (a in atlas){
  # Read in each atlas, append to list
  tmp = as.character(a)
  mr = nifti.image.read(tmp,read_data=1)
  mrs[[a]] = mr[,,]
}

# Now, for each of our author brain maps, create matrix of features
datadir = "/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/brainmaps"
authors = list.files(datadir,pattern="pFgA_z_FDR_0.05.nii")

# Create matrix of authors by features
fmatrix = array(0,dim=c(length(authors),nrow(features)))
uuid =gsub("_pFgA_z_FDR_0.05.nii","",authors)
colnames(fmatrix) = as.character(features$regionName)
rownames(fmatrix) = as.character(authors)

# Read in each author map, and count voxels in each region
for (a in 1:length(authors)){
  au = authors[a]
  cat("Starting",au,a,"of",length(authors),"\n")
  mr = nifti.image.read(paste(datadir,"/",au,sep=""),read_data=1)
  mr = mr[,,]
  for (f in 1:nrow(features)){
    idx = as.numeric(features$label[f])
    r = as.character(features$regionName[f])
    im = as.character(features$image[f])
    
    # First threshold map to index
    tmp = mrs[[im]]
    tmp[tmp != idx] = 0
    count = sum((tmp!=0) * (mr!=0))
    fmatrix[au,r] = count
  }
}
rownames(fmatrix) = uuids
save(fmatrix,file="featureMatrix157.Rda")

# Get rid of regions with zero
idx = as.numeric(which(colSums(fmatrix)==0))
fmatrix = fmatrix[,-idx] 
save(fmatrix,file="featureMatrix157Filt.Rda")

# Look for correlation of featues
corr = cor(fmatrix)

# Get author names
meta = read.csv("../highly_cited_2014_final.tab",sep="\t")
idx = match(uuids,meta$uuids)


# Do a quick clustering
# heatmap(fmatrix)
disty = dist(fmatrix)
hc = hclust(disty)
plot(hc)

