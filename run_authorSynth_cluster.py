#!/usr/bin/python

# This batch script will prepare and submit jobs for running on the cluster
import os

outdirectory = "/scratch/users/vsochat/DATA/BRAINMAP/authorSynth"
email = "vsochat@stanford.edu"

# Here is code to run authorSynth_cluster_pubmed.py ----------------------------------------
# This is if you want to look up authors in pubmed and
# crosslist with NeuroSynth database 
# Read in our list of authors
filey = open("data/highly_cited_2014_final.csv","r")
filey = filey.readlines()
header = filey.pop(0).strip("\n").split("\t")
pindex = header.index("Pubmed_Name")
uindex = header.index("uuids")

# We will keep lists of uuids and author names
uuids = []
authors = []
for f in filey:
  uuids.append(f.strip("\n").split("\t")[uindex])
  authors.append(f.strip("\n").split("\t")[pindex])

# Prepare and submit a job for each
for i in range(0,len(uuids)):
  filey = ".job/" + uuids[i] + ".job"
  filey = open(filey,"w")
  filey.writelines("#!/bin/bash\n")
  filey.writelines("#SBATCH --job-name=" + uuids[i] + "\n")
  filey.writelines("#SBATCH --output=.out/" + uuids[i] + ".out\n")
  filey.writelines("#SBATCH --error=.out/" + uuids[i] + ".err\n")
  filey.writelines("#SBATCH --time=2-00:00\n")
  filey.writelines("#SBATCH --mem=12000\n")
  # Usage : authorSynth_cluster.py uuid "author" email outdirectory
  filey.writelines("/home/vsochat/python-lapack-blas/bin/python /home/vsochat/SCRIPT/python/authorSynth/authorSynth_cluster.py " + uuids[i] + " \"" + authors[i] + "\" " + email + " " + outdirectory + "\n")
  filey.close()
  os.system("sbatch " + ".job/" + uuids[i] + ".job")


# Here is code to run authorSynth_cluster.py ----------------------------------------
# This is if you have a list of authors and pmid 
# and want to just produce brain images without pubmed
# Read in our list of authors
filey = open("data/authors.txt","r")
filey = filey.readlines()
header = filey.pop(0).strip("\n").split("\t")
pindex = header.index("Pubmed_Name")
uindex = header.index("uuids")

# We will keep lists of uuids and author names
uuids = []
authors = []
for f in filey:
  uuids.append(f.strip("\n").split("\t")[uindex])
  authors.append(f.strip("\n").split("\t")[pindex])

# Prepare and submit a job for each
for i in range(0,len(uuids)):
  filey = ".job/" + uuids[i] + ".job"
  filey = open(filey,"w")
  filey.writelines("#!/bin/bash\n")
  filey.writelines("#SBATCH --job-name=" + uuids[i] + "\n")
  filey.writelines("#SBATCH --output=.out/" + uuids[i] + ".out\n")
  filey.writelines("#SBATCH --error=.out/" + uuids[i] + ".err\n")
  filey.writelines("#SBATCH --time=2-00:00\n")
  filey.writelines("#SBATCH --mem=12000\n")
  # Usage : authorSynth_cluster.py uuid "author" email outdirectory
  filey.writelines("/home/vsochat/python-lapack-blas/bin/python /home/vsochat/SCRIPT/python/authorSynth/authorSynth_cluster.py " + uuids[i] + " \"" + authors[i] + "\" " + email + " " + outdirectory + " " + papers + "\n")
  filey.close()
  os.system("sbatch " + ".job/" + uuids[i] + ".job")


