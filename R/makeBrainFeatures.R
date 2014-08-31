# This script will create regional atlas features based on a set
# of white and gray matter brain atlas, and subcortical structure
# atlases.  We will

# 1) create feature matrix
# 2) count number of voxels in author maps for each feature
# 3) and then cluster to find simila researchers

args = commandArgs(TRUE)

# Input image file
mr = args[1]
uuid = args[2]
outfile = args[3]

library(Rniftilib)
library("R.utils")

setwd("/home/vsochat/SCRIPT/python/authorSynth/data/atlas")
atlas = list.files(pattern="*.nii")
load("atlasFeatures.Rda")
load("atlasImages.Rda")

# Create matrix of authors by features
regions = array(0,dim=nrow(features))
names(regions) = as.character(features$regionName)

mr = nifti.image.read(mr,read_data=1)
mr = mr[,,]
for (f in 1:nrow(features)){
  idx = as.numeric(features$label[f])
  r = as.character(features$regionName[f])
  im = as.character(features$image[f])
    
  # First threshold map to index
  tmp = mrs[[im]]
  tmp[tmp != idx] = 0
  count = sum((tmp!=0) * (mr!=0))
  regions[r] = count
}

save(regions,file=outfile)
