#!/usr/bin/python

# This is to run for a single author (on Sherlock cluster)
# Usage : authorSynth_cluster.py uuid "author" email outdirectory
# This will look up papers on pubmed, and cross list with
# neurosynth database.  To simply query database for a list
# of pre-generated pmid or doi, use "authorSynth_cluster.py"

# import authorSynth module
import authorSynth as AS
import sys

# Get arguments
uuid = sys.argv[1]
author = sys.argv[2]
email = sys.argv[3]
outdirectory = sys.argv[4]
dbsize = str(sys.argv[5])

# Init Neurosynth database, use "3000" terms
db = AS.neurosynthInit(dbsize)

print "Processing author " + author
papers = AS.getArticles(author,email)

# papers[0] is dictionary of doi (525)
# papers[1] is dictionary of pmid (3000)
if dbsize == "3000":
  papers = papers[0].values()
  ma = AS.neurosynthMatch(db,papers,author,outdirectory,uuid)
elif dbsize == "525":
  papers = papers[1].values()
  ma = AS.neurosynthMatch(db,papers,author,outdirectory,uuid)
else:
  print "ERROR: Invalid database size! Must be 525 or 3000."

