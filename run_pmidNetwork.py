#!/usr/bin/python

# This script will use the authorSynth module to extract data to 
# create a network of papers, with similarity regarded as overlap 
# in authors between papers. It creates an instance of pmidNetwork.py
# For each id in the database

# import authorSynth module
import authorSynth as AS
import os

# Output directory
outdir = "/scratch/users/vsochat/DATA/BRAINMAP/authorSynth/pmidNetwork"

# Init Neurosynth database, either "525" or "3000" terms
db = AS.neurosynthInit("3000")

# Get all pmids in database
ids = AS.getIDs(db)
ids = ids.values()[0]
  
# Prepare and submit a job for each
for i in range(4800,len(ids)):
  filey = ".job/" + ids[i] + ".job"
  filey = open(filey,"w")
  filey.writelines("#!/bin/bash\n")
  filey.writelines("#SBATCH --job-name=" + ids[i] + "\n")
  filey.writelines("#SBATCH --output=.out/" + ids[i] + ".out\n")
  filey.writelines("#SBATCH --error=.out/" + ids[i] + ".err\n")
  filey.writelines("#SBATCH --time=2-00:00\n")
  filey.writelines("#SBATCH --mem=12000\n")
  # Usage : authorSynth_cluster.py uuid "author" email outdirectory
  filey.writelines("/home/vsochat/python-lapack-blas/bin/python /home/vsochat/SCRIPT/python/authorSynth/pmidNetwork.py " + ids[i] + " " +  outdir + "\n")
  filey.close()
  os.system("sbatch " + ".job/" + ids[i] + ".job")

