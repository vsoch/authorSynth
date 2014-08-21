# matchToSOM

# This script will calculate match scores for one authorBrain map
# to all images in SOM BrainGrid. The output for each is a
# single row tab separated text file of the format:
# uid [tab] SOM1 [tab] SOM2 [tab]

library(fslr)

args = commandArgs(TRUE)

# directory with SOM template images
somdir = args[1]
# pattern to match images
pattern = args[2]
# functional network path
mr = args[3] 
# path to author Brains folder
brainPath = args[4]
# Output file
outfile = args[5]
# Standard space template (for images)
standard = args[6]
# FUNC image folder
imgfunc = args[7]

# Extract unique ID from mr name
uuid = strsplit(mr,"_")[[1]][1]

cat(somdir,pattern,mr,uuid,outfile,standard,imgfunc,sep="\n")

# Get list of SOM images to match to
soMR = list.files(somdir,pattern=pattern)
# Here are labels for the matrix
labels = as.numeric(gsub("_2mm.nii","",gsub("som_","",soMR)))
ordering = sort(labels,index.return=TRUE)
ordering = ordering$ix

# Define distance functions
euc.dist = function(x1,x2) {sqrt(sum((x1 - x2) ^ 2))}
cos.dist = function(x1,x2) {crossprod(x1, x2)/sqrt(crossprod(x1) * crossprod(x2))}

# Put in correct order - very important - this is order of nodes in SOM list
labels = soMR[ordering]

# Create array to hold match scores for each
score_so = array(dim=length(ordering))  # As a % of SOM maps
score_func = array(dim=length(ordering)) # As a % of functional networks
score_cos =  array(dim=length(ordering)) # Cosine distance
score_euc =  array(dim=length(ordering)) # Euclidean distance

# read in mr (functional) image
mr = paste(brainPath,"/",mr,sep="")
funcimg = readNIfTI(mr)
standard = readNIfTI(standard)

# Save picture of functional network
outimg = paste(imgfunc,"/",uuid,".png",sep="")
png(filename=outimg,width=300,height=300)
orthographic(standard,funcimg,zlim=c(min(standard),max(standard)),zlim.y=c(0.01,max(funcimg)))
dev.off()

# Now read in with Rniftilib
library(Rniftilib)

func = nifti.image.read(mr,read_data=1)
func = as.vector(func[,,,1])

# We will create a binary and non binary image
# Threshold less than 0 to 0
# These zstat images are already thresholded at Z=2.3
# This is the FSL default
func[func < 0] = 0
funcbin = func
funcbin[funcbin !=0] = 1

for (i in 1:length(labels)){

  # These so images are in the same space as the original
  # neurosynth maps - # This gets the absolute value FDR corrected at threshold
  # 'pAgF_z_FDR_0.05'
  # the z score map corresponding to the map of the probability of activation given that a study is tagged with the feature, FDR corrected .05
  # Since functional networks are also z scores, and we are interested in relatively + activation, we
  # threshold at 0 for both
  l = labels[i]
  so = paste(somdir,"/",l,sep="")
  so = nifti.image.read(so,read_data=1)
  so = as.vector(so[,,,1])
    
  # We will create a binary and non binary
  sobin = so
  
  # Now binarize
  sobin[sobin!=0] = 1
  
  # Calculate overlap of so and authorBrain map as % of total authorBrain map voxels
  # The author maps are small, so these scores will be very high
  score_func[i] = sum(sobin * funcbin) / sum(funcbin)
  # and % of so map covered by authorBrain map
  score_so[i] = sum(sobin * funcbin) / sum(sobin)  
  # Cosine distance
  score_cos[i] =  cos.dist(so,func)
  # Euclidean distance
  score_euc[i] = euc.dist(so,func)
}
names(score_so) = labels
names(score_func) = labels
names(score_euc) = labels
names(score_cos) = labels
match = list(so=score_so,func=score_func,euc=score_euc,cos=score_cos)
save(match,file=outfile)