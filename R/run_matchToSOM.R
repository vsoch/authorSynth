# bg_match

# This script will read in image paths from a text file,
# and submit to bg_match to calculate match scores.  
# on the Sherlock cluster.  The output for each is a
# single row tab separated text file of the format:
# uid [tab] SOM1 [tab] SOM2 [tab]

# This script will map a neuro2gene result object to our self organizing map
library("fslr")
options(fsl.path="/scratch/PI/dpwall/TOOLS/fsl/fsl")
setwd("/home/vsochat/SCRIPT/python/authorSynth")

# Here are the authorBrainMap images
authorBrains = "/scratch/users/vsochat/DATA/BRAINMAP/authorSynth"
setwd(authorBrains)
brains = list.files(pattern="*_pFgA_z_FDR_0.05.nii.gz")

# Here is path to where SOM images are
somdir = "/scratch/users/vsochat/DATA/BRAINMAP/nsynth525pFgA/som8mm504"
# This is the pattern for the image names
pattern = "*2mm.nii"
# Here is the output folder for match text files
outfolder = "/scratch/users/vsochat/DATA/BRAINMAP/nsynth525pFgA/scores"
# Here is our standard space image, for printing images of the networks
standard = file.path( getOption("fsl.path"), "data", "standard", "MNI152_T1_2mm_brain.nii.gz")
# Directory for png images
imgfunc = "/scratch/users/vsochat/DATA/BRAINMAP/nsynth525pFgA/img"

for (i in 1:length(brains)){
  mr = as.character(brains[i])  
  name = gsub(".nii.gz","",mr)
  outfile = paste(outfolder,"/",name,"_score.Rda",sep="")
  jobby = paste(name,".job",sep="")
  sink(paste(".job/",jobby,sep=""))
  cat("#!/bin/bash\n")
  cat("#SBATCH --job-name=",jobby,"\n",sep="")  
  cat("#SBATCH --output=.out/",jobby,".out\n",sep="")  
  cat("#SBATCH --error=.out/",jobby,".err\n",sep="")  
  cat("#SBATCH --time=2-00:00\n",sep="")
  cat("#SBATCH --mem=12000\n",sep="")
  cat("Rscript /home/vsochat/SCRIPT/python/authorSynth/R/matchToSOM.R",somdir,pattern,mr,authorBrains,outfile,standard,imgfunc,"\n")
  sink()
  
  # SUBMIT R SCRIPT TO RUN ON CLUSTER  
  system(paste("sbatch",paste(".job/",jobby,sep="")))
  
}

# When finished, we can use parseMatchScores.m to create matrix of all scores.
