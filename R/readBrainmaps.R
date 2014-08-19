# This script will read in author brain maps, and save to matrix,
# to prepare for unsupervised clustering

library(Rniftilib)
library("R.utils")
datadir = "/scratch/users/vsochat/DATA/BRAINMAP/authorSynth/"
datadir = "/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/brainmaps"
setwd(datadir)
mr = list.files(datadir,pattern="_pFgA_z_FDR_0.05.nii")

# Read in each brain map, append to matrix
#tmp = gunzip(mr[1])
tmp = as.character(mr[1])
authorBrains = nifti.image.read(tmp,read_data=1)
authorBrains = as.vector(authorBrains[,,])

for (m in 2:length(mr)){
  #tmp = gunzip(mr[m])
  cat("Processing",m,"of",length(mr),"\n")
  tmp = as.character(mr[m])
  authorBrain = nifti.image.read(tmp,read_data=1)
  authorBrain = as.vector(authorBrain[,,])
  authorBrains = rbind(authorBrains,authorBrain)
}

rownames(authorBrains) = gsub("pFgA_z_FDR_0.05.nii.gz","",mr)
save(authorBrains,file="authorBrains.Rda")
