# run_match_to_SOM

# This script will read in image paths from a directory,
# and submit to matchToSOM.R to calculate match scores.  
# on the Sherlock cluster.  The output for each is a
# .Rda file with euclidian distance, cosine distance,
# % overlap of network, and % overlap to SOM map.

# This script will map a neuro2gene result object to our self organizing map
library("fslr")
options(fsl.path="/scratch/PI/dpwall/TOOLS/fsl/fsl")
setwd("/home/vsochat/SCRIPT/python/authorSynth")

# HERE IS FOR  HIGHLY CITED AUTHORS (154) ---------------------------------------------
# Here are the authorBrainMap images
authorBrains = "/scratch/users/vsochat/DATA/BRAINMAP/authorSynth/brainmapsNeuroSynth"
setwd(authorBrains)
brains = list.files(pattern="*_pAgF_z_FDR_0.05.nii.gz")

# Here is path to where SOM images are

# This is for pFgA images
somdir = "/scratch/users/vsochat/DATA/BRAINMAP/nsynth525pFgA/som8mm504"

# This is for pAgF images
somdir = "/scratch/users/vsochat/DATA/BRAINMAP/dimensionality_reduction/som_pAgF/som504"

# This is the pattern for the image names
pattern = "*2mm.nii.gz"

# Here is the output folder for match text files
outfolder = "/scratch/users/vsochat/DATA/BRAINMAP/nsynth525pAgF/scores"

# Here is our standard space image, for printing images of the networks
standard = file.path( getOption("fsl.path"), "data", "standard", "MNI152_T1_2mm_brain.nii.gz")
# Directory for png images
imgfunc = "/scratch/users/vsochat/DATA/BRAINMAP/nsynth525pAgF/img"

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


# HERE IS FOR NEUROSYNTH PIs ----------------------------------------------------------
# Here are the authorBrainMap images
authorBrains = "/scratch/users/vsochat/DATA/BRAINMAP/authorSynth/brainmapsNeuroSynth"
setwd(authorBrains)
brains = list.files(pattern="*_pFgA_z_FDR_0.05.nii.gz")

# Filter brains down to PIs - we don't need images for non PIs
authors = read.csv("/home/vsochat/SCRIPT/python/authorSynth/data/authors.txt",sep="\t",head=TRUE)
idx = which(gsub("_pFgA_z_FDR_0.05.nii.gz","",brains) %in% authors$UUIDS[which(authors$PI == 1)])
brains = brains[idx]

# Here is path to where SOM images are
somdir = "/scratch/users/vsochat/DATA/BRAINMAP/nsynth525pFgA/som8mm504"
# This is the pattern for the image names
pattern = "*2mm.nii"
# Here is the output folder for match text files
outfolder = "/scratch/users/vsochat/DATA/BRAINMAP/nsynth525pFgA/scoresNeuroSynth"
# Here is our standard space image, for printing images of the networks
standard = file.path( getOption("fsl.path"), "data", "standard", "MNI152_T1_2mm_brain.nii.gz")
# Directory for png images
imgfunc = "/scratch/users/vsochat/DATA/BRAINMAP/nsynth525pFgA/imgNeuroSynth"

for (i in 1:length(brains)){
  mr = as.character(brains[i])  
  name = gsub(".nii.gz","",mr)
  outfile = paste(outfolder,"/",name,"_score.Rda",sep="")
  if (!file.exists(outfile)){
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
}
