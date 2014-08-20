# This script will read in raw neurosynth 525 images, and create a 22x23 SOM
# that we can map authorBrain maps onto to visually and qualitatively assess
# the maps. Both sets of images are in MNI standard space, 91 x 109 x 91 / 2mm 

# Here is how to make the self organizing map
library('kohonen')
library("Rniftilib")

# Path to raw 525 neurosynth maps
mrpath = "/scratch/users/vsochat/DATA/BRAINMAP/nsynth525pFgA/4mm"
mrs = list.files(mrpath,full.names=TRUE,pattern="*.nii")
# To make the SOM, we've resampled neurosynth maps to 8mm
# We will resample output images bakc to 2mm after
data = matrix(nrow=length(mrs),ncol=16128)

# Read in each file to a matrix
for (i in 1:length(mrs)){
  cat(i,"of",length(mrs))
  m = mrs[i]
  nii = nifti.image.read(m,read_data=1)
  niivector = as.vector(nii[,,,1])
  data[i,] = niivector
}
# Get rid of path for labels
labels = gsub("/home/vanessa/Documents/Work/NEUROSYNTH/brainmaps525/","",mrs)
rownames(data) = mrs 

# Save raw data matrix
# save(data,file="/home/vanessa/Documents/Work/NEUROSYNTH/nsyn525Matrix.Rda")
# save(data,file="/scratch/users/vsochat/DATA/BRAINMAP/nsyth5258mmRaw.Rda")
load("/scratch/users/vsochat/DATA/BRAINMAP/nsyth5258mmRaw.Rda")

# Create self organizing map
# Now sure about this command call, didn't test
# som = som(data, grid = somgrid(23, 22, "hexagonal"))

# Here use resize_img in Matlab to resample X.nii to 8mm space, and then create
# transformation matrix of 8mm to 2mm:
# flirt -in test/rX.nii -ref test/X.nii -omat standard8mmto2mm.mat -dof 6
# flirt -in rX.nii -ref X.nii -applyxfm -init standard8mmto2mm.mat -out testoutput.nii.gz

# Here we apply the above to register our brainMatrix images (in space of 8mm) back to 2mm (to be used to compare functional ICA to)
library('fslr')
setwd("/scratch/users/vsochat/DATA/BRAINMAP/dimensionality_reduction/som/som504")
brainmaps = list.files(pattern="^brainGrid*")
standard = list.files(pattern="X.nii")
matfile = list.files(pattern="*.mat")

# For each file, apply transformation to register back to 2mm space
for (z in brainmaps){
  outimg = paste(gsub(".nii","",z),"_2mm.nii",sep="")
  flirt(z, standard, omat=matfile, dof=6, outfile = outimg, retimg = FALSE, reorient = FALSE, intern = TRUE,opts=paste("-init", matfile,"-applyxfm"))    
}

# Now we have brainGrid_2mm.nii images in same space as MNI 152 2mm template to register ICA images to!