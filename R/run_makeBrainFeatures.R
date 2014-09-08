# run_makeBrainFeatures.R

# This script will create brain features for a subset of images on the Sherlock
# cluster, since running this serially takes forever.

datadir = "/scratch/users/vsochat/DATA/BRAINMAP/authorSynth/brainmapsNeuroSynth"
authors = list.files(datadir,pattern="pAgF_z_FDR_0.05.nii",full.names=TRUE)
files = list.files(datadir,pattern="pAgF_z_FDR_0.05.nii")

# Set the output directory
outfolder = "/scratch/users/vsochat/DATA/BRAINMAP/authorSynth/regionalFeaturespAgF"

# Will only run job if output file does not exist
for (i in 0:length(files)){
  mr = as.character(files[i])  
  name = gsub("_pAgF_z_FDR_0.05.nii.gz","",mr)
  outfile = paste(outfolder,"/",name,"_features.Rda",sep="")
  jobby = paste("RF_",name,".job",sep="")
  if (!file.exists(outfile)) {
    sink(paste(".job/",jobby,sep=""))
    cat("#!/bin/bash\n")
    cat("#SBATCH --job-name=",jobby,"\n",sep="")  
    cat("#SBATCH --output=.out/",jobby,".out\n",sep="")  
    cat("#SBATCH --error=.out/",jobby,".err\n",sep="")  
    cat("#SBATCH --time=1-00:00\n",sep="")
    cat("#SBATCH --mem=12000\n",sep="")
    cat("Rscript /home/vsochat/SCRIPT/python/authorSynth/R/makeBrainFeatures.R",authors[i],name,outfile,"\n")
    sink()
  
    # SUBMIT R SCRIPT TO RUN ON CLUSTER  
    system(paste("sbatch",paste(".job/",jobby,sep="")))
  }
}
