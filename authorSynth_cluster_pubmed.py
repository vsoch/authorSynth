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

# Init Neurosynth database, use "3000" terms
db = AS.neurosynthInit("3000")

print "Processing author " + author
papers = AS.getArticles(author,email)
ma = AS.neurosynthMatch(db,papers,author,outdirectory,uuid)

