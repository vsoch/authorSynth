# This script will read in author brain maps, and save to matrix,
# to prepare for unsupervised clustering

library(Rniftilib)
library("R.utils")
datadir = "/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/brainmapsNeuroSynth"
setwd(datadir)
mr = list.files(datadir,pattern="_pFgA_z_FDR_0.05.nii")

# Read in each brain map, append to matrix
#tmp = gunzip(mr[1])
tmp = as.character(mr[1])
authorBrains = nifti.image.read(tmp,read_data=1)
authorBrains = as.vector(authorBrains[,,])
authorBrains = array(0,dim=c(length(mr),length(authorBrains)))

for (m in 1:length(mr)){
  cat("Processing",m,"of",length(mr),"\n")
  tmp = as.character(mr[m])
  authorBrain = nifti.image.read(tmp,read_data=1)
  authorBrain = as.vector(authorBrain[,,])
  authorBrains[m,] = authorBrain
}

rownames(authorBrains) = gsub("pFgA_z_FDR_0.05.nii.gz","",mr)
save(authorBrains,file="authorBrainsNeuroSynth.Rda")
