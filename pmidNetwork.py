# This script will use the authorSynth module to extract data to 
# create a network of papers, with similarity regarded as overlap 
# in authors between papers.  This script is run by run_pmidNetwork.py
# on the Sherlock cluster

import sys

# Get arguments
iid = sys.argv[1]
outdir = sys.argv[2]

# import authorSynth module
import authorSynth as AS
import numpy as np

# Init Neurosynth database, either "525" or "3000" terms
db = AS.neurosynthInit("3000")

# Get all pmids in database
ids = AS.getIDs(db)
ids = ids.values()[0]

# We will keep a square matrix of pmid x pmid, with the tanimoto score
# of overlapping articles between the two papers
overlap = np.zeros((len(ids)))
author_i = set(AS.getAuthor(db,iid))
print "Calculating overlap for " + str(iid) + "."
for j in range(0,len(ids)):
    _j = ids[j]
    author_j = set(AS.getAuthor(db,_j))
    overlap[j] = len(author_i & author_j) / len(author_i | author_j)

# Done! Save matrix to file for analysis in R
authornum = ids.index(iid)
np.savetxt(outdir + "/" + str(authornum) + "_" + iid + ".txt", overlap,fmt='%-7.5f')
