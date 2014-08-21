# This script will read in raw neurosynth 525 images, and create a 22x23 SOM
# that we can map authorBrain maps onto to visually and qualitatively assess
# the maps. Both sets of images are in MNI standard space, 91 x 109 x 91 / 2mm 

# Here is how to make the self organizing map
library('kohonen')
library("Rniftilib")

# Path to raw 525 neurosynth maps
mrpath = "/scratch/users/vsochat/DATA/BRAINMAP/nsynth525pFgA/4mm"
mrpath = "/home/vanessa/Documents/Work/NEUROSYNTH/nsynth525pFgA/8mm"
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
labels = gsub("/home/vanessa/Documents/Work/NEUROSYNTH/nsynth525pFgA/8mm/r","",mrs)
rownames(data) = mrs 

# Save raw data matrix
# save(data,file="/home/vanessa/Documents/Work/NEUROSYNTH/nsyn525Matrix.Rda")
save(data,file="/home/vanessa/Documents/Work/NEUROSYNTH/nsyn5258mmRaw_pFgA.Rda")
# save(data,file="/scratch/users/vsochat/DATA/BRAINMAP/nsyth5258mmRaw.Rda")
load("/scratch/users/vsochat/DATA/BRAINMAP/nsyth5258mmRaw.Rda")

# Create self organizing map
# Now sure about this command call, didn't test
som = som(data, grid = somgrid(23, 22, "hexagonal"))

# Here are the class assignments for each row in matrix
som$unit.classif

# Create a vector (with indices corresponding to som$grid$pts) with labels of assigned terms
somLabels = c()
for (t in 1:length(som$unit.classif)){
  tmp = paste(labels[which(som$unit.classif==t)],collapse="\n")
  somLabels = c(somLabels,tmp)
}

# Here are the corresponding coordinates of the som
som$grid$pts

# Let's quickly plot!
plot(som$grid$pts,main="NeuroSynth Behavioral Brain Maps Similarity",col="#CCCCCC",xlab="Nodes",ylab="Nodes",pch=19,cex=1)
text(som$grid$pts,somLabels,cex=.4)

# Put together into list, and save to file
brainGrid = list(som=som,nodeLabels = somLabels,terms=labels)
save(brainGrid,file="som_pFgA.Rda")

# Here are the best matching unit images, the ones to turn into images for som
for (c in 1:nrow(som$codes)){
  vector = som$codes[c,]
  niinew = array(vector, dim=(dim(nii)))  
  template = nii
  template[,,] = niinew
  nifti.set.filenames(template,paste("/home/vanessa/Documents/Work/NEUROSYNTH/nsynth525pFgA/som8mm504/som_",c,".nii",sep=""))
  nifti.image.write(template)  
}
# Here use resize_img in Matlab to resample X.nii to 8mm space, and then create
# transformation matrix of 8mm to 2mm:
# flirt -in test/rX.nii -ref test/X.nii -omat standard8mmto2mm.mat -dof 6
# flirt -in rX.nii -ref X.nii -applyxfm -init standard8mmto2mm.mat -out testoutput.nii.gz
transform = "/home/vanessa/Documents/Work/NEUROSYNTH/nsynth525pFgA/transform/standard8mmto2mm.mat"
standard = "/home/vanessa/Documents/Work/NEUROSYNTH/nsynth525pFgA/transform/X.nii"

# Here we apply the above to register our brainMatrix images (in space of 8mm) back to 2mm (to be used to compare functional ICA to)
library('fslr')
setwd("/home/vanessa/Documents/Work/NEUROSYNTH/nsynth525pFgA/som8mm504")
brainmaps = list.files(pattern="^som*")

# For each file, apply transformation to register back to 2mm space
for (z in brainmaps){
  outimg = paste(gsub(".nii","",z),"_2mm.nii",sep="")
  flirt(z, standard, omat=transform, dof=6, outfile = outimg, retimg = FALSE, reorient = FALSE, intern = TRUE,opts=paste("-init", transform,"-applyxfm"))    
}

# Now we have brainGrid_2mm.nii images in same space as MNI 152 2mm template to register ICA images to!