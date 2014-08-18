#!/usr/bin/python

# This is to run for a single author (on Sherlock cluster)
# Usage : authorSynth_cluster.py uuid "author" email outdirectory

# import authorSynth module
import authorSynth as AS
import sys

# Get arguments
uuids = sys.argv[1]
author = sys.argv[2]
email = sys.argv[3]
outdirectory = sys.argv[4]

# Init Neurosynth database, use "3000" terms
db = AS.neurosynthInit("3000")

# Now run authorSynth for each author, save files with uuid as name
for i in range(5,len(authors)):
  print "Starting on " + str(i) + ": " + authors[i]
  papers = AS.getArticles(authors[i],email)
  ma = AS.neurosynthMatch(db,papers,author,outdirectory,uuids[i])

