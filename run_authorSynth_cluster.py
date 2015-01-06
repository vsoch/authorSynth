#!/usr/bin/python

# This batch script will prepare and submit jobs for running on a SLURM cluster
# You must of course edit the job to match your python installation, cluster details, script location, etc.
# It submits instances of authorSynth_cluster.py

import os
import authorSynth as AS

outdirectory = "/scratch/users/vsochat/DATA/BRAINMAP/authorSynth/brainmapsHighlyCited"
email = "vsochat@stanford.edu"
dbsize = "3000"  # either 525 or 3000

# Get list of authors
authors = AS.getAuthorDatabase()

# We will keep lists of uuids and author names
uuids = authors["uuids"]
ids = authors["ids"]
numpapers = authors["numpapers"]
authors = authors["authors"]

# Prepare and submit a job for each
for i in range(1,len(uuids)):
  fname = outdirectory + "/" + uuids[i] + "_pAgF_given_pF=0.50.nii.gz"
  if pi[i] == "1":
    if not os.path.isfile(fname):
      filey = ".job/" + uuids[i] + ".job"
      filey = open(filey,"w")
      filey.writelines("#!/bin/bash\n")
      filey.writelines("#SBATCH --job-name=" + uuids[i] + "\n")
      filey.writelines("#SBATCH --output=.out/" + uuids[i] + ".out\n")
      filey.writelines("#SBATCH --error=.out/" + uuids[i] + ".err\n")
      filey.writelines("#SBATCH --time=1-00:00\n")
      filey.writelines("#SBATCH --mem=12000\n")
      # Usage : authorSynth_cluster.py uuid "author" email outdirectory
      filey.writelines("/home/vsochat/python-lapack-blas/bin/python /home/vsochat/SCRIPT/python/authorSynth/authorSynth_cluster.py " + uuids[i] + " \"" + authors[i] + "\" " + outdirectory + " " + ids[i] + "\n")
      filey.close()
      os.system("sbatch " + ".job/" + uuids[i] + ".job")
